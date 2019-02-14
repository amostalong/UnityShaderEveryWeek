// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", float) = 1
        _Wavelength("Wave Length", vector) = (0.3,0.5,0.7,0.9)
        _Amplitude("Amplitude", vector) = (1,0.5,0.3,0.1)
        _Direction1("Direction1", vector) = (1,1,1,1)
        _Direction2("Direction2", vector) = (1,1,1,1)
        _Steepness("Steepness", vector) = (0.8,0.6,0.4,0.2)
    }
    SubShader
    {
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
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
            float4 _Wavelength;
            float4 _Amplitude;
            float4 _Direction1;
            float4 _Direction2;
            float4 _Steepness;

            float CalculateWaveYCir(float3 worldPos)
            {
                float frequency = 2 / _Wavelength;
                float ddir = sqrt(dot(worldPos.xz, worldPos.xz)) * frequency;
                float t = _Time.y * _Speed;
                float h = sin(ddir + t);
                float y = h * _Amplitude;
                return y;
            }

            //四个sin波叠加
            float CalculateWaveYDir(float3 worldPos)
            {
                float4 frequency = 2 / _Wavelength;
                float4 ddir = float4(dot(_Direction1.xy, worldPos.xz), dot(_Direction1.zw, worldPos.xz), dot(_Direction2.xy, worldPos.xz), dot(_Direction2.zw, worldPos.xz))  * frequency;
                float4 t = _Time.yyyy * _Speed;
                float4 Sin = sin(ddir + t);
                float y = dot(Sin, _Amplitude);
                return y;
            }

            //GerstnerWave
            //QA * Dx * cos (dot(wd,xy) + t)
            //QA * Dy * cos (dot(wd,xy) + t)
            //A * sin(dot(wd,xy) + t)
            float3 GerstnerWave(float3 worldPos)
            {
                float4 QA1 = _Steepness.xxyy * _Amplitude.xxyy * _Direction1.xyzw;
                float4 QA2 = _Steepness.zzww * _Amplitude.zzww * _Direction2.xyzw;
                float4 frequency = 2 * 3.14 / _Wavelength;
                float4 ddir = float4(dot(_Direction1.xy, worldPos.xz), dot(_Direction1.zw, worldPos.xz), dot(_Direction2.xy, worldPos.xz), dot(_Direction2.zw, worldPos.xz))  * frequency.xyzw;
                half4 TIME = _Time.yyyy * _Speed;

                /*
                float x1 = cos(ddir.x + TIME.x) * _Steepness.x * _Amplitude.x * _Direction1.x;
                float x2 = cos(ddir.y + TIME.y) * QA1.z;
                float x3 = cos(ddir.z + TIME.z) * QA2.x;
                float x4 = cos(ddir.w + TIME.w) * QA2.z;
                float x = x1 + x2 + x3 + x4
                */

                float4 COS = cos(ddir + TIME);
                float4 SIN = sin(ddir + TIME);
                float x = dot(COS, float4(QA1.xz, QA2.xz));
                float y = dot(COS, float4(QA1.yw, QA2.yw));
                float z = dot(SIN, _Amplitude);

                return float3(x,z,y);

            }

            v2f vert (appdata v)
            {
                v2f o;

                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                //o.vertex.y += CalculateWaveYDir(worldPos);
                float3 disPos = GerstnerWave(worldPos).xyz;
                v.vertex.xyz = mul(unity_WorldToObject, float4(worldPos.xyz+disPos, 1));
                o.vertex = UnityObjectToClipPos(v.vertex);
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
