// 参考: https://baba-s.hatenablog.com/entry/2018/10/11/170000
Shader "Unlit/Blur"
{
    Properties
    {
        _Factor ("Factor", Range(0, 5)) = 1.0
        // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        GrabPass { }
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
                // https://docs.unity3d.com/ja/2019.4/Manual/SL-GrabPass.html
                // TODO: なぜテクスチャ座標が四次元で返ってくる？何か追加の情報？
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // sampler2D _MainTex;
            // float4 _MainTex_ST;
            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            float _Factor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // UNITY_TRANSFER_FOG(o,o.vertex);
                // https://docs.unity3d.com/ja/2019.4/Manual/SL-GrabPass.html
                // https://docs.unity3d.com/ja/2019.4/Manual/SL-BuiltinFunctions.html
                // 描画内容を次のパスで使うために、頂点を画面端と対応づける？
                o.uv = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);
                // return col;
                half4 pixelCol = half4(0, 0, 0, 0);
                // https://docs.unity3d.com/ja/2019.4/Manual/SL-BuiltinMacros.html
                // UNITY_PROJ_COORD
                // > 4次元ベクトルを渡すと、投影されたテクスチャ読み込みに適切なテクスチャ座標を戻します。ほとんどのプラットフォームでは渡された値そのものを戻します。
                // TODO: なぜ必要？

                // https://edom18.hateblo.jp/entry/2019/07/30/091403
                // tex2Dproj
                // 上記サイトが参考になる。
                // しかし ComputeGrabScreenPos の z, w に何が入っているかがわからない...
                #define ADDPIXEL(weight,kernelX) tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(float4(i.uv.x + _GrabTexture_TexelSize.x * kernelX * _Factor, i.uv.y, i.uv.z, i.uv.w))) * weight
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
                return pixelCol;
            }
            ENDCG
        }
    }
}
