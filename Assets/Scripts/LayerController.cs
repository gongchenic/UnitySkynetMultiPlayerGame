using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LayerController : MonoBehaviour {

	public GameObject loginlayer;
	public GameObject gamelayer;
	public GameObject deadlayer;
	private string lastlayername;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (lastlayername != null) {
			if (lastlayername.Equals ("login")) {
				for(int i = 0;i<gamelayer.transform.childCount;i++)
				{
					GameObject go = gamelayer.transform.GetChild(i).gameObject;
					GameObject.DestroyImmediate(go);
				}
			}
			loginlayer.SetActive (lastlayername.Equals ("login"));
			gamelayer.SetActive (lastlayername.Equals ("game") || lastlayername.Equals ("dead"));
			deadlayer.SetActive (lastlayername.Equals ("dead"));
			if (lastlayername.Equals ("dead")) {
				deadlayer.GetComponent<AudioSource>().Play ();
			}
			lastlayername = null;
		}
	}

	void setLayerActive(string layername) {
		lastlayername = layername;
	}
}
