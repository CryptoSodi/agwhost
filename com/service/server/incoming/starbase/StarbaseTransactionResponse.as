package com.service.server.incoming.starbase
{
	import com.model.transaction.TransactionVO;
	import com.service.server.BinaryInputStream;
	import com.service.server.incoming.TransactionResponse;

	public class StarbaseTransactionResponse extends TransactionResponse
	{
		override public function read( input:BinaryInputStream ):void
		{
			super.read(input);
		}

		override public function readJSON( data:Object ):void
		{
			super.readJSON(data);
		}

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
