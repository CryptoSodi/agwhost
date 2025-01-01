package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import flash.geom.Point;

	public class BeamAttackData extends AttackData
	{
		public var sourceAttachPoint:String;
		public var targetAttachPoint:String;
		public var targetScatterX:Number;
		public var targetScatterY:Number;
		public var maxRange:Number;
		public var attackHit:Boolean;
		public var hitLocation:Point;
		public var hitTarget:String;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			sourceAttachPoint = input.readUTF();
			targetAttachPoint = input.readUTF();
			targetScatterX = input.readDouble();
			targetScatterY = input.readDouble();
			maxRange = input.readDouble();
			attackHit = input.readBoolean();
			hitLocation = readLocation(input);
			hitTarget = input.readUTF();
			input.checkToken();
		}

		public static var _propertyNames:Vector.<String>   = new <String>[
			"targetEntityId", // 0
			"rotation", // 1
			"targetAttachPoint", // 2 
			"targetScatterX", // 3
			"targetScatterY", // 4
			"attackHit", // 5
			"hitLocation", //6
			"hitTarget", //7
			];

		public static var _propertyReaders:Vector.<String> = new <String>[
			"readUTF", // 0
			"readUnsignedByte", // 1
			"readUTF", // 2
			"readFloat", // 3
			"readFloat", // 4
			"readBoolean", // 5
			"readLocation", //6
			"readUTF", // 7
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
