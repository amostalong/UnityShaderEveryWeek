Shader "USE/snow_effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _CameraDepthNormalsTexture;
			float4 _MainTex_ST;
			float4x4 _CamToWorld;

			sampler2D _SnowTex;
			float _SnowTexScale;

			half4 _SnowColor;

			fixed _BottomThreshold;
			fixed _TopThreshold;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//camera space normal
				half3 c_normal;
				//world space normal
				half3 w_normal;
				//depth from camera
				float _depth;

				//decode 16bit & 16bit data
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), _depth, c_normal);
				w_normal = mul((float3x3)_CamToWorld, c_normal);

				half snowAmount = w_normal.g;
				half scale = (_BottomThreshold + 1 - _TopThreshold) / 1 + 1;
				snowAmount = saturate((snowAmount - _BottomThreshold) * scale);
			}
			ENDCG
		}
	}
}
