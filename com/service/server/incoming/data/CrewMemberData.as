package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.service.server.BinaryInputStream;

	public class CrewMemberData implements IServerData
	{
		public var fleetOwner:String;
		public var crewMemberPrototype:String;
		public var rarity:int;
		public var rank:String;
		public var playerOwner:String;
		public var firstName:Number;
		public var lastName:Number;
		public var xp:Number;
		public var crewState:int;
		public var trainingStarted:Number;
		public var trainingEnds:Number;
		public var indoctrinated:Boolean;
		public var pendingXp:Number;
		public var pendingAdvancementSlot1:String;
		public var pendingAdvancementSlot2:String;
		public var pendingAdvancementSlot3:String;
		public var pendingAdvancementSlot4:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			fleetOwner = input.readUTF();
			crewMemberPrototype = input.readUTF();
			rarity = input.readInt();
			rank = input.readUTF();
			playerOwner = input.readUTF();
			firstName = input.readInt64();
			lastName = input.readInt64();
			xp = input.readInt64();
			crewState = input.readInt();
			trainingStarted = input.readInt64();
			trainingEnds = input.readInt64();
			indoctrinated = input.readBoolean();
			pendingXp = input.readInt64();
			pendingAdvancementSlot1 = input.readUTF();
			pendingAdvancementSlot2 = input.readUTF();
			pendingAdvancementSlot3 = input.readUTF();
			pendingAdvancementSlot4 = input.readUTF();

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function destroy():void
		{
		}
	}
}
