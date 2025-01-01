package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class AchievementData implements IServerData
	{
		public var key:String;
		public var achievementPrototype:String;
		public var claimedFlag:Boolean;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			key = input.readUTF();
			input.checkToken();
			achievementPrototype = input.readUTF();
			claimedFlag = input.readBoolean();
			input.readBoolean();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in AchievementData is not supported");
		}

		public function destroy():void
		{
		}
	}
}
