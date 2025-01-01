package com.game.entity.components.shared.fsm
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.nodes.shared.FSMNode;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import org.ash.core.Node;

	public class TurretFSM implements IFSMComponent
	{

		public static const DEFAULT:int  = -1;
		public static const INIT:int     = 0;
		public static const SCANNING:int = 1;
		public static const TRACKING:int = 2;
		public static const PAUSED:int   = 3;

		//the animation component of the turret. If this is null it either means the player does not have a gun equipped or the turret is offscreen
		public var animation:Animation;

		private var _state:int;

		public function TurretFSM()
		{
			_state = INIT;
		}

		private var crntRotation:Number;
		private var nextRotation:Number;

		private var increment:Number     = 0.0625;
		//		private var increment:Number     = 1;
		private var dir:int              = 1;

		private var timer:Timer;

		public function advanceState( node:Node ):Boolean
		{
			var fsmNode:FSMNode = node as FSMNode;
			var advanceState:Boolean;
			var proceed:Boolean = true;

			if (!node)
				return false;

			switch (_state)
			{
				case INIT:
				{
					if (isNaN(crntRotation))
						crntRotation = Math.random() * Math.PI * 2;
					nextRotation = Math.random() * Math.PI * 2;
					_state = SCANNING;
					break;
				}

				case SCANNING:
				{
					var delta:Number = dir == 1 ? nextRotation - crntRotation : crntRotation - nextRotation;

					if (delta <= increment * 2)
					{
						dir *= -1;
						_state = PAUSED;

						proceed = false;
						break;
					}

					crntRotation += increment * dir;

					break;
				}

				case PAUSED:
				{
					if (!timer)
					{
						timer = new Timer(Math.random() * 5000);
						timer.addEventListener(TimerEvent.TIMER, onTimer);
						timer.start();
					}

					break;
				}
			}

			if (proceed)
				rotateTurretGraphic(crntRotation);

			return true;
		}

		private function onTimer( event:TimerEvent ):void
		{
			_state = INIT;

			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer = null;
		}

		private function rotateTurretGraphic( rotation:Number, isRadians:Boolean = true ):void
		{
			if (!animation)
				return;

			var degrees:Number = isRadians ? (rotation / Math.PI) * 180 : rotation;
			degrees = degrees % 360;

			if (degrees < 0)
				degrees += 360;

			var num:int        = degrees / 8.18 | 0;
			animation.frame = num;

			if (animation.render && animation.spritePack)
				animation.render.updateFrame(animation.spritePack.getFrame(animation.label, num), animation);
		}

		public function get component():IFSMComponent  { return this; }

		public function get state():int  { return 0; }
		public function set state( v:int ):void  {}

		public function destroy():void
		{
			animation = null;
			_state = INIT;
		}
	}
}
