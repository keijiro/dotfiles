---
name: unity-cli-pipeline
description: Use when interacting with a running Unity Editor instance — sending commands, checking editor connection status, installing the Pipeline package, or evaluating C# expressions in the editor.
allowed-tools:
  - Bash
---

# Unity CLI — Pipeline / Connected Editors

The Pipeline package (`com.unity.pipeline`) must be installed in the project. It is resolved from the Unity UPM registry and written to `Packages/manifest.json`.

Use `--format json` when parsing output programmatically.

---

## pipeline — manage the Pipeline package

```bash
unity pipeline list --format json          # reachable editors + installed package version (flags when newer exists)
unity pipeline install                     # install pipeline package (auto-detects project)
unity pipeline install --project-path /path/to/MyProject
unity pipeline install --force             # always rewrite manifest to the latest version
unity pipeline install --package-version 1.2.3   # pin a specific version (validated against the registry)
unity pipeline upgrade                     # update only if the registry has a newer version
unity pipeline list-versions --format json # all published package versions, newest first
```

With multiple editors running, `install`/`upgrade` only consider the editors that
need the operation; pass `--project-path` in non-interactive contexts when
several qualify.

After installing, Unity Editor must be active (foreground) for the Pipeline package to compile and connect. Use this to bring it to the foreground:

```bash
open /Applications/Unity/Hub/Editor/<version>/Unity.app
```

---

## command — send commands to a running editor

```bash
unity command                              # list available commands + parameters on connected editor
unity command --format json
unity list --format json                   # same discovery as a top-level command

unity command editor_play
unity command editor_status --includeMemory true
unity command eval --code "return Application.unityVersion;"

# Target a specific editor (editors are auto-discovered; no host:port addressing)
unity command editor_play --project-path /path/to/MyProject
unity command editor_play --timeout 60

# Connect to a Unity Player runtime instead of an editor
unity command <cmd> --runtime MyPlayer         # search by process name
unity command <cmd> --runtime-path /path/to/port-file
```

### Command conventions

- The exact command set depends on the installed Pipeline package version — run `unity command` to enumerate the live set with full parameter details.
- Destructive commands and project-settings setters require `--confirm true`; most support `--dry_run true` to preview.
- Array parameters (`String[]`, e.g. `options`, `scenes`) must be passed as a JSON array: `--options '["Development"]'`. A bare scalar (`--options Development`) binds to null and is **silently ignored** — no error, the command just runs without it.
- Long-running operations (bakes, builds, target switch, packages, async tests) return immediately — poll the matching `*_status` command until `completed`.

### Editor control

| Command | Description |
|---|---|
| `editor_play` / `editor_pause` / `editor_stop` | Enter / pause / exit play mode |
| `editor_status` | Detailed editor status and state |
| `editor_focus` | Bring the editor window to the foreground |
| `set_autotick` | Keep the editor ticking while unfocused |
| `menu` | Execute an Editor menu item by path, or list items |

### Compile / scripts / eval

| Command | Description |
|---|---|
| `recompile` / `recompile_status` | Force a script recompile; poll status (`idle` \| `triggered` \| `compiling` \| `completed` \| `up_to_date`) |
| `create_script` | Create a C# script from a template (recompile before attaching) |
| `attach_script` | Add a MonoBehaviour to a GameObject by type or script path |
| `eval` / `eval_file` | Evaluate C# code (inline / from a .cs file) via Roslyn |
| `reload_file` / `reload_file_override` | Compile and apply `[HotReload]` edits from a source file |

**IMPORTANT — `eval`:** the `code` parameter must use method-body syntax; `return` and a trailing semicolon are required. A bare expression causes `CS1002`.

```bash
# Correct
unity command eval --code "return UnityEngine.SceneManagement.SceneManager.GetActiveScene().name;"

# Wrong — causes CS1002
unity command eval --code "UnityEngine.SceneManagement.SceneManager.GetActiveScene().name"
```

### Tests

| Command | Description |
|---|---|
| `run_tests` | Run tests (`mode`: all/editor/playmode; `filter`; `async_tests` for polling) |
| `list_tests` | List EditMode/PlayMode tests without running them |
| `test_status` / `cancel_tests` | Poll / cancel async test execution |

### Console / logs

| Command | Description |
|---|---|
| `console` | Captured console output (tail, level filter, follow via cursor) |
| `get_console_logs` | Recently captured Editor console logs (structured) |
| `clear_console` | Clear the log buffer and the Editor console |

### Capture

| Command | Description |
|---|---|
| `screenshot` | Capture the Scene or Game view as a PNG (file path) |
| `capture_game_view` | Render a camera to a PNG (base64) |
| `capture_scene_view` | Render the active Scene View to a PNG (base64) |

### Scenes

| Command | Description |
|---|---|
| `create_scene` / `open_scene` / `save_scene` / `save_all` | Create / open / save scenes |
| `list_open_scenes` | List open scenes with load/active/dirty state |
| `set_active_scene` | Set which open scene is active |
| `get_scene_hierarchy` | GameObject tree with instanceId + hierarchyPath handles |

### GameObjects

| Command | Description |
|---|---|
| `create_gameobject` / `create_gameobjects` | Create empty GameObjects or primitives (single / batch) |
| `find_gameobjects` | Find by name, tag, component type, hierarchy path |
| `delete_gameobject` / `rename_gameobject` | Delete (undoable) / rename |
| `set_transform` / `set_parent` / `set_active` / `set_tag` / `set_layer` | Set transform, parent, active state, tag, layer |

