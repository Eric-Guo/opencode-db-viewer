class Session < ApplicationRecord
  self.table_name = "session"

  belongs_to :project, class_name: "Project", foreign_key: :project_id, inverse_of: :sessions
  belongs_to :parent, class_name: "Session", foreign_key: :parent_id, inverse_of: :children, optional: true

  has_many :messages, class_name: "Message", foreign_key: :session_id, inverse_of: :session, dependent: :destroy
  has_many :parts, class_name: "Part", foreign_key: :session_id, inverse_of: :session
  has_many :children, class_name: "Session", foreign_key: :parent_id, inverse_of: :parent
  has_many :todos, class_name: "Todo", foreign_key: :session_id, inverse_of: :session, dependent: :destroy
  has_one :session_share,
    class_name: "SessionShare",
    foreign_key: :session_id,
    inverse_of: :session,
    dependent: :destroy
end
