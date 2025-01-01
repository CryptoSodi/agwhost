package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import com.service.server.replicable.ReplicableStruct;

	public class BattleDebuff extends ReplicableStruct
	{
		public var prototype:String;
		public var beginTick:int;
		public var endTick:int;
		public var stackCount:int;
		public var magnitude:Number;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			prototype = input.readUTF();
			beginTick = input.readInt();
			endTick = input.readInt();
			stackCount = input.readInt();
			magnitude = input.readFloat();
			input.checkToken();
		}

		public static var _propertyNames:Vector.<String>   = new <String>[
			"beginTick", // 0
			"endTick", // 1
			"stackCount", // 2
			"magnitude", // 3
			];

		public static var _propertyReaders:Vector.<String> = new <String>[
			"readInt", // 0
			"readInt", // 1
			"readInt", // 2
			"readFloat", // 3
			];

		override public function get propertyNames():Vector.<String>
		{
			return _propertyNames;
		}
		override public function get propertyReaders():Vector.<String>
		{
			return _propertyReaders;
		}
	}
}
