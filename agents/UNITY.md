# Keijiro URP Package — Coding Style Guide

A style guide for AI coding agents working in this family of Unity URP post-effect
packages (KinoFeedbackURP, MiniBokeh, StrobePages, Duotone). It captures the shared
conventions extracted from their C# and shader code. Follow these rules so that new
code is indistinguishable from the existing code.

---

## 1. Project & Package Layout

- One effect per UPM package, ID in reverse-DNS form: `jp.keijiro.<name>`.
- Standard directory layout inside the package:
  ```
  Packages/jp.keijiro.<name>/
    Runtime/   *.cs, *.asmdef, sometimes *.shader
    Shaders/   *.shader, *.hlsl   (when shaders are numerous)
    Editor/    *.cs, *.asmdef
  ```
  A small package may keep the `.shader` in `Runtime/`; a shader-heavy package gets
  a dedicated `Shaders/` folder.
- One assembly definition per folder: `<Name>.Runtime` and `<Name>.Editor`.
  Keep `rootNamespace` empty in the asmdef; namespaces are declared explicitly in
  source. Keep `allowUnsafeCode` false unless genuinely required.
- `package.json` is terse: `unity` baseline `6000.0`, URP dependency pinned
  (`com.unity.render-pipelines.universal`), license `Unlicense`, author
  "Keijiro Takahashi", and URLs pointing at the GitHub repo.

---

## 2. C# Conventions

### File & namespace structure
- Every file: `using` directives → blank line → `namespace X {` → blank line →
  type(s) → blank line → `} // namespace X`.
- The namespace body is **not** indented (the namespace brace is "flat"). Close it
  with a trailing comment: `} // namespace Duotone`.
- Namespace name matches the package feature (`Duotone`, `MiniBokeh`, `StrobePages`,
  `Kino.Feedback.Universal`). Editor-only types may use a `.Editor` sub-namespace.
- 4-space indentation, no tabs. Allman braces (opening brace on its own line) for
  types and multi-line methods.

### `using` directives and aliases
- List specific namespaces; rely on aliases to disambiguate or shorten:
  ```csharp
  using ShaderIDs = Kino.Feedback.Universal.ShaderPropertyIDs;
  using GraphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat;
  ```

### Types
- Mark concrete classes `sealed`. Use `partial` to split a large controller across
  several focused files (see §2 "Partial split").
- Prefer expression-bodied members for one-liners — methods, properties, even
  `Create()`/`OnDisable()`:
  ```csharp
  void OnDisable() => OnDestroy();
  public override void Create() => _pass = new DuotonePass { renderPassEvent = _passEvent };
  ```

### Fields & properties
- Private fields: `_camelCase` with a leading underscore.
- Public serialized state uses auto-properties with `[field:SerializeField]`:
  ```csharp
  [field:SerializeField, Range(0, 1)]
  public float HueShift { get; set; }

  [field:SerializeField]
  public float Scale { get; set; } = 1.1f;
  ```
  Assign defaults inline. Add `[Range(...)]`, `[ColorUsage(...)]` etc. inside the
  same attribute list.
- The effect's shader is a hidden serialized field:
  ```csharp
  [SerializeField, HideInInspector] Shader _shader = null;
  ```
- Group members with `#region` blocks using consistent names:
  `Public properties`, `Public members exposed for render passes`,
  `Private members`, `MonoBehaviour implementation`, `Constructor`,
  `Render pass implementation`, etc.

### Partial split (controllers)
When a controller grows, split it by concern into separate files, each declaring
`public sealed partial class XController`:
- `XController.cs` — MonoBehaviour lifecycle (`Update`, `OnDisable`, `OnDestroy`).
- `XControllerProperties.cs` — the serialized `[field:SerializeField]` properties.
- `XControllerRender.cs` / `...Bindings.cs` — material/buffer handling, shader IDs.
- `...Upgrader.cs` — editor-only migration helpers.

### Statements
- Use `var` for locals when the type is obvious.
- Use short names for short-lived locals in math-dense code (`a`, `s`, `c`, `o`,
  `desc`, `mat`, `ctrl`, `param`).
- Guard with early returns at the top of a method instead of nesting:
  ```csharp
  if (ctrl == null || !ctrl.enabled || !ctrl.IsReady) return;
  ```
- Use tuples for compact related state and swaps:
  ```csharp
  (bool init, bool capture) _flags;
  (_pageBase, _pageFlip) = (_pageFlip, _pageBase);
  ```
- Keep comments sparse and purposeful: a short section header or a "why" note, not
  narration of obvious code.

### Math
- For matrix/vector-heavy logic use `Unity.Mathematics` (`float3x3`, `float4x4`,
  `math.mul`, `math.radians`) rather than `UnityEngine` types.

---

## 3. URP Rendering Architecture

This is the load-bearing pattern; replicate it exactly.

