using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BloomTagMgr : MonoBehaviour {

	public Camera cam;
	private static BloomTagMgr instance;
	public static BloomTagMgr Instance
	{
		get
		{
			if(instance == null)
			{
				//instance = new BloomTagMgr();
				instance = GameObject.Find("BloomMgr").GetComponent<BloomTagMgr>();
			}

			return instance;
		}
	}

	public HashSet<BloomTag> bloomSet = new HashSet<BloomTag>();

	public void Add(BloomTag bt){

		if(bloomSet.Contains(bt))
		{
			return;
		}

		bloomSet.Add(bt);
	}

	public void Remove(BloomTag bt){

		if (bloomSet.Contains(bt))
		{
			bloomSet.Remove(bt);
		}
	}
}
