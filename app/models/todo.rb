class Todo < ApplicationRecord
  self.table_name = "todo"
  self.primary_key = %i[session_id position]

  belongs_to :session, class_name: "Session", foreign_key: :session_id, inverse_of: :todos
end
