using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveObject : MonoBehaviour
{
    [SerializeField]
    MeshRenderer meshObject;

    [SerializeField]
    float duration;

    float dissolveThreshold;

    protected Material material;

    void Start()
    {
        material = meshObject.material;
        meshObject.material = new Material(material);
        dissolveThreshold = 0;
    }

    void Update()
    {
        
        if (Input.GetKeyDown("space"))
        {
            Debug.Log("Start Dissolve");
            StartCoroutine("Dissolve");
        }
    }

    IEnumerator Dissolve() 
    {
        float time = 0;
        while(time < 1)
        {
            meshObject.material.SetFloat("_DissolveThreshold", time);
            time += Time.deltaTime/duration;
            yield return new WaitForEndOfFrame();
        }
        time = 0;
        while(time < 1)
        {
            meshObject.material.SetFloat("_DissolveThreshold", 1-time);
            time += Time.deltaTime/duration;
            yield return new WaitForEndOfFrame();
        }
    }
}
