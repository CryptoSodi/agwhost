package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	import org.shared.ObjectPool;
	
	public class StarbaseDailyRewardResponse implements IResponse
	{
		public var alloyReward:Number;
		public var creditsReward:Number;
		public var energyReward:Number;
		public var syntheticReward:Number;
		public var blueprintPrototype:String;
		public var buffPrototype:String;
		
		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			alloyReward = input.readInt64();
			creditsReward = input.readInt64();
			energyReward = input.readInt64();
			syntheticReward = input.readInt64();
			buffPrototype = input.readUTF();
			blueprintPrototype = input.readUTF();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			// Unimplemented.
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