package com.service.server.incoming.proxy
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class AuthResponse implements IResponse
	{
		public function AuthResponse()
		{
		}

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
		}

		public function readJSON( input:Object ):void
		{
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return 0; }
		public function set header( v:int ):void  {}

		public function get protocolID():int  { return 0; }
		public function set protocolID( v:int ):void  {}

		public function destroy():void
		{
		}
	}
}
