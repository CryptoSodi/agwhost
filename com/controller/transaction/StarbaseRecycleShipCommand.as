package com.controller.transaction
{
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRecycleShipCommand extends Command
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
			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (clientData)
						fleetModel.removeShip(clientData.id);
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					transactionModel.removeTransaction(responseData.token);
					break;
			}
		}
	}
}
