package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class AreaAttackData extends AttackData
	{
		public var endX:Number;
		public var endY:Number;
		public var reloadTime:Number;
		public var finishTick:int;
		public var nextFireTick:int;
		public var sourceAttachPoint:String;

		override public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			super.read(input);
			endX = input.readDouble();
			endY = input.readDouble();
			reloadTime = input.readDouble();
			finishTick = input.readInt();
			nextFireTick = input.readInt();
			sourceAttachPoint = input.readUTF();
			input.checkToken();
		}

		override public function readJSON( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				} else
				{
					// TODO - complain about missing key?
				}
			}
		}

		override public function destroy():void
		{

		}
	}
}
