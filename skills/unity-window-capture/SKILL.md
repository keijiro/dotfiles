---
name: unity-window-capture
description: Capture a specific Unity Editor window (including floating windows) as an image, resize it for token efficiency, and visually evaluate it. Use when asked to check, verify, or diagnose the visual state of any Unity Editor window.
allowed-tools: Bash, Read, Agent
---

# Unity Window Capture

Captures a specific Unity Editor window by OS window ID, strips the shadow, halves
the resolution, and reads the result for visual evaluation.

**Always delegate the capture + evaluation to a fork agent** so that the image
data and tool noise never land in the main conversation context. Only the fork's
text summary is returned.

## How to invoke (as the parent)

```
Agent(
  subagent_type: "fork",
  description: "Capture and evaluate Unity window",
  prompt: "Capture the Unity Editor window titled 'Audio Tailor' and check
           whether the waveform is rendered correctly (green bars filling the
           waveform area, no blank region). Save captures to <scratchpad_path>.
           Follow the unity-window-capture skill instructions for the capture
           steps, then report your findings in 2–3 sentences."
)
```

The fork inherits this skill's context — describe only the goal and evaluation criteria in the prompt.

## Prerequisites

macOS permissions (System Settings → Privacy & Security):
- **Accessibility** — enumerate windows
- **Screen Recording** — `screencapture`

## Step 1 — Find the window ID

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
    if layer == 0 && width > 100 && width < 2000 && height < 1200 {
        print("ID=\(id) \(width)x\(height) @(\(x),\(y))")
    }
}
EOF
```

Compare output before/after opening the target window to identify the new entry.

## Step 2 — Capture and resize

```bash
WID=<window_id>
OUT=<scratchpad_path>/unity_capture.png
SMALL=<scratchpad_path>/unity_capture_small.png

screencapture -l $WID -o $OUT
W=$(sips -g pixelWidth $OUT | awk '{print $2}')
sips -Z $((W / 2)) $OUT --out $SMALL
```

## Step 3 — Evaluate

Use the Read tool on `$SMALL`. Return a concise text summary (2–3 sentences) to the parent — do **not** include raw image data or tool output dumps.

## Opening a window programmatically

```bash
# Via MenuItem
unity command eval --code \
  'UnityEditor.EditorApplication.ExecuteMenuItem("Window/Audio/Audio Tailor");'

# Close by type name
unity command eval --code "
var wins = UnityEngine.Resources.FindObjectsOfTypeAll<UnityEditor.EditorWindow>();
foreach (var w in wins) if (w.GetType().Name == \"MyWindow\") { w.Close(); break; }
"
```

## Tips

- **Docked vs floating**: Docked panels are part of the main Unity window (large dimensions). Floating panels appear as separate entries.
- **Retina displays**: `screencapture` captures at 2× logical pixels; halving still gives sharp 1× images.
- **Token cost**: Full Retina capture ≈ 300–400 KB; after halving ≈ 50 KB (~75% reduction).
- **Fork rule**: The parent must never call Read on the captured image directly.
