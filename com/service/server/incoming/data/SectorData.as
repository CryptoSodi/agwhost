package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class SectorData implements IServerData
	{
		public var appearanceSeed:int;
		public var id:String;
		public var neighborhood:Number;
		public var prototype:IPrototype;
		public var sectorEnum:IPrototype;
		public var sectorName:IPrototype;
		public var splitTestCohortPrototype:IPrototype;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			prototype = PrototypeModel.instance.getSectorPrototypeByName(input.readUTF());
			sectorName = PrototypeModel.instance.getSectorNamePrototypeByName(input.readUTF());
			sectorEnum = PrototypeModel.instance.getSectorNamePrototypeByName(input.readUTF());
			neighborhood = input.readInt64();
			appearanceSeed = input.readInt();
			splitTestCohortPrototype = PrototypeModel.instance.getSplitTestCohortPrototypeByName(input.readUTF());

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ShipData is not supported");
		}

		public function destroy():void
		{
			prototype = null;
			sectorEnum = null;
			sectorName = null;
		}
	}
}
