package com.service.server.incoming.proxy
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class TimeSyncResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var clientNow:int = input.readInt();
			var serverNow:Number = input.readInt64();
			/*ServerTime.CLIENT_TIME = getTimer();
			   ServerTime.LATENCY = (ServerTime.CLIENT_TIME - clientNow) / 2;
			   ServerTime.SERVER_TIME = ReadUtil.readSignedFixedInt64(input).toNumber() + ServerTime.LATENCY;*/
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
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
