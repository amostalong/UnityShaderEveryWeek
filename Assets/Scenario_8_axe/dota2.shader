Shader "Custom/dota2"
{
    Properties
    {
		_MainColor("Main Color", Color) = (0.5, 0.5, 0.5, 0.5)
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
		_MainTex("Main Color Texture", 2D) = "white" {}
        _SpecularMask("Specular Mask", 2D) = "white" {}
        _SpecularExponent("Specular Exponent", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _RimMask("Rim Mask", 2D) = "White"{}
        _MetalnessMask("Metalness Mask", 2D) = "white"{}
        _TintMask("Tint Color Mask", 2D) = "white"{}
        _EmissionMask("EmissionMask", 2D) = "white"{}
        _DiffuseWarp("Diffuse Warp", 2D) = "White" {}
        _SpecularWarp("Specular Warp", 2D) = "White" {}
        _FresnelWarpRim("Fresnel Warp Rim", 2D) = "white" {}
        _Gloss ("Gloss", Range(1, 64)) = 20
        _Rim("Rim atten", Range(0, 20)) = 30
        _Fresnel("Fresnel", Float) = 0.3
        _Metalness("Metalness", Range(0,1)) = 0.5
        _SpecluarPow("Specular Power", Float) = 1

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

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
				float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;

                LIGHTING_COORDS(4,5) //自动处理光照和阴影
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _SpecularMask;
            sampler2D _DiffuseWarp;
            sampler2D _SpecularWarp;
            sampler2D _SpecularExponent;
            sampler2D _RimMask;
            sampler2D _FresnelWarpRim;
            sampler2D _MetalnessMask;
            sampler2D _TintMask;
            sampler2D _EmissionMask;

            float4 _MainTex_ST;
            float4 _SpecularMask_ST;
            float4 _MainColor;
            float4 _SpecularColor;
            float _Gloss;
            float _Rim;
            float _Fresnel;
            float _Metalness;
            float _SpecluarPow;

            inline float CalcFresnel(float VdotH, float fresnelValue)
            {
                float fresnel = pow(1.0 - VdotH, 5.0);
                fresnel += fresnelValue * (1.0 - fresnel);
                return max(0, fresnel);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _SpecularMask);

                float3 wpos = mul(unity_ObjectToWorld, v.vertex);
                fixed3 wnormal = UnityObjectToWorldNormal(v.normal); // 考虑非统一缩放时: normalize(mul(norm, (float3x3)unity_WorldToObject));
                fixed3 wtangent = UnityObjectToWorldDir(v.tangent.xyz);   //normalize(mul((float3x3)unity_ObjectToWorld, dir));
                fixed3 wbinormal = cross(wnormal, wtangent) * v.tangent.w; //tangent.w 是由于 uvz中的v在GL和DX时反的 所以w来表示这个方向是否要被反转？

                o.TtoW0 = float4(wtangent.x, wbinormal.x, wnormal.x, wpos.x);
                o.TtoW1 = float4(wtangent.y, wbinormal.y, wnormal.y, wpos.y);
                o.TtoW2 = float4(wtangent.z, wbinormal.z, wnormal.z, wpos.z);

                TRANSFER_VERTEX_TO_FRAGMENT(o); //非屏幕空间阴影：_ShadowCoord = mul( unity_WorldToShadow[0], mul( unity_ObjectToWorld, v.vertex ) );

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float atten = LIGHT_ATTENUATION(i); //shadow map 采样值, 自动用unity帮我们计算的_ShadowCoord来采样

                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);

                fixed3 tNormal = UnpackNormal(tex2D(_NormalMap, i.uv.xy));   //packednormal.xyz * 2 - 1;  

                //tNormal.z = sqrt(1.0 - saturate(dot(tNormal.xy, tNormal.xy))); //dot(A,b) => a.x*b.x + a.y*b.y + a.z*b.z + a.w*b.w

                //通过之前构造的空间列向量来计算world space下面的normal: 实际上就是mul(tangentNormal, tangentToWorld3X3Matrix)
                //展开就是就是下面直接展开去掉多余部分的结果，这样就得到了worldNormal
                fixed3 worldNormal = normalize(half3(dot(i.TtoW0.xyz, tNormal), dot(i.TtoW1.xyz, tNormal), dot(i.TtoW2.xyz, tNormal)));

                // return _WorldSpaceCameraPos.xyz - worldPos
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));

                //方向光直接返回_WorldSpaceLightPos0，否则要减速worldPos
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));

                //blinn-phong H = L + V
                float3 halfDir = normalize(lightDir + viewDir);

                float NdotL = dot(worldNormal, lightDir);
                float NdotH = dot(worldNormal, halfDir);
                float NdotV = dot(worldNormal, viewDir);
                float VdotH = dot(viewDir, halfDir);

                //float intensity = max(0, NdotL);
                float diff = (NdotL * 0.5) + 0.5;
                float3 diffIntensify = tex2D(_DiffuseWarp, diff.xx).xyz;

                // sample the texture
                fixed3 col = tex2D(_MainTex, i.uv.xy).rgb;

                float fresnel = CalcFresnel(VdotH, _Fresnel);

                //emission
                float emission = tex2D(_EmissionMask, i.uv.zw).r;

                //metalness
                float metalness = tex2D(_MetalnessMask, i.uv.zw).r; 
                float tint = tex2D(_TintMask, i.uv.zw).r;
                //高光计算
                fixed3 specularMask = tex2D(_SpecularMask, i.uv.zw).rgb;
                float specularExponent = tex2D(_SpecularExponent, i.uv.zw).r;
                float specular = _SpecluarPow * pow(max( 0, NdotH), _Gloss * specularExponent) * specularMask.r;

                //tint 决定了高光反射时 光照和贴图颜色 偏向
                float3 specularReflection = (_LightColor0.rgb * (1 - tint) + col.rgb * tint) * specular;

                //rim
                float rimPower = tex2D(_RimMask, i.uv.zw).r;
                float3 rim = rimPower * saturate(1 - saturate(NdotV) * _Rim);// * tex2D(_FresnelWarpRim, float2(fresnel, 0.5));

                //ambient
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * _MainColor.rgb;
                
                //diffse = Color * max(0, NdotL)
                float3 diffuseReflection = _LightColor0.rgb * diffIntensify * _MainColor.rgb + _MainColor.rgb * emission;



                return fixed4(col * (ambient + diffuseReflection) * (1 - metalness ) + (specularReflection + rim) * metalness, 1.0);
            }
            ENDCG
        }
    }
    Fallback"Diffuse"
}
