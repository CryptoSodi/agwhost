package com.game.entity.components.shared.fsm
{
	import com.game.entity.components.shared.Animation;

	import org.ash.core.Node;

	public class BuildingShieldFSM implements IFSMComponent
	{
		public static const BEGIN:int     = 0;
		public static const POWER_ON:int  = 1;
		public static const STABLE:int    = 2;
		public static const HIT:int       = 3;
		public static const POWER_OFF:int = 4;
		public static const END:int       = 5;

		public var animation:Animation;

		private var _state:int;

		public function BuildingShieldFSM()
		{
			_state = BEGIN;
		}

		public function advanceState( node:Node ):Boolean
		{
			var animation:Animation;
			switch (_state)
			{
				case BEGIN:
					break;
				case POWER_ON:
					break;
				case STABLE:
					break;
				case HIT:
					break;
				case POWER_OFF:
					break;
				case END:
					break;
			}
			return true;
		}

		public function get component():IFSMComponent  { return this; }

		public function get state():int  { return _state; }
		public function set state( v:int ):void  { _state = v; }

		public function destroy():void
		{
			animation = null;
			state = BEGIN;
		}
	}
}
