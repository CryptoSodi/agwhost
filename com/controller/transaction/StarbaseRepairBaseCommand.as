package com.controller.transaction
{
	import com.controller.toast.ToastController;
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRepairBaseCommand extends Command
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
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var entity:Entity;
			var responseData:TransactionVO = event.responseData;
			var token:int                  = event.transactionToken;
			var vo:BuildingVO              = starbaseModel.getBuildingByID(responseData.id, false);

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					if (vo)
					{
						if (vo.currentHealth == 0)
						{
							vo.currentHealth = .1;
							entity = game.getEntity(vo.id);
							if (entity)
								starbaseFactory.updateStarbaseBuilding(entity);
						}
					}
					transactionModel.updatedTransaction(responseData);
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					if (vo && vo.itemClass == TypeEnum.PYLON)
					{
						vo.currentHealth = 1;
						var system:StarbaseSystem = StarbaseSystem(game.getSystem(StarbaseSystem));
						if (system)
							system.findPylonConnections(game.getEntity(vo.id));
					}
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
