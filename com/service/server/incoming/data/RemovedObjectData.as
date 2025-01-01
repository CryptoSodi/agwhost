package com.service.server.incoming.data
{
	import com.enum.RemoveReasonEnum;
	import com.service.server.BinaryInputStream;

	public class RemovedObjectData implements IServerData
	{
		public var id:String;
		public var reason:int;
		public var x:Number;
		public var y:Number;

		public function read( input:BinaryInputStream ):void
		{
			id = input.readUTF();
			reason = input.readInt();
			if (reason == RemoveReasonEnum.AttackComplete || reason == RemoveReasonEnum.ShieldComplete || reason == RemoveReasonEnum.Intercepted)
			{
				x = input.readDouble();
				y = input.readDouble();
			}
		}

		public function readJSON( data:Object ):void
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

		public function destroy():void
		{

		}
	}
}
