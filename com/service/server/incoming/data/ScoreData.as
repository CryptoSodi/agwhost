package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class ScoreData implements IServerData
	{
		public var key:String;
		public var scoreKey:String;
		public var value:Number;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			key = input.readUTF();
			input.checkToken();
			scoreKey = input.readUTF();
			value = input.readInt64();
			
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ScoreData is not supported");
		}

		public function destroy():void
		{
		}
	}
}
