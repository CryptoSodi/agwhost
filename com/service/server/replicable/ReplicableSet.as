package com.service.server.replicable
{
	import com.enum.server.ReplicableOpEnum;

	import org.shared.ObjectPool;
	import com.service.server.BinaryInputStream;

	public dynamic class ReplicableSet extends Array implements IReplicable
	{
		public var readKey:Function;
		public var readRemove:Function;
		public var elementType:Class;

		public var added:Array    = new Array;
		public var modified:Array = new Array;
		public var removed:Array  = new Array;

		protected var _count:int;
		protected var _i:int;

		public function resetDeltas():void
		{
			modified.length = 0;
			added.length = 0;
			removed.length = 0;
		}

		public function find( key:* ):*
		{
			for (_i = 0; _i < this.length; _i++)
			{
				if (this[_i].id == key)
				{
					return this[_i];
				}
			}
			return null;
		}

		private function erase( key:* ):Boolean
		{
			for (_i = 0; _i < this.length; _i++)
			{
				if (this[_i].id == key)
				{
					this.splice(_i, 1);
					return true;
				}
			}
			return false;
		}

		public function read( input:BinaryInputStream ):void
		{
			_count = input.readUnsignedInt();
			length = 0;
			for (_i = 0; _i < _count; ++_i)
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
						var key:*              = readKey(input);
						var found1:IReplicable = find(key);
						if (found1 != null)
						{
							var level:int = 1 + found1.decode(input);
							if (modified.indexOf(found1) < 0)
							{
								modified.push(found1);
							}
							if (level < 0)
							{
								return level;
							}
						} else
						{
							throw new Error("ReplicableSet modifying " + key + " that is not present");
						}
						break;
					}

					case ReplicableOpEnum.Set:
					{
						var objSet:* = ObjectPool.get(elementType);
						objSet.read(input);
						erase(objSet.id); // erase the old one if it exists
						this.push(objSet); // add the new one
						added.push(objSet);
						break;
					}

					case ReplicableOpEnum.Erase:
					{
						var payload:*      = readRemove(input);
						var erased:Boolean = erase(payload.id);
						if (!erased)
						{
							throw new Error("ReplicableSet erasing " + payload.id + " that is not present");
						}

						removed.push(payload);
						break;
					}

					case ReplicableOpEnum.Copy:
					{
						read(input);
						break;
					}

					case ReplicableOpEnum.Clear:
					{
						this.length = 0;
						break;
					}

					default:
					{
						throw new Error("ReplicableSet invalid operation " + String(operation));
						break;
					}
				}
			}
			return 0;
		}
	}
}
