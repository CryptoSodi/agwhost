package com.service.server.incoming.chat
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	
	public class ChatEventResponse implements IResponse
	{
		public var attacker:String;
		public var target:String;
		public var sector:String;
		public var locationX:Number;
		public var locationY:Number;
		
		private var _header:int;
		private var _protocolID:int;
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var type:int = input.readInt();
			if(type == 1)
			{
				attacker = input.readUTF();
				target = input.readUTF();
				sector = input.readUTF();
				locationX = input.readDouble();
				locationY = input.readDouble();
			}
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