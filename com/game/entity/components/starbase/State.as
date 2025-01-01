package com.game.entity.components.starbase
{
	import com.event.TransactionEvent;
	import com.model.transaction.TransactionVO;

	import org.ash.core.Entity;

	public class State
	{
		public var component:Entity;
		public var text:String;
		private var _transactions:Vector.<TransactionVO>;

		public function get percentageDone():Number  { return _transactions[0].percentComplete; }
		public function get startTime():uint  { return _transactions[0].began; }
		public function get remainingTime():uint  { return _transactions[0].timeRemainingMS; }
		public function get endTime():uint  { return _transactions[0].began + _transactions[0].timeMS; }

		public function addTransaction( transaction:TransactionVO ):void
		{
			if (_transactions == null)
				_transactions = new Vector.<TransactionVO>;

			if (!alreadyAdded(transaction))
				_transactions.push(transaction);

			if (_transactions.length > 1)
				_transactions.sort(orderItems);
		}

		private function alreadyAdded( transaction:TransactionVO ):Boolean
		{
			var alreadyAdded:Boolean;
			var len:uint = _transactions.length;
			for (var i:uint = 0; i < len; ++i)
			{
				if (_transactions[i].id == transaction.id && _transactions[i].type == transaction.type)
				{
					alreadyAdded = true;
					break;
				}
			}

			return alreadyAdded;
		}

		public function removeTransaction( transactionID:String ):void
		{
			var len:uint = _transactions.length;
			for (var i:uint = 0; i < len; ++i)
			{
				if (_transactions[i].id == transactionID)
				{
					_transactions.splice(i, 1);
					break;
				}
			}
			if (_transactions.length > 1)
				_transactions.sort(orderItems);
		}

		private function orderItems( transactionOne:TransactionVO, transactionTwo:TransactionVO ):Number
		{
			if (!transactionOne)
				return -1;
			if (!transactionTwo)
				return 1;

			var timeRemainingOne:uint = transactionOne.timeRemainingMS;
			var timeRemainingTwo:uint = transactionTwo.timeRemainingMS;

			if (timeRemainingOne < timeRemainingTwo)
				return -1;
			if (timeRemainingOne > timeRemainingTwo)
				return 1;

			return 0;
		}

		public function get showConstruction():Boolean
		{
			var transaction:TransactionVO;
			for (var i:int = 0; i < _transactions.length; i++)
			{
				transaction = _transactions[i];
				if (transaction.type == TransactionEvent.STARBASE_BUILDING_BUILD
					|| transaction.type == TransactionEvent.STARBASE_BUILDING_UPGRADE
					|| transaction.type == TransactionEvent.STARBASE_REFIT_BUILDING
					|| transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
					return true;
			}
			return false;
		}

		public function get transaction():TransactionVO  { return _transactions[0]; }
		public function get transactionCount():uint  { return _transactions.length; }
		public function get type():String  { return _transactions[0].type; }

		public function destroy():void
		{
			component = null;
			text = null;
			_transactions.length = 0;
			_transactions = null;

		}
	}
}
