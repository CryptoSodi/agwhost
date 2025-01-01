package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRepairFleetCommand extends Command
	{

		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var toastController:ToastController;
		[Inject]
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var fleet:FleetVO              = fleetModel.getFleet(responseData.id);
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					fleetModel.repairFleet(fleet, (responseData.timeRemainingMS <= 0));
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					toastController.addTransactionToast(fleet, responseData);
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


