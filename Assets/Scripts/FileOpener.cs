using System.Collections;
using System.IO;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine;
using SFB;

public class FileOpener : MonoBehaviour
{

    Shader myShader;

    Renderer rend;

    public GameObject teapot;

    // Start is called before the first frame update
    void Start()
    {
        myShader = Shader.Find("Physically-Based-Lighting");
        teapot = GameObject.FindGameObjectWithTag("Player");
        rend = teapot.GetComponent<Renderer>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKey("escape"))
        {
            Application.Quit();
        }
    }

    public void OnClick()
    {
        // Open file with filter
        var extensions = new[] {
            new ExtensionFilter("Image Files", "png", "jpg", "jpeg" ),
        };
        Texture2D texture = rend.material.mainTexture as Texture2D;

        var path = StandaloneFileBrowser.OpenFilePanel("Open File", "", extensions, true);
        var fileContent = File.ReadAllBytes(path[0]);

        texture.LoadImage(fileContent);

        rend.material = new Material(myShader);
        rend.material.color = Color.blue;
        rend.material.mainTexture = texture;



    }

    public void UpdateMetallic(float val)
    {
        if(rend)
            rend.material.SetFloat("_Metallic", val);
    }

    public void UpdateSmoothness(float val)
    {
        if(rend)
            rend.material.SetFloat("_Glossiness", val);
    }
}
/*
 * 
 * Material newMat = rend.material;
        newMat.mainTexture = texture;

        rend.material.shader = myShader;
*/