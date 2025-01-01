package com.service.server
{
	public interface ITransactionRequest extends IRequest
	{
		function get token():int;
		function set token( v:int ):void;
	}
}
