package com.controller.transaction
{
	import com.enum.FleetStateEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.enum.ui.ButtonEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.transaction.TransactionVO;
	import com.ui.alert.ConfirmationView;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.ViewFactory;

	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	import org.robotlegs.extensions.presenter.impl.Command;

	public class StarbaseRecallFleetCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var fleetModel:FleetModel;
		[Inject]
		public var viewFactory:IViewFactory;

		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var fleet:FleetVO              = fleetModel.getFleet(responseData.id);
			var token:int                  = event.transactionToken;

			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
					break;
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
					break;
				case StarbaseTransactionStateEnum.FAILED:
					if (fleet && fleet.inBattle)
					{
						fleet.state = FleetStateEnum.OUT;
						fleetModel.updateFleet(fleet);
						var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
						buttons.push(new ButtonPrototype('OK', null, null, true, ButtonEnum.RED_A));

						var viewEvent:ViewEvent              = new ViewEvent(ViewEvent.SHOW_VIEW);
						var view:ConfirmationView            = ConfirmationView(viewFactory.createView(ConfirmationView));

						view.setup('IN COMBAT', "The currently selected fleet is in combat and cannot recall.", buttons)
						viewEvent.targetView = view;
						dispatch(viewEvent);
					}
					break;
			}
		}
	}
}
