package com.service.server.incoming.alliance
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class AllianceGenericResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var responseEnum:int;
		public var allianceKey:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			responseEnum = input.readInt(); // response code enum
			allianceKey = input.readUTF(); // alliance key
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
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
