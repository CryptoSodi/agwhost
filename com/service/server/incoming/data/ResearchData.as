package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class ResearchData implements IServerData
	{
		public var baseID:String;
		public var id:String = '';
		public var playerOwnerID:String;
		public var prototype:IPrototype;
		public var buildState:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			id= input.readUTF();
			input.checkToken();

			prototype = PrototypeModel.instance.getResearchPrototypeByName(input.readUTF());
			baseID = id.substr(0,id.indexOf(".research"));
			//input.readUTF();
			playerOwnerID = id.substr(0,id.indexOf(".base"));
			//input.readUTF();
			//input.readUTF(); //building owner id
			buildState = input.readInt();

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ResearchData is not supported");
		}

		public function destroy():void
		{
			prototype = null;
		}
	}
}
