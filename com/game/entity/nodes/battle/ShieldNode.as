package com.game.entity.nodes.battle
{
	import com.game.entity.components.battle.Shield;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.starbase.Building;

	import org.ash.core.Node;

	public class ShieldNode extends Node
	{
		public var animation:Animation;
		public var $building:Building;
		public var shield:Shield;
		public var vcList:VCList;

		private var _enabledCallback:Function;
		private var _strengthCallback:Function;

		public function init( enabledCallback:Function, strengthCallback:Function ):void
		{
			_enabledCallback = enabledCallback;
			_strengthCallback = strengthCallback;
			shield.addEnableListener(onEnableChanged);
			shield.addStrengthListener(onStrengthChanged);
		}

		private function onStrengthChanged( current:int ):void  { _strengthCallback(this, current); }
		private function onEnableChanged( enabled:Boolean ):void  { _enabledCallback(this, enabled); }

		public function destroy():void
		{
			_enabledCallback = null;
			_strengthCallback = null;
			shield.removeEnableListener(onEnableChanged);
			shield.removeStrengthListener(onStrengthChanged);
			animation = null;
			$building = null;
			shield = null;
			vcList = null;
		}
	}
}
