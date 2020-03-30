Shader "Unlit/TilesShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Density("Density", Range(1,10)) = 0
        _Thickness("Thickness", Range(0,1)) = 0
        _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ColorTwo ("ColorTwo", Color) = (1, 1, 1, 1)

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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Density;
            float _Thickness;
            half4 _BaseColor;
            half4 _Color;
            half4 _ColorTwo;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // size of tiles (assuming max texcoord is 1)
                float stepsize = 1/_Density;

                // get index of the tile closest to the current texcoords
                int squareIndexX = int(i.uv.x/stepsize);
                int squareIndexY = int(i.uv.y/stepsize);

                // get the center of the tile  (in which the texcoords are)
                float centerX = squareIndexX * stepsize + stepsize/2;
                float centerY = squareIndexY * stepsize + stepsize/2;

                // get the edge of the tile  (in which the texcoords are)
                float edgeX = squareIndexX * stepsize;
                float edgeY = squareIndexY * stepsize;

                float minX = edgeX + (stepsize / 0.5 * _Thickness);
                float maxX = edgeX - (stepsize / 0.5 * _Thickness);

                float minY = edgeY + (stepsize / 0.5 * _Thickness);
                float maxY = edgeY - (stepsize / 0.5 * _Thickness);
               
                // check if texcoord is on edge 
                float isOnEdgeX = step(i.uv.x, minX) * step(maxX, i.uv.x);
                float isOnEdgeY = step(i.uv.y, minY) * step(maxY, i.uv.y);

                // only one line should be visible
                float isVisibleY = max(step(squareIndexY,2) * step(2,squareIndexY), step(squareIndexY,4) * step(4,squareIndexY)) ;
                float isVisibleX = max(step(squareIndexX,1) * step(1,squareIndexX), step(squareIndexX,3) * step(3,squareIndexX)) ;
        
                // use sin for shiny effect
                half4 gradientColor = _Color * ( (sin(i.uv.x + _Time.w/2 ) ));
                // if texcoord are not on the edge the color is 0,0,0,0
                // texcoord only has to be on one edge so only one of the two hast be 1
                half4 gridColor = max(gradientColor * isOnEdgeX, gradientColor * isOnEdgeY);// * max(isVisibleX, isVisibleY);

                return gridColor;
            }
            ENDCG
        }
    }
}
