package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class StarbaseRefitBuildingRequest extends TransactionRequest
	{
		public var buildingPersistence:String;
		public var modules:Dictionary;
		public var slots:Array;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(buildingPersistence);
			output.writeInt(purchaseType);
			// NOTE - this is stolen from StarbaseBuildShipRequest, keep them in sync!
			output.writeUnsignedInt(slots.length);
			for (var i:int = 0; i < slots.length; i++)
			{
				output.writeUTF(slots[i]);
				if (modules.hasOwnProperty(slots[i]))
					output.writeUTF(modules[slots[i]] != null ? modules[slots[i]].name : '');
				else
					output.writeUTF('');
			}
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
			modules = null;
			slots = null;
		}
	}
}
