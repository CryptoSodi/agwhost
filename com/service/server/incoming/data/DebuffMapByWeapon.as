package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import com.service.server.replicable.ReplicableMap;
	import com.service.server.incoming.data.BattleDebuff;


	import org.shared.ObjectPool;

	public dynamic class DebuffMapByWeapon extends ReplicableMap
	{
		public override function readKey( input:BinaryInputStream ):*
		{
			return input.readUTF();
		}

		public override function readRemove( input:BinaryInputStream ):*
		{
			var data:RemovedObjectData = ObjectPool.get(RemovedObjectData);
			data.id = input.readUTF();
			return data;
		}
		public override function createValue():*
		{
			return ObjectPool.get(BattleDebuff);
		}
	}
}
