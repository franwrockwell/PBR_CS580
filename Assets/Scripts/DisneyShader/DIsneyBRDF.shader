Shader "Custom/DIsneyBRDF"
{
    Properties
    {
        _baseColor("baseColor",Color)=(1,1,1,1)
        _MainTex ("Texture",2D)="white"{}
        _subSurface("SubSurface",Range(0,1))=0.5
        _metallic("Metallic",Range(0,1))=0.5
        _specular("Specular",Range(0,1))=0.5
        _specularTint("SpecularTint",Range(0,1))=0.5
        _roughness("Roughness",Range(0,1))=0.5
        _anIsotropic("Anisotropic",Range(0,1))=0.5
        _sheen("Sheen",Range(0,1))=0
        _sheenTint("SheenTint",Range(0,1))=0
        _clearCoat("ClearCoat",Color)=(1,1,1,1)
        _clearCoatGloss("ClearCoatGloss",Range(0,1))=0
		[Toggle] _GTR1_GTR2("GTR1 or GTR2?", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry"}
        LOD 200

        Pass{
        
            Tags{"LightMode" = "ForwardBase"}
            Name "BaseWhiteColor"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include"AutoLight.cginc"
            #include"Lighting.cginc"
            #pragma multi_compile_fwdbase_fullshadows
			float4 _baseColor;

            struct VertexInput {
                float4 vertex : POSITION; //Model Space position
                float3 normal : NORMAL; //Model Space normal
                float4 tangent : TANGENT; //Model Space tangent
                float2 texcoord0 : TEXCOORD0; //uv coordinates
                float2 texcoord1 :TEXCOORD1; //lightmap uv coordinates
            };

            struct VertexOutput {
                float4 pos : SV_POSITION; //Screen Space position
                float2 uv0 : TEXCOORD0; //uv coordinates
                float2 uv1 : TEXCOORD1; //lightmap uv coordinates
                float3 normalDir: TEXCOORD3; //normal direction
                float3 posWorld:TEXCOORD4; //position in world Space
                float3 tangentDir:TEXCOORD5;
                float3 bitangentDir:TEXCOORD6;
                LIGHTING_COORDS(7,8)
                UNITY_FOG_COORDS(9)
            };

            //Vertex Shader
            VertexOutput vert(VertexInput v) {
                VertexOutput o=(VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            //pixel Shader
            float4 frag(VertexOutput i) :COLOR{
                return float4(_baseColor.rgb*0.1,1.0);
            }
            ENDCG
        }

        pass{
            Tags{"LightMode" = "ForwardAdd"}
            Name"FORWARD"
            Blend one one
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma multi_compile _GTR1_GTR2_OFF _GTR1_GTR2_ON
            #include "UnityCG.cginc"
            #include"AutoLight.cginc"
            #include"Lighting.cginc"
            #pragma target 3.0
            float4 _baseColor;
            half _subSurface;
            half _metallic;
            half _specular;
            half _specularTint;
            half _roughness;
            half _anIsotropic;
            half _sheen;
            half _sheenTint;
            float4 _clearCoat;
            half _clearCoatGloss;

            struct VertexInput {
                float4 vertex : POSITION; //Model Space position
                float3 normal : NORMAL; //Model Space normal
                float4 tangent : TANGENT; //Model Space tangent
                float2 texcoord0 : TEXCOORD0; //uv coordinates
                float2 texcoord1 :TEXCOORD1; //lightmap uv coordinates
            };
            struct VertexOutput {
                float4 pos : SV_POSITION; //Screen Space position
                float2 uv0 : TEXCOORD0; //uv coordinates
                float2 uv1 : TEXCOORD1; //lightmap uv coordinates
                float3 normalDir: TEXCOORD3; //normal direction
                float3 posWorld:TEXCOORD4; //position in world Space
                float3 tangentDir:TEXCOORD5;
                float3 bitangentDir:TEXCOORD6;
                LIGHTING_COORDS(7,8)
                UNITY_FOG_COORDS(9)
            };
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o=(VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.uv1 = v.texcoord1;
                o.normalDir = UnityObjectToWorldNormal(v.normal);
                o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o, o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            // [Burley 2012, "Physically-Based Shading at Disney"] 
            float3 Diffuse_Burley_Disney(float3 baseColor,float roughness,float NdotV, float NdotL,float VdotH)
            {
                float F_D90=0.5+2*VdotH*VdotH*roughness;
                float F_dV=1+(F_D90-1)*pow(1-NdotV,5);
                float F_dL=1+(F_D90-1)*pow(1-NdotL,5);
                return baseColor*((1/3.1415)*F_dL*F_dV);
            }

            float3 Diffuse_Subsurface_Disney(float3 baseColor,float roughness,float NdotV, float NdotL, float VdotH)
            {
                float F_ssD90=VdotH*VdotH*roughness;
                float F_ssdV=1+(F_ssD90-1)*pow(1-NdotV,5);
                float F_ssdL=1+(F_ssD90-1)*pow(1-NdotL,5);
                float F_ss=F_ssdV*F_ssdL;
                float F_ssNormalize=F_ss*(1/(NdotL+NdotV)-0.5);
                return 1.25*baseColor*(1/3.1415)*(F_ssNormalize+0.5);
            }

            float lum_Disney(float3 Color)
            {
                return 0.2126*Color.r+0.7152*Color.g+0.0722*Color.b;
            }

            float3 Diffuse_Sheen(float3 baseColor,float Sheen,float SheenTint,float VdotH)
            {
                float3 colorWhite=float3(1,1,1);
                float3 colorTint=baseColor/lum_Disney(baseColor);
                float3 sheenColor=lerp(colorWhite,colorTint,SheenTint);
                return sheenColor*Sheen*pow(1-VdotH,5);
            }

            float3 F_specular_Disney(float3 baseColor,float SpecularTint,float metallic,float specular,float VdotH)
            {
                float3 colorWhite=float3(1,1,1);
                float3 colorTint=baseColor/lum_Disney(baseColor);
                float3 specularColor=lerp(lerp(colorWhite,colorTint,SpecularTint)*specular*1,baseColor,metallic);
                return specularColor+(colorWhite-specularColor)*pow(1-VdotH,5);
				//return 1;
            }

            float G_specular_GGX_Disney(float roughness,float NdotV)
            {
                float alphaG=pow(0.5+roughness/2.0,2);
                float a=alphaG*alphaG;
                float b=NdotV*NdotV;
                return 1/(NdotV+sqrt(a+b-a*b));
            }

            float D_GTR1_Disney(float roughness,float NdotH)
            {
				roughness = min(0.99, roughness);
                float alpha=roughness*roughness;
                float a2=alpha*alpha;
                float cos2th=NdotH*NdotH;
                float den=(1+(a2-1)*cos2th);
                return (a2-1)/(3.1415*0.5*log(a2)*den);
            }

            float D_GTR2_Disney(float roughness,float NdotH)
            {
                float alpha=roughness*roughness;
                float a2=alpha*alpha;
                float cos2th=NdotH*NdotH;
                float t=1+(a2-1)*cos2th;
                return a2/(3.1415*t*t);
            }
			float sqr(float a)
			{
				return a * a;
			}
			float D_GTR2_Anisotropic(float roughness,float anisotropic, float HdotX, float HdotY, float NdotH)
			{
				roughness = max(0.01, roughness);
				float a = sqrt(1 - 0.9*anisotropic);
				float alpha_x = roughness * roughness / a;
				float alpha_y = roughness * roughness*a;
				return 1.0 / (3.1415*alpha_x*alpha_y*sqr(sqr(HdotY / alpha_x) + sqr(HdotX / alpha_y) + sqr(NdotH)));
			}

			float F_clearcoat(float VdotH)
			{
				return 0.04 + 0.96*pow(1 - VdotH, 5);
			}
			float D_clearcoat(float clearcoatgloss, float NdotH)
			{
				float alpha = lerp(0.1, 0.01, clearcoatgloss);
				float den = sqr(alpha)*sqr(NdotH) + (1 - sqr(NdotH));
				return (sqr(alpha) - 1) / (3.1415*log(alpha)*den);
			}
			float G_clearcoat(float roughness, float NdotV)
			{
				float alphaG = pow(0.5 + roughness / 2.0, 2);
				float a = sqr(alphaG);
				float b = sqr(NdotV);
				return 1.0 / (NdotV + sqrt(a + b - a * b));
			}

            float4 frag(VertexOutput i):COLOR
            {
                float3 normalDirection = normalize(i.normalDir);
				float3 X = normalize(i.tangentDir);
				float3 Y = normalize(i.bitangentDir);

                float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
                float3 lightReflectDirection = reflect(-lightDirection, normalDirection);
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
                float3 viewReflectDirection = normalize(reflect(-viewDirection, normalDirection));
                float3 halfDirection = normalize(viewDirection + lightReflectDirection);
                
                //Get Dot Production Result
                float NdotL = max(0.05,dot(normalDirection, lightDirection));
                float NdotH = max(0.05, dot(normalDirection, halfDirection));
                float NdotV = max(0.05, dot(normalDirection, viewDirection));
                float VdotH = max(0.01, dot(viewDirection, halfDirection));
				float HdotX = dot(halfDirection, X);
				float HdotY = dot(halfDirection, Y);
                float LdotH = max(0.0, dot(lightDirection, halfDirection));
                //float LdotV = max(0.0, dot(lightDirection, viewDirection));
                float LRdotV = max(0.0, dot(lightReflectDirection, viewDirection));

                float3 DiffusionColor_Based=Diffuse_Burley_Disney(_baseColor.rgb,_roughness,NdotV,NdotL,VdotH);
                float3 DiffusionColor_Subsurface=Diffuse_Subsurface_Disney(_baseColor.rgb,_roughness,NdotV,NdotL,VdotH);
                float3 DiffusionColor_Sheen=Diffuse_Sheen(_baseColor.rgb,_sheen,_sheenTint,VdotH);
                float3 DiffusionColor=DiffusionColor_Based*(1-_subSurface)+DiffusionColor_Subsurface*(_subSurface)+DiffusionColor_Sheen;
                if(_subSurface<0.01)
                {
                    DiffusionColor=DiffusionColor_Based+DiffusionColor_Sheen;
                }
                DiffusionColor=DiffusionColor*(1-_metallic);

				float d;

#ifdef _GTR1_GTR2_ON
				d = D_GTR1_Disney(_roughness, NdotH);
#else
				d = D_GTR2_Anisotropic(_roughness, _anIsotropic, HdotX, HdotY, NdotH);//D_GTR2_Disney(_roughness, NdotH);
#endif

                float3 specularColor=F_specular_Disney(_baseColor,_specularTint,_metallic,_specular,VdotH)*G_specular_GGX_Disney(_roughness,NdotV)*d;
				specularColor /= 4;//*NdotL*NdotV;

				float3 clearCoatColor = _clearCoat.rgb * (F_clearcoat(VdotH)*G_clearcoat(_roughness,NdotV)*D_clearcoat(_clearCoatGloss,NdotH))/(16*NdotL*NdotV);

                return float4(DiffusionColor+specularColor+clearCoatColor,1);
				//return float4(VdotH, 0, 0, 1);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
