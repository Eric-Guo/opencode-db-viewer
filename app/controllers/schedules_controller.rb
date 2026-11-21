class SchedulesController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized

  def index
    authorize Automation
    @query = params[:q].to_s.strip
    @status = params[:status].to_s
    scope = Automation.all
    scope = scope.where(status: @status) if %w[active paused done].include?(@status)
    if @query.present?
      scope = scope.where("name LIKE :q OR id LIKE :q OR session_id LIKE :q", q: "%#{Automation.sanitize_sql_like(@query)}%")
    end
    @pagy, @automations = pagy(scope.order(time_created: :desc, id: :desc), items: current_user.preferred_page_length)
    @related_sessions = policy_scope(Session).where(id: @automations.map(&:session_id)).index_by(&:id)
  end
end
