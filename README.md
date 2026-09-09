# OpenCode DB Viewer

A read-only Rails/CoreUI browser for an OpenCode SQLite database. The project and session pages support both OpenCode storage generations:

- current sessions in `session_v2` with sequenced `session_message` records, including assistant content, tool calls, usage, pending inputs, instruction context, and durable events;
- retained legacy conversations in `session`, `message`, and `part` for migrated databases that still contain older storage rows.

Account and credential tables have matching models for schema completeness, but secret values are intentionally not exposed by the views.

Project pages include search, top-level/subagent and archive filters, retained-message counts, and MyTodo project/work-package mappings when present. Sessions show their recorded outcome, usage, and linked parent/child conversations. Execution claims are recovery markers; the viewer does not treat them as proof that a process is currently running.

The activity timeline opens on the conversation and can be filtered to tools, subagents, browser activity, or durable events. Subagent cards show the delegated prompt, foreground/background mode, child session, and status at return alongside the child's current recorded outcome. Browser operations inside Code Mode `execute` calls come from `state.metadata.toolCalls`, including their inputs and recorded statuses. Stored captures can be previewed and downloaded with their original filenames through **Inspect input, output, and metadata**. The viewer reads saved activity; it does not connect to or control a browser.

Set the development database path in `config/database.yml`, then run:

```bash
bin/rails server
```

## Development notes

Run the Rails suite with `bin/rails test`, and the project/session browser checks with `HEADLESS=1 bin/rails test:system`. Tests use the separate database under `storage/`, including fixtures for background subagents and browser Code Mode calls.

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
