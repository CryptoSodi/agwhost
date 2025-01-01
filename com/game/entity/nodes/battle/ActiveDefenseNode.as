package com.game.entity.nodes.battle
{
	import com.game.entity.components.battle.ActiveDefense;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Node;

	public class ActiveDefenseNode extends Node
	{
		public var activeDefense:ActiveDefense;
		public var animation:Animation;
		public var detail:Detail;
		public var position:Position;
	}
}
