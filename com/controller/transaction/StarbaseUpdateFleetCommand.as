package com.controller.transaction
{
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseUpdateFleetCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					transactionModel.removeTransaction(token);
					break;
			}
		}
	}
}
