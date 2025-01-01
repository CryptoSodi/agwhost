package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseNegotiateContractRequest extends TransactionRequest
	{
		public var centerSpaceBase:Boolean;
		public var contractPrototype:String;
		public var factionPrototype:String;
		public var productivity:Number;
		public var payout:Number;
		public var duration:Number;
		public var frequency:Number;
		public var security:Number;
		public var fullBribe:Boolean;
		public var accepted:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeBoolean(centerSpaceBase);
			output.writeUTF(contractPrototype);
			output.writeUTF(factionPrototype);
			output.writeDouble(productivity);
			output.writeDouble(payout);
			output.writeDouble(duration);
			output.writeDouble(frequency);
			output.writeDouble(security);
			output.writeBoolean(fullBribe);
			writeExpectedCosts(output);
			output.writeBoolean(accepted);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
