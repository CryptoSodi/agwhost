package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseUpdateFleetRequest extends TransactionRequest
	{
		public var fleet:FleetVO;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(fleet.id);
			var ships:Vector.<ShipVO> = fleet.ships;
			var len:uint              = ships.length;
			output.writeUnsignedInt(len);
			for (var i:uint = 0; i < len; ++i)
			{
				if (ships[i])
				{
					output.writeUTF(ships[i].id);
				} else
				{
					output.writeUTF("");
				}
			}
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
