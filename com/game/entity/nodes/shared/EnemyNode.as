package com.game.entity.nodes.shared
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Node;

	public class EnemyNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var interactable:Interactable;
		public var enemy:Enemy;
		public var position:Position;
	}
}
