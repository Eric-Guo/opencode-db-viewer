class ApplicationController < ActionController::Base
  include Pundit::Authorization

  include SetLocale

  before_action :authenticate_user!
  before_action :set_page_layout_data, if: -> { request.get? && request.format.html? }
  before_action :prepare_meta_tags, if: -> { request.get? && request.format.html? }

  protected

  def set_page_layout_data
    @_wrapper_class = %w[wrapper d-flex flex-column min-vh-100 bg-body-tertiary]
    @_container_class = "container-lg"
    @viewer_layout = %w[projects sessions background_jobs schedules].include?(controller_name)
    @skip_title = true if @viewer_layout
    @_container_class = "container-fluid" if @viewer_layout
    @_wrapper_class << "oc-viewer-wrapper" if @viewer_layout
    if @viewer_layout && request.format.html?
      @nav_projects = policy_scope(Project).order(time_updated: :desc).limit(12)
      @nav_sessions = if params[:project_id].present? || (controller_name == "projects" && params[:id].present?)
        project = policy_scope(Project).find_by(id: params[:project_id] || params[:id])
        policy_scope(Session).where(project_id: project&.worktree_project_ids).order(time_updated: :desc).limit(12)
      else
        Session.none
      end
    end
    @_sidebar_name = if @viewer_layout
      "application"
    elsif current_user&.admin?
      "admin"
    else
      "application"
    end
  end

  def add_to_breadcrumbs(text, link = nil)
    @_breadcrumbs ||= []
    @_breadcrumbs.push(
      text: text,
      link: link
    )
  end

  private

  def prepare_meta_tags
    set_meta_tags title: t(".title")
  end

  def modern_browser?
    [
      browser.bot?, # support rails test
      browser.chrome?(">= 86"),
      browser.safari?(">= 12"),
      browser.firefox?(">= 86"),
      browser.edge?(">= 86"),
      browser.opera?(">= 75")
    ].any?
  end

  def check_brower
    unless modern_browser?
      redirect_to "/nosupport-browser.html"
    end
  end
end
