package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class WeaponData extends ModuleData
	{
		public var weaponState:uint;
		public var rotation:Number;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			weaponState = input.readInt();
			rotation = input.readUnsignedByte();
			input.checkToken();
		}
		
		public static var _propertyNames:Vector.<String>= new <String>[
			"weaponState", // 0
			"rotation", // 1
		];
		
		
		public static var _propertyReaders:Vector.<String>= new <String>[
			"readInt", // 0
			"readUnsignedByte", // 1
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

		}
	}
}


