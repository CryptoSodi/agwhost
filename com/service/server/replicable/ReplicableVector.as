package com.service.server.replicable
{
	import com.enum.server.ReplicableOpEnum;

	import org.shared.ObjectPool;
	import com.service.server.BinaryInputStream;

	public dynamic class ReplicableVector extends Array implements IReplicable
	{
		public var added:Array    = new Array;
		public var elementType:Class;
		public var modified:Array = new Array;
		public var removed:Array  = new Array;

		public function resetDeltas():void
		{
			modified.length = 0;
			added.length = 0;
			removed.length = 0;
		}

		public function read( input:BinaryInputStream ):void
		{
			var count:int = input.readShort();
			for (var i:int = 0; i < count; ++i)
			{
				var element:* = ObjectPool.get(elementType);
				element.read(input);
				super.push(element);
			}
		}

		public function decode( input:BinaryInputStream ):int
		{
			for (; ; )
			{
				var operation:int = input.readByte();
				if (operation < 0)
				{
					return operation;
				}

				switch (operation)
				{
					case ReplicableOpEnum.Modifychild:
					{
						var modifyIndex:uint      = input.readUnsignedByte();
						var modifyItem:IReplicable = this[modifyIndex];
						var level:int             = 1 + modifyItem.decode(input);
						modified.push(modifyItem);
						if (level < 0)
						{
							return level;
						}
						break;
					}

					case ReplicableOpEnum.Pushback:
					{
						var pushedElement:* = ObjectPool.get(elementType);
						pushedElement.read(input);
						this.push(pushedElement);
						added.push(pushedElement);
						break;
					}

					case ReplicableOpEnum.Set:
					{
						var setIndex:uint = input.readUnsignedByte();
						this[setIndex].read(input);
						break;
					}

					case ReplicableOpEnum.Erase:
					{
						var eraseIndex:uint = input.readUnsignedByte();
						var erased:Array    = super.splice(eraseIndex, 1);
						removed.push(erased[0]);
						break;
					}

					case ReplicableOpEnum.Copy:
					{
						length = 0;
						var copycount:int = input.readUnsignedByte();
						for (var i:int = 0; i < copycount; i++)
						{
							var copyelement:* = ObjectPool.get(elementType);
							copyelement.read(input);
							this.push(copyelement);
						}
						break;
					}

					case ReplicableOpEnum.Clear:
					{
						this.length = 0;
						break;
					}

					default:
					{
						throw new Error("ReplicableVector invalid operation " + String(operation));
						break;
					}

				}
			}
			return 0;
		}
	}
}
