---
name: unity-cli-conventions
description: Use when driving Unity with the `unity` CLI
allowed-tools:
  - Bash
---

# Unity CLI conventions

Supplements the `unity-cli` skill with two rules for every automated `unity`
invocation. Where the two differ, follow these.

## Pass `-automated` when opening Unity

When Unity is launched by an agent rather than a person, pass `-automated` to
the Editor:

```bash
unity open . --args -automated
```

## Always pass `--project-path`

`unity-cli` asks for `--project-path` only when more than one Editor may be
running. Pass it **every time** to Editor-driving commands — `unity command`,
`list`, `job`, `mcp` — so a call never reaches the wrong Editor, whatever the
shell's cwd or however many Editors are open:
