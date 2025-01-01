package com.service.server.outgoing
{
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.ITransactionRequest;
	import com.service.server.outgoing.starbase.StarbaseTransactionExpectedCost;

	import flash.utils.ByteArray;

	public class TransactionRequest implements ITransactionRequest
	{
		public var expectedCost:StarbaseTransactionExpectedCost = new StarbaseTransactionExpectedCost();
		public var purchaseType:int                             = PurchaseTypeEnum.INSTANT;

		protected var _token:int;

		protected var _protocolID:int;
		protected var _header:int;

		public function init( protocolID:int, header:int ):void
		{
			_protocolID = protocolID;
			_header = header;
		}

		public function write( output:ByteArray ):void
		{
			output.writeByte(_protocolID);
			output.writeByte(SpeakerEnum.CLIENT_SPEAKER);
			output.writeByte(_header);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_START);
			output.writeInt(_token);
		}

		public function writeExpectedCosts( output:ByteArray ):void  { expectedCost.write(purchaseType, output); }

		public function get token():int  { return _token; }
		public function set token( v:int ):void  { _token = v; }

		public function destroy():void
		{
			expectedCost.destroy();
		}
	}
}
