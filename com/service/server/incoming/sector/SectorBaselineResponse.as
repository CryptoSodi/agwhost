package com.service.server.incoming.sector
{
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;
	import com.service.server.incoming.data.IServerData;
	import com.service.server.incoming.data.SectorBattleData;
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorOrderData;

	import org.shared.ObjectPool;

	public class SectorBaselineResponse implements ITickedResponse
	{
		public var battles:Vector.<SectorBattleData>  = new Vector.<SectorBattleData>;
		public var entities:Vector.<SectorEntityData> = new Vector.<SectorEntityData>;
		public var orders:Vector.<SectorOrderData>    = new Vector.<SectorOrderData>;

		private var _header:int;
		private var _protocolID:int;
		private var _tick:int;
		private var _timeStep:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			_tick = input.readInt();
			_timeStep = input.readInt();

			var data:IServerData;
			var numEntities:int = input.readUnsignedInt();
			for (var i:int = 0; i < numEntities; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorEntityData);
				data.read(input);
				entities.push(data);
			}
			var numBattles:int  = input.readUnsignedInt();
			for (i = 0; i < numBattles; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorBattleData);
				data.read(input);
				battles.push(data);
			}
			var numOrders:int   = input.readUnsignedInt();
			for (i = 0; i < numOrders; i++)
			{
				input.readUTF();
				data = ObjectPool.get(SectorOrderData);
				data.read(input);
				orders.push(data);
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			_tick = data.nowTick;
			_timeStep = data.tickTimeMillis;

			var obj:IServerData;
			var key:String
			for (key in data.Entities)
			{
				obj = ObjectPool.get(SectorEntityData);
				obj.readJSON(data.Entities[key]);
				entities.push(obj);
			}
			for (key in data.Battles)
			{
				obj = ObjectPool.get(SectorBattleData);
				obj.readJSON(data.Battles[key]);
				battles.push(obj);
			}
			for (key in data.Orders)
			{
				obj = ObjectPool.get(SectorOrderData);
				obj.readJSON(data.Orders[key]);
				orders.push(obj);
			}
		}

		public function get isBaseline():Boolean  { return true; }
		public function get isTicked():Boolean  { return true; }
		public function get addTick():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function get tick():int  { return _tick }
		public function get timeStep():int  { return _timeStep; }

		public function destroy():void
		{
			var i:int = 0;
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
