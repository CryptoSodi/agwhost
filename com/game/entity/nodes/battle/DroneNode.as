package com.game.entity.nodes.battle
{
	import com.game.entity.components.battle.Drone;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Move;
	
	import org.ash.core.Node;
	
	public class DroneNode extends Node
	{
		public var animation:Animation;
		public var drone:Drone;
		public var detail:Detail;
		public var position:Position;
		public var move:Move;
	}
}