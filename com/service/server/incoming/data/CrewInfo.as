package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class CrewInfo implements IServerData
	{
		public var prototype:String;
		public var rank:String;
		public var rarity:int;
		public var firstName:String; // first name prototype
		public var lastName:String; // last name prototype

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			prototype = input.readUTF();
			rank = input.readUTF();
			rarity = input.readInt();
			firstName = input.readUTF();
			lastName = input.readUTF();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			prototype = data.prototype;
			rank = data.rank;
			rarity = data.rarity;
			firstName = data.firstName;
			lastName = data.lastName;
		}

		public function destroy():void
		{
		}
	}
}
