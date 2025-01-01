package com.game.entity.components.shared.fsm
{
	import org.ash.core.Node;

	public interface IFSMComponent
	{
		function advanceState( node:Node ):Boolean;

		function get component():IFSMComponent;

		function get state():int;
		function set state( v:int ):void;

		function destroy():void
	}
}
