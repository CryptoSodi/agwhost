package com.controller.transaction.requirements
{
	import com.enum.TypeEnum;
	import com.event.TransactionEvent;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.service.language.Localization;
	
	import flash.utils.Dictionary;

	public class BuildingNotBusyRequirement extends BuildingRequirementBase implements IRequirement
	{
		private var _building:BuildingVO;
		private var _transaction:TransactionVO;
		private var _transactionModel:TransactionModel;

		private const UPGRADE_IN_PROGRESS:String         = 'CodeString.ResearchInformation.UpgradeInProgress'; //Current upgrade must be finished
		private const RESEARCH_IN_PROGRESS:String        = 'CodeString.ResearchInformation.ResearchInProgress'; //Current research must be finished
		private const BUILD_IN_PROGRESS:String           = 'CodeString.ResearchInformation.BuildInProgress'; //Current build must be finished
		private const SHIP_BUILD_IN_PROGRESS:String      = 'CodeString.ResearchInformation.ShipBuildInProgress'; //Current ship construction must be finished.
		private const BUILDING_REPAIR_IN_PROGRESS:String = 'Current building repair must be finished.'; //Current building repair must be finished.

		public function init( building:BuildingVO ):void
		{
			_building = building;
		}

		public function get isMet():Boolean
		{
			//a building can be busy in a few different ways
			//some can also be researching and some can beairing
			//some can also be researching and some can be
			//performing an action on a ship. we need to check for all of these cases.
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_BUILDING_BUILD:
					case TransactionEvent.STARBASE_BUILDING_RECYCLE:
					case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					case TransactionEvent.STARBASE_REFIT_BUILDING:
					case TransactionEvent.STARBASE_REPAIR_BASE:
						if (_building && transaction.id == _building.id)
						{
							_transaction = transaction;
							return false;
						}
						break;
					case TransactionEvent.STARBASE_RESEARCH:
						var researchVO:ResearchVO = _starbaseModel.getResearchByID(transaction.id);
						var requiredBuilding:BuildingVO = researchVO ? _starbaseModel.getBuildingByClass(researchVO.requiredBuildingClass) : null;
						if (_building && requiredBuilding && _building.id == requiredBuilding.id)
						{
							_transaction = transaction;
							return false;
						}
						break;
				}
			}
			return true;
		}

		public function get showIfMet():Boolean  { return false; }

		public function toString():String
		{
			var key:String;
			switch (_transaction.type)
			{
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					key = UPGRADE_IN_PROGRESS;
					break;

				case TransactionEvent.STARBASE_RESEARCH:
					key = RESEARCH_IN_PROGRESS;
					break;

				case TransactionEvent.STARBASE_REFIT_BUILDING:
				case TransactionEvent.STARBASE_BUILDING_RECYCLE:
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					key = BUILD_IN_PROGRESS;
					break;

				case TransactionEvent.STARBASE_REFIT_SHIP:
				case TransactionEvent.STARBASE_RECYCLE_SHIP:
				case TransactionEvent.STARBASE_BUILD_SHIP:
				case TransactionEvent.STARBASE_REPAIR_FLEET:
					key = SHIP_BUILD_IN_PROGRESS;
					break;
				case TransactionEvent.STARBASE_REPAIR_BASE:
					key = BUILDING_REPAIR_IN_PROGRESS;
					break;
				default:
					throw new Error("A building's transaction ID does not appear to be a building-related transaction type: " + _transaction.type);
			}

			return Localization.instance.getString(key);
		}

		public function toHtml():String
		{
			return toString().toUpperCase();
		}

		public function get transaction():TransactionVO  { return _transaction; }

		[Inject]
		public function set transactionModel( v:TransactionModel ):void  { _transactionModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_building = null;
			_transaction = null;
			_transactionModel = null;
		}
	}
}
