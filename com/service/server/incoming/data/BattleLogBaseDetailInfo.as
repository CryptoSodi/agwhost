package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class BattleLogBaseDetailInfo implements IServerData
	{
		public var baseHealth:Number;
		public var buildings:Vector.<BattleLogEntityDetailInfo>;
		public var baseRating:int;

		public function read( input:BinaryInputStream ):void
		{
			buildings = new Vector.<BattleLogEntityDetailInfo>;
			input.checkToken();
			baseHealth = input.readDouble();
			baseRating = input.readInt();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			buildings = new Vector.<BattleLogEntityDetailInfo>;
			baseRating = data.rating;
			baseHealth = data.health;
		}

		public function destroy():void
		{

		}
	}
}
