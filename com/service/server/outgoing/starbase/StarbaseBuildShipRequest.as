package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;
	import flash.utils.Dictionary;

	public class StarbaseBuildShipRequest extends TransactionRequest
	{
		public var modules:Dictionary;
		public var shipPrototype:String;
		public var shipName:String;
		public var slots:Array;
		public var centerSpaceBase:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(shipPrototype);
			//output.writeUTF(shipName);
			output.writeInt(purchaseType);
			output.writeUnsignedInt(slots.length);
			for (var i:int = 0; i < slots.length; i++)
			{
				output.writeUTF(slots[i]);
				if (slots[i] in modules)
				{
					if (modules[slots[i]] != null)
						output.writeUTF(modules[slots[i]].name);
					else
						output.writeUTF('');
				} else
					output.writeUTF('');
			}
			output.writeBoolean(centerSpaceBase);
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
