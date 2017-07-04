" Vim syntax file
" Language:	UnityShader
" Maintainer:	ChangJie.Qiu <qiuchangjie@foxmail.com>
" Last Change:	2015-06-27
" Filenames:	*.shader
"

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Read the HLSL syntax to start with
if version < 600
  so <sfile>:p:h/cg.vim
else
  runtime! syntax/hlsl.vim
  unlet b:current_syntax
endif

syn keyword shaderType fixed
syn keyword shaderType fixed2
syn keyword shaderType fixed3
syn keyword shaderType fixed4
syn keyword shaderType half
syn keyword shaderType half2
syn keyword shaderType half3
syn keyword shaderType half4
syn keyword shaderType SurfaceOutput
syn keyword shaderType bool
syn keyword shaderType samplerCUBE
syn keyword shaderType sampler2D
syn keyword shaderType sampler3D
syn keyword shaderType void
syn keyword shaderType 2D
syn keyword shaderType 2DArray
syn keyword shaderType Color
syn keyword shaderType struct
syn keyword shaderType Float

syn keyword shaderStatement Shader
syn keyword shaderStatement Category
syn keyword shaderStatement Properties
syn keyword shaderStatement SubShader
syn keyword shaderStatement Pass
syn keyword shaderStatement Tags
syn keyword shaderStatement LOD
syn keyword shaderStatement Fallback
syn keyword shaderStatement Material
syn keyword shaderStatement Lighting
syn keyword shaderStatement Cull
syn keyword shaderStatement ZTest
syn keyword shaderStatement ZWrite
syn keyword shaderStatement Fog
syn keyword shaderStatement AlphaTest
syn keyword shaderStatement BindChannels
syn keyword shaderStatement Blend
syn keyword shaderStatement ColorMask
syn keyword shaderStatement Offset
syn keyword shaderStatement SeparateSpecular
syn keyword shaderStatement ColorMaterial
syn keyword shaderStatement UsePass

syn keyword shaderFunction length
syn keyword shaderFunction cross
syn keyword shaderFunction pow
syn keyword shaderFunction tex2D
syn keyword shaderFunction UnpackNormal
syn keyword shaderFunction saturate
syn keyword shaderFunction dot
syn keyword shaderFunction normalize
syn keyword shaderFunction clip
syn keyword shaderFunction frac
syn keyword shaderFunction mul
syn keyword shaderFunction TRANSFORM_TEX
syn keyword shaderFunction SetTexture
syn keyword shaderFunction combine
syn keyword shaderFunction UnityPixelSnap

syn keyword shaderCGProgram CGPROGRAM
syn keyword shaderCGProgram CGINCLUDE
syn keyword shaderCGProgram HLSLPROGRAM
syn keyword shaderCGProgram ENDCG

hi def link shaderType          Type
hi def link shaderStatement     Statement
hi def link shaderFunction      Keyword
hi def link shaderCGProgram     PreCondit

let b:current_syntax = "shaderlab"
