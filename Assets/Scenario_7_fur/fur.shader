Shader "Custom/Fur"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Shininess ("Shininess", Range(0.01, 256.0)) = 8.0
        
        _MainTex ("Texture", 2D) = "white" { }
        _FurTex ("Fur Pattern", 2D) = "white" { }
        
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.5
        _FurDensity ("Fur Density", Range(0, 2)) = 0.11
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 1
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.25

        _ForceGlobal ("Force Global", Vector) = (0, 0, 0, 0)
        _FurDir ("Fur Dir", Vector) = (0, 0, 0, 0)
        
        _RimColor ("Rim Color", Color) = (0, 0, 0, 1)
        _RimPower ("Rim Power", Range(0.0, 8.0)) = 6.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "IgnoreProjector" = "True" "Queue" = "Transparent" }
        Cull Off
        ZWrite On
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.0
            #include "furfunc.cginc"
            #pragma vertex vert_base
            #pragma fragment frag_base
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.05
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.10
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.2
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.3
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.4
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.5
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.6
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.7
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.7
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.8
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 0.9
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
        Pass
        {
            CGPROGRAM
            #define FURSTEP 1
            #include "furfunc.cginc"
            #pragma vertex vert_layers
            #pragma fragment frag_layers
            ENDCG
        }
    }
}
