package com.service.server
{
	public class StringInputCache
	{
		private var _count:uint            = 0;
		private var _capacity:uint         = 0;
		private var _table:Vector.<String> = new Vector.<String>;

		public function readBaseline( input:BinaryInputStream ):void
		{
			_table.length = 0;
			input.checkToken();
			_count = input.readUnsignedInt();
			_capacity = input.readUnsignedShort();
			var tableSize:int = Math.min(_count, _capacity);
			for (var i:int = 0; i < tableSize; ++i)
			{
				var len:uint = input.readUnsignedShort();
				_table.push(input.readUTFBytes(len));
			}
			input.checkToken();
		}

		public function readUTF( input:BinaryInputStream ):String
		{
			var id:uint = input.readUnsignedShort();
			if (id >= _capacity)
			{
				// new ( or replacement ) entry
				var len:uint     = id - _capacity;
				var value:String = input.readUTFBytes(len);
				if (_count < _capacity)
				{
					_table.push(value);
				} else
				{
					id = (_count * 33331) % _capacity;
					_table[id] = value;
				}
				++_count;

				return value;
			} else
			{
				if(id < _table.length)
				{
					return _table[id];
				}
				else
				{					
					return "";
				}
			}
		}
	}
}
