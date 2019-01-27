using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SendPos : MonoBehaviour
{

    int pid;
    
    Vector4 pos = new Vector4(1,1,1,1);
    public Material mat;


    /// Awake is called when the script instance is being loaded.
    /// </summary>
    void Awake()
    {
        pid = Shader.PropertyToID("_targetPos");
    }
    
    void Update()
    {
        pos[0] = transform.position.x;
        pos[1] = transform.position.y;
        pos[2] = transform.position.z;
        //Shader.SetGlobalVector(pid, pos);   

        //Shader.SetGlobalMatrix("unity_ViewToWorldMatrix", Camera.main.cameraToWorldMatrix);
        //Shader.SetGlobalMatrix("unity_InverseProjectionMatrix", Camera.main.projectionMatrix.inverse); 
        //Shader.SetGlobalVector(pid, pos);
    }
}
