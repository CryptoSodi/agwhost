package com.service.server.incoming.battle
{
	import com.enum.server.ResponseEnum;
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;

	public class BattleDataResponse implements ITickedResponse
	{
		// ITickedReponse stuff
		private var _header:int;
		private var _protocolID:int;
		public var _tick:int;
		public var _timeStep:int;
		
		private var _data:BinaryInputStream = new BinaryInputStream;
		
		public function read( input:BinaryInputStream ):void
		{
			input.readBytes( _data, 0, input.bytesAvailable - 8 );
			_tick = input.readInt();
			_timeStep = input.readInt();
			_data.sequenceToken = input.sequenceToken;
			_data.setStringInputCache( input.battleStringInputCache );
			// the final checkToken can't be done yet since there may be other tokens embedded in the binary data 
		}
		
		public function readJSON( data:Object ):void
		{
			throw new Error("this is unsupported");
		}		
		
		public function get input():BinaryInputStream  { return _data; }

		public function get isBaseline():Boolean  { return _header == ResponseEnum.BATTLE_BASELINE; }
		public function get isTicked():Boolean  { return true; }
 		public function get addTick():Boolean  { return true; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		public function get tick():int  { return _tick }
		public function get timeStep():int  { return _timeStep; }
		
		public function destroy():void {} 

	}
}
	
