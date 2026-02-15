class Session < ApplicationRecord
  self.table_name = "session"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :sessions

  has_many :messages, class_name: "Message", foreign_key: :session_id, inverse_of: :session, dependent: :destroy
  has_many :todos, class_name: "Todo", foreign_key: :session_id, inverse_of: :session, dependent: :destroy
  has_one :session_share,
    class_name: "SessionShare",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
end
