package com.event.signal
{
	import com.model.transaction.TransactionVO;

	import org.osflash.signals.Signal;

	public class TransactionSignal
	{
		public static const ALL:int                 = 0;
		public static const DATA_IMPORTED:int       = 1;
		public static const TRANSACTION:int         = 2;
		public static const TRANSACTION_REMOVED:int = 3;
		public static const TRANSACTION_UPDATED:int = 4;

		private var _onDataImported:Signal;
		private var _onTransactionRemoved:Signal;
		private var _onTransactionUpdated:Signal;
		private var _transaction:TransactionVO;

		public function TransactionSignal()
		{
			_onDataImported = new Signal(TransactionVO);
			_onTransactionRemoved = new Signal(TransactionVO);
			_onTransactionUpdated = new Signal(TransactionVO);
		}

		public function add( type:int, listener:Function ):void
		{
			switch (type)
			{
				//Be notified when new data is imported or a transaction is removed or updated	
				case ALL:
					_onDataImported.add(listener);
					_onTransactionRemoved.add(listener);
					_onTransactionUpdated.add(listener);
					break;

				//Be notified when new data is imported from the server
				case DATA_IMPORTED:
					_onDataImported.add(listener);
					break;

				//Be notified when a transaction is removed	
				case TRANSACTION_REMOVED:
					_onTransactionRemoved.add(listener);
					break;

				//Be notified when a transaction is updated		
				case TRANSACTION_UPDATED:
					_onTransactionUpdated.add(listener);
					break;

				//Be notified when a transaction is removed or updated		
				case TRANSACTION:
					_onTransactionRemoved.add(listener);
					_onTransactionUpdated.add(listener);
					break;
			}
		}

		public function dispatch( type:int, transaction:TransactionVO ):void
		{
			switch (type)
			{
				//Dispatch all notifications with the last transaction that was completed
				case ALL:
					_onDataImported.dispatch(transaction);
					_onTransactionRemoved.dispatch(transaction);
					_onTransactionUpdated.dispatch(transaction);
					break;

				//Dispatch a notification that new data has been imported
				case DATA_IMPORTED:
					_onDataImported.dispatch(transaction);
					break;

				//Dispatch a notification that a transaction has been removed
				case TRANSACTION_REMOVED:
					_onTransactionRemoved.dispatch(transaction);
					break;

				//Dispatch a notification that a transaction has been updated
				case TRANSACTION_UPDATED:
					_onTransactionUpdated.dispatch(transaction);
					break;

				//Dispatch a notification that a transaction has been updated and removed
				case TRANSACTION:
					_onTransactionRemoved.dispatch(transaction);
					_onTransactionUpdated.dispatch(transaction);
					break;
			}
		}

		/**
		 * Removes a listener from all signals
		 */
		public function remove( listener:Function ):void
		{
			_onDataImported.remove(listener);
			_onTransactionRemoved.remove(listener);
			_onTransactionUpdated.remove(listener);
		}
	}
}

