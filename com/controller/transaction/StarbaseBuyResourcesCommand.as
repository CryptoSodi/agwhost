package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuyResourcesCommand extends Command
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
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (clientData)
						toastController.addTransactionToast(clientData.prototype, responseData);
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
