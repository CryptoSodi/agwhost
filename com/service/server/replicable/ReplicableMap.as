package com.service.server.replicable
{
	import com.enum.server.ReplicableOpEnum;
	import com.service.server.BinaryInputStream;
	
	import flash.utils.Dictionary;
	
	import org.shared.ObjectPool;

	public dynamic class ReplicableMap extends Dictionary implements IReplicable
	{
		public function readKey( input:BinaryInputStream ):*  { return null; }
		public function readRemove( input:BinaryInputStream ):*  { return null; }
		public function createValue():*  { return null; }

		public var added:Dictionary    = new Dictionary;
		public var modified:Dictionary = new Dictionary;
		public var removed:Array       = new Array;

		protected var _count:int;
		protected var _i:int;

		public function resetDeltas():void
		{
			for each(var rm:IReplicable in modified)
			{
				rm.resetDeltas();
			}
			added	 = new Dictionary;
			modified = new Dictionary;
			
			removed.length = 0;
		}

		public function read( input:BinaryInputStream ):void
		{
			_count = input.readUnsignedInt();
			for (var id:* in this)
			{
				delete this[id];
			}

			for (_i = 0; _i < _count; ++_i)
			{
				var key:*     = readKey(input);
				var element:* = createValue();
				element.read(input);
				this[key] = element;
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
						var found1:IReplicable = this[key];
						if (found1 != null)
						{
							var level:int = 1 + found1.decode(input);
							modified[key] = found1;
							if (level < 0)
							{
								return level;
							}
						} else
						{
							if( key != null)
								throw new Error("ReplicableSet modifying " + key + " that is not present");
						}
						break;
					}

					case ReplicableOpEnum.Insertdefault:
					{
						var insertdefaultkey:* = readKey(input);
						this[insertdefaultkey] = createValue();
						break;
					}

					case ReplicableOpEnum.Set:
					{
						var setKey:* = readKey(input);
						var objSet:* = createValue();
						objSet.read(input);
						this[setKey] = objSet;
						added[setKey] = objSet;
						break;
					}

					case ReplicableOpEnum.Erase:
					{
						var payload:* = readRemove(input);
						delete this[payload.id];

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
