package com.controller.transaction
{
	import com.enum.StarbaseConstructionEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuildingRecycleCommand extends Command
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
		public var transactionModel:TransactionModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var buildingVO:BuildingVO      = clientData.buildingVO;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;

				case StarbaseTransactionStateEnum.TIMER_DONE:
					transactionModel.removeTransaction(responseData.token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					if (clientData)
					{
						//add the building back to the starbase
						starbaseModel.addBuilding(buildingVO);
						var starbaseSystem:StarbaseSystem = StarbaseSystem(game.getSystem(StarbaseSystem));
						if (starbaseSystem)
						{
							if (buildingVO.constructionCategory == StarbaseConstructionEnum.PLATFORM)
							{
								starbaseFactory.createBaseItem(buildingVO.id, buildingVO);
								if (starbaseSystem)
									starbaseSystem.depthSort(StarbaseSystem.DEPTH_SORT_PLATFORMS);
							} else
							{
								starbaseFactory.createBuilding(buildingVO.id, buildingVO);
								if (starbaseSystem)
									starbaseSystem.depthSort(StarbaseSystem.DEPTH_SORT_BUILDINGS);
							}

							if (starbaseSystem)
								starbaseSystem.findPylonConnections();
						}
					}
					transactionModel.removeTransaction(responseData.token);
					break;
			}
		}
	}
}
