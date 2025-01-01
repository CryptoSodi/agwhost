package com.game.entity.components.battle
{
	import com.Application;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.render.Render;
	import com.game.entity.components.shared.render.RenderSprite;
	import com.game.entity.components.shared.render.RenderSpriteStarling;
	import com.game.entity.components.shared.render.RenderStarling;
	import com.model.asset.AssetVO;

	import flash.utils.Dictionary;

	import org.shared.ObjectPool;


	public class DebuffTray
	{
		private var _animation:Animation;
		private var _debuffCounts:Dictionary;
		private var _debuffIDs:Dictionary;
		private var _debuffs:Vector.<AssetVO>;
		private var _fields:Vector.<IRender>;
		private var _stackCounts:Dictionary;

		public function init():void
		{
			_debuffCounts = new Dictionary();
			_debuffIDs = new Dictionary();
			_debuffs = new Vector.<AssetVO>;
			_fields = new Vector.<IRender>;
			_stackCounts = new Dictionary();
		}

		public function Draw( anim:Animation, assetVO:AssetVO = null ):void
		{
			if (!anim)
			{
				removeIcons();
				_animation.removeListener(onAnimationReady);
				_animation.alpha = 0;
				_animation = anim;
			} else
			{
				_animation = anim;
				_animation.label = assetVO.spriteName;
				_animation.alpha = 0;
				if (!_animation.render)
					_animation.addListener(onAnimationReady);
				else
					onAnimationReady(Animation.ANIMATION_RENDER_ADDED, anim);
			}
		}

		public function addDebuff( id:String, assetVo:AssetVO, stackCount:int ):void
		{
			if (id != null)
				_debuffIDs[id] = assetVo.type;
			_stackCounts[assetVo.type] = stackCount
			if (!_debuffCounts.hasOwnProperty(assetVo.type))
			{
				_debuffCounts[assetVo.type] = 1;
				_debuffs.push(assetVo);
				if (_animation && _animation.ready && _animation.render)
					createDebuffIcon(assetVo, _debuffs.length - 0, stackCount);
			}
			updateDebuffIcons();
		}

		private function onAnimationReady( state:int, anim:Animation ):void
		{
			if (state == Animation.ANIMATION_RENDER_ADDED)
			{
				_animation.alpha = 1;
				_fields.push(anim.render);
				for (var i:int = 0; i < _debuffs.length; i++)
				{
					createDebuffIcon(_debuffs[i], i, _stackCounts[_debuffs[i].type]);
				}
				updateDebuffIcons();
			}
		}

		private function createDebuffIcon( assetVO:AssetVO, index:int, stackCount:int ):void
		{
			if (index > 0)
			{
				var render:IRender = getRender();
				if (Application.STARLING_ENABLED)
				{
					RenderSpriteStarling(_animation.render).addChild(RenderStarling(render));
				} else
				{
					RenderSprite(_animation.render).addChild(Render(render));
				}
				_fields.push(render);
			}
		}

		private function updateDebuffIcons():void
		{
			if (_animation && _animation.ready && _animation.render)
			{
				for (var i:int = 0; i < _debuffs.length; i++)
				{
					var assetVO:AssetVO     = _debuffs[i];
					if(assetVO == null)
						continue;
					
					var spriteName:String   = assetVO.spriteName;
					var levelPattern:RegExp = /1/i;
					var stackCount:int      = _stackCounts[assetVO.type];
					if (stackCount > 3)
						stackCount = 3;
					else if(stackCount == 0)
					{
						//This is required because of the way the debuff sprites are named (They start at 1 instead of 0)
						stackCount = 1;
					}
					spriteName = spriteName.replace(levelPattern, stackCount);
					
					if(_fields.length > i)
						_fields[i].updateFrame(_animation.spritePack.getFrame(spriteName, 0), _animation);
				}
				updateIconPositions();
			}
		}

		private function updateIconPositions():void
		{
			for (var i:int = 1; i < _fields.length; i++)
			{
				_fields[i].x = i * 15;
				_fields[i].y = 0;
			}
		}

		public function removeDebuff( id:String ):void
		{
			var count:Number = _debuffCounts[_debuffIDs[id]];
			count--;
			_debuffCounts[_debuffIDs[id]] = count;
			if (count == 0)
			{
				delete _debuffCounts[_debuffIDs[id]];
				delete _debuffCounts[_debuffIDs[id]];
				for (var i:int = 0; i < _debuffs.length; i++)
				{
					if (_debuffs[i].type == _debuffIDs[id])
					{
						_debuffs.splice(i, 1);
						delete _debuffIDs[id];
						if (_fields.length != _debuffs.length && _debuffs.length != 0 && _animation != null)
						{
							i = 1;
							if (Application.STARLING_ENABLED)
								RenderSpriteStarling(_animation.render).removeChild(RenderStarling(_fields[i]));
							else
								RenderSprite(_animation.render).removeChild(Render(_fields[i]));
							ObjectPool.give(_fields[i]);
							_fields.splice(i, 1);
						}
						updateDebuffIcons();
						updateIconPositions();

						return;
					}
				}
			}

		}

		private function removeIcons():void
		{	
			for (var i:int = 1; i < _fields.length; i++)
			{
				if(_fields[0] != null && _fields[i] != null)
				{
					if (Application.STARLING_ENABLED)
						RenderSpriteStarling(_fields[0]).removeChild(RenderStarling(_fields[i]));
					else
						RenderSprite(_fields[0]).removeChild(Render(_fields[i]));
				}
				if(_fields[i] != null)
					ObjectPool.give(_fields[i]);
			}
			if (_animation)
				_animation.removeListener(onAnimationReady);
			_fields.length = 0;
		}

		private function getRender():IRender
		{
			var render:IRender;
			if (Application.STARLING_ENABLED)
			{
				render = ObjectPool.get(RenderStarling);
			} else
			{
				render = ObjectPool.get(Render);
			}
			return render;
		}

		public function isDebuffsEmpty():Boolean
		{
			if (_debuffs.length == 0)
				return true;
			else
				return false;
		}

		public function destroy():void
		{
			removeIcons();
			if (_animation)
				_animation.removeListener(onAnimationReady);
			_animation = null;
			_debuffCounts = null;
			_debuffs.length = 0;
			_debuffCounts = null;
			_debuffIDs = null;
		}




	}
}

