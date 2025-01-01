package com.service.server.incoming.sector
{
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;
	import com.service.server.incoming.data.IServerData;
	import com.service.server.incoming.data.RemovedObjectData;
	import com.service.server.incoming.data.SectorBattleData;
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorEntityUpdateData;
	import com.service.server.incoming.data.SectorOrderData;
	
	import org.shared.ObjectPool;

	public class SectorUpdateResponse implements ITickedResponse
	{
		public var entities:Vector.<SectorEntityData>            = new Vector.<SectorEntityData>;
		public var battles:Vector.<SectorBattleData>             = new Vector.<SectorBattleData>;
		public var orders:Vector.<SectorOrderData>               = new Vector.<SectorOrderData>;

		public var removedEntities:Vector.<RemovedObjectData>    = new Vector.<RemovedObjectData>;
		public var removedBattles:Vector.<RemovedObjectData>     = new Vector.<RemovedObjectData>;
		public var removedOrders:Vector.<RemovedObjectData>      = new Vector.<RemovedObjectData>;

		public var entityUpdates:Vector.<SectorEntityUpdateData> = new Vector.<SectorEntityUpdateData>;

		private var _header:int;
		private var _protocolID:int;
		private var _tick:int;
		private var _timeStep:int;

		public function read( input:BinaryInputStream ):void
		{
			_tick = input.readInt();
			_timeStep = input.readInt();

			var numQuadrants:int = input.readByte();
			for (var q:int = 0; q < numQuadrants; q++)
			{
				input.checkToken();
				var data:IServerData;
				//get the entities
				var numEntities:int = input.readUnsignedInt();
				for (var i:int = 0; i < numEntities; i++)
				{
					data = ObjectPool.get(SectorEntityData);
					data.read(input);
					entities.push(data);
				}
				//get the battles
				var numBattles:int  = input.readUnsignedInt();
				for (i = 0; i < numBattles; i++)
				{
					data = ObjectPool.get(SectorBattleData);
					data.read(input);
					battles.push(data);
				}
				//get the orders
				var numOrders:int   = input.readUnsignedInt();
				for (i = 0; i < numOrders; i++)
				{
					data = ObjectPool.get(SectorOrderData);
					data.read(input);
					orders.push(data);
				}
	
				//get the removed entities
				numEntities = input.readUnsignedInt();
				for (i = 0; i < numEntities; i++)
				{
					data = ObjectPool.get(RemovedObjectData);
					RemovedObjectData(data).read(input);
					removedEntities.push(data);
				}
				//get the removed battles
				numBattles = input.readUnsignedInt();
				for (i = 0; i < numBattles; i++)
				{
					data = ObjectPool.get(RemovedObjectData);
					RemovedObjectData(data).read(input);
					removedBattles.push(data);
				}
				//get the removed orders
				numOrders = input.readUnsignedInt();
				for (i = 0; i < numOrders; i++)
				{
					data = ObjectPool.get(RemovedObjectData);
					RemovedObjectData(data).read(input);
					removedOrders.push(data);
				}
	
				var numUpdates:int  = input.readUnsignedInt();
				for (i = 0; i < numUpdates; i++)
				{
					data = ObjectPool.get(SectorEntityUpdateData);
					SectorEntityUpdateData(data).id = input.readUTF();
					SectorEntityUpdateData(data).read(input);
					entityUpdates.push(data);
				}
				input.checkToken();
			}
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("this is unsupported");
		}

		public function get isBaseline():Boolean  { return false; }
		public function get isTicked():Boolean  { return true; }
		public function get addTick():Boolean  { return true; }

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

			for (i = 0; i < removedEntities.length; i++)
				ObjectPool.give(removedEntities[i]);
			removedEntities.length = 0;
			for (i = 0; i < removedBattles.length; i++)
				ObjectPool.give(removedBattles[i]);
			removedBattles.length = 0;
			for (i = 0; i < removedOrders.length; i++)
				ObjectPool.give(removedOrders[i]);
			removedOrders.length = 0;

			for (i = 0; i < entityUpdates.length; i++)
				ObjectPool.give(entityUpdates[i]);
			entityUpdates.length = 0;
		}
	}
}
