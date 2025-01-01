package com.game.entity.systems.shared
{
	import com.enum.CategoryEnum;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.shared.AnimationNode;
	import com.model.asset.AssetModel;
	import com.model.asset.ISpritePack;

	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class AnimationSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.shared.AnimationNode")]
		public var nodes:NodeList;

		private var _assetModel:AssetModel;
		private var _vfxFactory:IVFXFactory;

		override public function update( time:Number ):void
		{
			var node:AnimationNode;
			var animation:Animation;
			var detail:Detail;
			var spritePack:ISpritePack;
			var timeDiff:int;
			var animationFrames:Array;

			for (node = nodes.head; node; node = node.next)
			{
				detail = node.detail;
				animation = node.animation;

				if (animation.render && animation.render.alpha != animation.alpha)
					animation.render.alpha = animation.alpha;

				if (!animation.ready)
				{
					spritePack = _assetModel.getSpritePack(animation.type, true, node.entity);
					if (!spritePack || !spritePack.ready)
						continue;
					animation.spritePack = spritePack;
					animation.sprite = spritePack.getFrame(animation.label, animation.frame);
					var animationFrames:Array = spritePack.getFrames(animation.label);
					if(animationFrames)
						animation.numberOfFrames = animationFrames.length;
					else
						animation.numberOfFrames = 0;
						
					animation.labelChanged = false;
					if (animation.render)
					{
						animation.render.updateFrame(animation.sprite, animation, true);
						if (animation.center)
						{
							if (node.entity.has(Position))
								Position(node.entity.get(Position)).dirty = true;
							else
							{
								if (!animation.lostContext)
								{
									animation.render.x -= animation.offsetX;
									animation.render.y -= animation.offsetY;
								}
								animation.forceReady(true);
							}
						}
					}
					animation.dispatch(Animation.ANIMATION_READY);
				} else if (animation.labelChanged)
				{
					animation.frame = 0;
					animation.labelChanged = false;
					animation.sprite = animation.spritePack.getFrame(animation.label, animation.frame);
					animation.numberOfFrames = animation.spritePack.getFrames(animation.label).length;
					if (animation.render)
						animation.render.updateFrame(animation.sprite, animation, true);
					animation.playing = true;
				} else if (animation.textChanged && animation.text && animation.ready && animation.render)
				{
					if (animation.textLostContext)
					{
						Object(animation.render).text = null;
						animation.textLostContext = false;
					}
					animation.render.color = animation.color;
					Object(animation.render).text = animation.text;
					animation.textChanged = false;
				} else if (time != 0 && animation.numberOfFrames > 1 && animation.playing)
				{
					if (animation.randomStart)
					{
						animation.frame = (animation.numberOfFrames * Math.random());
						animation.randomStart = false;
					}

					animation.time += time;
					if (animation.time >= animation.frameDuration)
					{
						timeDiff = animation.time / animation.frameDuration | 0;
						animation.frame += timeDiff;
						if (animation.frame >= animation.numberOfFrames)
						{
							animation.frame = 0;
							animation.dispatch(Animation.ANIMATION_COMPLETE);
							if (!animation.replay)
								animation.playing = false;
							if (animation.destroyOnComplete)
							{
								if (detail.category == CategoryEnum.EXPLOSION)
									_vfxFactory.destroyVFX(node.entity);
							}
						}
						if (animation.spritePack)
						{
							animation.time -= timeDiff * animation.frameDuration;
							animation.sprite = animation.spritePack.getFrame(animation.label, animation.frame);
							if (animation.render)
								animation.render.updateFrame(animation.sprite, animation);
						}
					}
				}
			}
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }

		override public function removeFromGame( game:Game ):void
		{
			nodes = null;
			_assetModel = null;
			_vfxFactory = null;
		}
	}
}
