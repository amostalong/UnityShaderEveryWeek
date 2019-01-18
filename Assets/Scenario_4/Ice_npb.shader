Shader "Custom/Ice_npb"
{
	Properties
	{
		_RampTex ("Ramp Texture", 2D) = "White"{}
		_RampBump ("Ramp Bump", 2D) = "White"{}

		_BumpTex("Bump Texture", 2D) = "white"{}
		_EdgeThickness("Edge Thickness", float) = 1.0
		_AlphaMul("Base Alpha Mu", float) = 1.0
		_EdgeAdd("Edge Color Additivie", float) = 1.0
		_Opacity("Opacity", float) = 0.5
		_DistortMul("Distort Mul", float) = 1.0
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" }
		LOD 100
		Cull back
		Blend SrcAlpha OneMinusSrcAlpha
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
			sampler2D _RampBump;

			float _DistortMul;
			float4 _MainTex_ST;
			float _EdgeThickness;
			float _AlphaMul;
			float _EdgeAdd;
			float _BumpAdd;
			float _Opacity;

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

				float edgeFactor = saturate(dot(i.viewDir, i.normal));
				float oneMinusEdge = 1.0 - edgeFactor;
				float3 edgeColor = tex2D(_RampTex, float2(oneMinusEdge, 0.5));

				float edgeOpacity = pow(oneMinusEdge, _EdgeThickness);

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 normal = bump;
				float lightFactor = clamp(dot(normal, lightDir), 0.3, 1);
				float3 rampBump = tex2D(_RampBump, float2(lightFactor, 0.5));



				float3 finalGrab = grabColor * (1 - _Opacity);
				float3 finalEdge = edgeColor *  edgeOpacity * _Opacity;
				float3 viewColor = rampBump * _Opacity;

				float3 finalColor = finalGrab + finalEdge + viewColor;
				//return float4(edgeOpacity,0,0, 1);
				return float4(finalColor, 1);
			}
			ENDCG
		}
	}
}
