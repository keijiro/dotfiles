---
name: unity-pipeline-commands
description: Use when running `unity command` — finding commands and keeping calls cheap.
allowed-tools:
  - Bash
---

# Unity Pipeline commands: lookup and economy

Supplements the package's own `unity-pipeline` skill and the `unity-cli`
skill; general command discovery (`--query`, `--tag`, `--obsolete-command-names`),
`--result-only` and the built-in wait on a busy Editor are covered there. Pass
`--project-path` to every call (shortened to `$P` below; see
`unity-cli-conventions`).

The old flat command names (`create_gameobject`, `eval`, `editor_play`, …)
fail with `REMOTE_COMMAND_NOT_FOUND` on a current package, also inside a
`job batch`; the error names the replacement.

## Finding a command

The Editor exposes ~170 commands, and the full catalog (`--detail compact|full`
with no filter) is 20–350 KB. `unity-cli` calls `--detail full` the
authoritative catalog, but never ask for it: narrow in three steps instead,
reading only what each step needs.

```bash
# 1. Groups with command counts — once per session
unity command --project-path $P

# 2. Commands in a group, with descriptions and parameter names
unity command gameobject --project-path $P

# 3. Full spec of the one command you will run
unity command gameobject --project-path $P --json | jq '.data.commands[]
  | select(.command=="gameobject set_transform") | {description, parameters: [.parameters[] | {name, type, required, defaultValue, description}]}'
```

- An unknown group in step 2 fails with exit 13, but a wrong `--tag` returns
  nothing, not an error.
- `unity command <name> --help` shows no per-command help, and step 2's table
  has no types or parameter descriptions: use step 3. In the JSON, `.command`
  is the full name and `.name` only the action.

## Keep calls few

Every invocation costs input and output tokens. Prefer, in order:

1. **One `job batch` for several commands.** Later ops refer to earlier results
   with `$<id>.<path>`; `result_fields` trims what comes back.
   ```bash
   unity command job batch --project-path $P --result-only \
     --operations '[{"id":"a","command":"gameobject create","params":{"name":"Spawner"}},
                    {"command":"gameobject set_transform","params":{"target":"$a.instanceId","position":[0,1,0]}}]' \
     --result_fields '{"a":["instanceId"]}'
   ```
   - Transactional by default (one Undo step, all-or-nothing). It rejects
     asset, file and settings writes: pass `--transactional false` for those.
   - `--timeout` (seconds, default 60) bounds the whole batch; when it runs
     out the rest is skipped and a transactional batch rolls back.
   - Not batchable: `build run`, `build.target switch`, `package *`,
     `editor.playmode start|stop|pause`, `script recompile`, `script eval`,
     `script eval_file`, `script run`, `editor invoke_menu`,
     `scene open|create`, `test run|list`, runtime-only commands, nested
     `job batch`. `--dry_run true` checks a batch without running it.
   - Store batches you repeat as JSON and pass `--operations "$(cat ops.json)"`.
2. **A `script run` file for anything reusable**, as `unity-pipeline`
   describes.
3. **`script eval` only for a genuine one-liner.**
   - **In a git worktree, `script eval` is unavailable from the command line**
     (a current Claude Code restriction). Write even a one-liner to a file and
     run it with `script run` instead.