### The trio: Controller + Feature + Pass
- **Controller** — a `MonoBehaviour` attached to the Camera. Holds user parameters
  and owns GPU resources (Material, RTHandles, MaterialPropertyBlock).
  ```csharp
  [ExecuteInEditMode]
  [RequireComponent(typeof(Camera))]
  [AddComponentMenu("Kino/Feedback Controller")]
  public sealed class FeedbackController : MonoBehaviour
  ```
- **RendererFeature** (`ScriptableRendererFeature`) — creates the pass in `Create()`,
  wires `renderPassEvent` from a `[SerializeField] RenderPassEvent` field, and
  enqueues it. Skip non-game cameras:
  ```csharp
  if (data.cameraData.cameraType != CameraType.Game) return;
  renderer.EnqueuePass(_pass);
  ```
- **Pass** (`ScriptableRenderPass`) — implements `RecordRenderGraph`. Mark it
  `sealed`; make it `internal` (no modifier) unless it must be public.

### RenderGraph pass body
- Fetch frame data and the controller, then guard:
  ```csharp
  var camera = context.Get<UniversalCameraData>().camera;
  var ctrl = camera.GetComponent<MiniBokehController>();
  if (ctrl == null || !ctrl.enabled || !ctrl.IsReady) return;

  var resource = context.Get<UniversalResourceData>();
  if (resource.isActiveTargetBackBuffer) return;          // back buffer unsupported
  ```
- Expose an `IsReady` property on the controller for the pass to check:
  ```csharp
  public bool IsReady => MaterialProperties != null && ReferencePlane != null;
  ```
- Allocate destination textures from the source descriptor with these defaults:
  ```csharp
  var desc = graph.GetTextureDesc(source);
  desc.name = "Duotone";
  desc.clearBuffer = false;
  desc.depthBufferBits = 0;
  var dest = graph.CreateTexture(desc);
  ```
- Prefer `RenderGraphUtils.BlitMaterialParameters` + `graph.AddBlitPass(...,
  passName: "...")` for simple full-screen blits. For custom passes use
  `AddRasterRenderPass<PassData>`, a nested `PassData` class, and delegate the
  render function to a `static ExecutePass`:
  ```csharp
  using var builder = graph.AddRasterRenderPass<PassData>(name, out var passData);
  // ... fill passData ...
  builder.SetRenderFunc((PassData data, RasterGraphContext ctx) => ExecutePass(data, ctx));
  ```
- Redirect output back into the pipeline with `resource.cameraColor = dest;`.
- Name every pass with the effect name and a parenthetical phase, e.g.
  `"StrobePages (Capture)"`, `"MiniBokeh Downsample"`.

### Resource ownership & lifecycle
- Create materials with `CoreUtils.CreateEngineMaterial(_shader)`, lazily on first
  use. Destroy with `CoreUtils.Destroy(_material)`.
- `OnDisable` delegates to `OnDestroy` (or a shared `ReleaseResources()`); release
  RTHandles with the null-conditional operator and null them out:
  ```csharp
  void OnDisable() => OnDestroy();
  void OnDestroy()
  {
      CoreUtils.Destroy(_material);
      _material = null;
      _buffer?.Release();
      _buffer = null;
  }
  ```
- Allocate persistent buffers with `RTHandles.Alloc(Vector3.one, format, name: "...")`.
- Push parameters to the GPU in `LateUpdate` (or a `UpdateMaterial()` method called
  by the pass), lazily creating the `MaterialPropertyBlock`/`Material` if null.
  Clamp/transform user values here, not in the shader, when cheap.

### Shader property IDs
- Cache `Shader.PropertyToID` results. Two accepted forms:
  - A `static class ShaderPropertyIDs` of `static readonly int` fields, aliased as
    `ShaderIDs` at the call site.
  - A `struct ShaderBindings` constructed from the `Shader`, also holding
    `LocalKeyword`s, when the effect uses shader keywords.
- Toggle shader variants with `_material.SetKeyword(binding, condition)` and declare
  them with `#pragma multi_compile_local` in the shader.

---

## 4. Editor (Inspector) Conventions

- `[CustomEditor(typeof(XController))]`, class `sealed`, `internal` by default; add
  `CanEditMultipleObjects` when the inspector supports it.
- Access `[field:SerializeField]` auto-property backing fields by their generated
  name: `serializedObject.FindProperty("<PropName>k__BackingField")`.
- Two accepted UI styles:
  - **UIElements** — a `[SerializeField] VisualTreeAsset _uxml;` cloned via
    `_uxml.CloneTree()` in `CreateInspectorGUI()`; wire buttons/visibility there.
  - **IMGUI** — `OnInspectorGUI` with `serializedObject.Update()` … explicit
    `EditorGUILayout.PropertyField(...)` calls … `ApplyModifiedProperties()`, using
    `EditorGUILayout.Space()` to group and conditional fields to hide irrelevant
    options.
