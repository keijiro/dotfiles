---
name: unity-game-view-capture
description: Capture the Unity Editor Game View rendering to a PNG via ScreenCapture.CaptureScreenshot over the Pipeline CLI, then resize for token-efficient visual analysis. Use when asked to screenshot, check, or verify the Game View render of a connected Unity Editor.
allowed-tools: Bash, Read, Agent
---

# Unity Game View Capture

Captures the connected Unity Editor's Game View to a PNG using
`UnityEngine.ScreenCapture.CaptureScreenshot` via the `unity command eval` CLI.

**Delegate the capture + evaluation to a fork agent** so image data and tool
noise stay out of the main conversation.

## Capture

`ScreenCapture.CaptureScreenshot` writes on the **next real render event**, and in
edit mode that only happens when the **Game View is open and focused**. So:

1. Open + focus the Game View:
   ```
   UnityEditor.EditorApplication.ExecuteMenuItem("Window/General/Game");
   ```
   then find the `GameView` `EditorWindow` and call `Focus()` on it.
2. Call `UnityEngine.ScreenCapture.CaptureScreenshot("<absolute path>.png");`
3. Trigger a render: `Repaint()` the Game View and/or
   `UnityEditor.EditorApplication.QueuePlayerLoopUpdate();`.
4. Poll (`ls -l`) for the PNG to appear with non-zero size, re-triggering repaint
   a few times if needed.

`eval` needs method-body syntax — `return` and a trailing `;` are required.
The output size is the live Game View panel resolution, not a fixed dimension.

## Resize (do this before analyzing)

Halve the image with macOS `sips` — no extra tools needed:

```bash
W=$(sips -g pixelWidth capture.png | awk '/pixelWidth/{print $2}')
sips -Z $((W/2)) capture.png --out capture_small.png
```

`-Z` fits the longest side to the given value while preserving aspect ratio.

## Analyze

**For visual analysis, always Read the half-size `_small.png`, not the full
capture** — it cuts image tokens ~75% with no loss of legibility. Only fall back
to the full-size image if fine detail is genuinely unreadable at half size.
