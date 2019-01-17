Shader "Custom/Ice_npb"
{
	Properties
	{
		_RampTex ("Ramp Texture", 2D) = "White"{}
		_DistortMul("Distort Mul", float) = 1.0
		_BumpTex("Bump Texture", 2D) = "white"{}
		_EdgeThickness("Silouette Dropoff Rate", float) = 1.0
		_AlphaMul("Base Alpha Mu", float) = 1.0
		_EdgeAdd("Edge Color Additivie", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		Cull Back
        GrabPass
        {
            "_GrabTexture"
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
				float4 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 grabPos : TEXCOORD0;
				float4 texcoord : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			sampler2D _GrabTexture;
			sampler2D _BumpTex;
			sampler2D _RampTex;

			float _DistortMul;
			float4 _MainTex_ST;
			float _EdgeThickness;
			float _AlphaMul;
			float _EdgeAdd;

			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.grabPos = ComputeGrabScreenPos(o.pos);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.texcoord = v.texcoord;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 bump = tex2Dlod(_BumpTex, float4(i.texcoord.xy, 0, 0)).rgb;
				i.grabPos.x += bump.r * _DistortMul;
				i.grabPos.y += bump.g * _DistortMul;
				float3 grabColor = tex2Dproj(_GrabTexture, i.grabPos).rgb;

				float edgeFactor = abs(dot(i.viewDir, i.normal));
				float oneMinusEdge = 1.0 - edgeFactor;
				float3 edgeColor = tex2D(_RampTex, float2(oneMinusEdge, 0.5)).rgb * _EdgeAdd;

				float opacity = min(1.0, _AlphaMul / edgeFactor);
				opacity = pow(opacity, _EdgeThickness);

				float3 finalColor = grabColor * (1-opacity) + edgeColor * opacity;
				return float4(finalColor, 1);
			}
			ENDCG
		}
	}
}
