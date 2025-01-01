package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.MotdData;
	import org.shared.ObjectPool;
	
	public class StarbaseMotdListResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;

		public var motds:Vector.<MotdData> = new Vector.<MotdData>;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			var motdData:MotdData;
			var numMotds:int = input.readUnsignedShort();
			for ( var idx:int = 0; idx < numMotds; ++idx )
			{
				motdData = ObjectPool.get(MotdData);
				motdData.read(input);
				motds.push(motdData);
			}

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			// Unimplemented.
		}
		
		public function get isTicked():Boolean  { return false; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		
		public function destroy():void
		{
		}
	}
}
