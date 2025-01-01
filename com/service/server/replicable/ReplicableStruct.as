package com.service.server.replicable
{
	import com.enum.server.ReplicableOpEnum;
	import com.service.server.BinaryInputStream;

	import flash.geom.Point;

	public class ReplicableStruct implements IReplicable
	{
		public function read( input:BinaryInputStream ):void  {}

		public function readInt( input:BinaryInputStream ):int  { return input.readInt(); }

		public function readUnsignedByte( input:BinaryInputStream ):int  { return input.readUnsignedByte(); }

		public function readUTF( input:BinaryInputStream ):String  { return input.readUTF(); }

		public function readShort( input:BinaryInputStream ):int  { return input.readShort(); }

		public function readBoolean( input:BinaryInputStream ):Boolean  { return input.readBoolean(); }

		public function readFloat( input:BinaryInputStream ):Number  { return input.readFloat(); }

		public function readLocation( input:BinaryInputStream ):Point
		{
			var result:Point = new Point();
			result.x = input.readFloat();
			result.y = input.readFloat();
			return result;
			//p.setTo(input.readFloat(), input.readFloat());
		}
		
		public function resetDeltas():void
		{
			
		}

		public function decode( input:BinaryInputStream ):int
		{
			while (true)
			{
				var index:int = input.readByte();
				if (index < 0)
				{
					return index;
				}
				if (index == ReplicableOpEnum.Copy)
				{
					// special copy everything token
					read(input);
				} else
				{
					var propName:String = propertyNames[index];
					var child:*         = this[propName];
					var level:int       = 1;
					if (child is IReplicable)
					{
						level = 1 + IReplicable(child).decode(input);
					} else
					{
						this[propName] = this[propertyReaders[index]](input);
					}

					if (level < 0)
					{
						return level;
					}
				}
			}
			return 0;
		}

		public function get propertyNames():Vector.<String>  { return null; }
		public function get propertyReaders():Vector.<String>  { return null; }

	}
}
