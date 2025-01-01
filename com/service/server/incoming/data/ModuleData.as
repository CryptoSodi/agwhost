package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import com.service.server.replicable.ReplicableStruct;

	public class ModuleData extends ReplicableStruct implements IServerData
	{
		public var moduleIdx:int;
		public var type:int;
		public var isActive:Boolean;

		public var offsetX:int;
		public var offsetY:int;

		public var modulePrototype:String;
		public var weaponPrototype:String;
		public var activeDefensePrototype:String;
		public var slotPrototype:String;
		public var attachPointPrototype:String;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			moduleIdx = input.readInt();
			type = input.readInt();
			isActive = input.readBoolean();
			offsetX = input.readDouble();
			offsetY = input.readDouble();
			modulePrototype = input.readUTF();
			weaponPrototype = input.readUTF();
			activeDefensePrototype = input.readUTF();
			slotPrototype = input.readUTF();
			attachPointPrototype = input.readUTF();
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				} else
				{
					// TODO - complain about missing key?
				}
			}
		}

		public function destroy():void
		{

		}
	}
}


