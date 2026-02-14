# Ignore non-Rails metadata tables that use DB-specific types unsupported by Rails schema dumper.
ActiveRecord::SchemaDumper.ignore_tables |= ["__drizzle_migrations"]
