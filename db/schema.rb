# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 0) do
# Could not dump table "__drizzle_migrations" because of following StandardError
#   Unknown type 'SERIAL' for column 'id'


  create_table "control_account", primary_key: ["email", "url"], force: :cascade do |t|
    t.text "email", null: false
    t.text "url", null: false
    t.text "access_token", null: false
    t.text "refresh_token", null: false
    t.integer "token_expiry"
    t.integer "active", null: false
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
  end

  create_table "message", id: :text, force: :cascade do |t|
    t.text "session_id", null: false
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.text "data", null: false
    t.index ["session_id"], name: "message_session_idx"
  end

  create_table "part", id: :text, force: :cascade do |t|
    t.text "message_id", null: false
    t.text "session_id", null: false
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.text "data", null: false
    t.index ["message_id"], name: "part_message_idx"
    t.index ["session_id"], name: "part_session_idx"
  end

  create_table "permission", primary_key: "project_id", id: :text, force: :cascade do |t|
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.text "data", null: false
  end

  create_table "project", id: :text, force: :cascade do |t|
    t.text "worktree", null: false
    t.text "vcs"
    t.text "name"
    t.text "icon_url"
    t.text "icon_color"
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.integer "time_initialized"
    t.text "sandboxes", null: false
    t.text "commands"
  end

  create_table "session", id: :text, force: :cascade do |t|
    t.text "project_id", null: false
    t.text "parent_id"
    t.text "slug", null: false
    t.text "directory", null: false
    t.text "title", null: false
    t.text "version", null: false
    t.text "share_url"
    t.integer "summary_additions"
    t.integer "summary_deletions"
    t.integer "summary_files"
    t.text "summary_diffs"
    t.text "revert"
    t.text "permission"
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.integer "time_compacting"
    t.integer "time_archived"
    t.index ["parent_id"], name: "session_parent_idx"
    t.index ["project_id"], name: "session_project_idx"
  end

  create_table "session_share", primary_key: "session_id", id: :text, force: :cascade do |t|
    t.text "id", null: false
    t.text "secret", null: false
    t.text "url", null: false
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
  end

  create_table "todo", primary_key: ["session_id", "position"], force: :cascade do |t|
    t.text "session_id", null: false
    t.text "content", null: false
    t.text "status", null: false
    t.text "priority", null: false
    t.integer "position", null: false
    t.integer "time_created", null: false
    t.integer "time_updated", null: false
    t.index ["session_id"], name: "todo_session_idx"
  end

  add_foreign_key "message", "session", on_delete: :cascade
  add_foreign_key "part", "message", on_delete: :cascade
  add_foreign_key "permission", "project", on_delete: :cascade
  add_foreign_key "session", "project", on_delete: :cascade
  add_foreign_key "session_share", "session", on_delete: :cascade
  add_foreign_key "todo", "session", on_delete: :cascade
end
