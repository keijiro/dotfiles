---
name: unity-csharp-style
description: C# coding style for Unity projects. Use when writing or editing C# (.cs) files in a Unity project.
---

# Unity C# Coding Style

A style guide for writing C# in Unity projects. Follow these rules so that new code
reads like the existing code.

## File & namespace structure

- Every file: `using` directives → blank line → `namespace X {` → blank line →
  type(s) → blank line → `} // namespace X`.
- The namespace body is **not** indented (the namespace brace is "flat"). Close it
  with a trailing comment: `} // namespace MyEffect`.
- Editor-only types may use a `.Editor` sub-namespace.
- 4-space indentation, no tabs. Allman braces (opening brace on its own line) for
  types and multi-line methods.

## `using` directives and aliases

- List specific namespaces; rely on aliases to disambiguate or shorten:
  ```csharp
  using ShaderIDs = MyEffect.ShaderPropertyIDs;
  using GraphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat;
  ```

## Types

- Mark concrete classes `sealed`. Use `partial` to split a large controller across
  several focused files (see "Partial split").
- Prefer expression-bodied members for one-liners — methods, properties, even
  `Create()`/`OnDisable()`:
  ```csharp
  void OnDisable() => OnDestroy();
  public override void Create() => _pass = new MyPass { renderPassEvent = _passEvent };
  ```

## Fields & properties

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
- A shader referenced by the component is a hidden serialized field:
  ```csharp
  [SerializeField, HideInInspector] Shader _shader = null;
  ```
- Group related members with a plain comment header, not `#region`:
  ```csharp
  // Public properties

  // MonoBehaviour implementation

  // Private members
  ```

## Partial split (controllers)

When a controller grows, split it by concern into separate files, each declaring
`public sealed partial class XController`:
- `XController.cs` — MonoBehaviour lifecycle (`Update`, `OnDisable`, `OnDestroy`).
- `XControllerProperties.cs` — the serialized `[field:SerializeField]` properties.
- `XControllerRender.cs` / `...Bindings.cs` — material/buffer handling, shader IDs.
- `...Upgrader.cs` — editor-only migration helpers.

## Statements

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

## Math

- For matrix/vector-heavy logic use `Unity.Mathematics` (`float3x3`, `float4x4`,
  `math.mul`, `math.radians`) rather than `UnityEngine` types.

## Editor (Inspector) conventions

Apply this only when writing a custom inspector.

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
