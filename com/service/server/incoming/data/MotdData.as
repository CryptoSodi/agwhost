package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class MotdData implements IServerData
	{
		public var key:String;
		public var startTime:Number;
		public var title:String;
		public var subtitle:String;
		public var text:String;
		public var imageURL:String;
		public var isRead:Boolean;
		
		
		public function read(input:BinaryInputStream):void
		{
			input.checkToken();
			input.checkToken();
			key = input.readUTF();
			input.checkToken();
			startTime = input.readInt64();
			title = input.readUTF();
			subtitle = input.readUTF();
			text = input.readUTF();
			imageURL = input.readUTF();
			input.checkToken();

			isRead = input.readBoolean();
		}
		
		public function readJSON(data:Object):void
		{
			// Unimplemented.
		}
		
		public function destroy():void
		{
		}
	}
}