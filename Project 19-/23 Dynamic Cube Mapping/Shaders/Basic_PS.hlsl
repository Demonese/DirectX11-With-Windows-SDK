#include "Basic.hlsli"

// 像素着色器(3D)
float4 PS(VertexPosHWNormalTex pIn) : SV_Target
{
    uint texWidth, texHeight;
    g_DiffuseMap.GetDimensions(texWidth, texHeight);
    float4 texColor = float4(1.0f, 1.0f, 1.0f, 1.0f);
    if (texWidth > 0 && texHeight > 0)
    {
        // 提前进行Alpha裁剪，对不符合要求的像素可以避免后续运算
        texColor = g_DiffuseMap.Sample(g_Sam, pIn.tex);
        clip(texColor.a - 0.1f);
    }
    
    // 标准化法向量
    pIn.normalW = normalize(pIn.normalW);

    // 顶点指向眼睛的向量
    float3 toEyeW = normalize(g_EyePosW - pIn.posW);

    // 初始化为0 
    float4 ambient = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 diffuse = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 spec = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 A = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 D = float4(0.0f, 0.0f, 0.0f, 0.0f);
    float4 S = float4(0.0f, 0.0f, 0.0f, 0.0f);
    int i;

    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputeDirectionalLight(g_Material, g_DirLight[i], pIn.normalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
        
    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputePointLight(g_Material, g_PointLight[i], pIn.posW, pIn.normalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }

    [unroll]
    for (i = 0; i < 5; ++i)
    {
        ComputeSpotLight(g_Material, g_SpotLight[i], pIn.posW, pIn.normalW, toEyeW, A, D, S);
        ambient += A;
        diffuse += D;
        spec += S;
    }
  
    float4 litColor = texColor * (ambient + diffuse) + spec;

    // 反射
    if (g_ReflectionEnabled)
    {
        float3 incident = -toEyeW;
        float3 reflectionVector = reflect(incident, pIn.normalW);
        float4 reflectionColor = g_TexCube.Sample(g_Sam, reflectionVector);

        litColor += g_Material.reflect * reflectionColor;
    }
    
    // 折射
    if (g_RefractionEnabled)
    {
        float3 incident = -toEyeW;
        float3 refractionVector = refract(incident, pIn.normalW, g_Eta);
        float4 refractionColor = g_TexCube.Sample(g_Sam, refractionVector);

        litColor += g_Material.reflect * refractionColor;
    }
    
    litColor.a = texColor.a * g_Material.diffuse.a;
    return litColor;
}
