package com.game.entity.nodes.shared.grid
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;
	import org.ash.core.Node;

	public class GridNode extends Node implements IGridNode
	{
		public var internal_animation:Animation;
		public var internal_grid:Grid;
		public var internal_position:Position;

		public function get animation():Animation  { return internal_animation; }
		public function get ientity():Entity  { return entity; }
		public function get grid():Grid  { return internal_grid; }
		public function get position():Position  { return internal_position; }
	}
}
