Shader "Custom/wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", float) = 1
        _Wavelength("Wave Length", float) = 1
        _Amplitude("Amplitude", float) = 1
        _Direction("Directin", vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _Wavelength;
            float _Amplitude;
            float4 _Direction;



            float CalculateWaveYCir(float3 worldPos)
            {
                float frequency = 2 / _Wavelength;
                float ddir = sqrt(dot(worldPos.xz, worldPos.xz)) * frequency;
                float t = _Time.y * _Speed;
                float h = sin(ddir + t);
                float y = h * _Amplitude;
                return y;
            }

            float CalculateWaveYDir(float3 worldPos)
            {
                float frequency = 2 / _Wavelength;
                float ddir = dot(_Direction.xy, worldPos.xz) * frequency;
                float t = _Time.y * _Speed;
                float h = sin(ddir + t);
                float y = h * _Amplitude;
                return y;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.vertex.y += CalculateWaveYDir(worldPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
