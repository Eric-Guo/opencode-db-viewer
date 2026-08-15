# OpenCode DB Viewer

A read-only Rails/CoreUI browser for an OpenCode SQLite database. The project and session pages support both OpenCode storage generations:

- current sessions in `session_v2` with sequenced `session_message` records, including assistant content, tool calls, usage, pending inputs, instruction context, and durable events;
- retained legacy conversations in `session`, `message`, and `part` for migrated databases that still contain older storage rows.

Account and credential tables have matching models for schema completeness, but secret values are intentionally not exposed by the views.

Set the development database path in `config/database.yml`, then run:

```bash
bin/rails server
```

## Development notes

### When you want to debug the SCSS

Set `shakapacker.yml` hmr to true.

```yml
hmr: true
```

### Why should always include "stimulus"

Because using webpack 5, the loading sequence do matter.

### How to debug in VSCode?

Install `Ruby LSP` by Shopify and `VSCode rdbg Ruby Debugger` by KoichiSasada.

Make sure debug only having one version install as default gems, otherwise uninstall first:

```bash
gem uninstall -i /opt/homebrew/Cellar/ruby/3.2.2/lib/ruby/gems/3.2.0 debug
gem install debug --default
```

## Compress DB

```bash
cd /Users/guochunzhong/.local/share/opencode
sqlite3 opencode-eric_dev.db 'VACUUM'
```
