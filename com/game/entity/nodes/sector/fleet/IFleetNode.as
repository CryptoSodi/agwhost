package com.game.entity.nodes.sector.fleet
{
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.sector.Fleet;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;

	public interface IFleetNode
	{
		function get animation():Animation;
		function get detail():Detail;
		function get fleet():Fleet;
		function get ientity():Entity;
		function get inext():IFleetNode;
		function get move():Move;
		function get position():Position;
		function get render():IRender;
	}
}
