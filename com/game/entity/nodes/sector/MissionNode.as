package com.game.entity.nodes.sector
{
	import com.game.entity.components.sector.Mission;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	
	import org.ash.core.Node;
	
	public class MissionNode extends Node
	{
		public var detail:Detail;
		public var mission:Mission;
		public var position:Position;
	}
}