require "test_helper"
require "stringio"
require "tmpdir"

# This uses its own SQLite connection, not the app's OpenCode database or fixtures.
class SqliteRealSchemaTest < Minitest::Test
  class ScratchRecord < ActiveRecord::Base
    self.abstract_class = true
  end

  def test_dumps_sqlite_real_as_float
    Dir.mktmpdir do |directory|
      ScratchRecord.establish_connection(adapter: "sqlite3", database: File.join(directory, "open_code.sqlite3"))

      ScratchRecord.connection_pool.with_connection do |connection|
        connection.execute("CREATE TABLE session_v2 (id TEXT PRIMARY KEY, cost REAL DEFAULT 0 NOT NULL)")
        connection.execute("INSERT INTO session_v2 (id, cost) VALUES ('ses_synthetic', 1.25)")

        cost = connection.columns("session_v2").find { |column| column.name == "cost" }
        assert_equal "REAL", cost.sql_type.upcase
        assert_equal :float, cost.type
        assert_equal 1.25, connection.select_value("SELECT cost FROM session_v2")

        schema = StringIO.new
        ActiveRecord::SchemaDumper.dump(connection.pool, schema)
        assert_includes schema.string, 'create_table "session_v2"'
        assert_includes schema.string, 't.float "cost", default: 0.0, null: false'
        refute_includes schema.string, "Unknown type"
      end
    ensure
      ScratchRecord.remove_connection
    end
  end
end
