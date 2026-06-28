---
name: unity-shader-style
description: Shader coding style for Unity projects. Use when writing or editing Unity shader (.shader, .hlsl) files.
---

# Unity Shader Coding Style

A style guide for writing Unity shaders. Follow these rules so that new shaders
read like the existing code.

## File structure

A `.shader` file is organized in this order:

```
Shader "ShaderName"
{
    Properties
    {
        // Property list
    }

HLSLINCLUDE

// shared vertex/fragment shader code

ENDHLSL

    SubShader
    {
        // SubShader tags

        Pass
        {
            Name "PassName"
            // Pass tags
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }

        // Subsequent passes
    }
}
```

- Place `HLSLINCLUDE` … `ENDHLSL` at the file level between `Properties` and
  `SubShader`. All shared code (vertex shader, fragment shaders) lives there.
- 4-space indentation, Allman braces for blocks.

## Vertex shader

- Name: `Vert` + PascalCase description — `VertCommon`, `VertBlit`.
- When using custom input/output, define them as function arguments with
  semantics:
  ```hlsl
  void Vert(float4 position : POSITION,
            float2 texCoord : TEXCOORD0,
            out float4 outPosition : SV_Position,
            out float2 outTexCoord : TEXCOORD0)
  ```
- When a system-defined struct is required, use it directly:
  ```hlsl
  Varyings Vert(Attributes attrib)
  ```

## Fragment shaders

- Name: `Frag` + PascalCase description — `FragCommon`, `FragBlit`.
- When using custom input, define them as function arguments with semantics.
  Use a `float4` return value annotated with `: SV_Target`:
  ```hlsl
  float4 Frag(float4 position : SV_Position,
              float2 texCoord : TEXCOORD0) : SV_Target
  ```
- For MRT passes use `void` return with `out float4 targetN : SV_TargetN`
  parameters.
  ```hlsl
  void Frag(float4 position : SV_Position,
            float2 texCoord : TEXCOORD0,
            out float4 target0 : SV_Target0,
            out float4 target1 : SV_Target1,
            out float4 target2 : SV_Target2)
  ```

## SubShader

- Each `Pass` has a `Name` in PascalCase:
  ```hlsl
  Pass
  {
      Name "DownsamplePass"
      HLSLPROGRAM
      #pragma vertex VertCommon
      #pragma fragment FragDownsample
      ENDHLSL
  }
  ```
- Keep `HLSLPROGRAM` … `ENDHLSL` blocks inside passes to just the two `#pragma`
  lines; all actual code lives in `HLSLINCLUDE`.
