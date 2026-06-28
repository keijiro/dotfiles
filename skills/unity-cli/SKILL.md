---
name: unity-cli
description: Use for general Unity CLI operations — list or open projects, list installed editors, read CLI logs, or any other Unity CLI task not covered by a more specific skill (unity-cli-install, unity-cli-build, unity-cli-pipeline).
allowed-tools:
  - Bash
---

# Unity CLI

Use `--format json` when parsing output programmatically.

For less commonly used commands (`auth`, `license`, `cloud`, `templates`, `config`, `hub`, `doctor`, `env`, `cache`, `analytics`, `changelog`, `language`, `completion`, `bug`, `upgrade`, `self-uninstall`), run `unity <command> --help`.

## Exit codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Bad arguments |
| 3 | Authentication failure |
| 4 | Precondition not met (e.g. no license active) |
| 6 | Command-specific failure |
| 130 | Interrupted (Ctrl+C) |

---

## Editors — list

```bash
unity editors --installed --format json
unity editors --releases --format json
unity editors list --format json
unity editors --installed --architecture arm64 --format json
```

For installing, uninstalling, upgrading, or managing modules, use the `unity-cli-install` skill.

---

## Projects

```bash
unity projects list --format json
unity projects add /path/to/MyProject
unity projects remove /path/to/MyProject
unity projects info /path/to/MyProject --format json

# Open a project
unity open /path/to/MyProject
unity open /path/to/MyProject --editor-version 6000.0.47f1
unity 6000.0.47f1 /path/to/MyProject   # shorthand

# Create
unity projects create MyGame --editor-version 6000.0.47f1 --template com.unity.template.3d
unity projects create MyGame --path /path/to/projects --editor-version 6000.0.47f1
unity projects new MyGame              # non-interactive, resolves from stored defaults
unity projects new MyGame --open

# Clone from VCS
unity projects clone --vcs github --vcs-namespace my-org --vcs-repo my-game --path ./MyGame
unity projects clone --vcs github --vcs-namespace my-org --vcs-repo monorepo \
  --path ./repo --project-path packages/MyGame

# Upgrade project to a different editor version
unity projects upgrade /path/to/MyProject --to 6000.0.47f1 --yes

# Cloud / VCS linking
unity projects link cloud /path/to/MyProject --cloud-org <id-or-name>
unity projects unlink cloud /path/to/MyProject
unity projects link vcs /path/to/MyProject \
  --vcs github --git-namespace my-org --git-repo my-game --git-token-stdin
unity projects unlink vcs /path/to/MyProject
```

---

## Logs

```bash
unity logs
unity logs --tail 50
unity logs --follow
unity logs --level error    # trace, debug, info, warn, error, fatal
```