### Components / serialized data

| Command | Description |
|---|---|
| `add_component` / `remove_component` | Add / remove a component by type name |
| `get_component_properties` / `set_component_properties` | Read / write a component's serialized properties |
| `get_serialized_fields` / `set_serialized_field` | Read / write serialized fields on a component or asset |

### Prefabs

| Command | Description |
|---|---|
| `create_prefab` / `create_prefab_variant` | Save a GameObject as a prefab / create a variant |
| `instantiate_prefab` / `unpack_prefab` | Instantiate into a scene / unpack an instance |
| `apply_prefab_overrides` / `revert_prefab_overrides` | Apply / revert instance overrides |
| `save_prefab_contents` | Edit a prefab in an isolated stage and save (nested-safe) |

### Assets / project files

| Command | Description |
|---|---|
| `find_assets` / `search` | Find assets by type/name/label / run a Unity Search query |
| `create_asset` / `delete_asset` | Create a ScriptableObject asset / delete an asset |
| `move_asset` / `rename_asset` / `copy_asset` | Move (keeps GUID) / rename / copy (new GUID) |
| `import_asset` / `create_folder` | Import an external file / create a folder |
| `read_text_file` / `write_text_file` | Read / write a UTF-8 text file under the authoring root |
| `get_import_settings` / `set_import_settings` | Read / write an asset's importer settings |
| `get_selection` / `set_selection` | Read / set the Editor selection |
| `get_authoring_root` / `set_authoring_root` | Read / set the base folder bare paths resolve against |

### Shaders / materials

| Command | Description |
|---|---|
| `list_shaders` | Discover available shaders (name, path, builtin, supported) |
| `get_shader_properties` | Introspect a shader's declared properties |
| `get_material_properties` / `set_material_properties` | Read / write material properties, shader, queue, keywords |

### Animation / Timeline

| Command | Description |
|---|---|
| `create_animation_clip` / `get_animation_clip` | Create / read an AnimationClip |
| `set_animation_curve` / `remove_animation_curve` | Add-or-replace / remove a float curve binding |
| `create_animator_controller` / `get_animator_controller` | Create / read an AnimatorController |
| `add_animator_layer` / `add_animator_parameter` / `add_animator_state` / `add_animator_transition` | Build up an AnimatorController |
| `create_timeline` / `get_timeline` | Create / read a TimelineAsset (requires com.unity.timeline) |
| `add_timeline_track` / `add_timeline_clip` | Add tracks / clips to a TimelineAsset |

### Baking (async — poll `*_status`)

| Command | Description |
|---|---|
| `bake_lighting` / `lighting_bake_status` / `cancel_lighting_bake` / `clear_baked_lighting` | Lightmap bake lifecycle |
| `get_lighting_settings` / `set_lighting_settings` | Read / write the active LightingSettings |
| `bake_navmesh` / `bake_navmesh_surfaces` / `navmesh_bake_status` / `cancel_navmesh_bake` / `clear_navmesh` | NavMesh bake lifecycle (legacy + NavMeshSurface) |
| `get_navmesh_settings` / `set_navmesh_settings` | Read / write legacy NavMesh bake settings |
| `bake_occlusion_culling` / `occlusion_bake_status` / `cancel_occlusion_bake` / `clear_occlusion_culling` | Occlusion-culling bake lifecycle |

### Build

| Command | Description |
|---|---|
| `build` / `build_status` | Async Player build; poll for the full BuildReport |
| `get_build_settings` / `set_build_settings` | Read / write EditorUserBuildSettings |
| `add_scene_to_build` / `remove_scene_from_build` | Manage the Build Settings scene list |
| `switch_build_target` / `switch_build_target_status` | Switch active build target (destructive, long-running) |
| `list_build_targets` / `list_build_profiles` | List targets with install state / Build Profile assets (Unity 6) |

### Packages (UPM)

| Command | Description |
|---|---|
| `package_add` / `package_remove` | Add / remove a package (async; recompile follows) |
| `package_list` / `package_search` | List installed/available packages / search the registry |
| `package_resolve` / `package_status` | Re-resolve the manifest / poll the last async operation |

### Project settings (setters require `confirm=true`, support `dry_run`)

| Command | Description |
|---|---|
| `get_player_settings` / `set_player_settings` | PlayerSettings |
| `get_quality_settings` / `set_quality_settings` | QualitySettings |
| `get_physics_settings` / `set_physics_settings` | Physics |
| `get_time_settings` / `set_time_settings` | Time |
| `get_audio_settings` / `set_audio_settings` | Audio |
| `get_graphics_settings` / `set_graphics_settings` | GraphicsSettings (render pipeline) |
| `get_input_settings` / `set_input_settings` | Legacy Input Manager axes |
| `get_tags_layers` / `set_tags_layers` | Tags and named layers |

### Misc

| Command | Description |
|---|---|
| `get_performance_stats` | Render, memory, and frame-timing stats (read-only) |

---

## status — live state of connected editors

```bash
unity status --format json
unity status --port 8765
unity status --project megacity
```

Exits non-zero (`STATUS_NO_INSTANCES` / `STATUS_ALL_UNREACHABLE`) when no editor is reachable.
