---
name: unity-shader-graph
description: Use when creating or editing Unity Shader Graph assets programmatically (Unity 6.5+) — authoring custom nodes from HLSL via the Shader Function Reflection API, generating .shadergraph files, or wiring nodes by editing the graph JSON.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# Unity Shader Graph — Programmatic Authoring (Unity 6.5+)

Requires Unity 6.5 (6000.5) / Shader Graph 17.5+ and a connected editor with the
Pipeline package (see unity-cli-pipeline skill).

**Recommended division of labor:** write shader logic as HLSL functions exposed
via the Shader Function Reflection API, and keep the graph itself thin (a few
reflected nodes wired to the Master Stack). HLSL is robust to author; graph JSON
is fragile.

---

## 1. Custom nodes from HLSL (Shader Function Reflection API)

An `.hlsl` file anywhere under `Assets/` becomes a Shader Graph node
automatically on import:

```hlsl
#include "ShaderApiReflectionSupport.hlsl"

///<funchints>
///     <sg:ProviderKey>MyNodeKey</sg:ProviderKey>
///     <sg:DisplayName>My Node</sg:DisplayName>
///     <sg:SearchCategory>Custom/Test</sg:SearchCategory>
///     <sg:ReturnDisplayName>Color</sg:ReturnDisplayName>
///</funchints>
///<paramhints name = "tint">
///     <sg:Color/>
///     <sg:Default>1,0.5,0.2</sg:Default>
///</paramhints>
///<paramhints name = "amount">
///     <sg:Range>0, 1</sg:Range>
///     <sg:Default>0.5</sg:Default>
///</paramhints>
UNITY_EXPORT_REFLECTION
float3 MyNode(float2 uv, float3 tint, float amount, out float mask)
{
    // function body; `out` params become extra output ports
    mask = amount;
    return tint;
}
```

- `<sg:ProviderKey>` is mandatory — it is the stable join key between the graph
  and the HLSL asset (survives signature changes).
- Hint lines must start with `///`; `paramhints name` must match the HLSL
  parameter identifier exactly.
- Other hints: `sg:SearchName`, `sg:SearchTerms`, `sg:Dropdown` (int param),
  `sg:DynamicVector`, `sg:Literal`, `sg:Local`/`sg:Static` (hide port),
  `sg:Referable`, `sg:Linkage`, `sg:DynamicPrecision`.

### Verify the import

```bash
unity command eval --code "UnityEditor.AssetDatabase.ImportAsset(\"Assets/MyNode.hlsl\", UnityEditor.ImportAssetOptions.ForceUpdate); var objs = UnityEditor.AssetDatabase.LoadAllAssetsAtPath(\"Assets/MyNode.hlsl\"); var names = new System.Collections.Generic.List<string>(); foreach (var o in objs) names.Add(o.GetType().Name); return string.Join(\", \", names) + \" | guid: \" + UnityEditor.AssetDatabase.AssetPathToGUID(\"Assets/MyNode.hlsl\");"
```

Success = the sub-assets include `ShaderIncludeReflection`. Record the GUID —
it is needed to wire the node into a graph. Dumping the `ShaderIncludeReflection`
object with a `SerializedObject` iterator shows the parsed parameters and
directions if a hint seems ignored.

---

## 2. Create a graph asset

Use the Editor menu via the pipeline (works unfocused; no rename prompt):

```bash
unity command menu --path "Assets/Create/Shader Graph/URP/Lit Shader Graph"
```

- Created with the default name (`New Shader Graph.shadergraph`) in the folder
  currently selected in the Project window (`Assets/` root when nothing is
  selected). Use `set_selection` first, or rename/move afterwards:

```bash
unity command rename_asset --asset "Assets/New Shader Graph.shadergraph" --new_name "MyGraph"
```

- List available variants with
  `unity command menu --format json | jq ... | grep "Shader Graph"`
  (URP Lit/Unlit/Decal/Fullscreen/Sprite/..., Blank, Sub Graph).

