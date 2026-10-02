---
name: unity-pipeline-commands
description: Use when running `unity command` — finding commands and keeping calls cheap.
allowed-tools:
  - Bash
---

# Unity Pipeline commands: lookup and economy

Supplements the package's own `unity-pipeline` skill. The Editor exposes ~160
commands; the full catalog (`--detail compact|full` with no filter) is 20–350
KB, so never ask for it. Pass `--project-path` to every call (shortened to `$P`
below).

## Finding a command

Narrow in three steps, reading only what each step needs:

```bash
# 1. Tags with command counts — once per session
unity command --project-path $P --tags

# 2. Commands in a tag, with descriptions and parameter names
unity command --project-path $P --tag assets

# 3. Full spec of the one command you will run
unity command --project-path $P --json --query set_transform | jq '.data.commands[]
  | select(.name=="set_transform") | {description, parameters: [.parameters[] | {name, type, required, defaultValue, description}]}'
```

- Use `--tags`, not a bare `unity command`: on an older Pipeline package the
  bare form silently dumps the whole catalog instead of the tags.
- A wrong tag returns nothing, not an error. `--tags --query <word>` shows
  which tags hold matching commands.
- `unity command <name> --help` shows no per-command help, and step 2's table
  has no types or parameter descriptions: use step 3. `--query` is a substring
  match, so keep the `select(.name==…)`.
- `unity commands --grep` searches the CLI's own commands, not the Editor's.

## Keep calls few

Every invocation costs input and output tokens. Prefer, in order:

1. **One `batch` for several commands.** Later ops refer to earlier results
   with `$<id>.<path>`; `result_fields` trims what comes back.
   ```bash
   unity command batch --project-path $P --result-only \
     --operations '[{"id":"a","command":"create_gameobject","params":{"name":"Spawner"}},
                    {"command":"set_transform","params":{"target":"$a.instanceId","position":[0,1,0]}}]' \
     --result_fields '{"a":["instanceId"]}'
   ```
   - Transactional by default (one Undo step, all-or-nothing). It rejects
     asset, file and settings writes: pass `--transactional false` for those.
   - Not batchable: `build`, `package_*`, play/stop/pause, `recompile`,
     `eval`, `run_script`, `menu`, `open_scene`/`create_scene`, tests,
     nested `batch`. `--dry_run true` checks a batch without running it.
2. **A script for anything reusable.** Put C# in a file outside `Assets/`
   (e.g. `AgentScripts/`) and run it with `run_script --file … --entry …`;
   store batches you repeat as JSON and pass `--operations "$(cat ops.json)"`.
   Edit and rerun the file rather than retyping the call.
3. **`eval` only for a genuine one-liner.** A multi-line `eval`, or the same
   `eval` a second time, belongs in a `run_script` file.
   - **In a git worktree, `eval` is unavailable from the command line** (a
     current Claude Code restriction). Write even a one-liner to a file and
     run it with `run_script` instead.

Add `--result-only` to drop the response envelope.

## Don't retry on a busy Editor

`unity command <name>` already waits while the Editor is briefly unavailable
(right after `editor_play`, during a script reload) and runs once it is ready,
within `--timeout`. Do not wrap calls in a retry loop or add `sleep`s; raise
`--timeout` if a reload takes longer.

To wait for the Editor itself, such as after `unity open` (when plain
`unity status` lists nothing yet), run `unity status --project-path $P
--until-ready` once instead of polling. It returns as soon as the Editor is
ready, or exits 6 after `--timeout` seconds (default 300).
