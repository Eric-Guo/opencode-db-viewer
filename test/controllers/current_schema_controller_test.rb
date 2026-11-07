require "test_helper"

class CurrentSchemaControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup { sign_in users(:user_fangzixue) }

  test "session shows split content metadata and contextual work" do
    get project_session_path("project-current-schema", "session-current-schema")
    assert_response :success
    assert_select ".oc-markdown", text: /Schema supported/
    assert_select ".oc-tool strong", text: "bash"
    assert_select "#inspector-jobs .oc-work-item", count: 4
    assert_select "#inspector-schedules .oc-work-item", count: 2
    assert_select "img[alt='schema.png']"
    assert_select "img[alt='queued.png']"
    assert_includes response.body, "fixture-image"
    assert_includes response.body, "Media unavailable" if I18n.locale == :en
    assert_includes response.body, "call-split"
    assert_operator response.body.index("Schema supported"), :<, response.body.index("Inline tail")
  end

  test "media is served only through a matching session and message reference" do
    get project_session_medium_path("project-current-schema", "session-current-schema", "fixture-image", message_id: "msg-split-user", preview: 1)
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_includes response.headers["Content-Disposition"], "inline"
    assert_includes response.headers["Content-Disposition"], "schema.png"
    assert response.body.start_with?("\x89PNG".b)

    get project_session_medium_path("project-current-schema", "session-current-schema", "fixture-image", message_id: "not-owned")
    assert_response :not_found
    get project_session_medium_path("project-session-v2", "session-v2-fixture", "fixture-image", message_id: "msg-split-user")
    assert_response :not_found
  end

  test "media preserves tool and inbox filenames and requires login" do
    {"msg-split-assistant" => "result.png", "inbox-schema" => "queued.png"}.each do |message, name|
      get project_session_medium_path("project-current-schema", "session-current-schema", "fixture-image", message_id: message)
      assert_response :success
      assert_includes response.headers["Content-Disposition"], name
      assert_includes response.headers["Content-Disposition"], "attachment"
    end
    sign_out :user
    get project_session_medium_path("project-current-schema", "session-current-schema", "fixture-image", message_id: "msg-split-user")
    assert_redirected_to new_user_session_path
  end

  test "child sessions show related jobs and link to the owning session" do
    open_code_jobs(:completed).update!(child_session_id: "session-subagent-fixture")
    get project_session_path("project-session-v2", "session-subagent-fixture")
    assert_response :success
    assert_select "#inspector-jobs .oc-work-item", count: 1
    assert_select "#inspector-jobs a[href=?]", project_session_path("project-current-schema", "session-current-schema"), text: "Schema display review"
  end

  test "non-raster media always downloads and missing references return not found" do
    stored_blobs(:image).update!(mime: "image/svg+xml")
    get project_session_medium_path("project-current-schema", "session-current-schema", "fixture-image", message_id: "msg-split-user", preview: 1)
    assert_response :success
    assert_includes response.headers["Content-Disposition"], "attachment"

    get project_session_medium_path("project-current-schema", "session-current-schema", "missing", message_id: "msg-split-user")
    assert_response :not_found
  end

  test "user inline attachments download through the existing message route" do
    get project_session_message_path("project-current-schema", "session-current-schema", "msg-split-user", file: 1)
    assert_response :success
    assert_equal "inline", response.body
    assert_includes response.headers["Content-Disposition"], "inline.txt"
  end

  test "global work lists filter recorded statuses and include sessionless schedules" do
    get background_jobs_path(status: "running", kind: "shell", q: "repeated-job")
    assert_response :success
    assert_select ".oc-work-item", count: 1
    assert_includes response.body, "notification-running"
    get schedules_path(status: "done")
    assert_response :success
    assert_select ".oc-work-item", count: 1
    assert_includes response.body, "Schema done"
    get background_jobs_path(locale: "zh-CN")
    assert_response :success
    refute_includes response.body, "translation_missing"
    get schedules_path(locale: "zh-CN")
    assert_response :success
    refute_includes response.body, "translation_missing"
    get background_jobs_path(q: "no-matching-job")
    assert_select ".oc-work-item", count: 0
    sign_out :user
    get schedules_path
    assert_redirected_to new_user_session_path
  end

  test "deletion handles new parts refs schedules and jobs without touching shared blobs" do
    assert_difference -> { SessionPart.count }, -4 do
      assert_difference -> { OpenCodeJob.count }, -4 do
        assert_difference -> { Schedule.count }, -2 do
          delete project_session_path("project-current-schema", "session-current-schema")
        end
      end
    end
    assert_redirected_to project_path("project-current-schema")
    assert StoredBlob.exists?(hash: "fixture-image")
    assert_equal 0, BlobRef.where(session_id: "session-current-schema").count
  end
end
