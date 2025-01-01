package com.service.server
{
	import com.model.transaction.TransactionVO;

	public interface ITransactionResponse extends IResponse
	{
		function get data():TransactionVO;
		function set data( v:TransactionVO ):void;
		function get success():Boolean
		function get token():int;
	}
}
