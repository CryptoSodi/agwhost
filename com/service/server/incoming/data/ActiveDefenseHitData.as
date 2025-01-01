package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class ActiveDefenseHitData implements IServerData
	{
		public var attachPoint:String;
		public var owningShip:String;
		public var target:String;

		public function read( input:BinaryInputStream ):void
		{
			//Target here is guaranteed to be unique, and is intended to be used when an attack is removed with reason "intercepted" to determine who shot it down.
			//In C++-land, this is a map of target : attachPoint/owningShip objects.
			target = "Attack" + input.readUnsignedInt();
			attachPoint = input.readUTF();
			owningShip = input.readUTF();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ActiveDefenseHitData is not supported");
		}

		public function destroy():void
		{

		}
	}
}
