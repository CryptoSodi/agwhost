package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	public class StarbaseInstancedMissionAlertResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;
		
		public var instancedMissionBattle:String; // note that these are all serverIdentifier strings that can be used to ConnectToBattle
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			instancedMissionBattle = input.readUTF();
			input.checkToken();
		}
		
		public function readJSON( data:Object ):void
		{
			instancedMissionBattle = data.quickMissionBattle;
		}
		
		public function get isTicked():Boolean  { return false; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		
		public function destroy():void
		{
		}
	}
}
