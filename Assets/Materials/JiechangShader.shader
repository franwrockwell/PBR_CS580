// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/JiechangShader"
{//REF: https://www.jordanstevenstechart.com/physically-based-rendering
	Properties
	{
		_baseColor("baseColor",Color) = (1,1,1,1)
		_specularColor("SpecularColor",Color) = (1,1,1,1)
		_roughness("Roughness",Range(0.0,1.0)) = 0.5
		_metallic("Metallic",Range(0.0,1.0)) = 0.0
		_glossiness("Smoothness",Range(0,1)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" "Queue" = "Geometry" "LightMode" = "ForwardBase" }
		LOD 200
		Pass{
			Name "FORWARD"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#define UNITY_PASS_FORWARDBASE
			#include "UnityCG.cginc"
			#include"AutoLight.cginc"
			#include"Lighting.cginc"
			#pragma multi_compile_fwdbase_fullshadows
			#pragma target 3.0
			float4 _baseColor;
			float4 _specularColor;
			half _roughness;
			half _metallic;
			half _glossiness;

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
				VertexOutput o = (VertexOutput)0;
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

			//helper function
			float Phong_NDF(float RdotV, float specularpower, float speculargloss)
			{
				float Distribution = pow(RdotV, speculargloss)*specularpower;
				Distribution *= (2 + specularpower) / (2 * 3.1415926535);
				return Distribution;
			}
			//algorithms

			//pixel Shader
			float4 frag(VertexOutput i) :COLOR{
				float3 normalDirection = normalize(i.normalDir);

				float3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, _WorldSpaceLightPos0.xyz - i.posWorld.xyz, _WorldSpaceLightPos0.w));
				float3 lightReflectDirection = reflect(-lightDirection, normalDirection);
				float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 viewReflectDirection = normalize(reflect(-viewDirection, normalDirection));
				float3 halfDirection = normalize(viewDirection + lightDirection);
				
				//Get Dot Production Result
				float NdotL = max(0.0, dot(normalDirection, lightDirection));
				float NdotH = max(0.0, dot(normalDirection, halfDirection));
				float NdotV = max(0.0, dot(normalDirection, viewDirection));
				float VdotH = max(0.0, dot(viewDirection, halfDirection));
				float LdotH = max(0.0, dot(lightDirection, halfDirection));
				float LdotV = max(0.0, dot(lightDirection, viewDirection));
				float LRdotV = max(0.0, dot(lightReflectDirection, viewDirection));
				
				//Get Other Property Value
				float attenuation = LIGHT_ATTENUATION(i);
				float3 attenColor = attenuation * _LightColor0.rgb;
				float roughnessSquare = _roughness * _roughness;

				//Metallic
				float3 diffuseColor = _baseColor.rgb*(1 - _metallic);
				float3 specColor = lerp(_specularColor.rgb, _baseColor, _metallic*0.5);
				float3 SpecularDistribution = specColor;
				SpecularDistribution *= Phong_NDF(LRdotV, _glossiness, max(1,_glossiness*40));

				//algorithms function here

				return float4(float3(1, 1, 1)*SpecularDistribution, 1);
			}
			ENDCG
		}
    }
    FallBack "Diffuse"
}
