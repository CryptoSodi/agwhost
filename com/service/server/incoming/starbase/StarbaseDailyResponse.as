package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	import org.shared.ObjectPool;
	
	public class StarbaseDailyResponse implements IResponse
	{
		public var escalation:int;
		public var canNextClaimDelta:Number;
		public var dailyResetsDelta:Number;
		
		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			escalation = input.readInt(); // level of daily reward available
			canNextClaimDelta = input.readInt64(); // if this is > 0, it's number of milliseconds until you can claim again
			dailyResetsDelta = input.readInt64(); // if this is > 0, your daily escalation will be reset to 0 after this number of milliseconds
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
