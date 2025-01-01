package com.game.entity.nodes.starbase
{
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Pylon;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.State;

	import org.ash.core.Node;

	public class BuildingNode extends Node
	{
		public var animation:Animation;
		public var building:Building;
		public var detail:Detail;
		public var $health:Health;
		public var position:Position;
		public var $pylon:Pylon;
		public var $state:State;
		public var $vcList:VCList;

		private var _callback:Function;

		public function init( callback:Function ):void
		{
			_callback = callback;
			if ($health)
			{
				$health.addListener(onHealthChanged);
				_callback(this, $health.percent, 0);
			} else
			{
				building.buildingVO.addHealthListener(onHealthChanged);
				_callback(this, building.buildingVO.currentHealth, 0);
			}
		}

		private function onHealthChanged( percent:Number, change:Number ):void
		{
			//update the buildingVO if needed the health updates are happening on the health component
			if ($health)
				building.buildingVO.currentHealth = percent;
			_callback(this, percent, change);
		}

		public function destroy():void
		{
			_callback = null;
			if ($health)
				$health.removeListener(onHealthChanged);
			else
				building.buildingVO.removeHealthListener(onHealthChanged);
			$health = null;
			$pylon = null;
			$state = null;
			$vcList = null;
		}
	}
}
