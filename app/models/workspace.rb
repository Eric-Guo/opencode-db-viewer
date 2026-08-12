class Workspace < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "workspace"

  has_many :sessions, class_name: "Session", foreign_key: :workspace_id, inverse_of: :workspace
  has_many :legacy_sessions, class_name: "LegacySession", foreign_key: :workspace_id, inverse_of: :workspace

  def binding_data
    @binding_data ||= parsed_json(binding)
  end

  def created_time
    epoch_time(self[:created_at])
  end

  def last_used_time
    epoch_time(last_used_at)
  end
end
