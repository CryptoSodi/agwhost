package com.controller.transaction
{
	import com.controller.ServerController;
	import com.controller.transaction.requirements.BlueprintRequirement;
	import com.controller.transaction.requirements.BuildingLevelRequirement;
	import com.controller.transaction.requirements.BuildingNotBusyRequirement;
	import com.controller.transaction.requirements.BuildingNotDamagedRequirement;
	import com.controller.transaction.requirements.CategoryNotBuildingRequirement;
	import com.controller.transaction.requirements.IRequirementFactory;
	import com.controller.transaction.requirements.RequirementVO;
	import com.controller.transaction.requirements.ResearchRequirement;
	import com.controller.transaction.requirements.TechNotKnownRequirement;
	import com.controller.transaction.requirements.UnderMaxCountRequirement;
	import com.controller.transaction.requirements.UnderMaxResourceRequirement;
	import com.controller.transaction.requirements.UniqueEquipRequirement;
	import com.enum.CurrencyEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.enum.server.RequestEnum;
	import com.enum.server.StarbaseBuildStateEnum;
	import com.enum.server.StarbaseTransactionStateEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IShipyardPresenter;
	import com.service.server.ITransactionRequest;
	import com.service.server.ITransactionResponse;
	import com.service.server.outgoing.starbase.StarbaseBuildNewBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseBuildShipRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyOtherStoreItemRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyResourceRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyStoreItemRequest;
	import com.service.server.outgoing.starbase.StarbaseBuyoutBlueprintRequest;
	import com.service.server.outgoing.starbase.StarbaseCancelContractRequest;
	import com.service.server.outgoing.starbase.StarbaseCancelTransactionRequest;
	import com.service.server.outgoing.starbase.StarbaseCompleteBlueprintResearchRequest;
	import com.service.server.outgoing.starbase.StarbaseInstancedMissionStartRequest;
	import com.service.server.outgoing.starbase.StarbaseLaunchFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseMintNFTRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionAcceptRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionAcceptRewardsRequest;
	import com.service.server.outgoing.starbase.StarbaseMissionStepRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveStarbaseRequest;
	import com.service.server.outgoing.starbase.StarbaseMoveStarbaseToTransgateRequest;
	import com.service.server.outgoing.starbase.StarbaseNegotiateContractRequest;
	import com.service.server.outgoing.starbase.StarbaseRecallFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseRecycleBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseRecycleShipRequest;
	import com.service.server.outgoing.starbase.StarbaseRefitBuildingRequest;
	import com.service.server.outgoing.starbase.StarbaseRefitShipRequest;
	import com.service.server.outgoing.starbase.StarbaseRenameFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseRenamePlayerRequest;
	import com.service.server.outgoing.starbase.StarbaseRepairBaseRequest;
	import com.service.server.outgoing.starbase.StarbaseRepairFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseRerollBlueprintChanceRequest;
	import com.service.server.outgoing.starbase.StarbaseRerollBlueprintReceivedRequest;
	import com.service.server.outgoing.starbase.StarbaseResearchRequest;
	import com.service.server.outgoing.starbase.StarbaseSpeedUpTransactionRequest;
	import com.service.server.outgoing.starbase.StarbaseUpdateFleetRequest;
	import com.service.server.outgoing.starbase.StarbaseUpgradeBuildingRequest;
	import com.util.statcalc.StatCalcUtil;
	
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.robotlegs.extensions.eventCommandMap.api.IEventCommandMap;

	public class TransactionController
	{
		private var _assetModel:AssetModel;
		private var _commandMap:IEventCommandMap;
		private var _eventDispatcher:IEventDispatcher;
		private var _prototypeModel:PrototypeModel;
		private var _requirementVO:RequirementVO;
		private var _serverController:ServerController;
		private var _starbaseModel:StarbaseModel;
		private var _transactionModel:TransactionModel;
		private var _reqFactory:IRequirementFactory;
		private var _shipyardPresenter:IShipyardPresenter;

		protected const _logger:ILogger = getLogger('TransactionController');

		[PostConstruct]
		public function init():void
		{
			_commandMap.map(TransactionEvent.STARBASE_BUILDING_BUILD, TransactionEvent).toCommand(StarbaseBuildingBuildCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUILDING_MOVE, TransactionEvent).toCommand(StarbaseBuildingMoveCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUILDING_RECYCLE, TransactionEvent).toCommand(StarbaseBuildingRecycleCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUILD_SHIP, TransactionEvent).toCommand(StarbaseBuildShipCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUILDING_UPGRADE, TransactionEvent).toCommand(StarbaseBuildingUpgradeCommand);
			_commandMap.map(TransactionEvent.STARBASE_REFIT_BUILDING, TransactionEvent).toCommand(StarbaseRefitBuildingCommand);
			_commandMap.map(TransactionEvent.STARBASE_REFIT_SHIP, TransactionEvent).toCommand(StarbaseRefitShipCommand);
			_commandMap.map(TransactionEvent.STARBASE_REPAIR_BASE, TransactionEvent).toCommand(StarbaseRepairBaseCommand);
			_commandMap.map(TransactionEvent.STARBASE_RESEARCH, TransactionEvent).toCommand(StarbaseResearchCommand);
			_commandMap.map(TransactionEvent.STARBASE_UPDATE_FLEET, TransactionEvent).toCommand(StarbaseUpdateFleetCommand);
			_commandMap.map(TransactionEvent.STARBASE_REPAIR_FLEET, TransactionEvent).toCommand(StarbaseRepairFleetCommand);
			_commandMap.map(TransactionEvent.STARBASE_RECALL_FLEET, TransactionEvent).toCommand(StarbaseRecallFleetCommand);
			_commandMap.map(TransactionEvent.STARBASE_RECYCLE_SHIP, TransactionEvent).toCommand(StarbaseRecycleShipCommand);
			_commandMap.map(TransactionEvent.STARBASE_NEGOTIATE_CONTRACT_REQUEST, TransactionEvent).toCommand(StarbaseNegotiateContractCommand);
			_commandMap.map(TransactionEvent.STARBASE_CANCEL_CONTRACT_REQUEST, TransactionEvent).toCommand(StarbaseCancelContractCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUY_RESOURCES, TransactionEvent).toCommand(StarbaseBuyResourcesCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUY_STORE_ITEM, TransactionEvent).toCommand(StarbaseBuyStoreItemCommand);
			_commandMap.map(TransactionEvent.STARBASE_BUY_OTHER_STORE_ITEM, TransactionEvent).toCommand(StarbaseBuyOtherStoreItemCommand);

			_requirementVO = new RequirementVO(_assetModel);
		}

		public function addTransaction( request:ITransactionRequest, id:String, type:String, data:Object, createDefaultTransaction:Boolean = true ):void
		{
			if (!data)
				data = {};
			_transactionModel.addTransaction(request, id, type, data, createDefaultTransaction);
			_logger.debug('Adding New Transaction Type: {0}, Token: {1}', [type, request.token]);
			_serverController.send(request);
		}

		public function handleResponse( response:ITransactionResponse ):void
		{
			_logger.debug('Response Transaction Token: {}', response.token);
			var clientData:Object = _transactionModel.handleResponse(response);
			dispatch(response.token, clientData, response.data);
		}

		private function getRequest( protocolID:int, header:int ):ITransactionRequest
		{
			return ITransactionRequest(_serverController.getRequest(protocolID, header));
		}

		private function dispatch( transactionToken:int, clientData:Object, responseData:TransactionVO ):void
		{
			if (responseData.type)
				_eventDispatcher.dispatchEvent(new TransactionEvent(responseData.type, transactionToken, clientData, responseData));
			else
			{
				//if we don't know what the transaction is (due to a missing type), remove it
				_transactionModel.removeTransaction(responseData.token);
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//													NEW TRANSACTION
		//************************************************************************************************************
		//============================================================================================================

		public function starbaseBuild( buildingVO:BuildingVO, purchaseType:uint ):Boolean
		{
			if (checkCost(buildingVO, purchaseType))
			{
				var buildNewBuildingRequest:StarbaseBuildNewBuildingRequest = StarbaseBuildNewBuildingRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUILD_NEW_BUILDING));
				buildNewBuildingRequest.buildingPrototype = buildingVO.name;
				buildNewBuildingRequest.locationX = buildingVO.baseX;
				buildNewBuildingRequest.locationY = buildingVO.baseY;
				buildNewBuildingRequest.centerSpaceBase = false;
				buildNewBuildingRequest.purchaseType = purchaseType;

				buildNewBuildingRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : buildingVO.buildTimeSeconds * 1000;
				buildNewBuildingRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				buildNewBuildingRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				buildNewBuildingRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				buildNewBuildingRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;

				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost = _requirementVO.purchaseVO.premium;
					else
						premiumCost = _requirementVO.purchaseVO.resourcePremiumCost;

					buildNewBuildingRequest.expectedCost.hardCurrencyCost = premiumCost;
				}

				buildingVO.buildState = (purchaseType == PurchaseTypeEnum.INSTANT) ? StarbaseBuildStateEnum.DONE : StarbaseBuildStateEnum.BUILDING;
				addTransaction(buildNewBuildingRequest, buildingVO.id, TransactionEvent.STARBASE_BUILDING_BUILD, {id:buildingVO.id, purchaseType:purchaseType});
				return true;
			} else
				_logger.warn("Build request on {} failed to send to the server due to insufficient funds", buildingVO.itemClass);
			return false;
		}

		public function starbaseUpgradeBuilding( buildingVO:BuildingVO, upgradeVO:IPrototype, purchaseType:uint ):Boolean
		{
			if (checkCost(upgradeVO, purchaseType))
			{
				var upgradeBuildingRequest:StarbaseUpgradeBuildingRequest = StarbaseUpgradeBuildingRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_UPGRADE_BUILDING));
				upgradeBuildingRequest.buildingPersistence = buildingVO.id;
				upgradeBuildingRequest.purchaseType = purchaseType;

				upgradeBuildingRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : upgradeVO.buildTimeSeconds * 1000;
				upgradeBuildingRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				upgradeBuildingRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				upgradeBuildingRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				upgradeBuildingRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;

				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost = _requirementVO.purchaseVO.premium;
					else
						premiumCost = _requirementVO.purchaseVO.resourcePremiumCost;

					upgradeBuildingRequest.expectedCost.hardCurrencyCost = premiumCost;
				}

				buildingVO.buildState = (purchaseType == PurchaseTypeEnum.INSTANT) ? StarbaseBuildStateEnum.DONE : StarbaseBuildStateEnum.UPGRADING;
				addTransaction(upgradeBuildingRequest, buildingVO.id, TransactionEvent.STARBASE_BUILDING_UPGRADE, {id:buildingVO.id, purchaseType:purchaseType});
				return true;
			} else
				_logger.warn("Upgrade request on {} failed to send to the server due to insufficient funds", buildingVO.itemClass);
			return false;
		}

		public function starbaseMoveBuilding( buildingVO:BuildingVO, oldBaseX:int, oldBaseY:int ):void
		{
			var moveBuildingRequest:StarbaseMoveBuildingRequest = StarbaseMoveBuildingRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MOVE_BUILDING));
			moveBuildingRequest.buildingKey = buildingVO.id;
			moveBuildingRequest.locationX = buildingVO.baseX;
			moveBuildingRequest.locationY = buildingVO.baseY;
			moveBuildingRequest.centerSpaceBase = false;
			addTransaction(moveBuildingRequest, buildingVO.id, TransactionEvent.STARBASE_BUILDING_MOVE, {id:buildingVO.id, baseX:oldBaseX, baseY:oldBaseY}, false);
		}

		public function starbaseRecycleBuilding( buildingVO:BuildingVO ):void
		{
			var recycleBuildingRequest:StarbaseRecycleBuildingRequest = StarbaseRecycleBuildingRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RECYCLE_BUILDING));
			recycleBuildingRequest.buildingPersistence = buildingVO.id;
			addTransaction(recycleBuildingRequest, buildingVO.id, TransactionEvent.STARBASE_BUILDING_RECYCLE, {id:buildingVO.id, buildingVO:buildingVO});
		}

		/**
		 * Send a request to the sever to refit the building with the new modules
		 *
		 * @param buildingVO The vo of the building to refit
		 * @param equipped The new modules that we want on the building
		 * @param currentModules Save a reference to the old modules so that we can roll back in case the server denies the refit request
		 * @param instant Should the refit be done instantly or not
		 */
		public function starbaseRefitBuilding( buildingVO:BuildingVO, modules:Dictionary, purchaseType:uint ):void
		{
			if (checkCost(buildingVO, purchaseType))
			{
				var refitBuildingRequest:StarbaseRefitBuildingRequest = StarbaseRefitBuildingRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REFIT_BUILDING));
				refitBuildingRequest.buildingPersistence = buildingVO.id;
				refitBuildingRequest.purchaseType = purchaseType;
				refitBuildingRequest.modules = modules;
				refitBuildingRequest.slots = buildingVO.prototype.getValue('slots');

				refitBuildingRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : buildingVO.refitBuildTimeSeconds * 1000;
				refitBuildingRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				refitBuildingRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				refitBuildingRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				refitBuildingRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;

				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost += _requirementVO.purchaseVO.premium;
					else
						premiumCost += _requirementVO.purchaseVO.resourcePremiumCost;

					refitBuildingRequest.expectedCost.hardCurrencyCost = premiumCost;
				}

				addTransaction(refitBuildingRequest, buildingVO.id, TransactionEvent.STARBASE_REFIT_BUILDING, {id:buildingVO.id, modules:buildingVO.modules, purchaseType:purchaseType});
			}
		}

		public function starbaseRepairBuildings( hardCurrency:int, purchaseType:uint ):void
		{
			var repairTransactionRequest:StarbaseRepairBaseRequest = StarbaseRepairBaseRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REPAIR_BASE));
			repairTransactionRequest.purchaseType = purchaseType;
			repairTransactionRequest.centerSpaceBase = false;

			//expected costs are currently not used on building repair
			/*repairTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			   repairTransactionRequest.expectedCost.alloyCost = 0;
			   repairTransactionRequest.expectedCost.energyCost = 0;
			   repairTransactionRequest.expectedCost.syntheticCost = 0;
			   repairTransactionRequest.expectedCost.creditsCost = 0;*/

			addTransaction(repairTransactionRequest, '', TransactionEvent.STARBASE_REPAIR_BASE, {}, false);
		}

		public function dockUpdateFleet( selectedFleet:FleetVO ):void
		{
			var updateFleetRequest:StarbaseUpdateFleetRequest = StarbaseUpdateFleetRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_UPDATE_FLEET));
			updateFleetRequest.fleet = selectedFleet;
			addTransaction(updateFleetRequest, selectedFleet.id, TransactionEvent.STARBASE_UPDATE_FLEET, {vo:selectedFleet}, false);
		}

		public function dockChangeFleetName( fleetID:String, newName:String ):void
		{
			var renameFleetRequest:StarbaseRenameFleetRequest = StarbaseRenameFleetRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RENAME_FLEET));
			renameFleetRequest.fleetId = fleetID;
			renameFleetRequest.newName = newName;
			addTransaction(renameFleetRequest, fleetID, TransactionEvent.STARBASE_RENAME_FLEET, {id:fleetID}, false);
		}

		public function dockRepairShip( selectedFleet:FleetVO, purchaseType:uint ):void
		{
			if (checkCost(selectedFleet, purchaseType))
			{
				var repairFleetRequest:StarbaseRepairFleetRequest = StarbaseRepairFleetRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REPAIR_FLEET));
				repairFleetRequest.fleetId = selectedFleet.id;
				repairFleetRequest.purchaseType = purchaseType;

				repairFleetRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : selectedFleet.repairTime * 1000;
				repairFleetRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				repairFleetRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				repairFleetRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				repairFleetRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;

				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost = _requirementVO.purchaseVO.premium;
					else
						premiumCost = _requirementVO.purchaseVO.resourcePremiumCost;

					repairFleetRequest.expectedCost.hardCurrencyCost = premiumCost;
				}

				addTransaction(repairFleetRequest, selectedFleet.id, TransactionEvent.STARBASE_REPAIR_FLEET, {id:selectedFleet.id});
			}
		}

		public function dockLaunchFleet( fleetsToLaunch:Array ):void
		{
			var launchFleetRequest:StarbaseLaunchFleetRequest = StarbaseLaunchFleetRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_LAUNCH_FLEET));
			launchFleetRequest.fleets = fleetsToLaunch;
			addTransaction(launchFleetRequest, '', TransactionEvent.STARBASE_LAUNCH_FLEET, {fleets:fleetsToLaunch}, false);
		}

		public function dockBuildShip( ship:ShipVO, purchaseType:uint ):void
		{
			if (checkCost(ship, purchaseType))
			{
				var buildShipRequest:StarbaseBuildShipRequest = StarbaseBuildShipRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUILD_SHIP));
				buildShipRequest.shipPrototype = ship.prototypeVO.name;
				buildShipRequest.purchaseType = purchaseType;
				buildShipRequest.modules = ship.modules;
				buildShipRequest.shipName = ship.refitShipName;
				buildShipRequest.slots = ship.prototypeVO.getValue('slots');

				buildShipRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : ship.buildTimeSeconds * 1000;
				buildShipRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				buildShipRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				buildShipRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				buildShipRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;
				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost = _requirementVO.purchaseVO.premium;
					else
						premiumCost = _requirementVO.purchaseVO.resourcePremiumCost;

					buildShipRequest.expectedCost.hardCurrencyCost = premiumCost;
				}
				addTransaction(buildShipRequest, ship.id, TransactionEvent.STARBASE_BUILD_SHIP, {id:ship.id});
			}
		}

		public function dockRefitShip( ship:ShipVO, purchaseType:uint ):void
		{
			if (checkCost(ship, purchaseType))
			{
				var refitShipRequest:StarbaseRefitShipRequest = StarbaseRefitShipRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REFIT_SHIP));
				refitShipRequest.shipPersistence = ship.id;
				refitShipRequest.purchaseType = purchaseType;
				refitShipRequest.modules = ship.refitModules;
				refitShipRequest.shipName = ship.refitShipName;

				refitShipRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				refitShipRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.alloyCost;
				refitShipRequest.expectedCost.energyCost = _requirementVO.purchaseVO.alloyCost;
				refitShipRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.alloyCost;
				refitShipRequest.expectedCost.time_cost_milliseconds = purchaseType == PurchaseTypeEnum.INSTANT ? 0 : ship.buildTimeSeconds * 1000;

				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var shipPremiumCost:int;
					_requirementVO.reset();
					calculatePremiumCost(ship);

					if (purchaseType == PurchaseTypeEnum.INSTANT)
						shipPremiumCost = _requirementVO.purchaseVO.premium;
					else
						shipPremiumCost = _requirementVO.purchaseVO.resourcePremiumCost;
					refitShipRequest.expectedCost.hardCurrencyCost = shipPremiumCost;
				}
				addTransaction(refitShipRequest, ship.id, TransactionEvent.STARBASE_REFIT_SHIP, {ship:ship});
			}
		}

		public function dockRecycleShip( ship:ShipVO ):void
		{
			checkCost(ship, PurchaseTypeEnum.NORMAL);
			var recycleTransactionRequest:StarbaseRecycleShipRequest = StarbaseRecycleShipRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RECYCLE_SHIP));
			recycleTransactionRequest.shipPersistence = ship.id;
			addTransaction(recycleTransactionRequest, ship.id, TransactionEvent.STARBASE_RECYCLE_SHIP, {id:ship.id, ship:ship});

		}

		public function dockRecallFleet( fleetID:String ):void
		{
			var recallTransactionRequest:StarbaseRecallFleetRequest = StarbaseRecallFleetRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RECALL_FLEET));
			recallTransactionRequest.fleet = fleetID;
			addTransaction(recallTransactionRequest, fleetID, TransactionEvent.STARBASE_RECALL_FLEET, {id:fleetID});
		}

		public function starbaseStartResearch( prototype:IPrototype, purchaseType:uint ):void
		{
			if (checkCost(prototype, purchaseType))
			{
				var researchRequest:StarbaseResearchRequest = StarbaseResearchRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RESEARCH));
				researchRequest.researchPrototype = prototype.name;
				researchRequest.purchaseType = purchaseType;

				researchRequest.expectedCost.time_cost_milliseconds = (purchaseType == PurchaseTypeEnum.INSTANT) ? 0 : prototype.buildTimeSeconds * 1000;
				researchRequest.expectedCost.alloyCost = _requirementVO.purchaseVO.alloyCost;
				researchRequest.expectedCost.energyCost = _requirementVO.purchaseVO.energyCost;
				researchRequest.expectedCost.syntheticCost = _requirementVO.purchaseVO.syntheticCost;
				researchRequest.expectedCost.creditsCost = _requirementVO.purchaseVO.creditsCost;
				if (purchaseType == PurchaseTypeEnum.INSTANT || purchaseType == PurchaseTypeEnum.GET_RESOURCES)
				{
					var premiumCost:int;
					if (purchaseType == PurchaseTypeEnum.INSTANT)
						premiumCost = _requirementVO.purchaseVO.premium;
					else
						premiumCost = _requirementVO.purchaseVO.resourcePremiumCost;

					researchRequest.expectedCost.hardCurrencyCost = premiumCost;
				}

				addTransaction(researchRequest, '', TransactionEvent.STARBASE_RESEARCH, {baseVO:_starbaseModel.currentBase, vo:prototype});
			}
		}

		public function speedUpTransaction( serverKey:String, token:int, instant:Boolean, speedUpBy:int, fromStore:Boolean, cost:int ):void
		{
			var speedUpTransactionRequest:StarbaseSpeedUpTransactionRequest = StarbaseSpeedUpTransactionRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_SPEED_UP_TRANSACTION));
			speedUpTransactionRequest.purchaseType = instant ? PurchaseTypeEnum.INSTANT : PurchaseTypeEnum.NORMAL;
			speedUpTransactionRequest.milliseconds = speedUpBy;
			speedUpTransactionRequest.serverKey = serverKey;
			speedUpTransactionRequest.fromStore = fromStore;

			speedUpTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			speedUpTransactionRequest.expectedCost.alloyCost = 0;
			speedUpTransactionRequest.expectedCost.energyCost = 0;
			speedUpTransactionRequest.expectedCost.syntheticCost = 0;
			speedUpTransactionRequest.expectedCost.creditsCost = 0;
			speedUpTransactionRequest.expectedCost.hardCurrencyCost = cost;

			var transaction:TransactionVO                                   = _transactionModel.getTransactionByToken(token);
			if (transaction)
			{
				//set the pending state on the transaction to block players from doing more than they should
				transaction.setPendingState();
				_transactionModel.updatedTransaction(transaction);
			}
			addTransaction(speedUpTransactionRequest, '', TransactionEvent.STARBASE_SPEED_UP_TRANSACTION, {id:serverKey}, false);
		}

		public function buyResourceTransaction( prototype:IPrototype, percent:int, centerBase:Boolean, cost:int ):void
		{
			var resourceTransactionRequest:StarbaseBuyResourceRequest = StarbaseBuyResourceRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUY_RESOURCE));
			resourceTransactionRequest.resource = prototype.getValue('resourceType');
			resourceTransactionRequest.percent = percent;
			resourceTransactionRequest.centerSpaceBase = centerBase;

			resourceTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			resourceTransactionRequest.expectedCost.alloyCost = 0;
			resourceTransactionRequest.expectedCost.energyCost = 0;
			resourceTransactionRequest.expectedCost.syntheticCost = 0;
			resourceTransactionRequest.expectedCost.creditsCost = 0;
			resourceTransactionRequest.expectedCost.hardCurrencyCost = cost;

			addTransaction(resourceTransactionRequest, '', TransactionEvent.STARBASE_BUY_RESOURCES, {prototype:prototype}, false);
		}

		public function buyStoreItemTransaction( buffPrototype:IPrototype, centerBase:Boolean, tempID:String, cost:int ):void
		{
			if (CurrentUser.wallet.premium >= cost)
			{
				var itemTransactionRequest:StarbaseBuyStoreItemRequest = StarbaseBuyStoreItemRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUY_STORE_ITEM));
				itemTransactionRequest.buffPrototype = buffPrototype.name;
				itemTransactionRequest.centerSpaceBase = centerBase;

				itemTransactionRequest.expectedCost.time_cost_milliseconds = buffPrototype.buildTimeSeconds;
				itemTransactionRequest.expectedCost.alloyCost = 0;
				itemTransactionRequest.expectedCost.energyCost = 0;
				itemTransactionRequest.expectedCost.syntheticCost = 0;
				itemTransactionRequest.expectedCost.creditsCost = 0;
				itemTransactionRequest.expectedCost.hardCurrencyCost = cost;

				CurrentUser.wallet.withdraw(cost, CurrencyEnum.PREMIUM);

				addTransaction(itemTransactionRequest, '', TransactionEvent.STARBASE_BUY_STORE_ITEM, {id:tempID, buff:buffPrototype}, false);
			}
		}

		public function buyBlueprintTransaction( blueprintVO:BlueprintVO, partsPurchased:uint ):void
		{
			var cost:int                                                   = getBlueprintHardCurrencyCost(blueprintVO, partsPurchased);
			var blueprintTransactionRequest:StarbaseBuyoutBlueprintRequest = StarbaseBuyoutBlueprintRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUYOUT_BLUEPRINT));
			blueprintTransactionRequest.blueprintPersistence = blueprintVO.id;
			blueprintTransactionRequest.partsPurchased = partsPurchased;

			blueprintTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			blueprintTransactionRequest.expectedCost.alloyCost = 0;
			blueprintTransactionRequest.expectedCost.energyCost = 0;
			blueprintTransactionRequest.expectedCost.syntheticCost = 0;
			blueprintTransactionRequest.expectedCost.creditsCost = 0;
			blueprintTransactionRequest.expectedCost.hardCurrencyCost = cost;

			addTransaction(blueprintTransactionRequest, '', TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, {blueprint:blueprintVO}, false);
		}
		
		public function completeBlueprintResearchTransaction( blueprintVO:BlueprintVO):void
		{
			var blueprintTransactionRequest:StarbaseCompleteBlueprintResearchRequest = StarbaseCompleteBlueprintResearchRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_COMPLETE_BLUEPRINT_RESEARCH));
			blueprintTransactionRequest.blueprintPersistence = blueprintVO.id;
			
			blueprintTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			blueprintTransactionRequest.expectedCost.alloyCost = 0;
			blueprintTransactionRequest.expectedCost.energyCost = 0;
			blueprintTransactionRequest.expectedCost.syntheticCost = 0;
			blueprintTransactionRequest.expectedCost.creditsCost = 0;
			blueprintTransactionRequest.expectedCost.hardCurrencyCost = 0;
			
			addTransaction(blueprintTransactionRequest, '', TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, {blueprint:blueprintVO}, false);
		}
		
		
		public function mintNFTTransaction( tokenType:int, tokenAmount:int, tokenPrototype:String ):void
		{
			if(CurrentUser.playerWalletKey.length == 0)
			{
				var url:String = "https://wallet.vavelverse.com/?atx_id=" + CurrentUser.id + "&name=" + CurrentUser.name + "&faction=" + CurrentUser.faction +"&avatar=" + CurrentUser.avatarName;
				var urlRequest:URLRequest = new URLRequest(url);
				navigateToURL(urlRequest);
				return;
			}
			
			
			var starbaseMintNFTRequest:StarbaseMintNFTRequest = StarbaseMintNFTRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.
				STARBASE_MINT_NFT));
			
			starbaseMintNFTRequest.tokenType = tokenType;
			starbaseMintNFTRequest.tokenAmount = tokenAmount;
			starbaseMintNFTRequest.tokenPrototype = tokenPrototype;
			
			starbaseMintNFTRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseMintNFTRequest.expectedCost.alloyCost = 0;
			starbaseMintNFTRequest.expectedCost.energyCost = 0;
			starbaseMintNFTRequest.expectedCost.syntheticCost = 0;
			starbaseMintNFTRequest.expectedCost.creditsCost = 0;
			starbaseMintNFTRequest.expectedCost.hardCurrencyCost = 0;
			
			addTransaction(starbaseMintNFTRequest, '', TransactionEvent.STARBASE_MINT_NFT, {tokenType:int, tokenAmount:int, tokenPrototype:String }, false);
		}
		
		public function buyOtherStoreItemTransaction( prototype:IPrototype, amount:int, centerBase:Boolean, tempID:String, cost:int ):void
		{
			var otherTransactionRequest:StarbaseBuyOtherStoreItemRequest = StarbaseBuyOtherStoreItemRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BUY_OTHER_STORE_ITEM));
			otherTransactionRequest.storeItemPrototype = prototype.name;
			otherTransactionRequest.itemType = prototype.getValue('resourceType');
			otherTransactionRequest.itemAmount = amount;
			otherTransactionRequest.centerSpaceBase = centerBase;
			
			otherTransactionRequest.expectedCost.time_cost_milliseconds = 0;
			otherTransactionRequest.expectedCost.alloyCost = 0;
			otherTransactionRequest.expectedCost.energyCost = 0;
			otherTransactionRequest.expectedCost.syntheticCost = 0;
			otherTransactionRequest.expectedCost.creditsCost = 0;
			otherTransactionRequest.expectedCost.hardCurrencyCost = cost;
			
			addTransaction(otherTransactionRequest, '', TransactionEvent.STARBASE_BUY_OTHER_STORE_ITEM, {id:tempID, prototype:prototype}, false);
		}

		public function transactionCancel( id:String ):void
		{
			var transaction:TransactionVO = _transactionModel.getTransactionByID(id);
			if (transaction)
			{
				var cancelTransactionRequest:StarbaseCancelTransactionRequest = StarbaseCancelTransactionRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_CANCEL_TRANSACTION));
				cancelTransactionRequest.serverKey = transaction.serverKey;
				//set the pending state on the transaction to block players from doing more than they should
				transaction.setPendingState();
				_transactionModel.updatedTransaction(transaction);
				addTransaction(cancelTransactionRequest, '', TransactionEvent.STARBASE_CANCEL_TRANSACTION, {id:cancelTransactionRequest.serverKey}, false);
			}
		}

		public function requestContract( centerSpaceBase:Boolean, contractPrototype:String, duration:Number, factionPrototype:String, frequency:Number, payout:Number, productivity:Number, security:Number,
										 callback:Function, accepted:Boolean ):void
		{
			var requestContractRequest:StarbaseNegotiateContractRequest = StarbaseNegotiateContractRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_NEGOTIATE_CONTRACT));
			requestContractRequest.centerSpaceBase = centerSpaceBase;
			requestContractRequest.contractPrototype = contractPrototype;
			requestContractRequest.duration = duration;
			requestContractRequest.factionPrototype = factionPrototype;
			requestContractRequest.frequency = frequency;
			requestContractRequest.payout = payout;
			requestContractRequest.productivity = productivity;
			requestContractRequest.security = security;
			requestContractRequest.accepted = accepted;
			addTransaction(requestContractRequest, '', TransactionEvent.STARBASE_NEGOTIATE_CONTRACT_REQUEST, {tradeRoute:requestContractRequest, callback:callback}, false);
		}

		public function cancelContract( id:String ):void
		{
			var starbaseCancelContractRequest:StarbaseCancelContractRequest = StarbaseCancelContractRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_CANCEL_CONTRACT));
			starbaseCancelContractRequest.tradeRoutePersistence = id;
			addTransaction(starbaseCancelContractRequest, '', TransactionEvent.STARBASE_CANCEL_CONTRACT_REQUEST, {id:id}, false);
		}
		
		public function instancedMissionStart( instanceMissionID:String ):void
		{
			var starbaseInstancedMissionStartRequest:StarbaseInstancedMissionStartRequest = StarbaseInstancedMissionStartRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_INSTANCED_MISSION_START));
			starbaseInstancedMissionStartRequest.instancedMissionID = instanceMissionID;
			addTransaction(starbaseInstancedMissionStartRequest, '', TransactionEvent.STARBASE_INSTANCED_MISSION_START, {}, false);
		}
		
		
		public function missionStepRequest( missionPrototype:String, progress:int ):void
		{
			var starbaseMissionStepRequest:StarbaseMissionStepRequest = StarbaseMissionStepRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MISSION_STEP));
			starbaseMissionStepRequest.missionPrototype = missionPrototype;
			starbaseMissionStepRequest.progress = progress;
			addTransaction(starbaseMissionStepRequest, '', TransactionEvent.STARBASE_MISSION_STEP, {}, false);
		}

		public function missionAccept( missionPersistenceID:String ):void
		{
			var starbaseMissionAcceptRequest:StarbaseMissionAcceptRequest = StarbaseMissionAcceptRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MISSION_ACCEPT));
			starbaseMissionAcceptRequest.missionPersistence = missionPersistenceID;
			addTransaction(starbaseMissionAcceptRequest, '', TransactionEvent.STARBASE_MISSION_ACCEPT, {}, false);
		}

		public function missionAcceptRewards( missionPersistenceID:String ):void
		{
			var missionAcceptRewardsRequest:StarbaseMissionAcceptRewardsRequest = StarbaseMissionAcceptRewardsRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MISSION_ACCEPT_REWARDS));
			missionAcceptRewardsRequest.missionPersistence = missionPersistenceID;
			addTransaction(missionAcceptRewardsRequest, '', TransactionEvent.STARBASE_MISSION_ACCEPT_REWARD, {}, false);
		}

		public function starbaseRenamePlayer( newName:String ):void
		{
			var cost:int                                                = _prototypeModel.getConstantPrototypeValueByName('playerRenamePrice');
			var starbaseRenamePlayerRequest:StarbaseRenamePlayerRequest = StarbaseRenamePlayerRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_RENAME_PLAYER));
			starbaseRenamePlayerRequest.newName = newName;

			starbaseRenamePlayerRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseRenamePlayerRequest.expectedCost.alloyCost = 0;
			starbaseRenamePlayerRequest.expectedCost.energyCost = 0;
			starbaseRenamePlayerRequest.expectedCost.syntheticCost = 0;
			starbaseRenamePlayerRequest.expectedCost.creditsCost = 0;
			starbaseRenamePlayerRequest.expectedCost.hardCurrencyCost = cost;

			addTransaction(starbaseRenamePlayerRequest, '', TransactionEvent.STARBASE_RENAME_PLAYER, {newName:newName}, false);
		}

		public function starbaseRelocateStarbase( targetPlayer:String ):void
		{
			var cost:int                                                    = _prototypeModel.getConstantPrototypeValueByName('playerRenamePrice');
			var starbaseRelocateStarbaseRequest:StarbaseMoveStarbaseRequest = StarbaseMoveStarbaseRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MOVE_STARBASE));
			starbaseRelocateStarbaseRequest.targetPlayer = targetPlayer;

			starbaseRelocateStarbaseRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseRelocateStarbaseRequest.expectedCost.alloyCost = 0;
			starbaseRelocateStarbaseRequest.expectedCost.energyCost = 0;
			starbaseRelocateStarbaseRequest.expectedCost.syntheticCost = 0;
			starbaseRelocateStarbaseRequest.expectedCost.creditsCost = 0;
			starbaseRelocateStarbaseRequest.expectedCost.hardCurrencyCost = cost;

			addTransaction(starbaseRelocateStarbaseRequest, '', TransactionEvent.STARBASE_RELOCATE_STARBASE, {targetPlayer:targetPlayer}, false);
		}
		
		public function starbaseRelocateStarbaseToTransgate( targetSector:String, targetTransgate:String ):void
		{
			var cost:int                                                    = _prototypeModel.getConstantPrototypeValueByName('playerRenamePrice');
			var starbaseRelocateStarbaseToTransgateRequest:StarbaseMoveStarbaseToTransgateRequest = StarbaseMoveStarbaseToTransgateRequest(getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MOVE_STARBASE_TO_TRANSGATE));
			starbaseRelocateStarbaseToTransgateRequest.targetSector = targetSector;
			starbaseRelocateStarbaseToTransgateRequest.targetTransgate = targetTransgate;
			
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.alloyCost = 0;
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.energyCost = 0;
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.syntheticCost = 0;
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.creditsCost = 0;
			starbaseRelocateStarbaseToTransgateRequest.expectedCost.hardCurrencyCost = cost;
			
			addTransaction(starbaseRelocateStarbaseToTransgateRequest, '', TransactionEvent.STARBASE_RELOCATE_STARBASE, {targetTransgate:targetTransgate}, false);
		}

		public function starbasePurchaseReroll( battleKey:String ):void
		{
			var costProto:IPrototype                                           = _prototypeModel.getConstantPrototypeByName('rerollItemPrice');

			var starbaseRerollBPRequest:StarbaseRerollBlueprintReceivedRequest = StarbaseRerollBlueprintReceivedRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REROLL_BLUEPRINT_RECEIVED_MESSAGE));
			starbaseRerollBPRequest.battleKey = battleKey;
			starbaseRerollBPRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseRerollBPRequest.expectedCost.alloyCost = 0;
			starbaseRerollBPRequest.expectedCost.energyCost = 0;
			starbaseRerollBPRequest.expectedCost.syntheticCost = 0;
			starbaseRerollBPRequest.expectedCost.creditsCost = 0;
			starbaseRerollBPRequest.expectedCost.hardCurrencyCost = costProto.getValue('value');
			addTransaction(starbaseRerollBPRequest, '', TransactionEvent.STARBASE_REROLL_RECIEVED_BLUEPRINT, {battleKey:battleKey}, false);
		}

		public function starbasePurchaseDeepScan( battleKey:String ):void
		{
			var costProto:IPrototype                                         = _prototypeModel.getConstantPrototypeByName('rerollLootPrice');

			var starbaseRerollBPRequest:StarbaseRerollBlueprintChanceRequest = StarbaseRerollBlueprintChanceRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REROLL_BLUEPRINT_CHANCE_MESSAGE));
			starbaseRerollBPRequest.battleKey = battleKey;
			starbaseRerollBPRequest.expectedCost.time_cost_milliseconds = 0;
			starbaseRerollBPRequest.expectedCost.alloyCost = 0;
			starbaseRerollBPRequest.expectedCost.energyCost = 0;
			starbaseRerollBPRequest.expectedCost.syntheticCost = 0;
			starbaseRerollBPRequest.expectedCost.creditsCost = 0;
			starbaseRerollBPRequest.expectedCost.hardCurrencyCost = costProto.getValue('value');
			addTransaction(starbaseRerollBPRequest, '', TransactionEvent.STARBASE_REROLL_BLUEPRINT_CHANCE, {battleKey:battleKey}, false);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													REQUIREMENTS
		//************************************************************************************************************
		//============================================================================================================

		public function canBuild( prototypeVO:IPrototype ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(prototypeVO, PurchaseTypeEnum.INSTANT, true);

			var underMaxResourceRequirement:UnderMaxResourceRequirement = new UnderMaxResourceRequirement();
			underMaxResourceRequirement.init(_requirementVO.purchaseVO);

			_requirementVO.addRequirement(underMaxResourceRequirement);
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BuildingLevelRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, UnderMaxCountRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, CategoryNotBuildingRequirement));

			return _requirementVO;
		}

		public function canUpgrade( buildingVO:BuildingVO ):RequirementVO
		{
			_requirementVO.reset();
			//ensure we have enough resources
			checkCost(buildingVO, PurchaseTypeEnum.INSTANT, true);

			var underMaxResourceRequirement:UnderMaxResourceRequirement = new UnderMaxResourceRequirement();
			underMaxResourceRequirement.init(_requirementVO.purchaseVO);

			_requirementVO.addRequirement(underMaxResourceRequirement);
			_requirementVO.addRequirement(_reqFactory.createRequirement(buildingVO, BuildingLevelRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(buildingVO, BuildingNotDamagedRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(buildingVO, BuildingNotBusyRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(buildingVO.prototype, CategoryNotBuildingRequirement));

			return _requirementVO;
		}

		public function canResearch( prototypeVO:IPrototype ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(prototypeVO, PurchaseTypeEnum.INSTANT, true);

			var underMaxResourceRequirement:UnderMaxResourceRequirement = new UnderMaxResourceRequirement();
			underMaxResourceRequirement.init(_requirementVO.purchaseVO);

			_requirementVO.addRequirement(underMaxResourceRequirement);
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BuildingLevelRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, ResearchRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, TechNotKnownRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BlueprintRequirement));

			_requirementVO.requiredFor = _prototypeModel.getResearchThatRequires(prototypeVO.name);

			return _requirementVO;
		}

		public function canPurchaseResearch( prototypeVO:IPrototype ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(prototypeVO, PurchaseTypeEnum.INSTANT, true);

			var underMaxResourceRequirement:UnderMaxResourceRequirement = new UnderMaxResourceRequirement();
			underMaxResourceRequirement.init(_requirementVO.purchaseVO);

			_requirementVO.addRequirement(underMaxResourceRequirement);
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BuildingLevelRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BuildingNotDamagedRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BuildingNotBusyRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, ResearchRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, TechNotKnownRequirement));
			_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, BlueprintRequirement));

			_requirementVO.requiredFor = _prototypeModel.getResearchThatRequires(prototypeVO.name);

			return _requirementVO;
		}

		public function canRepair( fleetVO:FleetVO ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(fleetVO, PurchaseTypeEnum.INSTANT, true);

			return _requirementVO;
		}

		public function canBuildShip( shipVO:IPrototype ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(shipVO, PurchaseTypeEnum.INSTANT, true);

			return _requirementVO;
		}

		public function canRefit( prototypeVO:IPrototype ):RequirementVO
		{
			_requirementVO.reset();

			//ensure we have enough resources
			checkCost(prototypeVO, PurchaseTypeEnum.INSTANT, true);

			//_requirementVO.addRequirement(_reqFactory.createRequirement(prototypeVO, CategoryNotBuildingRequirement));

			return _requirementVO;
		}

		public function canEquip( proto:IPrototype, slotID:String ):RequirementVO
		{
			_requirementVO.reset();

			var modules:Dictionary;
			var refitModules:Dictionary;
			if (shipyardPresenter)
			{
				modules = _shipyardPresenter.currentShip.modules;
				refitModules = _shipyardPresenter.currentShip.refitModules;
			}

			var uniqueEquipped:UniqueEquipRequirement = new UniqueEquipRequirement();
			uniqueEquipped.init(proto, modules, refitModules, slotID);

			_requirementVO.addRequirement(uniqueEquipped);
			_requirementVO.addRequirement(_reqFactory.createRequirement(proto, ResearchRequirement));

			return _requirementVO;
		}

		private function violatesUniqueConstraint( proto:IPrototype, slotID:String ):Boolean
		{
			if (!shipyardPresenter)
				return false;

			var uniqueCat:String = proto.getValue("uniqueCategory");

			if (uniqueCat.length == 0)
				return false;

			for (var key:String in _shipyardPresenter.currentShip.modules)
			{
				var module:IPrototype;
				if (_shipyardPresenter.currentShip.refitModules.hasOwnProperty(key))
					module = _shipyardPresenter.currentShip.refitModules[key];
				else
					module = _shipyardPresenter.currentShip.modules[key];

				if (module.getValue("uniqueCategory") == uniqueCat && slotID != key)
					return true;
				else
				{
					if (module == proto)
						return true;
				}

			}

			return false;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													HELPERS
		//************************************************************************************************************
		//============================================================================================================

		public function getAllStarbaseBuildingTransactions():Vector.<TransactionVO>
		{
			var v:Vector.<TransactionVO> = new Vector.<TransactionVO>();
			var transactions:Dictionary  = _transactionModel.transactions;

			for each (var transaction:TransactionVO in transactions)
			{
				if (transaction.timeMS > 0 || transaction.state == StarbaseTransactionStateEnum.PENDING)
				{
					switch (transaction.type)
					{
						case TransactionEvent.STARBASE_BUILDING_BUILD:
						case TransactionEvent.STARBASE_BUILDING_RECYCLE:
						case TransactionEvent.STARBASE_BUILDING_UPGRADE:
						case TransactionEvent.STARBASE_REFIT_BUILDING:
						{
							v.push(transaction);
								//							break;
						}
					}
				}
			}

			return v;
		}

		public function getStarbaseBuildingTransaction( constructionCategory:String = null, buildingID:String = null ):TransactionVO
		{
			var building:BuildingVO;
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				//only pay attention to transactions that are not instant
				if (transaction.timeMS > 0 || transaction.state == StarbaseTransactionStateEnum.PENDING)
				{
					switch (transaction.type)
					{
						case TransactionEvent.STARBASE_BUILDING_BUILD:
						case TransactionEvent.STARBASE_BUILDING_RECYCLE:
						case TransactionEvent.STARBASE_BUILDING_UPGRADE:
						case TransactionEvent.STARBASE_REFIT_BUILDING:
							building = _starbaseModel.getBuildingByID(transaction.id);
							if (building)
							{
								if (buildingID != null && buildingID == building.id)
									return transaction;
								if (constructionCategory && building.constructionCategory == constructionCategory)
									return transaction;
							}
					}
				}
			}
			return null;
		}

		public function getStarbaseResearchTransaction():TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_RESEARCH:
						return transaction;
				}
			}
			return null;
		}

		public function getBuffTransaction( id:String ):TransactionVO
		{
			var building:BuildingVO;
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				if (transaction.type == TransactionEvent.STARBASE_BUY_STORE_ITEM)
				{
					if (transaction.id == id)
						return transaction;
				}
			}
			return null;
		}

		public function getStarbaseResearchTransactionByBuildingType( buildingType:String ):TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			var research:ResearchVO;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_RESEARCH:
					{
						research = _starbaseModel.getResearchByID(transaction.id);
						if (research && buildingType == research.requiredBuildingClass)
							return transaction;
					}
				}
			}
			return null;
		}

		/**
		 * @return A transaction associated with the dock or null if none exists
		 */
		public function getDockTransaction():TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_REPAIR_FLEET:
						return transaction;
				}
			}
			return null;
		}

		/**
		 * @return A transaction associated with the shipyard or null if none exists
		 */
		public function getShipyardTransaction():TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_BUILD_SHIP:
					case TransactionEvent.STARBASE_RECYCLE_SHIP:
					case TransactionEvent.STARBASE_REFIT_SHIP:
						return transaction;
				}
			}
			return null;
		}

		public function isResearched( name:String, buildingType:String ):Boolean
		{
			var isResearched:Boolean              = _starbaseModel.isResearched(name);
			var researchTransaction:TransactionVO = getStarbaseResearchTransactionByBuildingType(buildingType);
			var research:ResearchVO;
			if (researchTransaction)
			{
				research = _starbaseModel.getResearchByID(researchTransaction.id);

				if (research && research.name == name)
					isResearched = false;
			}

			return isResearched;
		}

		/**
		 * @return A transaction associated with Trade Routes or null if none exists
		 */
		public function getTradeRouteTransaction( id:String ):TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				switch (transaction.type)
				{
					case TransactionEvent.STARBASE_NEGOTIATE_CONTRACT_REQUEST:
						if (id == transaction.id)
							return transaction;
				}
			}
			return null;
		}

		public function getBaseRepairTransaction():TransactionVO
		{
			var transactions:Dictionary = _transactionModel.transactions;
			for each (var transaction:TransactionVO in transactions)
			{
				if (transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
					return transaction;
			}
			return null;
		}

		//============================================================================================================
		//************************************************************************************************************
		//													COST CHECKS
		//************************************************************************************************************
		//============================================================================================================

		public function checkCost( prototype:IPrototype, transactionType:int = 0, check:Boolean = false, confirm:Boolean = false ):Boolean
		{
			_requirementVO.purchaseVO.reset();
			if (prototype)
			{
				calculatePremiumCost(prototype);
				var baseVO:BaseVO   = _starbaseModel.currentBase;
				var success:Boolean = true;
				_requirementVO.purchaseVO.alloyCost = StatCalcUtil.baseStatCalc("alloyCost", prototype.alloyCost);
				_requirementVO.purchaseVO.creditsCost = StatCalcUtil.baseStatCalc("creditsCost", prototype.creditsCost);
				_requirementVO.purchaseVO.energyCost = StatCalcUtil.baseStatCalc("energyCost", prototype.energyCost);
				_requirementVO.purchaseVO.syntheticCost = StatCalcUtil.baseStatCalc("syntheticCost", prototype.syntheticCost);

				//dont allow purchase if the player's max resources are less than the cost
				if (baseVO.maxResources < _requirementVO.purchaseVO.alloyCost ||
					baseVO.maxCredits < _requirementVO.purchaseVO.creditsCost ||
					baseVO.maxResources < _requirementVO.purchaseVO.energyCost ||
					baseVO.maxResources < _requirementVO.purchaseVO.syntheticCost)
				{
					_requirementVO.purchaseVO.costExceedsMaxResources = true;
					_requirementVO.purchaseVO.canPurchase = _requirementVO.purchaseVO.canPurchaseWithPremium = _requirementVO.purchaseVO.canPurchaseResourcesWithPremium = false;
				} else if (baseVO.alloy < _requirementVO.purchaseVO.alloyCost ||
					baseVO.credits < _requirementVO.purchaseVO.creditsCost ||
					baseVO.energy < _requirementVO.purchaseVO.energyCost ||
					baseVO.synthetic < _requirementVO.purchaseVO.syntheticCost)
				{
					_requirementVO.purchaseVO.canPurchase = false;
				}

				if ((_requirementVO.purchaseVO.canPurchase && transactionType == PurchaseTypeEnum.NORMAL) ||
					(_requirementVO.purchaseVO.canPurchaseWithPremium && (transactionType == PurchaseTypeEnum.INSTANT || transactionType == PurchaseTypeEnum.GET_RESOURCES)))
					success = true;
				else
					success = false;

				if (!check)
				{

					switch (transactionType)
					{
						case PurchaseTypeEnum.NORMAL:
							baseVO.withdraw(_requirementVO.purchaseVO.alloyCost, CurrencyEnum.ALLOY);
							baseVO.withdraw(_requirementVO.purchaseVO.creditsCost, CurrencyEnum.CREDIT);
							baseVO.withdraw(_requirementVO.purchaseVO.energyCost, CurrencyEnum.ENERGY);
							baseVO.withdraw(_requirementVO.purchaseVO.syntheticCost, CurrencyEnum.SYNTHETIC);
							break;
						case PurchaseTypeEnum.GET_RESOURCES:
							CurrentUser.wallet.withdraw(_requirementVO.purchaseVO.resourcePremiumCost, CurrencyEnum.PREMIUM);
							baseVO.withdraw((_requirementVO.purchaseVO.alloyCost > baseVO.alloy) ? baseVO.alloy : _requirementVO.purchaseVO.alloyCost, CurrencyEnum.ALLOY);
							baseVO.withdraw((_requirementVO.purchaseVO.creditsCost > baseVO.credits) ? baseVO.credits : _requirementVO.purchaseVO.creditsCost, CurrencyEnum.CREDIT);
							baseVO.withdraw((_requirementVO.purchaseVO.energyCost > baseVO.energy) ? baseVO.energy : _requirementVO.purchaseVO.energyCost, CurrencyEnum.ENERGY);
							baseVO.withdraw((_requirementVO.purchaseVO.syntheticCost > baseVO.synthetic) ? baseVO.synthetic : _requirementVO.purchaseVO.syntheticCost, CurrencyEnum.SYNTHETIC);
							break;
						case PurchaseTypeEnum.INSTANT:
							CurrentUser.wallet.withdraw(_requirementVO.purchaseVO.premium, CurrencyEnum.PREMIUM);
							break;
					}
					baseVO.updateResources();
				}
			}
			return true;
		}

		public function refund( prototype:IPrototype, instant:Boolean = false ):void
		{
			var baseVO:BaseVO = _starbaseModel.currentBase;
			if (instant)
			{
				calculatePremiumCost(prototype);
				CurrentUser.wallet.deposit(_requirementVO.purchaseVO.premium, CurrencyEnum.PREMIUM);
			} else
			{
				//withdraw the currency amounts from the wallet
				baseVO.deposit(StatCalcUtil.baseStatCalc("alloyCost", prototype.alloyCost), CurrencyEnum.ALLOY);
				baseVO.deposit(StatCalcUtil.baseStatCalc("creditsCost", prototype.creditsCost), CurrencyEnum.CREDIT);
				baseVO.deposit(StatCalcUtil.baseStatCalc("energyCost", prototype.energyCost), CurrencyEnum.ENERGY);
				baseVO.deposit(StatCalcUtil.baseStatCalc("syntheticCost", prototype.syntheticCost), CurrencyEnum.SYNTHETIC);
			}
		}

		public function calculatePremiumCost( purchaseable:IPrototype ):int
		{
			var baseVO:BaseVO        = _starbaseModel.currentBase;
			var currentAlloy:int     = baseVO.alloy;
			var currentCredits:int   = baseVO.credits;
			var currentEnergy:int    = baseVO.energy;
			var currentSynthetic:int = baseVO.synthetic;

			_requirementVO.purchaseVO.alloyAmountShort = (purchaseable.alloyCost > currentAlloy) ? purchaseable.alloyCost - currentAlloy : 0;
			_requirementVO.purchaseVO.creditsAmountShort = (purchaseable.creditsCost > currentCredits) ? purchaseable.creditsCost - currentCredits : 0;
			_requirementVO.purchaseVO.energyAmountShort = (purchaseable.energyCost > currentEnergy) ? purchaseable.energyCost - currentEnergy : 0;
			_requirementVO.purchaseVO.syntheticAmountShort = (purchaseable.syntheticCost > currentSynthetic) ? purchaseable.syntheticCost - currentSynthetic : 0;
			_requirementVO.purchaseVO.premium = StatCalcUtil.baseStatCalc("hardCurrencyCost", getHardCurrencyCostFromSeconds(purchaseable.buildTimeSeconds));

			// if the player can't afford to buy this with their resources, figure out how much cash they have to spend
			// to increase their resources to exactly meet their needs
			var resourcePremium:int;
			if (_requirementVO.purchaseVO.alloyAmountShort > 0 && _requirementVO.purchaseVO.premium > 0)
			{
				resourcePremium = getHardCurrencyCostFromResource(_requirementVO.purchaseVO.alloyAmountShort, CurrencyEnum.ALLOY);
				_requirementVO.purchaseVO.premium += resourcePremium;
				_requirementVO.purchaseVO.resourcePremiumCost += resourcePremium;
			}
			if (_requirementVO.purchaseVO.creditsAmountShort > 0 && _requirementVO.purchaseVO.premium > 0)
			{
				resourcePremium = getHardCurrencyCostFromResource(_requirementVO.purchaseVO.creditsAmountShort, CurrencyEnum.CREDIT);
				_requirementVO.purchaseVO.premium += resourcePremium;
				_requirementVO.purchaseVO.resourcePremiumCost += resourcePremium;
			}
			if (_requirementVO.purchaseVO.energyAmountShort > 0 && _requirementVO.purchaseVO.premium > 0)
			{
				resourcePremium = getHardCurrencyCostFromResource(_requirementVO.purchaseVO.energyAmountShort, CurrencyEnum.ENERGY);
				_requirementVO.purchaseVO.premium += resourcePremium;
				_requirementVO.purchaseVO.resourcePremiumCost += resourcePremium;
			}
			if (_requirementVO.purchaseVO.syntheticAmountShort > 0 && _requirementVO.purchaseVO.premium > 0)
			{
				resourcePremium = getHardCurrencyCostFromResource(_requirementVO.purchaseVO.syntheticAmountShort, CurrencyEnum.SYNTHETIC);
				_requirementVO.purchaseVO.premium += resourcePremium;
				_requirementVO.purchaseVO.resourcePremiumCost += resourcePremium;
			}

			var currentPremium:int   = CurrentUser.wallet.premium;
			if (_requirementVO.purchaseVO.premium > currentPremium)
				_requirementVO.purchaseVO.canPurchaseWithPremium = false;

			if (_requirementVO.purchaseVO.resourcePremiumCost > currentPremium)
				_requirementVO.purchaseVO.canPurchaseResourcesWithPremium = false;

			return _requirementVO.purchaseVO.premium;
		}

		public function getHardCurrencyCostFromSeconds( buildTimeSeconds:Number ):int
		{
			var buildTimeMinutes:Number = buildTimeSeconds / 60.0;
			var cost:int                = 0;
			var timeBaseCostPerHour:int = 2;
			if (buildTimeMinutes <= 30)
				cost = Math.ceil(timeBaseCostPerHour * 0.50);
			else if (buildTimeMinutes <= 60)
				cost = Math.ceil(timeBaseCostPerHour * 1.00);
			else
				cost = Math.ceil(timeBaseCostPerHour * (buildTimeMinutes / 60));

			return cost == 0 ? 1 : cost;
		}

		public function getHardCurrencyCostFromResource( resources:int, type:String ):int
		{
			if (resources <= 0)
				return 0;

			var baseVO:BaseVO                = _starbaseModel.currentBase;
			var totalResourceCost:int        = 0;
			var baseResourceCost:Number      = 0;
			var resourceIncomePerHour:Number = baseVO.baseResourceIncome;
			var creditIncomePerHour:Number   = baseVO.baseCreditIncome;
			var resourceBuyScale:Number      = baseVO.baseResourcePurchaseScale;
			var creditBuyScale:Number        = baseVO.baseCreditPurchaseScale;
			var scale:Number                 = 0;

			if (type == CurrencyEnum.ALLOY || type == CurrencyEnum.ENERGY || type == CurrencyEnum.SYNTHETIC)
			{
				baseResourceCost = resourceIncomePerHour / 2;
				scale = resourceBuyScale;
			} else if (type == CurrencyEnum.CREDIT)
			{
				baseResourceCost = creditIncomePerHour / 2;
				scale = creditBuyScale;
			}

			totalResourceCost = Math.ceil(scale * resources / baseResourceCost);

			totalResourceCost = StatCalcUtil.baseStatCalc("hardCurrencyCost", totalResourceCost);

			return totalResourceCost;
		}

		public function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number
		{
			// Get base cost of the blueprint part by rarity
			var baseCost:Number;
			var rarity:String       = blueprint.getUnsafeValue('rarity');

			switch (rarity)
			{
				case 'Uncommon':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostUncommon');
					break;
				case 'Rare':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostRare');
					break;
				case 'Epic':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostEpic');
					break;
				case 'Legendary':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostLegendary');
					break;
				case 'Advanced1':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostAdvanced1');
					break;
				case 'Advanced2':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostAdvanced2');
					break;
				case 'Advanced3':
					baseCost = _prototypeModel.getConstantPrototypeValueByName('blueprintPartsCostAdvanced3');
					break;
			}

			// Get bulk discount applied for buying it all
			var bulkDiscount:Number = 0.0;
			if (partsPurchased == blueprint.partsRemaining)
				bulkDiscount = _prototypeModel.getConstantPrototypeValueByName('blueprintBulkDiscount');

			return Math.ceil(partsPurchased * (baseCost - bulkDiscount) * blueprint.costScale);
		}

		public function dataImported():void  { _transactionModel.dataImported(); }
		public function addListener( type:int, listener:Function ):void  { _transactionModel.addListener(type, listener); }
		public function removeListener( listener:Function ):void  { _transactionModel.removeListener(listener); }

		public function get transactions():Dictionary  { return _transactionModel.transactions; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set commandMap( v:IEventCommandMap ):void  { _commandMap = v; }
		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set requirementFactory( v:IRequirementFactory ):void  { _reqFactory = v; }
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionModel( v:TransactionModel ):void  { _transactionModel = v; }

		public function get shipyardPresenter():IShipyardPresenter  { return _shipyardPresenter; }
		public function set shipyardPresenter( value:IShipyardPresenter ):void  { _shipyardPresenter = value; }
	}
}


