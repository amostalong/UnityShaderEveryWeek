using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BloomRender : MonoBehaviour {

	private CommandBuffer bloomBuff;
	private bool hasAdded = false;
	void OnWillRenderObject()
	{
		if (hasAdded) return;
		hasAdded = true;
		
		bloomBuff = new CommandBuffer();
		bloomBuff.name = "Bloom Command Buff";

		int id = Shader.PropertyToID("_TempRT");
		bloomBuff.GetTemporaryRT(id, -1, -1, 16, FilterMode.Bilinear);
		bloomBuff.SetRenderTarget(id);
		bloomBuff.ClearRenderTarget(true, true, Color.black);

		foreach(var bt in BloomTagMgr.Instance.bloomSet)
		{
			var renders = bt.GetComponents<Renderer>();

			foreach(var render in renders)
			{
				Debug.Log("Draw Render:" + render.gameObject.name + "," + bt.bloomMaterial.name);
				bloomBuff.DrawRenderer(render, bt.bloomMaterial, 0, 1);
			}
		}

		bloomBuff.SetGlobalTexture("_GlowMap", id);
		Camera.main.AddCommandBuffer(CameraEvent.BeforeForwardOpaque, bloomBuff);

		Debug.Log("Has Add Command Buffer");
	}
}
