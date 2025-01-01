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

	import flash.utils.Dictionary;

	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRefitShipCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var game:Game;
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
			var ship:ShipVO                = fleetModel.getShip(responseData.id);
			var token:int                  = event.transactionToken;
			
			if(ship == null)
				return;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					fleetModel.removeShipFromFleet(responseData.id);
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					ship.built = false;
					ship.refiting = true;
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					toastController.addTransactionToast(ship.prototypeVO, responseData);
					ship.built = true;
					ship.refiting = false;
					ship.refitModules = new Dictionary();
					ship.calculateCosts();
					ExternalInterfaceAPI.shareTransaction(responseData.type, ship);
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					ship.built = true;
					ship.refiting = false;
					ship.calculateCosts();
					transactionModel.removeTransaction(token);
					break;
			}
		}
	}
}


