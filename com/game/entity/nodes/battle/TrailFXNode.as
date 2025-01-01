package com.game.entity.nodes.battle
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.battle.TrailFX;

	import org.ash.core.Node;

	public class TrailFXNode extends Node
	{
		public var animation:Animation;
		public var position:Position;
		public var trail:TrailFX;
	}
}


