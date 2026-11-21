# OpenCode uses SQLite REAL for session cost. Without a type alias Rails skips
# the whole table during schema export. Defer to Rails once the adapter maps it.
ActiveSupport.on_load(:active_record_sqlite3adapter) do
  type_map = self::TYPE_MAP
  type_map.alias_type(/\Areal\z/i, "float") unless type_map.lookup("REAL").type
end
