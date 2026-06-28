---
name: unity-cli-build
description: Use when building, running headless, or running tests for a Unity project from the command line.
allowed-tools:
  - Bash
---

# Unity CLI — Build / Run / Test

Use `--format json` when parsing output programmatically.

---

## Run — headless/batch execution

Batch mode is automatic. Do **not** pass `-batchmode` or `-quit` after `--`.

```bash
unity run /path/to/MyProject -- -executeMethod Builder.Build
unity run /path/to/MyProject --editor-version 6000.0.47f1 -- -nographics -logFile out.log
unity run /path/to/MyProject --allow-install -- -executeMethod Builder.Build
unity run /path/to/MyProject --timeout 300 -- -executeMethod Builder.Build
```

Reserved flags (added automatically, rejected if passed): `-batchmode`, `-quit`, `-projectPath`, `-useHub`, `-hubIPC`.

---

## Test — EditMode/PlayMode tests

Writes an NUnit XML report. Exits 0 on pass, 6 on failure.

```bash
unity test /path/to/MyProject
unity test /path/to/MyProject --mode EditMode
unity test /path/to/MyProject --mode PlayMode --output ./results/play.xml
unity test /path/to/MyProject --filter "MyNamespace.MyTests"
unity test /path/to/MyProject --editor-version 6000.0.47f1 --allow-install --timeout 600
unity test /path/to/MyProject -- -nographics
```

Default output: `test-results.xml`. Do not pass `-quit` — `-runTests` quits the editor itself.

---

## Build

Both `--target` and `--execute-method` are required. Unity has no built-in CLI build; your method handles the actual build logic.

```bash
unity build /path/to/MyProject \
  --target StandaloneOSX \
  --execute-method Builder.PerformBuild \
  --output-path ./build/output
```

Common targets: `StandaloneOSX`, `StandaloneWindows64`, `StandaloneLinux64`, `Android`, `iOS`, `WebGL`.

| Flag | Description |
|---|---|
| `--target <target>` | Build target (required) |
| `--execute-method <method>` | Static C# method to invoke (required) |
| `-o, --output-path <path>` | Passed as `-buildOutput` |
| `-l, --log-file <path>` | Log file (default: `<project>/Logs/build-<target>-<timestamp>.log`) |
| `--editor-version <version>` | Override editor version |
| `--allow-install` | Install editor if missing |
| `--allow-dirty-build` | Skip uncommitted-changes guard |
| `--no-tail` | Do not stream log to stdout |

**Android signing** (optional): `--android-export-type apk|aab|android-studio-project`, `--android-keystore-base64`, `--android-keystore-password`, `--android-key-alias`, `--android-key-alias-password`.
