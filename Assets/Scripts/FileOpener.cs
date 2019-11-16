using System.Collections;
using System.IO;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine;
using SFB;

public class FileOpener : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        
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
        Texture2D texture = GameObject.FindGameObjectWithTag("Player").GetComponent<Renderer>().material.mainTexture as Texture2D;

        var path = StandaloneFileBrowser.OpenFilePanel("Open File", "", extensions, true);
        var fileContent = File.ReadAllBytes(path[0]);

        texture.LoadImage(fileContent);



    }
}
