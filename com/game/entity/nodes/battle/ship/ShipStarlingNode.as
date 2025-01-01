package com.game.entity.nodes.battle.ship
{
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.shared.render.RenderStarling;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class ShipStarlingNode extends Node implements IShipNode
	{
		public var internal_animation:Animation;
		public var internal_detail:Detail;
		public var internal_health:Health;
		public var internal_move:Move;
		public var internal_position:Position;
		public var internal_render:RenderStarling;
		public var internal_ship:Ship;

		public function get animation():Animation  { return internal_animation; }
		public function get detail():Detail  { return internal_detail; }
		public function get health():Health  { return internal_health; }
		public function get ientity():Entity  { return entity; }
		public function get inext():IShipNode  { return next; }
		public function get move():Move  { return internal_move; }
		public function get position():Position  { return internal_position; }
		public function get render():IRender  { return internal_render; }
		public function get ship():Ship  { return internal_ship; }
	}
}
