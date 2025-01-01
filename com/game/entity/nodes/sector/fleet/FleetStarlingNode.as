package com.game.entity.nodes.sector.fleet
{
	import com.game.entity.components.shared.render.RenderStarling;
	import com.game.entity.components.sector.Fleet;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class FleetStarlingNode extends Node implements IFleetNode
	{
		public var internal_animation:Animation;
		public var internal_detail:Detail;
		public var internal_fleet:Fleet;
		public var internal_move:Move;
		public var internal_position:Position;
		public var internal_render:RenderStarling;

		public function get animation():Animation  { return internal_animation; }
		public function get detail():Detail  { return internal_detail; }
		public function get fleet():Fleet  { return internal_fleet; }
		public function get ientity():Entity  { return entity; }
		public function get inext():IFleetNode  { return next; }
		public function get move():Move  { return internal_move; }
		public function get position():Position  { return internal_position; }
		public function get render():IRender  { return internal_render; }
	}
}
