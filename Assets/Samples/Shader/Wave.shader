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
        Tags {
            "RenderType"="Opaque"
            "LightMode" = "ForwardBase" // ライトモードはFowardに
        }
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
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float _Amp;
            float _Freq;
            float _Speed;
            float _Ox;
            float _Oy;
            float4 _MainTex_ST;
            uniform float4 _LightColor0; // ディレクショナルライトカラー

            static const float PI = 3.14159265f;

            v2f vert (appdata v)
            {
                v2f o;
                {
                    float2 diff = float2(v.vertex.x - _Ox, v.vertex.z - _Oy);
                    float dist = sqrt(diff.x * diff.x + diff.y * diff.y);
                    float2 norm = float2(0, 0);
                    v.vertex.y =  _Amp * sin(2.0f * PI * _Freq * (_Time.y - (dist / _Speed)));
                    if (dist == 0.0f) {
                        norm = float2(0.0f, 0.0f);
                    } else {
                        float temp_cosin = -_Amp * 2.0f * PI * _Freq * cos(2.0f * PI * _Freq * (_Time.y - dist / _Speed)) / dist / _Speed;
                        norm = float2(-temp_cosin * diff.x, -temp_cosin * diff.y);
                    }
                    o.normal = float3(norm.x, 1.0f, norm.y);
                    o.normal = UnityObjectToWorldNormal(o.normal);
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
                // 参考
                // http://marupeke296.com/Shader_No7_GeometoryLevelWave.html
                float3 lightDir = normalize( _WorldSpaceLightPos0.xyz );
                float diffusePower = dot( normalize( i.normal ), lightDir );
                col.rgb = max( 0.0, diffusePower ) * _LightColor0.rgb * col.xyz;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
