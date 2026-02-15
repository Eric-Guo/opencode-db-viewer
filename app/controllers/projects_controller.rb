class ProjectsController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized, only: %i[index show]
  after_action :verify_policy_scoped, only: :index
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def index
    authorize Project
    add_to_breadcrumbs t("projects.index.title")
    @pagy, @projects = pagy(policy_scope(Project).order(time_updated: :desc), items: current_user.preferred_page_length)
  end

  def show
    @project = policy_scope(Project).find(params[:id])
    authorize @project
    add_to_breadcrumbs t("projects.index.title"), projects_path
    add_to_breadcrumbs @project.name.presence || @project.id
    sessions_scope = @project.sessions
    @total_sessions, @total_additions, @total_deletions = sessions_scope.pick(
      Arel.sql("COUNT(*)"),
      Arel.sql("COALESCE(SUM(summary_additions), 0)"),
      Arel.sql("COALESCE(SUM(summary_deletions), 0)")
    ).map(&:to_i)
    @pagy, @sessions = pagy(sessions_scope.order(time_updated: :desc), items: current_user.preferred_page_length)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"),
       link: root_path}
    ]
  end
end
