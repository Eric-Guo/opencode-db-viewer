require "test_helper"

class CurrentSchemaTest < ActiveSupport::TestCase
  test "parts are ordered before inline content and feed real tools" do
    message = session_messages(:split_assistant)
    assert_equal %w[reasoning text tool text], message.content.map { |part| part["type"] }
    assert_equal "Inline tail after the split parts.", message.content.last["text"]
    assert_equal "bash", message.tools.fetch(2).name
    assert_equal "Parts-only response.", session_messages(:parts_only).content.first["text"]
    assert_equal "Current schema assistant response", session_messages(:session_message_v2_assistant).content.second["text"]
  end

  test "job identity is the notification and repeated job IDs remain distinct" do
    assert_equal "notification-running", open_code_jobs(:running).id
    assert_equal open_code_jobs(:running).job_id, open_code_jobs(:cancelled).job_id
    assert_equal 4, OpenCodeJob.where(session_id: "session-current-schema").count
    assert_equal "shell", open_code_jobs(:running).recovery_data["kind"]
  end

  test "blob hash column is distinct from Ruby object hash" do
    assert_equal "fixture-image", stored_blobs(:image).content_hash
    assert_equal stored_blobs(:image), blob_refs(:user).stored_blob
  end

  test "execution duration requires a completion after the recorded start" do
    session = sessions(:current_schema)
    assert_equal 50, session.execution_duration
    assert_equal Time.zone.at(1_700_000_010), session.time_busy_at
    session.time_idle = session.time_busy - 1
    assert_nil session.execution_duration
    session.time_busy = nil
    assert_nil session.execution_duration
  end

  test "schedule retains conditions state and recurrence" do
    schedule = schedules(:active)
    assert_equal "every 1 hour", schedule.recurrence
    assert_equal "until", schedule.check_data["mode"]
    assert_equal "pending", schedule.state_data["previous"]
  end
end
