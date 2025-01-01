package com.game.entity.nodes.shared
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Node;

	public class MoveNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var move:Move;
		public var position:Position;
	}
}
