package com.game.entity.components.battle
{
	import com.service.server.incoming.data.SectorBattleData;

	public class Attack
	{
		public var attackData:*;
		public var battleServerAddress:String;
		public var bubbled:Boolean  = false;
		public var inBattle:Boolean = false;

		private var _organicTargetID:String;
		private var _targetID:String;

		public var battle:SectorBattleData;

		public function get organicTargetID():String  { return _organicTargetID; }
		public function set organicTargetID( v:String ):void  { _organicTargetID = v; }

		public function get targetID():String  { return _targetID; }
		public function set targetID( v:String ):void  { _targetID = v; }

		public function destroy():void
		{
			attackData = null;
			battleServerAddress = null;
			bubbled = false;
			inBattle = false;
			_organicTargetID = null;
			_targetID = null;
			battle = null;
		}
	}
}
