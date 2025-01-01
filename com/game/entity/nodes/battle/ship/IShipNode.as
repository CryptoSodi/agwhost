package com.game.entity.nodes.battle.ship
{
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;

	public interface IShipNode
	{
		function get animation():Animation;
		function get detail():Detail;
		function get health():Health;
		function get ientity():Entity;
		function get inext():IShipNode;
		function get move():Move;
		function get position():Position;
		function get render():IRender;
		function get ship():Ship;
	}
}
