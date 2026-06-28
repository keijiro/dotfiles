---
name: unity-cli-pipeline
description: Use when interacting with a running Unity Editor instance — sending commands, capturing screenshots, checking editor connection status, installing the Pipeline package, or evaluating C# expressions in the editor.
allowed-tools:
  - Bash
---

# Unity CLI — Pipeline / Connected Editors

The Pipeline package (`com.unity.pipeline`) must be installed in the project. It is resolved from the Unity UPM registry and written to `Packages/manifest.json`.

Use `--format json` when parsing output programmatically.

---

## pipeline — manage the Pipeline package

```bash
unity pipeline list --format json          # list reachable editors + package status
unity pipeline install                     # install/update pipeline package (auto-detects project)
unity pipeline install --project-path /path/to/MyProject
unity pipeline install --force
```

---

## command — send commands to a running editor

```bash
unity command                              # list available commands on connected editor
unity command --format json

unity command editor_play
unity command log_editor "Hello from CLI"
unity command editor_status --includeMemory true
unity command screenshot --output ./shot.png --width 1920 --height 1080

# Target a specific instance
unity command editor_play --project-path /path/to/MyProject
unity command editor_play --instance localhost:8765
unity command editor_play --timeout 60
```

### Built-in commands

| Command | Description |
|---|---|
| `editor_focus` | Bring the Unity Editor window to the foreground |
| `editor_play` | Enter Unity Editor play mode |
| `editor_pause` | Pause Unity Editor play mode |
| `editor_stop` | Exit Unity Editor play mode |
| `editor_status` | Get detailed Unity Editor status and state information |
| `quit` | Quit the Unity Editor |
| `recompile` | Force a script recompile (works while unfocused/minimized). Poll `recompile_status` for completion. |
| `recompile_status` | Get the status of the last recompile: `idle` \| `triggered` \| `compiling` \| `completed` \| `up_to_date` |
| `run_tests` | Execute Unity tests with filtering options |
| `list_tests` | List all available tests (EditMode and/or PlayMode) without running them |
| `cancel_tests` | Cancel running test execution |
| `test_status` | Get status of running async test execution |
| `eval` | Evaluate C# code dynamically using Roslyn compiler |
| `log` | Send a log message to the editor console |
| `reload_file` | Compile and apply in-place `[HotReload]` edits from a source file |
| `reload_file_override` | Compile and apply hot reload file changes immediately |
| `hotreload_status` | Get Hot Reload status |
| `cleanup_hotreload` | Clean up Hot Reload state |
| `runtime_status` | Get runtime / Player connection status |
| `set_autotick` | Keep the editor ticking while unfocused (forces `EditorApplication.SignalTick`) |
| `set_target_framerate` | Set `Application.targetFrameRate` |
| `set_timescale` | Set `Time.timeScale` |

#### run_tests

| Parameter | Type | Default | Description |
|---|---|---|---|
| `mode` | String | `all` | `all`, `editor`, `playmode` |
| `filter` | String | `""` | Test name filter (case-insensitive partial match) |
| `filter_type` | String | `testName` | `testName`, `assembly`, `category` |
| `include_explicit` | Boolean | `false` | Include tests marked with `[Explicit]` |
| `async_tests` | Boolean | `false` | Return immediately; poll `test_status` for results |
| `timeout` | Int32 | `300` | Timeout in seconds |

#### list_tests

| Parameter | Type | Default | Description |
|---|---|---|---|
| `mode` | String | `all` | `all`, `editor`, `playmode` |

#### set_autotick

| Parameter | Type | Default | Description |
|---|---|---|---|
| `enable` | Boolean | `true` | Enable or disable auto-tick |
| `interval_ms` | Int32 | `16` | Minimum ms between ticks. `0` = every update (max rate, pegs a CPU core) |

#### eval

| Parameter | Type | Default | Description |
|---|---|---|---|
| `code` | String | **required** | C# code to evaluate |
| `timeout` | Int32 | `5000` | Timeout in milliseconds |

**IMPORTANT:** The `code` parameter must use method-body syntax — `return` keyword and trailing semicolon are required. A bare expression without `return`/`;` causes `CS1002` compilation failure.

```bash
# Correct
unity command eval --code "return UnityEngine.SceneManagement.SceneManager.GetActiveScene().name;"

# Wrong — causes CS1002
unity command eval --code "UnityEngine.SceneManagement.SceneManager.GetActiveScene().name"
```

#### reload_file

| Parameter | Type | Default | Description |
|---|---|---|---|
| `filename` | String | **required** | Source file containing `[HotReload]` methods |
| `timeout` | Int32 | `30000` | Compilation timeout in milliseconds |
| `assemblyDir` | String | `null` | Save compiled assemblies to disk (default: in-memory only) |
| `pdb` | Boolean | `false` | Emit portable PDB debug symbols (unoptimized build) |

#### reload_file_override

| Parameter | Type | Default | Description |
|---|---|---|---|
| `filename` | String | **required** | Hot reload source file to compile |
| `timeout` | Int32 | `30000` | Compilation timeout in milliseconds |
| `assemblyDir` | String | `null` | Save compiled assemblies to disk (default: in-memory only) |

---

## status — live state of connected editors

```bash
unity status --format json
unity status --port 8765
unity status --project megacity
```

Exits non-zero (`STATUS_NO_INSTANCES` / `STATUS_ALL_UNREACHABLE`) when no editor is reachable.
