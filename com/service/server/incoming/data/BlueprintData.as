package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.service.server.BinaryInputStream;

	public class BlueprintData implements IServerData
	{
		public var id:String;
		public var blueprintPrototype:String;
		public var prototype:IPrototype;
		public var playerOwner:String;
		public var partsCollected:int;
		public var partsCollectedBank:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			
			input.checkToken();
			id = input.readUTF();
			input.checkToken();
			
			blueprintPrototype = input.readUTF();
			playerOwner = input.readUTF();			
			partsCollected = input.readInt();	
			partsCollectedBank = input.readInt();
			
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			id = data.key;
			blueprintPrototype = data.blueprintPrototype;
			playerOwner = data.playerOwner;
			partsCollected = data.partsCollected;
			partsCollectedBank = data.partsCollectedBank;
		}

		public function destroy():void
		{
			prototype = null;
		}
	}
}
