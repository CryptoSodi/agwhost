package com.presenter.starbase
{
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.event.StarbaseEvent;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.alliance.AllianceModel;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.GamePresenter;

	import org.ash.core.Entity;
	import org.osflash.signals.Signal;
	import org.parade.core.ViewController;

	public class StarbasePresenter extends GamePresenter implements IStarbasePresenter
	{
		private var _instant:Boolean;
		private var _onBaseInteraction:Signal;
		private var _showedBuildings:Boolean;
		private var _starbaseFactory:IStarbaseFactory;
		private var _starbaseModel:StarbaseModel;
		private var _blueprintModel:BlueprintModel;
		private var _starbaseSystem:StarbaseSystem;
		private var _system:StarbaseInteractSystem;
		private var _transactionController:TransactionController;
		private var _viewController:ViewController;
		private var _allianceModel:AllianceModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_instant = false;
			_onBaseInteraction = new Signal(int, int, Entity);
			_showedBuildings = false;
			_starbaseSystem = StarbaseSystem(_game.getSystem(StarbaseSystem));
			_system = StarbaseInteractSystem(_game.getSystem(StarbaseInteractSystem));
			_system.presenter = this;
		}

		public function cancelTransaction( transaction:TransactionVO ):void  { _transactionController.transactionCancel(transaction.id); }
		public function moveEntity():void  { _system.setState(StarbaseInteractSystem.MOVE_STATE); }
		public function onInteractionWithBaseEntity( x:int, y:int, baseEntity:Entity ):void
		{
			_onBaseInteraction.dispatch(x, y, baseEntity);
		}

		public function performTransaction( transactionType:String, prototype:IPrototype, purchaseType:uint, ... args ):void
		{
			var buildingVO:BuildingVO;
			switch (transactionType)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					StarbaseInteractSystem(_game.getSystem(StarbaseInteractSystem)).buildFromPrototype(prototype, purchaseType);
					break;

				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					buildingVO = BuildingVO(prototype);
					var upgradeVO:IPrototype = _prototypeModel.getBuildingPrototype(buildingVO.getValue('upgrade'));
					if (_transactionController.starbaseUpgradeBuilding(buildingVO, upgradeVO, purchaseType))
					{
						//if the upgrade is instant then we want to update the prototype
						if (purchaseType == PurchaseTypeEnum.INSTANT)
						{
							buildingVO.prototype = upgradeVO;
						}
					}
					break;

				case TransactionEvent.STARBASE_BUILDING_RECYCLE:
					//remove the building from the game
					buildingVO = BuildingVO(prototype);
					_starbaseModel.removeBuildingByID(buildingVO.id);

					//deposit the recycle profits into the player's base
					var baseVO:BaseVO = _starbaseModel.currentBase;
					baseVO.deposit(Math.floor(buildingVO.alloyCost * 0.20), CurrencyEnum.ALLOY);
					baseVO.deposit(Math.floor(buildingVO.creditsCost * 0.20), CurrencyEnum.CREDIT);
					baseVO.deposit(Math.floor(buildingVO.energyCost * 0.20), CurrencyEnum.ENERGY);
					baseVO.deposit(Math.floor(buildingVO.syntheticCost * 0.20), CurrencyEnum.SYNTHETIC);

					if (buildingVO.itemClass == TypeEnum.PYLON)
						_starbaseSystem.findPylonConnections(_game.getEntity(buildingVO.id), true);

					//send to the server
					_transactionController.starbaseRecycleBuilding(buildingVO);
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(buildingVO.id));
					break;

				case TransactionEvent.STARBASE_REFIT_BUILDING:
					buildingVO = BuildingVO(prototype);
					_transactionController.starbaseRefitBuilding(buildingVO, args[0], purchaseType);
					if (purchaseType == PurchaseTypeEnum.INSTANT)
					{
						buildingVO.modules = args[0];
							//update the turret graphic
						/*if (buildingVO.asset == TypeEnum.POINT_DEFENSE_PLATFORM || buildingVO.asset == TypeEnum.SHIELD_GENERATOR)
						   {
						   _starbaseFactory.updateStarbaseBuilding(_game.getEntity(buildingVO.id));
						   }*/
					} else
						buildingVO.refitModules = args[0];
					break;

				case TransactionEvent.STARBASE_RESEARCH:
					_transactionController.starbaseStartResearch(prototype, purchaseType);
					break;

				case TransactionEvent.STARBASE_REPAIR_BASE:
					_transactionController.starbaseRepairBuildings(getRepairCost(), purchaseType);
					break;

				default:
					throw new Error("Unable to perform transaction of type " + transactionType);
					break;
			}
		}

		public function getFilterAssetVO( prototype:IPrototype ):AssetVO  { return _assetModel.getEntityData(prototype.getValue('filterCategory')); }
		public function getBuildingUpgrade( buildingVO:BuildingVO ):IPrototype  { return _prototypeModel.getBuildingPrototype(buildingVO.getValue('upgrade')); }
		public function getBuildingVO( id:String ):BuildingVO  { return _starbaseModel.getBuildingByID(id); }
		public function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO  { return _starbaseModel.getBuildingByClass(itemClass, highestLevel); }
		public function getEntityName( assetName:String ):String  { return _assetModel.getEntityData(assetName).visibleName; }

		public function getPrototypeByName( proto:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getBuildingPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getResearchPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getShipPrototype(proto);
			if (!iproto)
				iproto = _prototypeModel.getStoreItemPrototypeByName(proto);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(proto);
			return iproto;
		}

		public function getBlueprintByName( prototype:String ):BlueprintVO
		{
			return _blueprintModel.getBlueprintByName(prototype);
		}

		public function getRequirements( transactionType:String, prototype:IPrototype ):RequirementVO
		{
			switch (transactionType)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					return _transactionController.canBuild(prototype);
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					return _transactionController.canUpgrade(BuildingVO(prototype));
				case TransactionEvent.STARBASE_BLUEPRINT_PURCHASE:
				case TransactionEvent.STARBASE_RESEARCH:
					return _transactionController.canPurchaseResearch(prototype);
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					return _transactionController.canRefit(prototype);

			}
			throw new Error("Unable to find requirements of transaction type " + transactionType);
			return null;
		}

		public function getRepairCost():int
		{
			return _transactionController.getHardCurrencyCostFromSeconds(getRepairTime(true));
		}

		/**
		 * @param getTotal If true calculates the total time of all buildings otherwise calculates the longest of one building
		 * @return The total time to repair a base or the longest amount of time to repair one building
		 */
		public function getRepairTime( getTotal:Boolean = false ):int
		{
			var building:BuildingVO;
			var localTime:int = 0;
			var time:int      = 0;
			for (var i:int = 0; i < _starbaseModel.buildings.length; i++)
			{
				building = _starbaseModel.buildings[i];
				if (building.currentHealth == 1)
					continue;
				localTime = building.prototype.getValue("repairTimeSeconds");
				for each (var proto:IPrototype in building.modules)
				{
					if (!proto)
						continue;
					localTime += proto.getValue("repairTimeSeconds");
				}
				if (getTotal)
					time += localTime * (1 - building.currentHealth);
				else
				{
					localTime = localTime * (1 - building.currentHealth);
					if (localTime > time)
						time = localTime;
				}
			}
			return time;
		}

		public function getSlotType( key:String ):String  { return _prototypeModel.getSlotPrototype(key).getValue('slotType'); }
		public function getStarbaseBuildingTransaction( constructionCategory:String = null, buildingID:String = null ):TransactionVO  { return _transactionController.getStarbaseBuildingTransaction(constructionCategory, buildingID); }
		public function getStarbaseResearchTransaction( buildingType:String ):TransactionVO  { return _transactionController.getStarbaseResearchTransactionByBuildingType(buildingType); }
		public function loadIcon( url:String, callback:Function ):void  { _assetModel.getFromCache("assets/" + url, callback); }

		public function showBuildings():void
		{
			if (!_showedBuildings)
			{
				StarbaseSystem(_game.getSystem(StarbaseSystem)).createBuildingsFromStarbase();
				_showedBuildings = true;
			}
		}

		public function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number
		{
			return _transactionController.getBlueprintHardCurrencyCost(blueprint, partsPurchased);
		}

		public function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void
		{
			_transactionController.buyBlueprintTransaction(blueprint, partsPurchased);
		}
		public function completeBlueprintResearch( blueprint:BlueprintVO):void  
		{ 
			_transactionController.completeBlueprintResearchTransaction(blueprint); 
		}

		public function addBaseInteractionListener( callback:Function ):void  { _onBaseInteraction.add(callback); }

		public function addTransactionListener( listener:Function ):void  { _transactionController.addListener(TransactionSignal.TRANSACTION, listener); }
		public function removeTransactionListener( listener:Function ):void  { _transactionController.removeListener(listener); }

		public function addOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.add(callback); }
		public function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.remove(callback); }

		public function getConstantPrototypeValueByName( name:String ):Number
		{
			var proto:IPrototype = _prototypeModel.getConstantPrototypeByName(name);
			return proto.getValue('value');
		}

		public function getStatPrototypeByName( name:String ):IPrototype
		{
			var proto:IPrototype = _prototypeModel.getStatPrototypeByName(name);
			return proto;
		}

		override public function confirmReady():void
		{
			super.confirmReady();
			dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));
		}

		public function get buildingPrototypes():Vector.<IPrototype>  { return _prototypeModel.getBuildableBuildingPrototypes(); }
		public function get currentBase():BaseVO  { return _starbaseModel.currentBase; }
		public function get researchPrototypes():Vector.<IPrototype>  { return _prototypeModel.getResearchPrototypes(); }

		public function get totalDamagedBuildings():int
		{
			var damaged:int                   = 0;
			var buildings:Vector.<BuildingVO> = _starbaseModel.buildings;
			if (buildings)
			{
				for (var i:int = 0; i < buildings.length; i++)
				{
					if (buildings[i].currentHealth < 1 && buildings[i].currentHealth > 0)
						damaged++;
				}
			}
			return damaged;
		}

		public function get totalDestroyedBuildings():int
		{
			var destroyed:int                 = 0;
			var buildings:Vector.<BuildingVO> = _starbaseModel.buildings;
			if (buildings)
			{
				for (var i:int = 0; i < buildings.length; i++)
				{
					if (buildings[i].currentHealth == 0)
						destroyed++;
				}
			}
			return destroyed;
		}

		public function get totalBaseDamage():Number
		{
			var health:Number                 = 0;
			var buildings:Vector.<BuildingVO> = _starbaseModel.buildings;
			var maxHealth:Number              = 0;
			if (buildings)
			{
				for (var i:int = 0; i < buildings.length; i++)
				{
					if (buildings[i].constructionCategory != StarbaseConstructionEnum.PLATFORM)
					{
						health += buildings[i].currentHealth * 100;
						maxHealth += 100;
					}
				}
			}
			return Math.round((1 - (health / maxHealth)) * 100);
		}

		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set allianceModel( v:AllianceModel ):void  { _allianceModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set viewController( v:ViewController ):void  { _viewController = v; }

		override public function destroy():void
		{
			super.destroy();
			_onBaseInteraction.removeAll();
			_onBaseInteraction = null;
			_starbaseFactory = null;
			_starbaseModel = null;
			_blueprintModel = null;
			_system = null;
			_transactionController = null;
			_viewController = null;
		}
	}
}