- For repetitive IMGUI inspectors, the reflection-based `AutoProperty` helper
  (auto-binds fields named after properties) is the preferred pattern; suppress the
  unused-field warning around the block with `#pragma warning disable/restore CS0649`.
- Editor-only migration code lives behind `#if UNITY_EDITOR`, records undo, and logs
  a tagged message: `Debug.Log("[Duotone] Upgraded shader reference.", this);`.

---

## 5. Shader (.shader) Conventions

- Name hidden effect shaders `"Hidden/<Name>"`.
- Put shared HLSL in an `HLSLINCLUDE … ENDHLSL` block before `SubShader`; the
  per-pass `HLSLPROGRAM` blocks then only set `#pragma vertex/fragment` (and
  keywords). Standard includes, by full package path:
  ```hlsl
  #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
  #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
  ```
- Declare uniforms matching the C# property IDs (`float`, `float4`, `int`,
  `float4x4`). Declare textures with the `TEXTURE2D_X` family and sample with
  `SAMPLE_TEXTURE2D_X`, using `sampler_LinearClamp` / `sampler_PointClamp` (or an
  explicit `SAMPLER(...)`).
- For full-screen passes, either reuse `Blit.hlsl`'s `Vert`/`Varyings` (and call
  `UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX` in the fragment), or write a `Vert`
  using `GetFullScreenTriangleVertexPosition` / `GetFullScreenTriangleTexCoord`.
- Each `Pass` declares a `Name "..."` and explicit render state, typically
  `ZTest Always/LEqual ZWrite Off Cull Off Blend Off`. Tag the SubShader
  `Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }`.
- Use `half`/`half3`/`half4` for color/LDR work; `float` for positions, UVs, and
  accumulators.
- Declare shader variants with `#pragma multi_compile_local`, matching the
  `LocalKeyword`s set from C#.

---

## 6. HLSL Include (.hlsl) Conventions

- Wrap each file in an include guard named after the file:
  ```hlsl
  #ifndef MINIBOKEH_COMMON_INCLUDED
  #define MINIBOKEH_COMMON_INCLUDED
  ...
  #endif // MINIBOKEH_COMMON_INCLUDED
  ```
- Keep a `Common.hlsl` for shared uniforms and helper functions; split algorithm
  variants into their own includes (e.g. `HexSeparable.hlsl`,
  `CircularSeparable.hlsl`) that `#include "Common.hlsl"`.
- Group uniform declarations under short comment headers (`// DoF parameters`,
  `// Texture inputs`).
- Use `#define` for compile-time constants and small helper macros
  (`#define KERNEL_RADIUS 8`, `#define RCP_WIDTH (...)`); `static const` for lookup
  tables and weight arrays.
- In loops with a known max, bound the iteration count and use `[unroll(N)]` (or
  `[loop]` with an internal `break`) for predictable codegen:
  ```hlsl
  const int maxSamples = 8;
  int sampleCount = clamp((int)(coc * 2), 1, maxSamples);
  [unroll(8)]
  for (int i = 1; i <= maxSamples; i++) { if (i > sampleCount) continue; ... }
  ```
- Add early-out guards in expensive fragment functions (`if (coc < 0.5) return color;`).

---

## 7. Comments & Attribution

- Comments are minimal and explain intent or non-obvious math, plus first-frame /
  edge-case notes (`// First frame rejection`, `// back buffer unsupported`).
- When implementing a published algorithm, cite the source with author, title,
  venue, and DOI/URL in a comment block at the top of the relevant `.hlsl`:
  ```hlsl
  // Citation: Garcia, K. (2017). "Circular Separable Convolution Depth of Field".
  // doi:10.1145/3084363.3085022
  ```

---

## 8. Quick Checklist for New Code

- [ ] `sealed` classes; `_underscore` private fields; `[field:SerializeField]`
      auto-properties with inline defaults and `[Range]`/`[ColorUsage]`.
- [ ] Flat namespace with `} // namespace X` footer; aliased `using`s where helpful.
- [ ] Controller on Camera (`[ExecuteInEditMode]`, `[RequireComponent(typeof(Camera))]`),
      with an `IsReady` guard property.
- [ ] Feature wires `renderPassEvent` from a serialized field and skips non-game cameras.
- [ ] Pass uses RenderGraph, guards null/disabled/back-buffer, names every pass,
      writes back via `resource.cameraColor`.
- [ ] Materials via `CoreUtils.CreateEngineMaterial`/`Destroy`; RTHandles released and nulled.
- [ ] Cached `Shader.PropertyToID` (ShaderPropertyIDs class or ShaderBindings struct).
- [ ] Shader: `Hidden/...`, `HLSLINCLUDE` shared block, `TEXTURE2D_X`/`SAMPLE_TEXTURE2D_X`,
      named passes with explicit render state, `multi_compile_local` for variants.
- [ ] `.hlsl` include guards, `Common.hlsl` for shared code, cited algorithms.
