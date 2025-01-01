package com.game.entity.nodes.battle
{
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.VCList;

	import org.ash.core.Node;

	public class HealthNode extends Node
	{
		public var animation:Animation;
		public var detail:Detail;
		public var health:Health;
		public var vcList:VCList;

		private var _callback:Function;

		public function init( callback:Function ):void
		{
			_callback = callback;
			health.addListener(onHealthChanged);
		}

		private function onHealthChanged( percent:Number, change:Number ):void  { _callback && _callback(this, percent, change); }

		public function destroy():void
		{
			_callback = null;
			health.removeListener(onHealthChanged);
		}
	}
}
