---
name: unity-console-log
description: Use when reading the Unity Editor Console (log/warning/error entries) or detecting compile errors (C#/Burst, shader, compute shader) from a connected editor via the Pipeline package.
allowed-tools:
  - Bash
---

# Unity Console Log — Read & Detect Errors

Reads the Unity Editor Console over the Pipeline package. There is no dedicated
"read console" command, so use `unity command eval` to call internal Editor APIs.
Requires a reachable editor — see the `unity-cli-pipeline` skill for setup
(`unity status`, `unity pipeline install`, `editor_focus`).

`eval` code must use method-body syntax (`return ...;`). Wrap in one command.

---

## Read all console entries

The Console is backed by internal `UnityEditor.LogEntries` / `LogEntry`.

```bash
unity command eval --timeout 15000 --code '
var asm = typeof(UnityEditor.Editor).Assembly;
var logEntries = asm.GetType("UnityEditor.LogEntries");
var logEntry = asm.GetType("UnityEditor.LogEntry");
var flags = System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic;
int count = (int)logEntries.GetMethod("StartGettingEntries", flags).Invoke(null, null);
var entry = System.Activator.CreateInstance(logEntry);
var getEntry = logEntries.GetMethod("GetEntryInternal", flags);
var msgField = logEntry.GetField("message");
var modeField = logEntry.GetField("mode");
var sb = new System.Text.StringBuilder();
sb.AppendLine("count: " + count);
for (int i = 0; i < count; i++) {
  object[] args = new object[] { i, entry };
  getEntry.Invoke(null, args);
  string msg = (string)msgField.GetValue(args[1]);
  int mode = (int)modeField.GetValue(args[1]);
  var first = msg.Split(new char[]{(char)10})[0];
  sb.AppendLine("[" + i + "] mode=" + mode + " | " + first);
}
logEntries.GetMethod("EndGettingEntries", flags).Invoke(null, null);
return sb.ToString();
'
```

Always call `StartGettingEntries` before and `EndGettingEntries` after.
`message` holds the text + stacktrace; split on `\n` (char 10) for the first line.

---

## The `mode` field — severity / origin bit flags

`mode` is an OR of `UnityEditor.LogMessageFlags` bits, not a single value. Test bits
to classify. Key bits observed:

| Bit | Flag | Meaning |
|---|---|---|
| 2048 | `kScriptCompileError` | C# / Burst compile error |
| 64 | `kAssetImportError` | Shader / compute shader error |
| 256 | `kScriptingError` | runtime scripting error |
| 512 | `kScriptingWarning` | warning |
| 1024 | `kScriptingLog` | normal `Debug.Log` |
| 262144 | `kDontExtractStacktrace` | message carries file/line inline |

To classify an entry as an error, test the error bits, e.g.
`(mode & (2048 | 64 | 256 | 1)) != 0`. To dump the exact flags of a value, iterate
`System.Enum.GetNames(asm.GetType("UnityEditor.LogMessageFlags"))` and AND each.

---

## Detect errors by category

**C# / Burst** — surface via a recompile, then read the console.
```bash
unity command recompile
unity command recompile_status --format json   # poll until completed
```
C# errors block the recompile; Burst errors (`BC####`) appear as console entries
with `kScriptCompileError` even when C# itself compiles.

**Shader (.shader)** — force a synchronous reimport, then query per-asset:
```bash
unity command eval --code '
UnityEditor.AssetDatabase.ImportAsset("Assets/My.shader", UnityEditor.ImportAssetOptions.ForceSynchronousImport | UnityEditor.ImportAssetOptions.ForceUpdate);
var sh = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Shader>("Assets/My.shader");
var sb = new System.Text.StringBuilder();
sb.AppendLine("hasError=" + UnityEditor.ShaderUtil.ShaderHasError(sh));
foreach (var m in UnityEditor.ShaderUtil.GetShaderMessages(sh))
  sb.AppendLine("[" + m.severity + "] line " + m.line + ": " + m.message);
return sb.ToString();
'
```

**Compute shader (.compute)** — same reimport, but use the compute-specific API.
`ShaderUtil.ShaderHasError` takes a `Shader` and will NOT accept a `ComputeShader`.
```bash
unity command eval --code '
var cs = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.ComputeShader>("Assets/My.compute");
var sb = new System.Text.StringBuilder();
foreach (var m in UnityEditor.ShaderUtil.GetComputeShaderMessages(cs))
  sb.AppendLine("[" + m.severity + "] line " + m.line + ": " + m.message);
return sb.ToString();
'
```

Shader and compute errors also land in the console (`kAssetImportError`), reported as
`Shader error in '<name>': <msg> at <file>(<line>) (on <platform>)`.
