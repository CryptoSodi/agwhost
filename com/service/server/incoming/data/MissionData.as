package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.service.server.BinaryInputStream;

	public class MissionData implements IServerData
	{
		public var accepted:Boolean;
		public var id:String;
		public var missionPrototype:String;
		public var prototype:IPrototype;
		public var playerOwner:String;
		public var progress:int;
		public var rewardAccepted:Boolean;
		public var sector:String;
		public var transgate:String;
		public var transGateSectorLocationX:Number;
		public var transGateSectorLocationY:Number;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			missionPrototype = input.readUTF();
			playerOwner = input.readUTF();
			transgate = input.readUTF();
			sector = input.readUTF();

			progress = input.readInt();
			accepted = input.readBoolean();
			rewardAccepted = input.readBoolean();

			input.readUTF(); //accepting fleet

			transGateSectorLocationX = input.readDouble();
			transGateSectorLocationY = input.readDouble();


			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			accepted = data.accepted;
			id = data.key;
			missionPrototype = data.missionPrototype;
			playerOwner = data.playerOwner;
			progress = data.progress;
			rewardAccepted = data.rewardAccepted;
			sector = data.sector;
			transgate = data.transGate;
		}

		public function get category():String  { return prototype.getUnsafeValue("category"); }

		public function destroy():void
		{
			prototype = null;
		}
	}
}
