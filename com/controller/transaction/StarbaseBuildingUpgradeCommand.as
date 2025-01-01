package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.ExternalInterfaceAPI;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuildingUpgradeCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var game:Game;
		[Inject]
		public var prototypeModel:PrototypeModel;
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
			var upgradeVO:IPrototype;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
				{
					if (vo)
					{
						toastController.addTransactionToast(vo.prototype, responseData);
						var sis:StarbaseInteractSystem = StarbaseInteractSystem(game.getSystem(StarbaseInteractSystem));
						if (sis)
						{
							entity = game.getEntity(responseData.id);
							if (entity)
							{
								starbaseFactory.updateStarbaseBuilding(entity);
								if (vo.itemClass == TypeEnum.PYLON)
								{
									var starbaseSystem:StarbaseSystem = StarbaseSystem(game.getSystem(StarbaseSystem));
									if (starbaseSystem)
										starbaseSystem.findPylonConnections(game.getEntity(vo.id));
								}
							}
							sis.updateRanges();
						}
						var asset:AssetVO              = AssetModel.instance.getEntityData(vo.asset);
						if (asset)
						{
							if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
								ExternalInterfaceAPI.shareTransaction(event.type, vo);
						}
					}
					transactionModel.removeTransaction(token);
					break;
				}
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					entity = game.getEntity(responseData.id);
					if (entity)
					{
						starbaseFactory.updateStarbaseBuilding(entity);
					}
					transactionModel.removeTransaction(token);
					break;
			}

		}
	}
}
