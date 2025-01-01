package com.event
{
	import com.model.transaction.TransactionVO;
	
	import flash.events.Event;

	public class TransactionEvent extends Event
	{
		public static const STARBASE_BUILDING_BUILD:String             = "BuildingBuild";
		public static const STARBASE_BUILDING_MOVE:String              = "BuildingMove";
		public static const STARBASE_BUILDING_RECYCLE:String           = "BuildingRecycle";
		public static const STARBASE_BUILDING_UPGRADE:String           = "BuildingUpgrade";
		public static const STARBASE_BUILD_SHIP:String                 = "BuildShip";
		public static const STARBASE_LAUNCH_FLEET:String               = "LaunchFleet";
		public static const STARBASE_RENAME_FLEET:String               = "RenameFleet";
		public static const STARBASE_REPAIR_FLEET:String               = "RepairFleet";
		public static const STARBASE_RECALL_FLEET:String               = "RecallFleet";
		public static const STARBASE_REPAIR_BASE:String                = "RepairBase";
		public static const STARBASE_REFIT_BUILDING:String             = "RefitBuilding";
		public static const STARBASE_UPDATE_FLEET:String               = "UpdateFleet";
		public static const STARBASE_SPEED_UP_TRANSACTION:String       = "SpeedUpTransaction";
		public static const STARBASE_CANCEL_TRANSACTION:String         = "CancelTransaction";
		public static const STARBASE_BUY_RESOURCES:String              = "BuyResources";
		public static const STARBASE_BUY_STORE_ITEM:String             = "BuyStoreItem";
		public static const STARBASE_BUY_OTHER_STORE_ITEM:String       = "BuyOtherStoreItem";
		public static const STARBASE_RESEARCH:String                   = "Research";
		public static const STARBASE_RECYCLE_SHIP:String               = "RecycleShip";
		public static const STARBASE_REFIT_SHIP:String                 = "RefitShip";
		public static const STARBASE_NEGOTIATE_CONTRACT_REQUEST:String = "SNCR";
		public static const STARBASE_CANCEL_CONTRACT_REQUEST:String    = "SCCR";
		public static const STARBASE_MISSION_STEP:String               = "SBMS"
		public static const STARBASE_MISSION_ACCEPT:String             = "SBMA";
		public static const STARBASE_MISSION_ACCEPT_REWARD:String      = "SBMAR";
		public static const STARBASE_BLUEPRINT_PURCHASE:String         = "SBBPP";
		public static const STARBASE_REROLL_BLUEPRINT_CHANCE:String    = "SBRBC"
		public static const STARBASE_REROLL_RECIEVED_BLUEPRINT:String  = "SBRRB";
		public static const STARBASE_RENAME_PLAYER:String              = "SBRP";
		public static const STARBASE_RELOCATE_STARBASE:String          = "SBRSB";
		public static const STARBASE_INSTANCED_MISSION_START:String    = "SIMS";
		public static const STARBASE_MINT_NFT:String    			   = "SMNFT";
		

		public var clientData:Object;
		public var responseData:TransactionVO;
		public var transactionToken:int;

		public function TransactionEvent( type:String, transactionToken:int, clientData:Object, responseData:TransactionVO )
		{
			super(type, false, false);
			this.clientData = clientData;
			this.responseData = responseData;
			this.transactionToken = transactionToken;
		}
	}
}
