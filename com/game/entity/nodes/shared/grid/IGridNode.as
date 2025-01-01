package com.game.entity.nodes.shared.grid
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Position;

	import org.ash.core.Entity;

	public interface IGridNode
	{
		function get animation():Animation;
		function get ientity():Entity;
		function get grid():Grid;
		function get position():Position;
	}
}
