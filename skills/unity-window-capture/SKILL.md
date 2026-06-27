---
name: unity-window-capture
description: Capture a specific Unity Editor window (including floating windows) as an image, resize it for token efficiency, and visually evaluate it. Use when asked to check, verify, or diagnose the visual state of any Unity Editor window.
allowed-tools: Bash, Read
---

# Unity Window Capture

Captures a specific Unity Editor window by OS window ID, strips the shadow, halves
the resolution, and reads the result for visual evaluation.

## Prerequisites

macOS permissions required (grant once via System Settings → Privacy & Security):
- **Accessibility** — needed to enumerate windows
- **Screen Recording** — needed for `screencapture`

## Step 1 — Find the window ID

Use Swift/CoreGraphics to list Unity windows with their sizes and positions.
Identify the target window by size/position change before and after opening it.

```bash
swift - <<'EOF'
import CoreGraphics
let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as! [[String: Any]]
for w in windows {
    guard let owner = w["kCGWindowOwnerName"] as? String, owner == "Unity" else { continue }
    let id     = w["kCGWindowNumber"] as? Int ?? -1
    let bounds = w["kCGWindowBounds"] as? [String: Any] ?? [:]
    let width  = bounds["Width"]  as? Int ?? 0
    let height = bounds["Height"] as? Int ?? 0
    let x      = bounds["X"] as? Int ?? 0
    let y      = bounds["Y"] as? Int ?? 0
    let layer  = w["kCGWindowLayer"] as? Int ?? 0
    // Filter out tiny/fullscreen elements; layer 0 = normal windows
    if layer == 0 && width > 100 && width < 2000 && height < 1200 {
        print("ID=\(id) \(width)x\(height) @(\(x),\(y))")
    }
}
EOF
```

If the target window is not yet open, open it first (e.g. via
`unity command eval` or `ExecuteMenuItem`), then re-run the listing to spot
the newly added entry.

## Step 2 — Capture and resize

```bash
WID=<window_id>
OUT=/tmp/unity_capture.png
SMALL=/tmp/unity_capture_small.png

# Capture without drop shadow (-o flag)
screencapture -l $WID -o $OUT

# Halve the resolution (saves ~75% of tokens vs full resolution)
W=$(sips -g pixelWidth $OUT | awk '{print $2}')
sips -Z $((W / 2)) $OUT --out $SMALL
```

`-o` removes the macOS window drop shadow, so no extra whitespace appears around
the window content.

## Step 3 — Evaluate

Use the Read tool on `$SMALL`. The halved resolution is sufficient for
diagnosing layout issues, waveform rendering, color problems, etc.

## Opening a Unity Editor window programmatically

When the target window is not open, open it via `unity command eval`:

```bash
# Via MenuItem (works for any registered menu item)
unity command eval --code \
  'UnityEditor.EditorApplication.ExecuteMenuItem("Window/Audio/Audio Tailor");'

# Via reflection (when the class is internal)
unity command eval --code "
var clip = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.AudioClip>(\"Assets/Foo.wav\");
var t = System.Type.GetType(\"MyNamespace.MyWindow, MyAssembly\");
t.GetMethod(\"Open\").Invoke(null, new object[] { clip });
"

# Close a window by type name
unity command eval --code "
var wins = UnityEngine.Resources.FindObjectsOfTypeAll<UnityEditor.EditorWindow>();
foreach (var w in wins) if (w.GetType().Name == \"MyWindow\") { w.Close(); break; }
"
```

## Tips

- **Identifying the right window**: Compare the window list before and after
  opening the target. The new entry is your window.
- **Docked vs floating**: Docked panels are part of the main Unity window
  (ID with large dimensions). Floating panels appear as separate entries.
- **Retina displays**: `screencapture` captures at full Retina resolution
  (2× logical pixels), so halving with `sips` still gives sharp 1× images.
- **Token cost**: Full Retina capture ≈ 300–400 KB PNG; after halving ≈ 50 KB,
  which reduces vision token usage by roughly 75%.
