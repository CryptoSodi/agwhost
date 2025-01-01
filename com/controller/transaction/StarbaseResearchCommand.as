package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.player.CurrentUser;
	import com.model.starbase.BaseVO;
	import com.model.starbase.ResearchVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.ExternalInterfaceAPI;
	import com.service.server.incoming.data.ResearchData;

	import org.robotlegs.extensions.presenter.impl.Command;
	import org.shared.ObjectPool;

	public class StarbaseResearchCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var toastController:ToastController;
		[Inject]
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			if(event == null)
				return;
			
			if(starbaseModel == null)
				return;
			
			if(transactionModel == null)
				return;
			
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			
			if(responseData == null)
				return;
			
			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					if(clientData == null)
						return;
					
					var baseVO:BaseVO             = clientData.baseVO;
					var researchData:ResearchData = ObjectPool.get(ResearchData);
					
					if(baseVO == null)
						return;
					if(researchData == null)
						return;
					
					researchData.baseID = baseVO.id;
					researchData.id = responseData.id;
					researchData.playerOwnerID = CurrentUser.id;
					researchData.prototype = clientData.vo;
					starbaseModel.importResearchData(researchData);
					transactionModel.updatedTransaction(responseData);
					ObjectPool.give(researchData);
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if(toastController == null)
						return;
					var research:ResearchVO       = starbaseModel.getResearchByID(responseData.id);
					if(research == null)
						return;
					toastController.addTransactionToast(research, responseData);
					ExternalInterfaceAPI.shareTransaction(event.type, research);
					transactionModel.removeTransaction(responseData.token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					transactionModel.removeTransaction(responseData.token);
					starbaseModel.removeResearchByID(responseData.id);
					break;
			}
		}
	}
}
