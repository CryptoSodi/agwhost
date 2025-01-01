package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	import flash.utils.Dictionary;

	public class BuildingData implements IServerData
	{
		public var baseID:String;
		public var baseX:Number;
		public var baseY:Number;
		public var buildState:int;
		public var currentHealth:Number;
		public var id:String;
		public var modules:Dictionary;
		public var playerOwnerID:String;
		public var refitModules:Dictionary;
		public var prototype:IPrototype;
		public var type:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			var prototypeModel:PrototypeModel = PrototypeModel.instance;
			type = input.readUTF();
			prototype = prototypeModel.getBuildingPrototype(type);
			baseID = input.readUTF();
			playerOwnerID = input.readUTF();

			baseX = input.readInt();
			baseY = input.readInt();

			currentHealth = input.readDouble();
			if (currentHealth < 0)
				currentHealth = 0;
			buildState = input.readInt();

			// current modules
			var slotName:String;
			var modulePrototype:String;
			var numModules:int                = input.readUnsignedInt();
			if (numModules > 0)
				modules = new Dictionary();
			for (var j:int = 0; j < numModules; j++)
			{
				slotName = input.readUTF();
				modulePrototype = input.readUTF();
				modules[slotName] = prototypeModel.getWeaponPrototype(modulePrototype);
			}

			// refit modules
			numModules = input.readUnsignedInt();
			if (numModules > 0)
				refitModules = new Dictionary();
			for (j = 0; j < numModules; j++)
			{
				slotName = input.readUTF();
				modulePrototype = input.readUTF();
				refitModules[slotName] = prototypeModel.getWeaponPrototype(modulePrototype);
			}

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in BuildingData is not supported");
		}

		public function destroy():void
		{
			modules = null;
			prototype = null;
			refitModules = null;
		}
	}
}
