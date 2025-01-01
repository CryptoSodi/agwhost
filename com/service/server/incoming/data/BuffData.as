package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class BuffData implements IServerData
	{
		public var baseID:String;
		public var began:Number;
		public var ends:Number;
		public var id:String;
		public var playerOwnerID:String;
		public var prototype:IPrototype;
		public var timeRemaining:Number;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			prototype = PrototypeModel.instance.getBuffPrototype(input.readUTF());
			/* storeItemPrototype*/
			input.readUTF();
			baseID = input.readUTF();
			playerOwnerID = input.readUTF();
			began = input.readInt64();
			ends = input.readInt64();

			input.checkToken();
		}

		public function set now( v:Number ):void
		{
			timeRemaining = ends - v;
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in BuffData is not supported");
		}

		public function destroy():void
		{
			prototype = null;
		}
	}
}
