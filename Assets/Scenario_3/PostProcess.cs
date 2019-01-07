using UnityEngine;

public class PostProcess : MonoBehaviour {

	public Material material;

	/// <summary>/// Awake is called when the script instance is being loaded.

	void Awake()
	{
		Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		Graphics.Blit(source, destination, material);
	}
}
