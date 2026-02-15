class ProjectsController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized, only: :index
  after_action :verify_policy_scoped, only: :index
  before_action :set_breadcrumbs, if: -> { request.format.html? }

  def index
    authorize Project
    add_to_breadcrumbs t("projects.index.title")
    @pagy, @projects = pagy(policy_scope(Project).order(time_updated: :desc), items: current_user.preferred_page_length)
  end

  private

  def set_breadcrumbs
    @_breadcrumbs = [
      {text: t("layouts.sidebars.application.header"),
       link: root_path}
    ]
  end
end
