package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class MailInboxData implements IServerData
	{
		
		public var key:String;
		public var sender:String;
		public var subject:String;
		public var isRead:Boolean;
		public var timeSent:Number;
		
		
		public function read(input:BinaryInputStream):void
		{
			input.checkToken();
			key = input.readUTF(); // key
			sender = input.readUTF(); // senderName
			subject = input.readUTF(); // subject
			isRead = input.readBoolean(); // read flag
			timeSent = input.readInt64(); // when it was sent (UTC millis)
			input.checkToken();
			
		}
		
		public function readJSON(data:Object):void
		{
			key = data.key;
			sender = data.senderName;
			subject = data.subject;
			isRead = data.readFlag;
			timeSent = data.timeSent;
			
		}
		
		public function destroy():void
		{
		}
	}
}