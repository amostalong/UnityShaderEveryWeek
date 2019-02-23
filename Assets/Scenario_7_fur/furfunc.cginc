#include "UnityCG.cginc"
#include "Lighting.cginc"

struct v2f
{
    float4 pos: SV_POSITION;
    half4 uv: TEXCOORD0;
    float3 worldNormal: TEXCOORD1;
    float3 worldPos: TEXCOORD2;
    float3 vertLight: TEXCOORD3;
};

fixed4 _Color; //基础色
fixed4 _Specular;  //高光色
half _Shininess; //反光度

sampler2D _MainTex; //毛皮贴图
half4 _MainTex_ST;
sampler2D _FurTex; //毛发噪点图
half4 _FurTex_ST;

fixed _FurLength; //毛发长度
fixed _FurDensity; //毛发密度
fixed _FurThinness; //毛发厚薄
fixed _FurShading; //毛发色度

float4 _ForceGlobal; //全局方向
float4 _FurDir; //方向

fixed4 _RimColor; //边缘色
half _RimPower; //边缘强度

v2f vert_base(appdata_base v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

    return o;
}

fixed4 frag_base(v2f i) : SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
    fixed3 worldHalf = normalize(worldView + worldLight);
    
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
    fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLight)); //漫反射 基于 发现和光照方向的点乘 
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, worldHalf)), _Shininess); //Specular = 直射光*pow(max(cosθ,0),高光的参数) Blinn

    fixed3 color = ambient + diffuse + specular;
    
    return fixed4(color, 1.0);
}

v2f vert_layers(appdata_base v)
{
    v2f o;

    float2 offset = FURSTEP * _FurDir * 0.1;   
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + offset;
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _FurTex) + offset;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; 

    fixed3 worldView = normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz);
    float3 ex = v.vertex.xyz + v.normal * _FurLength * FURSTEP;
    ex += mul(unity_WorldToObject, _ForceGlobal) * pow(FURSTEP, 2) * _FurLength;
    o.pos = UnityObjectToClipPos(float4(ex, 1.0));

    float3 normal = normalize(mul(UNITY_MATRIX_MV, float4(v.normal,0)).xyz);
    half3 SH = saturate(normal.y * 0.25 + 0.35) ;
    half Occlusion = FURSTEP * FURSTEP; //伽马转线性最精简版
    Occlusion += 0.05 ;
    half3 SHL = lerp ( _RimColor * SH, SH, Occlusion);
    half Fresnel = 1 - max(0,dot(o.worldNormal, worldView));//pow (1-max(0,dot(N,V)),2.2);
    half RimLight = Fresnel * Occlusion; //AO的深度剔除 很重要
    //RimLight *= RimLight; //fresnel~pow简化版
    RimLight *= SH; //加上环境光因数
    SHL += RimLight * _RimColor;

    o.vertLight = SHL;
    return o;
}

fixed4 frag_layers(v2f i) : SV_TARGET
{
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color;
    fixed3 color = i.vertLight + albedo;
    fixed3 noise = tex2D(_FurTex, i.uv.zw * _FurThinness).r;
    fixed alpha = clamp(noise - (FURSTEP * FURSTEP) * _FurDensity, 0, 1);

    return fixed4(color, alpha);
}

