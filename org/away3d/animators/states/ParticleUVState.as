package org.away3d.animators.states
{
	import flash.geom.Vector3D;
	
	import org.away3d.arcane;
	import org.away3d.cameras.Camera3D;
	import org.away3d.animators.data.AnimationRegisterCache;
	import org.away3d.animators.data.AnimationSubGeometry;
	import org.away3d.core.base.IRenderable;
	import org.away3d.core.managers.Stage3DProxy;
	import org.away3d.animators.nodes.ParticleUVNode;
	import org.away3d.animators.ParticleAnimator;
	
	use namespace arcane;
	
	/**
	 * ...
	 */
	public class ParticleUVState extends ParticleStateBase
	{
		
		private var _particleUVNode:ParticleUVNode;
		
		public function ParticleUVState(animator:ParticleAnimator, particleUVNode:ParticleUVNode)
		{
			super(animator, particleUVNode);
			
			_particleUVNode = particleUVNode;
		}
		
		override public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, animationSubGeometry:AnimationSubGeometry, animationRegisterCache:AnimationRegisterCache, camera:Camera3D):void
		{
			if (animationRegisterCache.needUVAnimation) {
				var index:int = animationRegisterCache.getRegisterIndex(_animationNode, ParticleUVNode.UV_INDEX);
				var data:Vector3D = _particleUVNode._uvData;
				animationRegisterCache.setVertexConst(index, data.x, data.y);
			}
		}
	
	}

}
