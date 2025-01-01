package com.game.entity.nodes.battle
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.DebugLine;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.render.RenderStarling;

	import org.ash.core.Node;

	public class DebugLineNode extends Node
	{
		public var debugLine:DebugLine;
		public var position:Position;
		public var anim:Animation;
		public var render:RenderStarling;
	}
}
