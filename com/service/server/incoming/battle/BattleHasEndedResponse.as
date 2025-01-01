package com.service.server.incoming.battle
{
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;

	import flash.utils.Dictionary;
	import com.service.server.incoming.data.CrewMemberData;
	import org.shared.ObjectPool;

	public class BattleHasEndedResponse implements ITickedResponse
	{
		public var battleKey:String;
		public var victors:Dictionary;
		public var alloyLoot:Number;
		public var energyLoot:Number;
		public var syntheticLoot:Number;
		public var creditBounty:Number;
		public var blueprintReward:String;
		public var crewReward:CrewMemberData;
		public var cargoFull:Boolean;

		private var _header:int;
		private var _protocolID:int;
		private var _tick:int;
		private var _timeStep:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			_tick = input.readInt();
			battleKey = input.readUTF();
			victors = new Dictionary();
			var numVictors:int  = input.readUnsignedInt();
			for (var i:int = 0; i < numVictors; i++)
			{
				var key:String = input.readUTF();
				victors[key] = true;
			}
			alloyLoot = input.readInt64();
			energyLoot = input.readInt64();
			syntheticLoot = input.readInt64();
			creditBounty = input.readInt64();
			blueprintReward = input.readUTF();
			var hasCrew:Boolean = false;
			hasCrew = input.readBoolean();
			if (hasCrew)
			{
				crewReward = ObjectPool.get(CrewMemberData);
				crewReward.read(input);
			}
			cargoFull = input.readBoolean();
			input.checkToken();
			_tick = int.MAX_VALUE; // process this on the last tick
		}

		public function readJSON( data:Object ):void
		{
			_tick = data.battleEndTick;
			_timeStep = data.tickTimeMillis;

			victors = data.victors;
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
		}
	}
}
