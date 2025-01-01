package com.game.entity.nodes.starbase
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.starbase.Platform;

	import org.ash.core.Node;

	public class PlatformNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var platform:Platform;
		public var position:Position;
	}
}
