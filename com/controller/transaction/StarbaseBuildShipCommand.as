package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetModel;
	import com.model.fleet.ShipVO;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.ExternalInterfaceAPI;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuildShipCommand extends Command
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
			if(event == null)
				return;
			
			if(fleetModel == null)
				return;
			
			if(transactionModel == null)
				return;
			
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			
			if(responseData == null)
				return;
			
			var ship:ShipVO                = fleetModel.getShip(responseData.id);
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					if(clientData != null)
						fleetModel.updateShipID(clientData.id, responseData.id);
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					if (ship)
						ship.built = false;
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (ship)
					{
						toastController.addTransactionToast(ship.prototypeVO, responseData);
						ExternalInterfaceAPI.shareTransaction(responseData.type, ship);
						ship.built = true;
					}
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					fleetModel.removeShip(responseData.id);
					transactionModel.removeTransaction(token);
					break;
			}

		}
	}
}


