package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;
	
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.adobe.utils.DictionaryUtil;

	public class StarbaseRefitShipRequest extends TransactionRequest
	{
		public var shipPersistence:String;
		public var modules:Dictionary;
		public var shipName:String;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(shipPersistence);
			output.writeUTF(shipName);
			output.writeInt(purchaseType);
			// NOTE - this is stolen from StarbaseBuildShipRequest, keep them in sync!
			output.writeUnsignedInt(DictionaryUtil.getLength(modules));

			for (var key:String in modules)
			{
				output.writeUTF(key);
				if (modules[key] != null)
					output.writeUTF(modules[key].name);
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
		}
	}
}
