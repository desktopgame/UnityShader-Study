Shader "Unlit/Test"
{
    Properties
    {
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
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 pos : TEXCOORD1;
            };

            sampler2D _GrabTex;
            float4 _GrabTex_ST;
            float4 _GrabTexSize;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _GrabTex);
                o.pos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float2 uv = i.pos.xy / i.pos.w;
                float2 uv = float2(i.pos.x, i.pos.y);
                half4 pixelCol = half4(0, 0, 0, 0);
                #define ADDPIXEL(weight,kernelX) tex2Dproj(_GrabTex, UNITY_PROJ_COORD(float4(i.pos.x + _GrabTexSize.x * kernelX, i.pos.y, i.pos.z, i.pos.w))) * weight
                // #define ADDPIXEL(weight,kernelX) tex2D(_GrabTex, float2(uv.x + _GrabTexSize.x * kernelX, uv.y)) * weight
                // UVを少しずらしながら色を重ねる？
                pixelCol += ADDPIXEL(0.05, 4.0);
                pixelCol += ADDPIXEL(0.09, 3.0);
                pixelCol += ADDPIXEL(0.12, 2.0);
                pixelCol += ADDPIXEL(0.15, 1.0);
                pixelCol += ADDPIXEL(0.18, 0.0);
                pixelCol += ADDPIXEL(0.15, -1.0);
                pixelCol += ADDPIXEL(0.12, -2.0);
                pixelCol += ADDPIXEL(0.09, -3.0);
                pixelCol += ADDPIXEL(0.05, -4.0);
                // pixelCol.r *= 0.1;
                return pixelCol;
                // return tex2D(_GrabTex, i.uv);
                // return tex2D(_GrabTex, i.uv) * float4(1, 0.2, 1, 1);
                // return float4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}
