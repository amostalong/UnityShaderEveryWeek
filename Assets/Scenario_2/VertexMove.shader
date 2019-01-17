Shader "USE/VertexMove"
{
	Properties
	{
		_heightCutoff("Height Cutoff", float) = 1.2
		_heightFactor("Height Factor", float) = 1
		_RampTex("Ramp", 2D) = "white" {}
		_Color("Color", Color) = (1, 1, 1, 1)
		WorldSize("World Size", vector) = (1, 1, 1, 1)
		_WindSpeed("Wind Speed", vector) = (1, 1, 1, 1)
		_WindTex("Wind Texture", 2D) = "white" {}
		_WaveAmp("Wave Amp", float) = 1.0
		_WaveSpeed("Wave Speed", float) = 1.0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase 
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				//float2 uv : TEXCOORD0;
				float3 normal : NORMAL;

			};

			struct v2f
			{
				//UNITY_FOG_COORDS(0);
				//float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 vertex : SV_POSITION;
				float4 sp : TEXCOORD0; // test sample position
			};

			sampler2D _RampTex;
			sampler2D _WindTex;

			float _heightCutoff;
			float _heightFactor;
			float _offsetFactor;
			fixed4 _Color;
			float4 WorldSize;
			float4 _WindSpeed;
			float _WaveSpeed;
			float _WaveAmp;

			v2f vert (appdata v)
			{
				v2f o;
				//o.vertex = UnityObjectToClipPos(v.vertex);

				//o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject)).xyz;
				o.normal = UnityObjectToWorldNormal(v.normal);
				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float2 samplePos = worldPos.xz / WorldSize.xz;
				samplePos += _Time.x * _WindSpeed.xy;
				float windSample = tex2Dlod(_WindTex, float4(samplePos, 0, 0));

				//o.sp = float4(windSample,0,0,0); // test sample position
				float heightFactor = v.vertex.y > _heightCutoff;
				heightFactor = heightFactor * pow(v.vertex.y, _heightFactor);

				v.vertex.x += sin(_WaveSpeed * windSample) * _WaveAmp * heightFactor;
				v.vertex.z += cos(_WaveSpeed * windSample) * _WaveAmp * heightFactor;
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//return float4(frac(i.sp.x), 0, 0, 1); // test sample position
				// sample the texture
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float ramp = clamp(dot(i.normal, lightDir), 0.001, 1);
				ramp = ramp / 2;
				float3 lighting = tex2D(_RampTex, float2(ramp, 0.5)).rgb;
				float3 rgb = _LightColor0.rgb * lighting * _Color.rgb;
				return float4(rgb, 1.0);
			}
			ENDCG
		}

		Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                //V2F_SHADOW_CASTER;
				float4 pos : SV_POSITION;
                float3 vec : TEXCOORD0;
            };

			sampler2D _RampTex;
			sampler2D _WindTex;

			float _heightCutoff;
			float _heightFactor;
			float _offsetFactor;
			fixed4 _Color;
			float4 WorldSize;
			float4 _WindSpeed;
			float _WaveSpeed;
			float _WaveAmp;

            v2f vert(appdata_base v)
            {
                v2f o;

 

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				float2 samplePos = worldPos.xz / WorldSize.xz;
				samplePos += _Time.x * _WindSpeed.xy;
				float windSample = tex2Dlod(_WindTex, float4(samplePos, 0, 0));
				//o.sp = float4(windSample,0,0,0); // test sample position
				float heightFactor = v.vertex.y > _heightCutoff;
				heightFactor = heightFactor * pow(v.vertex.y, _heightFactor);
				v.vertex.x += sin(_WaveSpeed * windSample) * _WaveAmp * heightFactor;
				v.vertex.z += cos(_WaveSpeed * windSample) * _WaveAmp * heightFactor;
				
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

	}

			Fallback"Diffuse"
}
