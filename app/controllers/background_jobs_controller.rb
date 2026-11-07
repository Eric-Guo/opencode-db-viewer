class BackgroundJobsController < ApplicationController
  include Pagy::Backend

  after_action :verify_authorized

  def index
    authorize OpenCodeJob
    @query = params[:q].to_s.strip
    @status = params[:status].to_s
    @kind = params[:kind].to_s
    scope = OpenCodeJob.all
    scope = scope.where(status: @status) if %w[running completed error cancelled].include?(@status)
    scope = scope.where(kind: @kind) if %w[shell subagent image].include?(@kind)
    if @query.present?
      scope = scope.where("title LIKE :q OR id LIKE :q OR session_id LIKE :q", q: "%#{OpenCodeJob.sanitize_sql_like(@query)}%")
    end
    @pagy, @jobs = pagy(scope.order(time_created: :desc, notification_id: :desc), items: current_user.preferred_page_length)
    @related_sessions = policy_scope(Session).where(id: @jobs.flat_map { |job| [job.session_id, job.child_session_id] }).index_by(&:id)
  end
end
