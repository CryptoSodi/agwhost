package com.service.server.incoming.battle
{
	import com.service.server.BinaryInputStream;
	import com.service.server.ITickedResponse;
	import com.service.server.incoming.data.DebugLineData;
	import com.service.server.incoming.data.IServerData;
	import com.service.server.incoming.data.RemovedObjectData;

	import org.shared.ObjectPool;

	public class BattleDebugLinesResponse implements ITickedResponse
	{
		public var debugLines:Vector.<DebugLineData>       = new Vector.<DebugLineData>;
		public var removedLines:Vector.<RemovedObjectData> = new Vector.<RemovedObjectData>;

		private var _header:int;
		private var _protocolID:int;
		private var _tick:int;
		private var _timeStep:int;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			_tick = input.readInt();
			_timeStep = input.readInt();

			var debugLine:DebugLineData;
			var numAdded:int   = input.readUnsignedInt();
			for (var i:int = 0; i < numAdded; i++)
			{
				input.readUnsignedInt();
				debugLine = ObjectPool.get(DebugLineData);
				debugLine.read(input);
				debugLines.push(debugLine);
			}
			var data:IServerData;
			var numRemoved:int = input.readUnsignedInt();
			for (i = 0; i < numRemoved; i++)
			{
				data = ObjectPool.get(RemovedObjectData);
				RemovedObjectData(data).id = "DebugLine" + input.readUnsignedInt();
				RemovedObjectData(data).reason = input.readInt();
				removedLines.push(data);
			}
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
		}

		public function get isBaseline():Boolean  { return false; }
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
			for (i = 0; i < debugLines.length; i++)
				ObjectPool.give(debugLines[i]);
			debugLines.length = 0;

			for (i = 0; i < removedLines.length; i++)
				ObjectPool.give(removedLines[i]);
			removedLines.length = 0;
		}
	}
}
