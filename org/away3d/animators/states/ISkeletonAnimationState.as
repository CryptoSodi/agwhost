package org.away3d.animators.states
{
	import org.away3d.animators.data.*;
	
	public interface ISkeletonAnimationState extends IAnimationState
	{
		/**
		 * Returns the output skeleton pose of the animation node.
		 */
		function getSkeletonPose(skeleton:Skeleton):SkeletonPose;
	}
}
