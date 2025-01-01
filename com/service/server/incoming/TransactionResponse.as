package com.service.server.incoming
{
	import com.model.transaction.TransactionVO;
	import com.service.server.BinaryInputStream;
	import com.service.server.ITransactionResponse;

	import org.shared.ObjectPool;

	public class TransactionResponse implements ITransactionResponse
	{
		protected var _data:TransactionVO;

		protected var _header:int;
		protected var _protocolID:int;

		public function read( input:BinaryInputStream ):void
		{
			_data = ObjectPool.get(TransactionVO);
			_data.read(input);
		}

		public function readJSON( data:Object ):void
		{
			_data = ObjectPool.get(TransactionVO);
			_data.readJSON(data);
		}

		public function get isTicked():Boolean  { return false; }

		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }

		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }

		public function get success():Boolean  { return _data.success; }
		public function get token():int  { return _data.token; }

		public function get data():TransactionVO  { return _data; }
		public function set data( v:TransactionVO ):void  { _data = v; }

		public function destroy():void
		{
			_data = null;
		}
	}
}
