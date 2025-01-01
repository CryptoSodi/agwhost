package com.controller.transaction
{
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	
	import org.robotlegs.extensions.presenter.impl.Command;
	
	public class StarbaseContractCommand extends Command
	{
		[Inject]
		public var event:TransactionEvent;
		[Inject]
		public var transactionModel:TransactionModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		
		override public function execute():void
		{
			var clientData:Object          = event.clientData;
			var responseData:TransactionVO = event.responseData;
			var token:int                  = event.transactionToken;
			
			switch (responseData.state)
			{
				case StarbaseTransactionStateEnum.SAVED:
				case StarbaseTransactionStateEnum.TIMER_RUNNING:
					break;
				case StarbaseTransactionStateEnum.TIMER_DONE:
					break;
				case StarbaseTransactionStateEnum.CANCELLED:
				case StarbaseTransactionStateEnum.FAILED:
					break;
			}
		}
	}
}