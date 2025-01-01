package com.service.server.incoming.chat
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class ChatResponse implements IResponse
	{
		public var responseCode:int;
		public var channel:int;
		public var senderKey:String;
		public var senderName:String;
		public var senderFaction:String;
		public var message:String;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			responseCode = input.readInt();
			channel = input.readInt();
			senderKey = input.readUTF();
			senderName = input.readUTF();
			senderFaction = input.readUTF();
			message = input.readUTF();
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
