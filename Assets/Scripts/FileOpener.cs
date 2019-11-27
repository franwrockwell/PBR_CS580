using System.Collections;
using System.IO;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine;
using SFB;

public class FileOpener : MonoBehaviour
{

    Shader myShader;

    Renderer rend0, rend1, rend2;

    public GameObject obj0, obj1, obj2;

    // Start is called before the first frame update
    void Start()
    {
        myShader = Shader.Find("Physically-Based-Lighting");
        obj0 = GameObject.FindGameObjectWithTag("Player");
        obj1 = GameObject.FindGameObjectWithTag("Player1");
        obj2 = GameObject.FindGameObjectWithTag("Player2");
        rend0 = obj0.GetComponent<Renderer>();
        rend1 = obj1.GetComponent<Renderer>();
        rend2 = obj2.GetComponent<Renderer>();
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
        //Texture2D texture = rend.material.mainTexture as Texture2D;

        //var path = StandaloneFileBrowser.OpenFilePanel("Open File", "", extensions, true);
        //var fileContent = File.ReadAllBytes(path[0]);

        //texture.LoadImage(fileContent);

        //rend.material = new Material(myShader);
        //rend.material.color = Color.blue;
        //rend.material.mainTexture = texture;



    }

    public void UpdateMetallic(float val)
    {
        rend0.material.SetFloat("_metallic", val);
        rend1.material.SetFloat("_metallic", val);
        rend2.material.SetFloat("_metallic", val);
    }

    public void UpdateSmoothness(float val)
    {
        rend0.material.SetFloat("_roughness", val);
        rend1.material.SetFloat("_roughness", val);
        rend2.material.SetFloat("_roughness", val);
    }

    public void UpdateSubSurface(float val)
    {
        rend0.material.SetFloat("_subSurface", val);
        rend1.material.SetFloat("_subSurface", val);
        rend2.material.SetFloat("_subSurface", val);
    }

    public void UpdateSpecular(float val)
    {
        rend0.material.SetFloat("_specular", val);
        rend1.material.SetFloat("_specular", val);
        rend2.material.SetFloat("_specular", val);
    }

    public void UpdateSpecularTint(float val)
    {
        rend0.material.SetFloat("_specularTint", val);
        rend1.material.SetFloat("_specularTint", val);
        rend2.material.SetFloat("_specularTint", val);
    }

    public void UpdateAnisotropic(float val)
    {
        rend0.material.SetFloat("_anIsotropic", val);
        rend1.material.SetFloat("_anIsotropic", val);
        rend2.material.SetFloat("_anIsotropic", val);
    }

    public void UpdateSheen(float val)
    {
        rend0.material.SetFloat("_sheen", val);
        rend1.material.SetFloat("_sheen", val);
        rend2.material.SetFloat("_sheen", val);
    }

    public void UpdateSheenTint(float val)
    {
        rend0.material.SetFloat("_sheenTint", val);
        rend1.material.SetFloat("_sheenTint", val);
        rend2.material.SetFloat("_sheenTint", val);
    }

    public void UpdateClearCoatGloss(float val)
    {
        rend0.material.SetFloat("_clearCoatGloss", val);
        rend1.material.SetFloat("_clearCoatGloss", val);
        rend2.material.SetFloat("_clearCoatGloss", val);
    }
}
/*
 * 
 * Material newMat = rend.material;
        newMat.mainTexture = texture;

        rend.material.shader = myShader;
*/