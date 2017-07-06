using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Spine;
using Spine.Unity;

public class SpineController : MonoBehaviour {
	public SkeletonAnimation skeletonAnimation;

	public void SetAnimationLoop(string name) {
		if (skeletonAnimation.AnimationName != "A") {
			skeletonAnimation.state.SetAnimation (0, name, true);
		} else {
			skeletonAnimation.state.AddAnimation (0, name, true, 0f);
		}
	}

	public void SetAnimationOnce(string name) {
		if (skeletonAnimation.AnimationName != "A") {
			skeletonAnimation.state.SetAnimation(0, name, false);
		} else {
			skeletonAnimation.state.AddAnimation (0, name, false, 0f);
		}
	}
}
