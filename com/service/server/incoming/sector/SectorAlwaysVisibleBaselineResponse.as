package com.service.server.incoming.sector
{
	import com.model.player.PlayerVO;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;
	import com.service.server.incoming.data.IServerData;
	import com.service.server.incoming.data.SectorBattleData;
	import com.service.server.incoming.data.SectorData;
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorObjectiveData;
	import com.service.server.incoming.data.SectorOrderData;
	
	import org.shared.ObjectPool;

	public class SectorAlwaysVisibleBaselineResponse implements ITickedResponse
	{
		public var activeSplitPrototypes:Vector.<String> = new Vector.<String>;

		public var players:Vector.<PlayerVO>             	= new Vector.<PlayerVO>;
		public var battles:Vector.<SectorBattleData>     	= new Vector.<SectorBattleData>;
		public var entities:Vector.<SectorEntityData>    	= new Vector.<SectorEntityData>;
		public var orders:Vector.<SectorOrderData>       	= new Vector.<SectorOrderData>;
		public var objectives:Vector.<SectorObjectiveData>  = new Vector.<SectorObjectiveData>;
		public var sector:SectorData;

		private var _header:int;
		private var _protocolID:int;
		private var _tick:int;
		private var _timeStep:int;

		public function read( input:BinaryInputStream ):void
		{
			input.setStringInputCache(input.sectorAlwaysVisibleStringInputCache);
			input.readStringCacheBaseline();

			input.checkToken();

			var activeSplit:String;
			var numSplits:int    = input.readUnsignedInt();
			for (i = 0; i < numSplits; ++i)
			{
				activeSplit = input.readUTF(); // split test prototype
				if (activeSplit != '')
					activeSplitPrototypes.push(activeSplit);
			}


			_tick = input.readInt();
			_timeStep = input.readInt();

			sector = ObjectPool.get(SectorData);
			sector.id = input.readUTF();
			sector.prototype = PrototypeModel.instance.getSectorPrototypeByName(input.readUTF());
			sector.appearanceSeed = input.readInt();
			sector.sectorName = PrototypeModel.instance.getSectorNamePrototypeByName(input.readUTF());
			sector.sectorEnum = PrototypeModel.instance.getSectorNamePrototypeByName(input.readUTF());
			sector.neighborhood = input.readInt64();

			var data:IServerData;
			var vo:PlayerVO;
			//get the players
			var numPlayers:int   = input.readUnsignedInt();
			for (var i:int = 0; i < numPlayers; i++)
			{
				input.readUTF();
				vo = ObjectPool.get(PlayerVO);
				vo.read(input);
				if(vo.name.length > 0)
					players.push(vo);
			}
			var numEntities:int  = input.readUnsignedInt();
			for (i = 0; i < numEntities; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorEntityData);
				data.read(input);
				entities.push(data);
			}
			var numBattles:int   = input.readUnsignedInt();
			for (i = 0; i < numBattles; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorBattleData);
				data.read(input);
				battles.push(data);
			}
			var numOrders:int    = input.readUnsignedInt();
			for (i = 0; i < numOrders; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorOrderData);
				data.read(input);
				orders.push(data);
			}
			//get the waypoints
			var numWaypoints:int = input.readUnsignedInt();
			for (i = 0; i < numWaypoints; i++)
			{
				//input.readUTF();
				data = ObjectPool.get(SectorObjectiveData);
				data.read(input);
				objectives.push(data);
//				var str:String = input.readUTF(); //Mission key
//				input.checkToken();
//				var x:Number   = input.readDouble(); //locationX
//				var y:Number   = input.readDouble(); //locationY
//				input.readUTF(); //Asset
//				input.readUTF(); //Type
//				input.checkToken();
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in SectorAlwaysVisibleResponse is not supported");
		}

		public function get isBaseline():Boolean  { return false; } // while this is 'a' baseline, it is not first baseline packet
		public function get isTicked():Boolean  { return false; }
		public function get addTick():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function get tick():int  { return _tick }
		public function get timeStep():int  { return _timeStep; }

		public function destroy():void
		{
			ObjectPool.give(sector);
			sector = null;

			var i:int = 0;
			players.length = 0;
			for (i = 0; i < entities.length; i++)
				ObjectPool.give(entities[i]);
			entities.length = 0;
			for (i = 0; i < battles.length; i++)
				ObjectPool.give(battles[i]);
			battles.length = 0;
			for (i = 0; i < orders.length; i++)
				ObjectPool.give(orders[i]);
			orders.length = 0;
		}
	}
}
