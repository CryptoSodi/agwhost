package com.model.transaction
{
	import com.enum.server.RequestEnum;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.model.Model;
	import com.service.server.ITransactionRequest;
	import com.service.server.ITransactionResponse;

	import flash.utils.Dictionary;

	import org.shared.ObjectPool;

	public class TransactionModel extends Model
	{
		private var _clientData:Dictionary;
		private var _id:int;
		private var _transactions:Dictionary;
		private var _transactionSignal:TransactionSignal;

		[PostConstruct]
		public function init():void
		{
			_clientData = new Dictionary();
			_id = 0;
			_transactions = new Dictionary();
			_transactionSignal = new TransactionSignal();
		}

		public function addTransaction( request:ITransactionRequest, id:String, type:String, data:Object, createDefaultTransaction:Boolean ):void
		{
			request.token = token;
			data.token = request.token;
			data.type = type;

			_clientData[request.token] = data;
			if (createDefaultTransaction)
			{
				var transaction:TransactionVO = ObjectPool.get(TransactionVO);
				transaction.init(id, type, data.token);
				_transactions[data.token] = transaction;
				updatedTransaction(transaction);
			}
		}

		public function handleResponse( response:ITransactionResponse ):Object
		{
			var transactionToken:int = response.token;
			response.data.type = getType(response.data.messageID);
			//update the _id if the transactionToken is greater so that we don't reuse a id that is already in use
			if (_id <= transactionToken)
				_id = transactionToken + 1;
			if (_transactions[transactionToken] != null)
			{
				//update the transaction we have instead of replacing
				//object pool the old one and swap in the response
				_transactions[transactionToken].importData(response.data);
				ObjectPool.give(response.data);
				response.data = _transactions[transactionToken];
			} else
				_transactions[transactionToken] = response.data;
			return _clientData[transactionToken];
		}

		public function updatedTransaction( transactionVO:TransactionVO ):void
		{
			_transactionSignal.dispatch(TransactionSignal.TRANSACTION_UPDATED, transactionVO);
		}

		public function removeTransaction( tranactionToken:int ):void
		{
			var transaction:TransactionVO = _transactions[tranactionToken];
			_transactions[tranactionToken] = null;
			delete _transactions[tranactionToken];
			//clear the clientData
			_clientData[tranactionToken] = null;
			delete _clientData[tranactionToken];
			_transactionSignal.dispatch(TransactionSignal.TRANSACTION_REMOVED, transaction);
			//object pool the transaction
			ObjectPool.give(transaction);
		}

		public function dataImported():void
		{
			_transactionSignal.dispatch(TransactionSignal.DATA_IMPORTED, null);
		}

		public function getTransactionByID( id:String ):TransactionVO
		{
			for each (var transaction:TransactionVO in _transactions)
			{
				if (transaction.id == id)
					return transaction;
			}
			return null;
		}

		public function getTransactionByToken( token:int ):TransactionVO
		{
			if (_transactions.hasOwnProperty(token))
				return _transactions[token];
			return null;
		}

		private function getType( messageID:int ):String
		{
			var type:String;
			switch (messageID)
			{
				case RequestEnum.STARBASE_REPAIR_FLEET:
					type = TransactionEvent.STARBASE_REPAIR_FLEET;
					break;
				case RequestEnum.STARBASE_BUILD_NEW_BUILDING:
					type = TransactionEvent.STARBASE_BUILDING_BUILD;
					break;
				case RequestEnum.STARBASE_UPGRADE_BUILDING:
					type = TransactionEvent.STARBASE_BUILDING_UPGRADE;
					break;
				case RequestEnum.STARBASE_RECYCLE_BUILDING:
					type = TransactionEvent.STARBASE_BUILDING_RECYCLE;
					break;
				case RequestEnum.STARBASE_REFIT_BUILDING:
					type = TransactionEvent.STARBASE_REFIT_BUILDING;
					break;
				case RequestEnum.STARBASE_REPAIR_BASE:
					type = TransactionEvent.STARBASE_REPAIR_BASE;
					break;
				case RequestEnum.STARBASE_MOVE_BUILDING:
					type = TransactionEvent.STARBASE_BUILDING_MOVE;
					break;
				case RequestEnum.STARBASE_RESEARCH:
					type = TransactionEvent.STARBASE_RESEARCH;
					break;
				case RequestEnum.STARBASE_BUY_STORE_ITEM:
					type = TransactionEvent.STARBASE_BUY_STORE_ITEM;
					break;
				case RequestEnum.STARBASE_BUY_OTHER_STORE_ITEM:
					type = TransactionEvent.STARBASE_BUY_OTHER_STORE_ITEM;
					break;
				case RequestEnum.STARBASE_BUY_RESOURCE:
					type = TransactionEvent.STARBASE_BUY_RESOURCES;
					break;
				case RequestEnum.STARBASE_BUILD_SHIP:
					type = TransactionEvent.STARBASE_BUILD_SHIP;
					break;
				case RequestEnum.STARBASE_RECYCLE_SHIP:
					type = TransactionEvent.STARBASE_RECYCLE_SHIP;
					break;
				case RequestEnum.STARBASE_RECALL_FLEET:
					type = TransactionEvent.STARBASE_RECALL_FLEET;
					break;
				case RequestEnum.STARBASE_REFIT_SHIP:
					type = TransactionEvent.STARBASE_REFIT_SHIP;
					break;
				case RequestEnum.STARBASE_NEGOTIATE_CONTRACT:
					type = TransactionEvent.STARBASE_NEGOTIATE_CONTRACT_REQUEST;
					break;
				case RequestEnum.STARBASE_UPDATE_FLEET:
					type = TransactionEvent.STARBASE_UPDATE_FLEET;
				/* TODO -- ?
				   public static const STARBASE_BRIBE_CONTRACT:int         = 23;
				   public static const STARBASE_CANCEL_CONTRACT:int        = 24;
				   public static const STARBASE_EXTEND_CONTRACT:int        = 25;
				   public static const STARBASE_RESECURE_CONTRACT:int      = 26;
				 */
			}

			return type;
		}

		public function addListener( type:int, listener:Function ):void  { _transactionSignal.add(type, listener); }
		public function removeListener( listener:Function ):void  { _transactionSignal.remove(listener); }

		public function get token():int  { return _id++; }
		public function get transactions():Dictionary  { return _transactions; }
	}
}


