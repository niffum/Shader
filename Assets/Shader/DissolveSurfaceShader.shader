Shader "Custom/DissolveSurfaceShader"
{
    Properties
    {
        _DissolveTex ("Texture", 2D) = "white" {}
        _DissolveThreshold("Threshold", Range(0,1)) = 0
        _BorderWidth("Border", Range(0,1)) = 0
        _BorderColor ("BorderColor", Color) = (1,1,1,1)
        _BorderColorTwo ("BorderColorTwo", Color) = (1,1,1,1)

        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off //Fast way to turn your material double-sided

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        sampler2D _DissolveTex;
        float4 _DissolveTex_ST;
        float _DissolveThreshold;
        float _BorderWidth;
        fixed4 _BorderColor;
        fixed4 _BorderColorTwo;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // sample the texture
            float dissolveValue = tex2D(_DissolveTex, IN.uv_MainTex).r;
            float isGoneValue = dissolveValue - _DissolveThreshold;
            //remove values below zero
            clip(dissolveValue - _DissolveThreshold);
            fixed4 borderColor = _BorderColor * ( abs(sin( _Time.w )));

            //o.Emission = _BorderColor.rgb * step(dissolveValue - _DissolveThreshold, _BorderWidth); //emits color with border size

            // Albedo comes from a texture tinted by color
            fixed4 normalColor = tex2D (_MainTex, IN.uv_MainTex)  * _Color * step(0, isGoneValue);
            //fixed4 disColor = tex2D (_MainTex, IN.uv_MainTex)  * _BorderColor * step(isGoneValue, 0) * ( abs(sin( _Time.w )));
            fixed4 disColor = tex2D (_MainTex, IN.uv_MainTex)  * (_BorderColor * ( abs(sin( _Time.w ))) + _BorderColorTwo * ( abs(cos( _Time.w ))) ) ;
            o.Emission =  disColor.rgb * step(dissolveValue - _DissolveThreshold, _BorderWidth);
            fixed4 c = normalColor;// + disColor;

            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
