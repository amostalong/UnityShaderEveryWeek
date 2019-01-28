Shader "Custom/CameraDepthEffectShader"
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
                float4 worldDirection : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _targetPos;
            float4 _MainTex_ST;
            float4x4 _CurrentInverseVP;
            float range;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                float4 clip = float4(o.vertex.xy, 0.0, 1.0);
                o.worldDirection.xyz = normalize(mul(_CurrentInverseVP, clip) - _WorldSpaceCameraPos);
                return o;
            }

            float4 GetWorldPositionFromDepthValue(float2 uv, float linearDepth, float4 dir, float eyeDepth) 
            {
                //y 是相机naer z是far w是1/far x是1或者-1
                float camPosZ = _ProjectionParams.y + (_ProjectionParams.z - _ProjectionParams.y) * linearDepth;

                // unity_CameraProjection._m11 = near / t，其中t是视锥体near平面的高度的一半。
                // 投影矩阵的推导见：http://www.songho.ca/opengl/gl_projectionmatrix.html。
                // 这里求的height和width是坐标点所在的视锥体截面（与摄像机方向垂直）的高和宽，并且
                // 假设相机投影区域的宽高比和屏幕一致。
                float height = 2 * camPosZ / unity_CameraProjection._m11;
                float width = _ScreenParams.x / _ScreenParams.y * height;

                float camPosX = width * uv.x - width / 2;
                float camPosY = height * uv.y - height / 2;
                float4 camPos = float4(camPosX, camPosY, camPosZ, 1.0);

                //return eyeDepth * dir + camPos;
                return mul(unity_CameraToWorld, camPos);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float z = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv));
                float d1 = Linear01Depth(z);
                float d = LinearEyeDepth(z);
                //后处理时uv直接就是ndc坐标(从0 - 1,映射到-1 - 1)
                //float4 ndc = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, z, 1);
                //float4 v = mul(unity_CameraInvProjection, ndc); 
                //float4 w = mul(UNITY_MATRIX_I_V, v);
                //float4 W = mul(_CurrentInverseVP, ndc);
                //float3 worldPos = i.worldDirection * d + _WorldSpaceCameraPos;
                //float4 worldPos  = W / W.w;
                //float dis = length(worldPos.xyz);

                //float3 worldPos2 = worldPos.xyz / dis;
                //worldPos2 = worldPos2 * 0.5 + 0.5;

                float3 worldPos = GetWorldPositionFromDepthValue(i.uv, d1, i.worldDirection, d).xyz;
                //return float4(d1,d1,d1,1);
                //return float4(worldPos / 25 ,1);

                //return fixed4(d,d,d,1);
                worldPos.y = _targetPos.y;
                float dis = distance(worldPos.xyz, _targetPos);

                float p = step(range, dis);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                //fixed gv = dot(col.rgb, fixed3(.222,.707,.071));
                fixed gv = dot(col.rag, unity_ColorSpaceLuminance.xyz);
                fixed4 gray = fixed4(gv, gv, gv, 1);  

                fixed3 finalCol = gray * p + col * (-p + 1);

                //return fixed4(dis / 2, 0,0 ,1);
                return fixed4(finalCol.rgb, 1);
            }
            ENDCG
        }
    }
}
