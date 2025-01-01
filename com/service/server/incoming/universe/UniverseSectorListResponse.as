package com.service.server.incoming.universe
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.SectorData;

	import org.shared.ObjectPool;

	public class UniverseSectorListResponse implements IResponse
	{
		public var sectors:Vector.<SectorData> = new Vector.<SectorData>;
		public var privateSectors:Vector.<SectorData> = new Vector.<SectorData>;

		private var _header:int;
		private var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			{
				var numSectors:int = input.readUnsignedInt();
				var sectorData:SectorData;
				for (var idx:int = 0; idx < numSectors; idx++)
				{
					/* key */
					input.readUTF();
	
					sectorData = ObjectPool.get(SectorData);
					sectorData.read(input);
					sectors.push(sectorData);
				}
			}
			input.checkToken();
			input.checkToken();
			{
				var numSectors:int = input.readUnsignedInt();
				var sectorData:SectorData;
				for (var idx:int = 0; idx < numSectors; idx++)
				{
					/* key */
					input.readUTF();
					
					sectorData = ObjectPool.get(SectorData);
					sectorData.read(input);
					privateSectors.push(sectorData);
				}
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
			for (var i:int = 0; i < sectors.length; i++)
				ObjectPool.give(sectors[i]);
			sectors.length = 0;
		}
	}
}
