package com.controller.transaction
{
	import com.enum.TypeEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseBuildingMoveCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var transactionModel:TransactionModel;
		[Inject]
		public var game:Game;
		[Inject]
		public var starbaseFactory:IStarbaseFactory;
		[Inject]
		public var starbaseModel:StarbaseModel;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var entity:Entity;
			var responseData:TransactionVO = event.responseData;
			var token:int                  = event.transactionToken;
			var vo:BuildingVO;
			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					transactionModel.removeTransaction(token);
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					var id:String = clientData.id;
					vo = starbaseModel.getBuildingByID(id);
					//remove the building vo from the grid
					starbaseModel.grid.removeFromGrid(vo);
					//update building vo position
					vo.baseX = clientData.baseX;
					vo.baseY = clientData.baseY;
					//add back to the grid
					starbaseModel.grid.addToGrid(vo, true);
					entity = game.getEntity(id);
					if (entity)
					{
						var position:Position     = entity.get(Position);
						//update the entity position
						starbaseModel.grid.convertBuildingGridToIso(position.position, vo);
						//have to do this to update followers
						position.x = position.position.x;
						position.y = position.position.y;

						var system:StarbaseSystem = StarbaseSystem(game.getSystem(StarbaseSystem));
						if (system)
						{
							if (vo.itemClass == TypeEnum.PYLON)
							{
								system.positionPylonBase(entity);
								system.findPylonConnections(entity);
							}
							system.depthSort(StarbaseSystem.DEPTH_SORT_ALL);
						}

						//update the entity on the grid
						var gridSystem:GridSystem = GridSystem(game.getSystem(GridSystem));
						if (gridSystem)
							gridSystem.forceGridCheck(entity);
					}
					transactionModel.removeTransaction(token);
					break;
			}
		}
	}
}
