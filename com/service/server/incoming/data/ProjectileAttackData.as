package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	import flash.geom.Point;

	public class ProjectileAttackData extends AttackData
	{
		public var end:Point                               = new Point();
		public var finishTick:int;
		public var guided:Boolean;

		public var fadeTime:Number                         = -1;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			location = readLocation(input);
			end = readLocation(input);
			finishTick = input.readInt();
			guided = input.readBoolean();
			input.checkToken();
		}

		public static var _propertyNames:Vector.<String>   = new <String>[
			"location", // 0
			"rotation", // 1
			"targetEntityId", // 2
			];

		public static var _propertyReaders:Vector.<String> = new <String>[
			"readLocation", // 0
			"readUnsignedByte", // 1
			"readUTF", // 2
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
				}
			}
		}

		override public function destroy():void
		{

		}
	}
}
