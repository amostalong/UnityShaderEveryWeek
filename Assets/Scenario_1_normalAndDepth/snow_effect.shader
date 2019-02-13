Shader "USE/snow_effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		//Cull Off ZWrite Off ZTest Always

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
			sampler2D _CameraDepthNormalsTexture;
			sampler2D _CameraDepthTexture;
			float4 _MainTex_ST;
			float4x4 _CamToWorld;
			float4x4 _ProjectToCam;

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
			
			half4 frag (v2f i) : SV_Target
			{
				//camera space normal
				half3 normal;
			
				//depth from camera
				float _depth;

				//decode 16bit & 16bit data
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.uv), _depth, normal);

				float _d = Linear01Depth(_depth);

				normal = mul((float3x3)_CamToWorld, normal);



				half snowAmount = normal.g;
				half scale = (_BottomThreshold + 1 - _TopThreshold) / 1 + 1;
				snowAmount = saturate((snowAmount - _BottomThreshold) * scale);
                snowAmount = clamp(snowAmount,0,0.8);
//				float2 p11_22 = float2(unity_CameraProjection._11, unity_CameraProjection._22);
//				float3 vpos = float3( (i.uv * 2 - 1) / p11_22, -1) * _depth;
//				float4 wpos = mul(_CamToWorld, float4(vpos, 1));
//				float _d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
//				float _d01 = Linear01Depth(_d);
				float4 h = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, _d * 2 -1, 1);
				float4 d = mul(_ProjectToCam, h);
				float4 wpos = d / d.w; 


		
				half3 snowColor = tex2D(_SnowTex, wpos.xz * _SnowTexScale * _ProjectionParams.z) * _SnowColor;
//			 
//				// get color and lerp to snow texture
				half4 col = tex2D(_MainTex, i.uv);
				return half4(lerp(col, fixed3(snowColor.xyz),snowAmount),1);
			}
			ENDCG
		}
	}
}
