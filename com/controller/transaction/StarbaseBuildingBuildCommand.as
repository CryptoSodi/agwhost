package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.ExternalInterfaceAPI;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuildingBuildCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var game:Game;
		[Inject]
		public var starbaseFactory:IStarbaseFactory;
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
			var entity:Entity;
			var responseData:TransactionVO = event.responseData;
			var token:int                  = event.transactionToken;
			var vo:BuildingVO              = starbaseModel.getBuildingByID(responseData.id);

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					entity = game.getEntity(clientData.id);
					starbaseModel.updateBuildingID(clientData.id, responseData.id);
					if (entity)
					{
						vo = starbaseModel.getBuildingByID(responseData.id);
						//update the id of the entity with the one from the server
						game.updateEntityID(entity, responseData.id);
						if (vo.itemClass == TypeEnum.PYLON)
						{
							var system:StarbaseSystem = StarbaseSystem(game.getSystem(StarbaseSystem));
							if (system)
								system.findPylonConnections(entity);
						}
					}
					clientData.id = responseData.id;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (vo && vo.prototype)
					{
						if (vo.prototype.getValue("category") != StarbaseCategoryEnum.STARBASE_STRUCTURE)
						{
							toastController.addTransactionToast(vo.prototype, responseData);
							var asset:AssetVO = AssetModel.instance.getEntityData(vo.asset);
							if (asset)
							{
								var img:String = asset.mediumImage;
								ExternalInterfaceAPI.shareTransaction(event.type, vo);
							}
						}
					}
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					var id:String = (clientData) ? clientData.id : responseData.id;
					vo = starbaseModel.removeBuildingByID(id);
					entity = game.getEntity(id);
					if (entity)
					{
						if (vo.itemClass == TypeEnum.PYLON)
						{
							system = StarbaseSystem(game.getSystem(StarbaseSystem));
							if (system)
								system.findPylonConnections(entity, true);
						}
						starbaseFactory.destroyStarbaseItem(entity);
					}
					transactionModel.removeTransaction(token);
					break;
			}
		}
	}
}


