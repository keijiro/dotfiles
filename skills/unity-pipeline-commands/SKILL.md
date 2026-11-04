---
name: unity-pipeline-commands
description: Use when running `unity command` — finding commands and keeping calls cheap.
allowed-tools:
  - Bash
---

# Unity Pipeline commands: lookup and economy

Supplements the package's own `unity-pipeline` skill and the `unity-cli`
skill; general command discovery (`--query`, `--tag`, `--obsolete-command-names`)
and `--result-only` are covered there. Pass `--project-path` to every call
(shortened to `"$P"` below; see `unity-cli-conventions`).

The old flat command names (`create_gameobject`, `eval`, `editor_play`, …)
fail with `REMOTE_COMMAND_NOT_FOUND` (exit 13) on a current package, also
inside a `job batch`; the error names the replacement. Under `--format json`
that failure leaves stdout empty: add `--result-only` to read it as JSON.

## Parameter names are kebab-case

Current packages spell parameters with hyphens (`--dry-run`,
`--result-fields`, `--output-path`, `--async-tests`) and match them exactly.
A snake_case spelling, still found in older docs including the
`unity-pipeline` skill, fails with `INVALID_COMMAND_ARGS`; the error suggests
the right name.

## Finding a command

The Editor exposes ~190 commands, and the full catalog (`--detail full` with
no filter) is ~340 KB; even `--detail compact` is ~55 KB. Never dump it:
narrow in three steps instead, reading only what each step needs.

```bash
# 1. Groups with command counts — once per session
unity command --project-path "$P"

# 2. Commands in a group, with parameter names and descriptions
unity command gameobject --project-path "$P"

# 3. Full spec (types, required, defaults) of the command you will run
unity command --query set_transform --detail full --json --project-path "$P" \
  | jq '.commands[] | {command, description, parameters: [.parameters[] | {name, type, required, defaultValue, description}]}'
```

- An unknown group in step 2 fails with exit 13, but a wrong `--tag` returns
  nothing, not an error.
- `unity command <name> --help` shows only the CLI's own help, and step 2's
  table has no types: use step 3. Its JSON has no `.data` envelope, and
  `--query` matches substrings, so check `.command` (the full name) when
  several commands match.
- After a group name, listing flags are no longer listing flags:
  `unity command gameobject --detail full` is read as a command named
  `gameobject --detail` and fails with exit 13.

## Waiting on the Editor

A domain reload (script changes, `script recompile`) takes the Pipeline
server down for a moment. A call made then fails at once with exit 12
(`EDITOR_NOT_RUNNING`) in every output mode; the CLI does not wait it out.
Run `unity status --until-ready --project-path "$P"`, then retry.

## Keep calls few

Every invocation costs input and output tokens. Prefer, in order:

1. **One `job batch` for several commands.** Later ops refer to earlier results
   with `$<id>.<path>` (or `$<index>.<path>`); `--result-fields` trims what
   comes back.
   ```bash
   unity command job batch --project-path "$P" --result-only \
     --operations '[{"id":"a","command":"gameobject create","params":{"name":"Spawner"}},
                    {"command":"gameobject set_transform","params":{"target":"$a.instanceId","position":[0,1,0]}}]' \
     --result-fields '{"a":["instanceId"]}'
   ```
   - Transactional by default (one Undo step, all-or-nothing). It rejects
     anything Undo cannot revert (`not_batchable_transactional`): asset and
     file writes, `scene save`, prefab and animation assets, materials,
     settings, bakes. Pass `--transactional false` for those, or
     `--on-error continue` to run every op and collect the errors (this forces
     `transactional` off).
   - `--timeout` (seconds, default 60) bounds the whole batch; when it runs
     out the rest is skipped and a transactional batch rolls back.
   - Never batchable (`not_batchable`): `script eval|eval_file|run`, async
     commands such as `test run|list`, `scene open|create`, `job wait`, the
     `package` group, `build run`, `build.target switch`,
     `editor.playmode start|stop|pause`, `script recompile`,
     `editor invoke_menu`, runtime-only commands, nested `job batch`.
   - `--dry-run true` checks command names, parameters, references and both
     restrictions without running anything: run it first on a new batch.
   - Store batches you repeat as JSON and pass `--operations "$(cat ops.json)"`.
2. **A `script run` file for anything reusable**, as `unity-pipeline`
   describes (translate its snake_case parameter names; see above).
3. **`script eval` only for a genuine one-liner.**
   - **In a git worktree, `script eval` is unavailable from the command line**
     (a current Claude Code restriction). Write even a one-liner to a file and
     run it with `script run` instead.
