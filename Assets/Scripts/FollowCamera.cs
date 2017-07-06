using UnityEngine;
using System.Collections;

public class FollowCamera: MonoBehaviour {
	public Transform player;

	// Use this for initialization
	void Start () {
		Invoke ("Test", 2);
	}

	public void Test() {
		Debug.Log ("fuck");
	}
}
