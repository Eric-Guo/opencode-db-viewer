class SchedulesController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized

  def index
    authorize Schedule
    @query = params[:q].to_s.strip
    @status = params[:status].to_s
    scope = Schedule.all
    scope = scope.where(status: @status) if %w[active paused done].include?(@status)
    if @query.present?
      scope = scope.where("name LIKE :q OR id LIKE :q OR session_id LIKE :q", q: "%#{Schedule.sanitize_sql_like(@query)}%")
    end
    @pagy, @schedules = pagy(scope.order(time_created: :desc, id: :desc), items: current_user.preferred_page_length)
    @related_sessions = policy_scope(Session).where(id: @schedules.map(&:session_id)).index_by(&:id)
  end
end
