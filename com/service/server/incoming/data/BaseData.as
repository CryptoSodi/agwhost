package com.service.server.incoming.data
{
	import com.model.player.CurrentUser;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	import org.shared.ObjectPool;

	public class BaseData implements IServerData
	{
		public var alloy:uint;
		public var credits:uint;
		public var energy:uint;
		public var id:String;
		public var lastUpdateTimeUTCMillis:Number;
		public var bubbleEnds:Number;
		public var bubbleTimeRemaining:Number;
		public var ownerID:String;
		public var sector:SectorData;
		public var sectorLocationX:int;
		public var sectorLocationY:Number;
		public var synthetic:uint;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			sector = ObjectPool.get(SectorData);
			sector.id = input.readUTF();

			ownerID = input.readUTF();

			alloy = input.readInt64();
			synthetic = input.readInt64();
			energy = input.readInt64();
			credits = input.readInt64();

			lastUpdateTimeUTCMillis = input.readInt64();
			bubbleEnds = input.readInt64();

			CurrentUser.baseRating = input.readInt();
			input.readInt(); // baseRatingTech - currently we don't use it in Client

			sectorLocationX = input.readDouble();
			sectorLocationY = input.readDouble();
			sector.prototype = PrototypeModel.instance.getSectorPrototypeByName(input.readUTF());
			sector.appearanceSeed = input.readInt();

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in BaseData is not supported");
		}

		public function destroy():void
		{
		}
	}
}
