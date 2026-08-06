class LegacySession < ApplicationRecord
  include OpenCodeRecord

  self.table_name = "session"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :legacy_sessions
  belongs_to :workspace, class_name: "Workspace", foreign_key: :workspace_id, inverse_of: :legacy_sessions, optional: true

  has_many :messages, class_name: "Message", foreign_key: :session_id, inverse_of: :session, dependent: :destroy
  has_many :parts, class_name: "Part", foreign_key: :session_id, inverse_of: :session
  has_one :session_share,
    class_name: "SessionShare",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
end
