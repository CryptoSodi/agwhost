package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.prototype.IPrototype;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuyStoreItemCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var toastController:ToastController;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var prototype:IPrototype       = (clientData != null) ? clientData.buff : starbaseModel.getBuffByID(responseData.id);
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					if(clientData == null)
					{
						// Possible if the client transaction was created by server and not registered in client.
						return;
					}
					if (clientData.id)
						starbaseModel.updateBuffID(clientData.id, responseData.id);
					if (prototype == null)
						prototype = starbaseModel.getBuffByID(responseData.id);
					//if (responseData.timeMS > 0)
					toastController.addTransactionToast(prototype, responseData);
					transactionController.dataImported();
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (responseData.timeMS > 0)
						toastController.addTransactionToast(prototype, responseData);
					starbaseModel.removeBuffByID(responseData.id);
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					if(clientData == null)
					{
						// Possible if the client transaction was created by server and not registered in client.
						return;
					}
					//try to remove the client buff if it hasn't been updated yet
					if (clientData.id)
						starbaseModel.removeBuffByID(clientData.id);
					starbaseModel.removeBuffByID(responseData.id);
					transactionModel.removeTransaction(token);
					break;
			}
		}
	}
}
