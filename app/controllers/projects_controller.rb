class ProjectsController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized, only: %i[index show]
  after_action :verify_policy_scoped, only: :index
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def index
    authorize Project
    add_to_breadcrumbs t("projects.index.title")
    @pagy, @projects = pagy(policy_scope(Project).order(time_updated: :desc), items: current_user.preferred_page_length)
    project_ids = @projects.map(&:id)
    @session_counts = Session.where(project_id: project_ids).group(:project_id).count
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
    @total_tokens = sessions_scope.sum(
      Arel.sql("tokens_input + tokens_output + tokens_reasoning + tokens_cache_read + tokens_cache_write")
    ).to_i
    @worktrees = @project.worktrees.order(:directory)
    @workspaces = @project.workspaces.order(last_used_at: :desc)
    @permissions = @project.permissions.order(:action, :resource)
    @pagy, @sessions = pagy(sessions_scope.order(time_updated: :desc), items: current_user.preferred_page_length)
    session_ids = @sessions.map(&:id)
    @session_message_counts = SessionMessage.where(session_id: session_ids).group(:session_id).count
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
