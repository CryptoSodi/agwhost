package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.AchievementData;
	import com.service.server.incoming.data.ScoreData;

	import org.shared.ObjectPool;

	public class StarbaseAchievementsResponse implements IResponse
	{
		public var unlockToast:Boolean;
		public var achievements:Vector.<AchievementData> = new Vector.<AchievementData>;
		public var scores:Vector.<ScoreData>             = new Vector.<ScoreData>;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			unlockToast = input.readBoolean();
			
			var i:uint
			var achievementData:AchievementData;
			var len:uint = input.readUnsignedInt();
			for (i = 0; i < len; ++i)
			{
				achievementData = ObjectPool.get(AchievementData);
				input.readUTF(); // key
				achievementData.read(input);
				achievements.push(achievementData);
			}

			var scoreData:ScoreData;
			len = input.readUnsignedInt();
			for (i = 0; i < len; ++i)
			{
				scoreData = ObjectPool.get(ScoreData);
				input.readUTF(); // key
				scoreData.read(input);
				scores.push(scoreData);
			}

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			// Unimplemented.
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