---

## 3. The .shadergraph format

A `.shadergraph` file is **multiple pretty-printed JSON documents separated by
blank lines**. Parse/serialize with:

```python
docs = [json.loads(c) for c in raw.split("\n\n") if c.strip()]
raw = "\n\n".join(json.dumps(d, indent=4) for d in docs) + "\n"
```

- Doc 0 is `GraphData`: `m_Properties` (blackboard), `m_Nodes`, `m_Edges`,
  `m_ActiveTargets`. Everything else is a flat pool of objects referenced by
  `{"m_Id": "<32-hex GUID>"}` ↔ `m_ObjectId`. New object IDs: `uuid4().hex`.
- Master Stack = `BlockNode`s named `VertexDescription.*` /
  `SurfaceDescription.*`; their input slot id is `0`.
- Edges:

```json
{"m_OutputSlot": {"m_Node": {"m_Id": "<node>"}, "m_SlotId": 0},
 "m_InputSlot":  {"m_Node": {"m_Id": "<node>"}, "m_SlotId": 2}}
```

### Reflected nodes in the graph (ProviderNode)

A reflected function appears as `UnityEditor.ShaderGraph.ProviderSystem.ProviderNode`
linked to the HLSL by managed reference:

```json
"m_provider": {"rid": 1000},
"references": {"version": 2, "RefIds": [{"rid": 1000,
    "type": {"class": "ReflectedFunctionProvider",
             "ns": "UnityEditor.ShaderGraph.ProviderSystem",
             "asm": "Unity.ShaderGraph.Editor"},
    "data": {"m_providerKey": "<ProviderKey>",
             "m_sourceAssetId": "<hlsl asset GUID>"}}]}
```

**Slot id convention:** return value = slot `0`, parameters = slots `1..N` in
declaration order (both `in` and `out`). Slot objects live as separate docs
(`m_Id` = integer slot id, `m_SlotType` 0 = input / 1 = output,
`m_ShaderOutputName` = HLSL parameter name; the return slot uses
`"__UNITY_SHADERGRAPH_UNUSED"`).

| HLSL hint | Slot type |
|---|---|
| (float3/float4 + `sg:Color`) | `ColorRGBMaterialSlot` |
| `sg:Range` | `Vector1MaterialRangeSlot` (`m_sliderRange`, `m_SliderType`, `m_SliderPower`) |
| `sg:Dropdown` | `Vector1MaterialEnumSlot` |
| plain floatN | `VectorNMaterialSlot` (`Vector1..4MaterialSlot`) |

The easiest way to build node/slot docs is to clone them from a graph where the
node was placed once by hand (or from a previously generated graph) and remap
the GUIDs.

---

## 4. Verify after editing

Always reimport and check for errors after touching a `.shadergraph`:

```bash
unity command eval --timeout 30000 --code "var p = \"Assets/MyGraph.shadergraph\"; UnityEditor.AssetDatabase.ImportAsset(p, UnityEditor.ImportAssetOptions.ForceUpdate); var s = UnityEditor.AssetDatabase.LoadAssetAtPath<UnityEngine.Shader>(p); return s == null ? \"FAIL\" : \"hasError: \" + UnityEditor.ShaderUtil.ShaderHasError(s);"
```

For a visual check: create a `Material` from the shader, assign it to a quad in
front of `Camera.main`, then `unity command screenshot --view game` and Read the
PNG.

**Gotcha:** in a dark scene a `BaseColor`-only wiring renders black. Wire the
debug output to `SurfaceDescription.Emission` too when visually verifying.

## Known limitations (as of 6.5)

- Reference types (auto UV/Position binding), dual precision, and parts of
  dynamic vectors are not implemented yet in the Reflection API.
- Matrix defaults are always Identity; `vector<float,4>` ≠ `float4` for type
  matching.
- The `.shadergraph` format is internal and version-dependent (`m_SGVersion`);
  prefer minimal, template-based edits over free-form generation.
