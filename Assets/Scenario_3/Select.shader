Shader "Custom/Select"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};
			sampler2D _MainTex;
			float4 _MainTex_ST;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;

			}

			fixed4 frag (v2f i) : SV_Target
			{	
				fixed4 col;
				col.xyz = tex2D(_MainTex, i.uv).xyz;
				col.z = 1;
				return col;
			}
			ENDCG
		}
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
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD1;
				float linearDepth : TEXCOORD2;
			};

			sampler2D _MainTex;
			uniform sampler2D_float _CameraDepthTexture;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				o.screenPos = ComputeScreenPos(o.vertex);
				o.linearDepth.x = -(UnityObjectToViewPos(v.vertex).z * _ProjectionParams.w);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// decode depth texture info
				// normalized screen-space pos
				float2 screen_uv = i.screenPos.xy / i.screenPos.w;
				float camDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screen_uv).r;
				// converts z buffer value to depth value from 0..1
				camDepth = Linear01Depth(camDepth);

				float offset = i.linearDepth.x - camDepth;//如果camDepth小于linearDepth说明，物体不可见； 这个时候offset> 0
				float diff = 1 - step(0.0001, offset);
				fixed4 col = fixed4(0,0,0,1);
				// sample the texture
				col.rgb = tex2D(_MainTex, i.uv).rgb * diff;
				// apply fog
				//offset = offset * 100000;
				return col;
			}
			ENDCG
		}
	}
}
