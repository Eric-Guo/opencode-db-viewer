# OpenCode DB Viewer

A read-only Rails/CoreUI 5 browser for an OpenCode SQLite database. The project and session pages support both OpenCode storage generations:

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

The header's color-theme menu supports Light, Dark, and Auto (system preference), saved in the browser. CoreUI 5 integration checks cover color modes, responsive navigation, admin charts, tables, and modal selects in `test/system/coreui_v5_test.rb`.

The UI uses CoreUI Pro 5.27.1, adapting the Rails template changes in
`pagila-rails-portal` commit `e09e99e9071823408eee40a8e31420f43684c405`:

- The header search button opens project search with **Command + /** or **Ctrl + /**. Autocomplete suggests up to eight matching projects; selecting one and submitting opens it. Free-text searches still open the full project results.
- Active project/session filters appear as removable chips. Removing one preserves the others and resets pagination; **Clear all** restores the unfiltered list.
- Activity categories use a single-selection chip set with arrow-key, Home/End, Enter, and Space navigation. **Reset** returns to the conversation and clears the activity search.
- Both sidebars use tree navigation, with the current project and session shown in context. Existing admin tables, modal selects, and charts remain in use.

Suggestions use the same authenticated, policy-scoped project search as the full list. This design update does not change the OpenCode database schema. Component APIs and styles were checked against `/Users/guochunzhong/git/oss/coreui-pro`; the dependency is pinned to the published 5.27.1 package so builds do not require that local checkout.

### When you want to debug the SCSS

Set `shakapacker.yml` hmr to true.

```yml
hmr: true
```

### Frontend initialization

The application pack starts Stimulus and registers the controllers in `app/javascript/controllers`. Charts, DataTables, and Selectize load their dependencies when their controllers connect. Pages only append their optional stylesheet packs; a separate Stimulus JavaScript pack is no longer needed.

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
