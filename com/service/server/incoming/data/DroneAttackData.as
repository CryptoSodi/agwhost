package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class DroneAttackData extends AttackData
	{
		public var isOrbiting:Boolean;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			location = readLocation(input);
			isOrbiting = input.readBoolean()

			input.checkToken();
		}

		public static var _propertyNames:Vector.<String>   = new <String>[
			"location", // 0
			"rotation", // 1 
			"targetEntityId", // 2
			"isOrbiting", // 3
			];

		public static var _propertyReaders:Vector.<String> = new <String>[
			"readLocation", // 0
			"readUnsignedByte", // 1
			"readUTF", // 2
			"readBoolean", // 3
			];

		override public function get propertyNames():Vector.<String>
		{
			return _propertyNames;
		}
		override public function get propertyReaders():Vector.<String>
		{
			return _propertyReaders;
		}

		override public function readJSON( data:Object ):void
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

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
