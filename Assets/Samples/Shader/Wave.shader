// 参考
// https://qiita.com/note-nota/items/d2e251d93bc5fac2cbba
// http://marupeke296.com/Shader_No8_GeoVtxOperation.html
Shader "Unlit/Wave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Amp("Amplitude", float) = 1.0
        _Freq("Frequency", float) = 0.3
        _Speed("Speed", float) = 0.05
        _Ox("origin_x", Range(-0.5,0.5)) = 0
        _Oy("origin_y", Range(-0.5,0.5)) = 0
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
            float _Amp;
            float _Freq;
            float _Speed;
            float _Ox;
            float _Oy;
            float4 _MainTex_ST;

            static const float PI = 3.14159265f;

            v2f vert (appdata v)
            {
                v2f o;
                {
                    float2 diff = float2(v.vertex.x - _Ox, v.vertex.z - _Oy);
                    float dist = sqrt(diff.x * diff.x + diff.y * diff.y);
                    v.vertex.y =  _Amp * sin(2.0f * PI * _Freq * (_Time.y - (dist / _Speed)));
                }
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
