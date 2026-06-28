---
name: unity-cli-install
description: Use when installing, uninstalling, or upgrading Unity editors, adding or listing modules, or browsing available Unity releases.
allowed-tools:
  - Bash
---

# Unity CLI — Install / Uninstall / Modules

Use `--format json` when parsing output programmatically.

---

## Install an editor

```bash
unity install 6000.0.47f1
unity install 6000.0.47f1 --module windows-mono --module android
unity install 6000.0.47f1 -m android ios          # space-separated modules
unity install 6000.0.47f1 --yes --accept-eula      # CI / non-interactive
unity install 6000.0.47f1 --force                  # reinstall even if present
unity install 6000.0.47f1 --resume                 # recover interrupted download
unity install 6000.0.47f1 --dry-run --format json
```

---

## Uninstall an editor

```bash
unity uninstall 6000.0.47f1 --yes
unity uninstall 6000.0.47f1 --architecture arm64 --yes
```

---

## Upgrade an editor

Upgrades to the newest patch in the same `major.minor` line. Old version is kept unless `--replace` is passed.

```bash
unity editors upgrade 2022.3.10f1
unity editors upgrade lts
unity editors upgrade --all --yes --accept-eula
unity editors upgrade --all --dry-run --format json
unity editors upgrade 2022.3.10f1 --replace --yes   # remove old after upgrade
unity editors upgrade 2022.3.10f1 --module android --module ios  # add modules
```

---

## Releases

```bash
unity releases --format json
unity releases --lts --format json
unity releases --stream lts --format json
unity releases --stream tech --format json
```

---

## Modules

```bash
# List modules for an installed editor
unity editors module list 6000.0.47f1 --format json
unity modules list 6000.0.47f1 --format json
unity modules list 6000.0.47f1 --architecture arm64 --format json

# Add modules
unity editors module add 6000.0.47f1 --module android --module ios
unity editors module add 6000.0.47f1 --all
unity editors module add 6000.0.47f1 --module android --accept-eula

# install-modules (alternative interface)
unity install-modules --editor-version 6000.0.47f1 --module android --module ios
unity install-modules --editor-version 6000.0.47f1 --all --yes
unity install-modules --editor-version 6000.0.47f1 --list
unity install-modules --editor-version 6000.0.47f1 --all --accept-eula --dry-run
```

`--list` and `--all` are mutually exclusive.
