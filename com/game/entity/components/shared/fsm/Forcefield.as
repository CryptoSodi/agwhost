package com.game.entity.components.shared.fsm
{
	import com.Application;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.render.Render;
	import com.game.entity.components.shared.render.RenderSprite;
	import com.game.entity.components.shared.render.RenderSpriteStarling;
	import com.game.entity.components.shared.render.RenderStarling;
	import com.model.starbase.BuildingVO;

	import org.ash.core.Node;
	import org.shared.ObjectPool;

	public class Forcefield implements IFSMComponent
	{
		public static const BEGIN:int               = 0;
		public static const POWER_ON:int            = 1;
		public static const STABLE:int              = 2;
		public static const POWER_OFF:int           = 3;
		public static const END:int                 = 4;

		private static const POWER_ON_SPEED:Number  = .3;
		private static const POWER_OFF_SPEED:Number = .45;

		public var animation:Animation;
		public var building:BuildingVO;
		public var color:uint;

		private var _fields:Vector.<IRender>;
		private var _render:IRender;
		private var _state:int;

		public function Forcefield()
		{
			_fields = new Vector.<IRender>;
			_state = BEGIN;
		}

		public function advanceState( node:Node ):Boolean
		{
			var i:int;
			var lengths:int;
			var num:Number;
			switch (_state)
			{
				case BEGIN:
					if (animation.ready && animation.render && _fields.length == 0)
					{
						animation.render.color = color;
						animation.render.alpha = 0;
						animation.alpha = 0;
						_fields.push(animation.render);
						_render = animation.render;
						var dir:int = (building.sizeX > 5) ? 1 : -1;
						lengths = ((building.sizeX > 5) ? building.sizeX / 5 : building.sizeY / 5) - 1;
						for (i = 0; i < lengths; i++)
						{
							createFieldLength(i + 1, dir);
						}
						state = POWER_ON;
					}
					break;

				case POWER_ON:
					if (!animation.render)
					{
						removeFieldLengths();
						state = BEGIN;
					}
					lengths = _fields.length - 1;
					
					if(lengths<0)
						break;
						
					num = Math.round(_fields.length * .5);
					
					if(_fields.length <= num)
						num = _fields.length - 1;
					
					for (i = 0; i < num; i++)
					{
						if (_fields[i].alpha != 1)
							break;
					}
					if (i == 0)
					{
						animation.alpha += POWER_ON_SPEED;
						if (animation.alpha > 1)
							animation.alpha = 1;
					}
					_fields[i].alpha += POWER_ON_SPEED;
					if (_fields[i].alpha >= 1)
					{
						_fields[i].alpha = 1;
						if (i == num - 1)
							state = STABLE;
					}
					
					if (_fields[i] != _fields[lengths - i])
						_fields[lengths - i].alpha = _fields[i].alpha;
					break;

				case STABLE:
					if (!animation.render)
					{
						removeFieldLengths();
						state = BEGIN;
					}
					break;

				case POWER_OFF:
					removeFieldLengths();
					state = BEGIN;
					break;

				case END:
					removeFieldLengths();
					state = BEGIN;
					return false;
					break;
			}

			return true;
		}

		public function adjustFieldLengths():void
		{
			if (_render && _state != BEGIN && _state != POWER_OFF && _state != END)
			{
				var dir:int     = (building.sizeX > 5) ? 1 : -1;
				var lengths:int = ((building.sizeX > 5) ? building.sizeX / 5 : building.sizeY / 5);
				if (lengths != _fields.length)
				{
					var lengthRender:IRender;
					if (_state == POWER_ON)
					{
						for (var i:int = 0; i < _fields.length; i++)
							_fields[i].alpha = 1;
						animation.alpha = 1;
						state = STABLE;
					}
					while (_fields.length != lengths)
					{
						if (_fields.length < lengths)
							createFieldLength(_fields.length, dir, 1);
						else
						{
							lengthRender = _fields.pop();
							if (Application.STARLING_ENABLED)
								RenderSpriteStarling(_render).removeChild(RenderStarling(lengthRender));
							else
								RenderSprite(_render).removeChild(Render(lengthRender));
							ObjectPool.give(lengthRender);
						}
					}
				}
			}
		}

		private function createFieldLength( count:int, direction:int, alpha:Number = 0 ):IRender
		{
			var render:IRender;
			if (Application.STARLING_ENABLED)
			{
				render = ObjectPool.get(RenderStarling);
				RenderSpriteStarling(animation.render).addChild(RenderStarling(render));
			} else
			{
				render = ObjectPool.get(Render);
				RenderSprite(animation.render).addChild(Render(render));
			}
			render.x = 64.7 * count * direction;
			render.y = 32 * count;
			render.alpha = alpha;
			render.color = color;
			render.updateFrame(animation.spritePack.getFrame(animation.label, 0), animation);
			_fields.push(render);
			return render;
		}

		private function removeFieldLengths():void
		{
			if (_render)
			{
				for (var i:int = 1; i < _fields.length; i++)
				{
					if (Application.STARLING_ENABLED)
						RenderSpriteStarling(_render).removeChild(RenderStarling(_fields[i]));
					else
						RenderSprite(_render).removeChild(Render(_fields[i]));
					ObjectPool.give(_fields[i]);
				}
				_render = null;
			}
			_fields.length = 0;
		}

		public function get component():IFSMComponent  { return this; }

		public function get state():int  { return _state; }
		public function set state( v:int ):void  { _state = v; }

		public function destroy():void
		{
			removeFieldLengths();
			_render = null;
			_state = BEGIN;

			animation = null;
			building = null;
		}
	}
}
