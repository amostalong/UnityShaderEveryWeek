using UnityEngine;

public class PostProcess : MonoBehaviour {

	public Material material;
	public DepthTextureMode mode = DepthTextureMode.Depth;

	public Camera camera;
	/// <summary>/// wake is called when the script instance is being loaded.

	Matrix4x4 VPMatrix;
	void Awake()
	{
		if (camera == null)
		{
			camera = GetComponent<Camera>();
		}

		camera.depthTextureMode = mode;
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination) {

		VPMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
		Matrix4x4 currentVP = VPMatrix;
		Matrix4x4 currentInverseVP = VPMatrix.inverse;
		material.SetMatrix("_CurrentInverseVP", currentInverseVP);
		Graphics.Blit(source, destination, material);
	}
}
