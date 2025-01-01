package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.ExternalInterfaceAPI;

	import flash.utils.Dictionary;

	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRefitBuildingCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var game:Game;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var starbaseFactory:IStarbaseFactory;
		[Inject]
		public var toastController:ToastController;
		[Inject]
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object             = event.clientData;
			var responseData:TransactionVO    = event.responseData;
			var token:int                     = event.transactionToken;
			var buildingVO:BuildingVO         = starbaseModel.getBuildingByID(responseData.id);
			var system:StarbaseInteractSystem = StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem));

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					toastController.addTransactionToast(buildingVO.prototype, responseData);
					ExternalInterfaceAPI.shareTransaction(responseData.type, buildingVO);
					buildingVO.refitModules = new Dictionary();
					starbaseFactory.updateStarbaseBuilding(game.getEntity(buildingVO.id));
					transactionModel.removeTransaction(token);
					//hide any residual ranges
					if (system)
						system.updateRanges();
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					if (clientData && clientData.purchaseType == PurchaseTypeEnum.INSTANT)
					{
						//rollback the modules on this building
						buildingVO.refitModules = new Dictionary();
						starbaseFactory.updateStarbaseBuilding(game.getEntity(buildingVO.id));
					}
					transactionModel.removeTransaction(token);
					//hide any residual ranges
					if (system)
						system.updateRanges();
					break;
			}
		}
	}
}
