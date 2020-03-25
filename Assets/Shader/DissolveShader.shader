Shader "Unlit/DissolveShader"
{
    Properties
    {
        _DissolveTex ("Texture", 2D) = "white" {}
        _DissolveThreshold("Threshold", Range(0,1)) = 0
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off //Fast way to turn your material double-sided

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            float _DissolveThreshold;
            half4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _DissolveTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = v.normal;
                return o;
            }

            float3 phong(float3 normal, float3 viewDir, float3 lightDir, float3 diffuse)
            {

                // Diffuse
                float3 diffuseColor = diffuse.rgb;// float3(0.5, 1.0, 1.0);
                float diffuseIntensity = 1.0;

                float ndotl = dot(normal, lightDir);

                // no ndotl < 0 because we want everything visible

                // faking ambient
                float3 ambient = .1f * diffuseColor.rgb;

                float3 diffuseComponent = ndotl * diffuseColor.rgb + ambient;

                // Specular
                float3 specularColor = float3(1.0, 1.0, 1.0);
                float shininessPower = 5.0;

                float3 reflectionDir = 0.5 + reflect(-lightDir, normal);

                // max is important or everythinf back facing the light is black
                float rdotv = max(dot(reflectionDir, viewDir), 0.0);

                float3 specularComponent = specularColor.rgb  * pow(rdotv, shininessPower);

                // specular should not be visible on sourrounding box
                // by multiplying it with diffuse it gets darker7black when diffuse isn't visible either
                return diffuseComponent.rgb + specularComponent.rgb * diffuseComponent.rgb;
                //return float4(abs(normal), 1.0);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float dissolveValue = tex2D(_DissolveTex, i.uv).r;
                //remove values below zero
                clip(dissolveValue - _DissolveThreshold);


                float3 lightDir = 0.5 + normalize(_WorldSpaceLightPos0.xyz);//normalize((_WorldSpaceLightPos0 - i.vertex).xyz);
                float3 viewDir = 0.5 + normalize(i.vertex);//normalize(_WorldSpaceCameraPos - i.vertex.xyz);
                fixed4 result = fixed4 (phong(i.normal, lightDir, viewDir, _Color), 1);
                return result;
            }

            ENDCG
        }
    }
}
