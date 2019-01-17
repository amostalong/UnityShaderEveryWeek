Shader "Custom/SelectBloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Radius ("Radius", float) = 3
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _GlowMap;
			float4 _GlowMap_TexelSize;
            float _Radius;

			float4 gaussianBlur(sampler2D tex, float2 dir, float2 uv, float res)
            {
				float4 sum = { 0,0,0,0};
				float blur = _Radius / res;
				
				float hstep = dir.x;
				float vstep = dir.y;

                sum += tex2Dlod(tex, float4(uv.x - 4*blur*hstep, uv.y - 4.0*blur*vstep, 0, 0)) * 0.0162162162;
                sum += tex2Dlod(tex, float4(uv.x - 3.0*blur*hstep, uv.y - 3.0*blur*vstep, 0, 0)) * 0.0540540541;
                sum += tex2Dlod(tex, float4(uv.x - 2.0*blur*hstep, uv.y - 2.0*blur*vstep, 0, 0)) * 0.1216216216;
                sum += tex2Dlod(tex, float4(uv.x - 1.0*blur*hstep, uv.y - 1.0*blur*vstep, 0, 0)) * 0.1945945946;
                
                sum += tex2Dlod(tex, float4(uv.x, uv.y, 0, 0)) * 0.2270270270;
                
                sum += tex2Dlod(tex, float4(uv.x + 1.0*blur*hstep, uv.y + 1.0*blur*vstep, 0, 0)) * 0.1945945946;
                sum += tex2Dlod(tex, float4(uv.x + 2.0*blur*hstep, uv.y + 2.0*blur*vstep, 0, 0)) * 0.1216216216;
                sum += tex2Dlod(tex, float4(uv.x + 3.0*blur*hstep, uv.y + 3.0*blur*vstep, 0, 0)) * 0.0540540541;
                sum += tex2Dlod(tex, float4(uv.x + 4.0*blur*hstep, uv.y + 4.0*blur*vstep, 0, 0)) * 0.0162162162;

				return float4(sum.rgb, 1.0);
			}
			
			fixed4 frag (v2f_img input) : SV_Target
			{
				float resX = _GlowMap_TexelSize.z;
				float resY = _GlowMap_TexelSize.w;

				float4 blurX = gaussianBlur(_GlowMap, float2(1,0), input.uv, resX);
                float4 blurY = gaussianBlur(_GlowMap, float2(0,1), input.uv, resY);
				float4 bloom = blurX + blurY;

				// sample the texture
				fixed4 col = tex2D(_MainTex, input.uv);

				return bloom / 2 + col;
			}
			ENDCG
		}
	}
}
