require "digest"
require "open3"

namespace :projects do
  desc "Delete projects with no sessions, no worktrees and no other dependent records"
  task clean: :environment do
    scope = Project
      .where.not(id: Session.select(:project_id))
      .where.not(id: LegacySession.select(:project_id))
      .where.not(id: Worktree.select(:project_id))
      .where.not(id: Permission.select(:project_id))
      .where.not(id: ProjectDirectory.select(:project_id))

    total = scope.count
    if total.zero?
      puts "No empty projects found."
      next
    end

    puts "Deleting #{total} empty project(s):"
    scope.find_each do |project|
      puts "  #{project.id} (#{project.name.presence || project.worktree})"
      project.destroy!
    end
    puts "Done."
  end

  desc "Move all sessions (and legacy sessions) from one project to another, e.g. when the old " \
    "project's worktree was removed. Usage: bin/rails 'projects:move_sessions[old_project_id,target_project_id]' " \
    "Use DRY_RUN=1 to preview."
  task :move_sessions, [:old_project_id, :target_project_id] => :environment do |_t, args|
    dry_run = ENV["DRY_RUN"] == "1"
    abort("Usage: bin/rails 'projects:move_sessions[old_project_id,target_project_id]'") if args[:old_project_id].blank? || args[:target_project_id].blank?
    abort("old_project_id and target_project_id must differ.") if args[:old_project_id] == args[:target_project_id]

    old_project = Project.find_by(id: args[:old_project_id])
    target_project = Project.find_by(id: args[:target_project_id])
    abort("Old project not found: #{args[:old_project_id]}") unless old_project
    abort("Target project not found: #{args[:target_project_id]}") unless target_project

    puts "Move sessions: #{old_project.id} (#{old_project.name.presence || old_project.worktree}) " \
      "-> #{target_project.id} (#{target_project.name.presence || target_project.worktree})"

    now_ms = (Time.current.to_f * 1000).to_i
    [[Session, "sessions"], [LegacySession, "legacy sessions"]].each do |model, label|
      count = model.where(project_id: old_project.id).count
      puts "  #{label}: move #{count}"
      model.where(project_id: old_project.id).update_all(project_id: target_project.id) unless dry_run || count.zero?
    end
    target_project.update!(time_updated: now_ms) unless dry_run

    puts dry_run ? "Dry run, nothing changed." : "Done."
  end

  desc "Move sessions (and legacy sessions) from the global project into per-directory " \
    "projects, creating projects when missing. Use DRY_RUN=1 to preview."
  task move_sessions_from_global: :environment do
    dry_run = ENV["DRY_RUN"] == "1"
    global = Project.find_by(id: "global")
    abort("No global project found.") unless global

    now_ms = (Time.current.to_f * 1000).to_i

    # Mirror opencode's Project.resolve: a git directory resolves to its repository
    # root (worktree), identified by the first root commit SHA. Directories outside
    # any repository get a stable SHA1 of their path instead.
    resolve_directory = lambda do |directory|
      canonical = directory
      vcs = nil
      id = nil
      if File.directory?(directory)
        toplevel, _, status = Open3.capture3("git", "-C", directory, "rev-parse", "--show-toplevel")
        if status.success? && toplevel.present?
          canonical = toplevel.strip
          vcs = "git"
          roots, = Open3.capture3("git", "-C", directory, "log", "--max-parents=0", "--format=%H")
          id = roots.lines.first&.strip.presence
        end
      end
      id ||= Digest::SHA1.hexdigest(directory)
      [id, canonical, vcs]
    end

    created_by_canonical = {}
    find_or_create = lambda do |directory|
      id, canonical, vcs = resolve_directory.call(directory)
      project = created_by_canonical[canonical] || Project.find_by(worktree: canonical) || Project.find_by(id: id)
      if project.nil?
        project = Project.new(
          id: id,
          worktree: canonical,
          vcs: vcs,
          name: File.basename(canonical),
          sandboxes: "[]",
          time_created: now_ms,
          time_updated: now_ms
        )
        puts "  create project #{project.id} (name: #{project.name}, worktree: #{project.worktree})"
        project.save! unless dry_run
        created_by_canonical[canonical] = project
      else
        puts "  reuse project #{project.id} (#{project.name.presence || project.worktree})"
        project.update!(time_updated: now_ms) unless dry_run
      end
      project
    end

    [[Session, "sessions"], [LegacySession, "legacy sessions"]].each do |model, label|
      counts = model.where(project_id: global.id).group(:directory).count
      puts "#{label}: #{counts.values.sum} in global across #{counts.size} directorie(s)"
      counts.each do |directory, count|
        project = find_or_create.call(directory)
        puts "    #{directory}: move #{count} -> project #{project.id}"
        model.where(project_id: global.id, directory: directory).update_all(project_id: project.id) unless dry_run
      end
    end

    puts dry_run ? "Dry run, nothing changed." : "Done."
  end
end
