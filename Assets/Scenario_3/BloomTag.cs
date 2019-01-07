using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BloomTag : MonoBehaviour {

   public Material bloomMaterial;

   public void OnEnable()
   {
      BloomTagMgr.Instance.Add(this);
   }

   public void Start()
   {
      BloomTagMgr.Instance.Add(this);
   }

   public void OnDisable()
   {
      BloomTagMgr.Instance.Remove(this);
   }
}
