---
name: unity-pipeline-commands
description: Use when running `unity command` — finding commands and keeping calls cheap.
allowed-tools:
  - Bash
---

# Unity Pipeline commands: lookup and economy

Supplements the package's own `unity-pipeline` skill. The Editor exposes ~150
commands; the full listing is ~25 KB, so never dump it. Pass `--project-path`
to every call (shortened to `$P` below).

## Finding a command

Narrow in three steps, reading only what each step needs:

```bash
# 1. Tag tree (categories + counts) — once per session
unity command --project-path $P --json --detail compact --group_by tag \
  | jq -r 'def t(d): .[] | "\("  "*d)\(.tag) (\(.count))", (.children // [] | t(d+1)); .data.groups | t(0)'

# 2. Names in a category (a tag includes its subtags: `assets` covers `assets/import`)
unity command --project-path $P --json --detail compact --tag assets | jq -r '.data.commands[].name'

# 3. Spec of one command
unity command --project-path $P --json --query set_transform | jq '.data.commands[]
  | select(.name=="set_transform") | {description, parameters: [.parameters[] | {name, type, required, defaultValue, description}]}'
```

- Tags must match exactly; a wrong one returns nothing, not an error.
- When no tag fits, `--query <word>` matches name, description and tag. It is
  looser, so pipe it through the same `jq` for names only.
- `--query` is a substring match: keep the `select(.name==…)` in step 3.
- `unity command <name> --help` shows no per-command help; step 3 is the spec.

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

Add `--result-only` to drop the response envelope.
