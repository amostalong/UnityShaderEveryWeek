using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DepthPse : MonoBehaviour
{
    // Start is called before the first frame update
	public Material material;
	public DepthTextureMode mode = DepthTextureMode.Depth;

	public Camera _camera;
	/// <summary>/// wake is called when the script instance is being loaded.

    public Transform target;

    public float range = 0;
	Matrix4x4 VPMatrix;
    Vector4 vec = Vector4.zero;
	void Awake()
	{
		if (_camera == null)
		{
			_camera = GetComponent<Camera>();
		}

		_camera.depthTextureMode = mode;
	}

	void OnRenderImage (RenderTexture source, RenderTexture destination) {

		VPMatrix = _camera.projectionMatrix * _camera.worldToCameraMatrix;
        //Debug.Log(_camera.projectionMatrix);
		Matrix4x4 currentInverseVP = VPMatrix.inverse;
		material.SetMatrix("_CurrentInverseVP", currentInverseVP);
        vec.x = target.position.x;
        vec.y = target.position.y;
        vec.z = target.position.z;
        material.SetVector("_targetPos", vec);
        material.SetFloat("range", range);
		Graphics.Blit(source, destination, material);
	}
}
