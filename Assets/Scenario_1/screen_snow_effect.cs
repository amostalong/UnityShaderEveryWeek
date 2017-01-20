using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class screen_snow_effect : MonoBehaviour {

	[SerializeField]
	Texture2D snow_texture;
	[SerializeField]
	float snow_scale  = 0.1f;
	[SerializeField]
	Matrix4x4 camera_to_world;
	[Range(0,1)]
	public float bottom_threshold = 0f;
	[Range(0,1)]
	float top_threshold = 1;
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
		var project_to_camera = (Camera.main.worldToCameraMatrix * Camera.main.projectionMatrix).inverse;

		material.SetTexture ("_SnowTex", snow_texture);
		material.SetFloat ("_SnowTexScale", snow_scale);
		material.SetMatrix ("_CamToWorld", camera_to_world);
		material.SetFloat ("BottomThreshod", bottom_threshold);
		material.SetFloat ("_TopThreshod", top_threshold);
		material.SetColor ("_SnowColor", snow_color);
		material.SetMatrix ("_ProecjtToCam", project_to_camera);

		Graphics.Blit (src, dst, material);
	}
}
