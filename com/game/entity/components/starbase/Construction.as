package com.game.entity.components.starbase
{
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.shared.fsm.IFSMComponent;
	import com.game.entity.nodes.shared.FSMNode;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class Construction implements IFSMComponent
	{
		public static const BEGIN:int        = 0;
		public static const BEAM_DESCEND:int = 1;
		public static const STABLE:int       = 2;
		public static const BEAM_ASCEND:int  = 3;
		public static const END:int          = 4;
		public static const DONE:int         = 5;
		public static const RESTABILIZE:int  = 6;

		public var alpha:Number;
		public var beam:Entity;
		public var beam2:Entity;
		public var beamScaleY:Number;
		public var glow:Entity;
		public var mothership:Entity;
		public var owner:Entity;
		public var positionOffset:Number;
		public var ypos:Number;

		private var _alphaCount:Number;
		private var _positionCount:Number;
		private var _positionMod:Number;
		private var _state:int;

		public function Construction()
		{
			_alphaCount = 0;
			_positionCount = positionOffset = 0;
			_positionMod = 2;
			_state = BEGIN;
		}

		public function advanceState( node:Node ):Boolean
		{
			var animation:Animation;
			var cNode:FSMNode = FSMNode(node);
			switch (_state)
			{
				case BEGIN:
					adjustAlpha(0);
					cNode.animation.alpha += .05;
					if (cNode.animation.alpha >= 1)
					{
						cNode.animation.alpha = 1;
						state = Construction.BEAM_DESCEND;
					}
					break;
				case BEAM_DESCEND:
					adjustAlpha(_alphaCount + 2);
					animation = beam.get(Animation);
					animation.scaleY += .05;
					animation.render.scaleY += .05;
					animation = beam2.get(Animation);
					animation.scaleY += .05;
					animation.render.scaleY += .05;
					animation.alpha = 0;
					animation.render.alpha = 0;
					if (_alphaCount >= 100 && animation.render.scaleY >= beamScaleY)
						state = Construction.STABLE;
					if (animation.render.scaleY >= beamScaleY)
					{
						animation.render.scaleY = beamScaleY;
						animation = beam.get(Animation);
						animation.render.scaleY = beamScaleY;
					}
					SoundController.instance.playSound(AudioEnum.AFX_BLD_CONSTRUCTION_START, 0.6, 0, 0);
					break;
				case STABLE:
					adjustAlpha();
					break;
				case RESTABILIZE:
					animation = beam.get(Animation);
					animation.render.scaleY = beamScaleY;
					animation = beam2.get(Animation);
					animation.render.scaleY = beamScaleY;
					cNode.animation.alpha = 1;
					state = Construction.STABLE;
					break;
				case BEAM_ASCEND:
					animation = beam.get(Animation);
					animation.alpha = (animation.alpha > 0) ? animation.alpha - .1 : 0;
					animation.render.alpha = animation.alpha;
					var animation2:Animation = beam2.get(Animation);
					animation2.alpha = (animation2.alpha > 0) ? animation2.alpha - .1 : 0;
					animation2.render.alpha = animation2.alpha;
					var animation3:Animation = glow.get(Animation);
					animation3.alpha = (animation3.alpha > 0) ? animation3.alpha - .1 : 0;
					animation3.render.alpha = animation3.alpha;
					if (animation.alpha <= 0 && animation2.alpha <= 0 && animation3.alpha <= 0)
						state = Construction.END;
					SoundController.instance.playSound(AudioEnum.AFX_BLD_CONSTRUCTION_COMPLETE, 1.0, 0, 0);
					break;
				case END:
					cNode.animation.alpha -= .1;
					if (cNode.animation.alpha <= 0)
					{
						state = Construction.DONE;
						var vcList:VCList = owner.get(VCList);
						vcList.removeComponentType(TypeEnum.BUILDING_CONSTRUCTION);
						return false;
					}
					break;
			}
			//adjust position
			if (_state != DONE)
				adjustPosition();

			return true;
		}

		private function adjustAlpha( value:Number = -1 ):void
		{
			if (value == -1)
				_alphaCount += 1.5;
			else
				_alphaCount = value;
			alpha = Math.abs(((_alphaCount / 100 | 0) % 2) - (_alphaCount % 100) * .01);

			//adjust the alphas
			var animation:Animation = beam.get(Animation);
			animation.alpha = alpha;
			animation.render.alpha = alpha;
			animation = beam2.get(Animation);
			animation.alpha = (value != -1) ? alpha : 1 - alpha;
			animation.render.alpha = alpha;
			animation = glow.get(Animation);
			animation.alpha = alpha;
			animation.render.alpha = alpha;
		}

		private function adjustPosition():void
		{
			_positionCount += .1;
			positionOffset = ypos + _positionMod * Math.sin(_positionCount);

			//adjust the positions
			var animation:Animation = glow.get(Animation);
			animation.render.y = positionOffset;
			animation = mothership.get(Animation);
			animation.render.y = positionOffset;
		}

		public function get component():IFSMComponent  { return this; }

		public function get state():int  { return _state; }
		public function set state( v:int ):void
		{
			_state = v;
			switch (_state)
			{
				case BEAM_ASCEND:
					_alphaCount % 100;
					break;
			}
		}

		public function destroy():void
		{
			alpha = _alphaCount = 0;
			beam = null;
			beam2 = null;
			glow = null;
			mothership = null;
			owner = null;
			_positionCount = positionOffset = 0;
			state = BEGIN;
		}
	}
}
