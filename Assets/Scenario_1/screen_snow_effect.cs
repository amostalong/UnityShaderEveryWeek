using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class screen_snow_effect : MonoBehaviour {

	[SerializeField]
	Texture2D snow_texture;
	[SerializeField]
	float snow_scale;
	[SerializeField]
	Matrix4x4 camera_to_world;
	[Range(0,1)]
	float bottom_threshold;
	[Range(0,1)]
	float top_threshold;
	[SerializeField]
	Color snow_color = Color.white;

	Material material;

	// Use this for initialization
	void OnEnable () {

		material = new Material(Shader.Find("USE/snow_effect"));

		Camera.main.depthTextureMode |= DepthTextureMode.DepthNormals;
	}
	
	void OnRenderImage(RenderTexture src, RenderTexture dst)
	{
		camera_to_world = Camera.main.cameraToWorldMatrix;

		material.SetTexture ("_SnowTex", snow_texture);
		material.SetFloat ("_SnowTexScale", snow_scale);
		material.SetMatrix ("_CamToWorld", camera_to_world);
		material.SetFloat ("BottomThreshod", bottom_threshold);
		material.SetFloat ("_TopThreshod", top_threshold);
		material.SetColor ("_SnowColor", snow_color);

		Graphics.Blit (src, dst, material);
	}
}
