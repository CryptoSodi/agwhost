package com.game.entity.components.shared.fsm
{
	import org.ash.core.Node;
	import org.shared.ObjectPool;

	public class FSM implements IFSMComponent
	{
		private var _component:IFSMComponent;

		public function init( component:IFSMComponent ):void
		{
			_component = component;
		}

		public function advanceState( node:Node ):Boolean
		{
			return _component.advanceState(node);
		}

		public function get component():IFSMComponent  { return _component; }

		public function get state():int  { return _component.state; }
		public function set state( v:int ):void  { _component.state = v; }

		public function destroy():void
		{
			ObjectPool.give(_component);
			_component = null;
		}
	}
}
