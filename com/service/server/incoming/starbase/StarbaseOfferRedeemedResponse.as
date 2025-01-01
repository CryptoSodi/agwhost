package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	public class StarbaseOfferRedeemedResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;
		
		public var offerPrototype:String;
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			offerPrototype = input.readUTF();
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
