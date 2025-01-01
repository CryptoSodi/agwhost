package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class StarbaseBattleAlertResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var homeBaseBattle:String; // note that these are all serverIdentifier strings that can be used to ConnectToBattle
		public var centerSpaceBaseBattle:String;
		public var fleetBattles:Object = new Object;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			homeBaseBattle = input.readUTF();
			centerSpaceBaseBattle = input.readUTF();
			var mapSize:int = input.readUnsignedInt();
			for (var i:int = 0; i < mapSize; i++)
			{
				fleetBattles[input.readUTF()] = input.readUTF();
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			homeBaseBattle = data.homeBaseBattle;
			centerSpaceBaseBattle = data.centerSpaceBaseBattle;
			fleetBattles = data.Battles;
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }


		public function destroy():void
		{
			fleetBattles = null;
		}
	}
}
