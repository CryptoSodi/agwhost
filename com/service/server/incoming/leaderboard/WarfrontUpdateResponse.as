package com.service.server.incoming.leaderboard
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.WarfrontData;

	import org.shared.ObjectPool;

	public class WarfrontUpdateResponse implements IResponse
	{
		public var removed:Vector.<String>         = new Vector.<String>;
		public var warfronts:Vector.<WarfrontData> = new Vector.<WarfrontData>;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var data:WarfrontData;
			var num:int = input.readUnsignedInt();
			for (var idx:int = 0; idx < num; idx++)
			{
				input.readUTF(); // map key
				data = ObjectPool.get(WarfrontData);
				data.read(input);
				warfronts.push(data);
			}
			num = input.readUnsignedInt();
			for (idx = 0; idx < num; idx++)
			{
				removed.push(input.readUTF());
				/*reason =*/ input.readInt();
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function destroy():void
		{
			for (var i:int = 0; i < warfronts.length; i++)
				ObjectPool.give(warfronts[i]);
			warfronts.length = 0;
		}
	}
}
