require "test_helper"

class SessionToolTest < ActiveSupport::TestCase
  test "migrated task calls identify legacy subagents and their child sessions" do
    tool = SessionTool.new("name" => "task", "state" => {"status" => "completed", "input" => {"subagent_type" => "explore", "description" => "Find the endpoint"}, "metadata" => {"sessionId" => "legacy-child"}})

    assert tool.subagent?
    assert_equal "subagents", tool.category
    assert_equal "legacy-child", tool.session_id
    assert_equal "explore", tool.agent
    assert_equal "Find the endpoint", tool.summary
  end

  test "subagent progress identifies the child before the call completes" do
    tool = SessionTool.new("name" => "subagent", "state" => {"status" => "running", "input" => {"agent" => "explore", "sessionID" => "old-child"}, "metadata" => {"sessionID" => "new-child", "status" => "running"}})

    assert_equal "new-child", tool.session_id
    assert_equal "subagents", tool.category
    assert_equal "running", tool.status
    assert_equal "explore", tool.agent
  end

  test "failed continuation retains its input session link" do
    tool = SessionTool.new("name" => "subagent", "state" => {"status" => "error", "input" => {"sessionID" => "existing-child"}})

    assert_equal "existing-child", tool.session_id
  end

  test "Code Mode errors and nested browser calls use recorded metadata" do
    tool = SessionTool.new("name" => "execute", "state" => {"status" => "completed", "metadata" => {"error" => true, "toolCalls" => [{"tool" => "browser.tabs.open", "input" => {"url" => "https://example.com"}, "status" => "error"}]}})

    assert_equal "error", tool.status
    assert_equal "browser", tool.calls.first.category
    assert_equal "https://example.com", tool.calls.first.summary
    assert_equal "error", tool.calls.first.status
  end

  test "streaming input and old malformed metadata do not break rendering" do
    tool = SessionTool.new("name" => "execute", "state" => {"status" => "streaming", "input" => '{"code":', "metadata" => {"toolCalls" => [nil, "old", {"tool" => 1}]}})

    assert_empty tool.input
    assert_empty tool.calls
    assert_nil tool.duration_ms
  end

  test "direct browser tool names use provider-normalized names" do
    tool = SessionTool.new("name" => "browser_tabs_open", "time" => {"created" => 1000, "completed" => 2500})

    assert tool.browser?
    assert_equal 1500, tool.duration_ms
  end
end
