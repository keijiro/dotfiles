---
name: unity-cli-conventions
description: Use when driving Unity with the `unity` CLI
allowed-tools:
  - Bash
---

# Unity CLI conventions

Supplements the `unity-cli` skill with two rules for every automated `unity`
invocation. Where the two differ, follow these. For waiting on the Editor
(`--until-ready`, exit codes) and how `--project-path` matches, see `unity-cli`.

## Pass `-automated` when opening Unity

When Unity is launched by an agent rather than a person, pass `-automated` to
the Editor:

```bash
unity open "$P" --args -automated --until-ready
```

## Always pass `--project-path`

`unity-cli` asks for `--project-path` only when more than one Editor may be
running. Pass it **every time**, with the project's full path, to
Editor-driving commands — `unity command`, `status`, `recompile`, `job`, `mcp`,
`pipeline` — so a call never reaches the wrong Editor, whatever the shell's cwd
or however many Editors are open. Prefer the flag over `UNITY_PROJECT_PATH`.
