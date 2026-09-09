class ProjectsController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized, only: %i[index show]
  after_action :verify_policy_scoped, only: :index
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def index
    authorize Project
    @skip_title = true
    add_to_breadcrumbs t("projects.index.title")
    projects = policy_scope(Project)
    @query = params[:q].to_s.strip
    if @query.present?
      projects = projects.where("name LIKE :query OR worktree LIKE :query OR id LIKE :query", query: "%#{Project.sanitize_sql_like(@query)}%")
    end
    @pagy, @projects = pagy(projects.order(time_updated: :desc), items: current_user.preferred_page_length)
    project_ids = @projects.map(&:id)
    @session_counts = Session.where(project_id: project_ids).group(:project_id).count
    @subagent_counts = Session.where(project_id: project_ids).where.not(parent_id: nil).group(:project_id).count
    @worktree_counts = Worktree.where(project_id: project_ids).group(:project_id).count
  end

  def show
    @project = policy_scope(Project).find(params[:id])
    authorize @project
    add_to_breadcrumbs t("projects.index.title"), projects_path
    add_to_breadcrumbs @project.name.presence || @project.id
    @duplicate_projects =
      if @project.worktree.present?
        Project.where(worktree: @project.worktree).where.not(id: @project.id).order(:id)
      else
        Project.none
      end
    sessions_scope = Session.where(project_id: @project.worktree_project_ids)
    @total_sessions, @total_additions, @total_deletions = sessions_scope.pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("COALESCE(SUM(summary_additions), 0)"),
      Arel.sql("COALESCE(SUM(summary_deletions), 0)")
    ).map(&:to_i)
    @total_cost = sessions_scope.sum(:cost).to_f
    @subagent_count = sessions_scope.where.not(parent_id: nil).count
    @total_tokens = sessions_scope.sum(
      Arel.sql("tokens_input + tokens_output + tokens_reasoning + tokens_cache_read + tokens_cache_write")
    ).to_i
    @worktrees = @project.worktrees.order(:directory)
    @workspaces = @project.workspaces.order(last_used_at: :desc)
    @permissions = @project.permissions.order(:action, :resource)
    @query = params[:q].to_s.strip
    @session_kind = %w[all primary subagents].include?(params[:kind]) ? params[:kind] : "all"
    @session_state = %w[all unarchived archived].include?(params[:state]) ? params[:state] : "all"
    sessions_scope = sessions_scope.where(parent_id: nil) if @session_kind == "primary"
    sessions_scope = sessions_scope.where.not(parent_id: nil) if @session_kind == "subagents"
    sessions_scope = sessions_scope.where(time_archived: nil) if @session_state == "unarchived"
    sessions_scope = sessions_scope.where.not(time_archived: nil) if @session_state == "archived"
    if @query.present?
      sessions_scope = sessions_scope.where("title LIKE :query OR slug LIKE :query OR id LIKE :query OR agent LIKE :query", query: "%#{Session.sanitize_sql_like(@query)}%")
    end
    @pagy, @sessions = pagy(sessions_scope.includes(:parent).order(time_updated: :desc), items: current_user.preferred_page_length)
    session_ids = @sessions.map(&:id)
    @session_message_counts = SessionMessage.where(session_id: session_ids).group(:session_id).count
    @retained_message_counts = SessionMessageRetained.where(session_id: session_ids).group(:session_id).count
    @child_counts = Session.where(parent_id: session_ids).group(:parent_id).count
    @legacy_message_counts = Message.where(session_id: session_ids).group(:session_id).count
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"),
       link: root_path}
    ]
  end
end
