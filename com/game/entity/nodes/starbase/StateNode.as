package com.game.entity.nodes.starbase
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.starbase.State;

	import org.ash.core.Node;

	public class StateNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var state:State;
	}
}
