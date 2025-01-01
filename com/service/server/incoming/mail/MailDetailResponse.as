package com.service.server.incoming.mail
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;

	public class MailDetailResponse implements IResponse
	{
		public var key:String;
		public var sender:String;
		public var senderAlliance:String;
		public var senderRace:String;
		public var body:String;
		public var html:Boolean;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			key = input.readUTF();
			sender = input.readUTF();
			senderAlliance = input.readUTF();
			senderRace = input.readUTF();
			body = input.readUTF();
			html = input.readBoolean();
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
