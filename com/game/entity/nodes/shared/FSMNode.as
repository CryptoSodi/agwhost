package com.game.entity.nodes.shared
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.fsm.FSM;

	import org.ash.core.Node;

	public class FSMNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var fsm:FSM;
	}
}
