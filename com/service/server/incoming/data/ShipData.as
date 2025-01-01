package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	import flash.utils.Dictionary;

	public class ShipData implements IServerData
	{
		public var currentHealth:Number;
		public var fleetOwner:String;
		public var shipName:String;
		public var positionIndex:int;
		public var i:int;
		public var id:String;
		public var modules:Dictionary;
		public var ownerID:String;
		public var prototype:IPrototype;
		public var refitModules:Dictionary;
		public var buildState:int;

		public function read( input:BinaryInputStream ):void
		{
			var prototypeModel:PrototypeModel = PrototypeModel.instance;

			input.checkToken();
			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			prototype = prototypeModel.getShipPrototype(input.readUTF());
			ownerID = input.readUTF();
			fleetOwner = input.readUTF();
			positionIndex = input.readInt();
			//shipName = "Unknown";
			shipName = input.readUTF();
			/* refitShipName */
			input.readUTF();
			/* baseOwner = */
			input.readUTF();
			currentHealth = input.readDouble();
			buildState = input.readInt();

			var slotName:String;
			var modulePrototype:String;

			// current modules
			var numModules:int                = input.readUnsignedInt();
			modules = new Dictionary();
			for (i = 0; i < numModules; i++)
			{
				slotName = input.readUTF();
				modulePrototype = input.readUTF();
				modules[slotName] = prototypeModel.getWeaponPrototype(modulePrototype);
			}

			// refit modules
			numModules = input.readUnsignedInt();
			if (numModules > 0)
				refitModules = new Dictionary();
			for (i = 0; i < numModules; i++)
			{
				slotName = input.readUTF();
				modulePrototype = input.readUTF();
				refitModules[slotName] = prototypeModel.getWeaponPrototype(modulePrototype);
			}

			//fill in any missing slots
			//var slots:Array                   = prototype.getValue("slots");
			//for (i = 0; i < slots.length; i++)
			//{
			//	slotName = slots[i];
			//	modules[slotName] = modules[slotName];
			//}

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in ShipData is not supported");
		}

		public function destroy():void
		{
			modules = null;
			prototype = null;
			refitModules = null;
		}
	}
}
