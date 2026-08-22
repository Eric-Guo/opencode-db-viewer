class Session < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session_v2"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :sessions
  belongs_to :parent, class_name: "Session", foreign_key: :parent_id, inverse_of: :children, optional: true
  belongs_to :fork_session, class_name: "Session", foreign_key: :fork_session_id, inverse_of: :forks, optional: true
  belongs_to :workspace, class_name: "Workspace", foreign_key: :workspace_id, inverse_of: :sessions, optional: true

  has_many :legacy_messages, class_name: "Message", foreign_key: :session_id, primary_key: :id
  has_many :session_messages,
    class_name: "SessionMessage",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
  has_many :session_pendings,
    class_name: "SessionPending",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
  has_many :session_inboxes,
    class_name: "SessionInbox",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
  has_many :instruction_entries,
    class_name: "InstructionEntry",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
  has_many :children, class_name: "Session", foreign_key: :parent_id, inverse_of: :parent
  has_many :forks, class_name: "Session", foreign_key: :fork_session_id, inverse_of: :fork_session
  has_one :event_sequence,
    class_name: "EventSequence",
    foreign_key: :aggregate_id,
    primary_key: :id,
    dependent: :destroy
  has_many :events, through: :event_sequence, source: :events
  has_one :instruction_state,
    class_name: "InstructionState",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy

  def time_created_at
    epoch_time(time_created)
  end

  def time_updated_at
    epoch_time(time_updated)
  end

  def time_archived_at
    epoch_time(time_archived)
  end

  def time_compacting_at
    epoch_time(time_compacting)
  end

  def execution_claimed_at
    epoch_time(time_suspended)
  end

  def time_idle_at
    epoch_time(time_idle)
  end

  def time_viewed_at
    epoch_time(time_viewed)
  end

  def model_data
    @model_data ||= parsed_json(model)
  end

  def metadata_data
    @metadata_data ||= parsed_json(metadata)
  end

  def fork_boundary_data
    @fork_boundary_data ||= parsed_json(fork_boundary)
  end

  def fork_boundary_type
    fork_boundary_data["type"]
  end

  def fork_boundary_message_id
    fork_boundary_data["messageID"]
  end

  def summary_diffs_data
    @summary_diffs_data ||= parsed_json(summary_diffs, fallback: [])
  end

  def total_tokens
    tokens_input.to_i + tokens_output.to_i + tokens_reasoning.to_i + tokens_cache_read.to_i + tokens_cache_write.to_i
  end
end
