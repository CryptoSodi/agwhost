package com.presenter.starbase
{
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.RequirementVO;
	import com.enum.CurrencyEnum;
	import com.enum.TypeEnum;
	import com.enum.server.PurchaseTypeEnum;
	import com.event.TransactionEvent;
	import com.event.signal.TransactionSignal;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionVO;
	import com.presenter.ImperiumPresenter;

	import flash.utils.Dictionary;

	import org.ash.core.Game;
	import org.parade.core.IView;
	import org.parade.core.ViewController;

	public class ConstructionPresenter extends ImperiumPresenter implements IConstructionPresenter
	{
		private var _assetModel:AssetModel;
		private var _blueprintModel:BlueprintModel;
		private var _game:Game;
		private var _prototypeModel:PrototypeModel;
		private var _requirementsCache:Dictionary;
		private var _starbaseModel:StarbaseModel;
		private var _starbaseFactory:IStarbaseFactory;
		private var _transactionController:TransactionController;
		private var _viewController:ViewController;
		private var _working:Vector.<IPrototype>;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_working = new Vector.<IPrototype>;
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
					{
						var starbaseSystem:StarbaseSystem = StarbaseSystem(_game.getSystem(StarbaseSystem));
						starbaseSystem.findPylonConnections(_game.getEntity(buildingVO.id), true);
					}

					//send to the server
					_transactionController.starbaseRecycleBuilding(buildingVO);
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(buildingVO.id));
					break;

				case TransactionEvent.STARBASE_RESEARCH:
					_transactionController.starbaseStartResearch(prototype, purchaseType);
					break;

				default:
					throw new Error("Unable to perform transaction of type " + transactionType);
					break;
			}
		}

		public function getComponents( groupID:String, subItemID:String, slotID:String, showHighest:Boolean, showAdvancedOnly:Boolean, showCommonOnly:Boolean, showUncommonOnly:Boolean, showRareOnly:Boolean, showEpicOnly:Boolean, showLegendaryOnly:Boolean ):Vector.<IPrototype>
		{
			_working.length = 0;
			_requirementsCache = new Dictionary(true);
			var blueprint:BlueprintVO;
			var module:IPrototype;
			var modules:Vector.<IPrototype> = _prototypeModel.getModulesBySlotType(groupID);
			for (var i:int = 0; i < modules.length; i++)
			{
				module = modules[i];
				blueprint = _blueprintModel.getBlueprintByName(module.name);
				if (module.getValue("filterCategory") == subItemID || (subItemID == "Blueprint" && module.getUnsafeValue('rarity') != "Common"))
				{
					if (canEquip(module, slotID).allMet)
					{
						if (showHighest)
						{
							if (_requirementsCache[module.itemClass] == null || _requirementsCache[module.itemClass].getValue("level") < module.getValue("level"))
							{
								if (_requirementsCache[module.itemClass] != null)
									_working.splice(_working.indexOf(_requirementsCache[module.itemClass]), 1);
								_requirementsCache[module.itemClass] = module;
								_working.push(module);
							}
						}
						else if(showAdvancedOnly)
						{
							if(module.getUnsafeValue('rarity') == "Advanced1" || module.getUnsafeValue('rarity') == "Advanced2" || module.getUnsafeValue('rarity') == "Advanced3")
							{
								_working.push(module);
							}
						} 
						else if(showCommonOnly)
						{
							if(module.getUnsafeValue('rarity') == "Common")
							{
								_working.push(module);
							}
						} 
						else if(showUncommonOnly)
						{
							if(module.getUnsafeValue('rarity') == "Uncommon")
							{
								_working.push(module);
							}
						} 
						else if(showRareOnly)
						{
							if(module.getUnsafeValue('rarity') == "Rare")
							{
								_working.push(module);
							}
						} 					
						else if(showEpicOnly)
						{
							if(module.getUnsafeValue('rarity') == "Epic")
							{
								_working.push(module);
							}
						} 
						else if(showLegendaryOnly)
						{
							if(module.getUnsafeValue('rarity') == "Legendary")
							{
								_working.push(module);
							}
						} 
						else
							_working.push(module);
					}
				}
			}

			if (_working.length > 0)
				_working.sort(orderComponents);
			return _working;
		}

		public function canEquip( prototype:IPrototype, slotType:String ):RequirementVO  { return _transactionController.canEquip(prototype, slotType); }

		protected function orderComponents( itemOne:IPrototype, itemTwo:IPrototype ):Number
		{
			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			if (itemOne.getValue("sort") < itemTwo.getValue("sort"))
				return -1;
			else
				return 1;
		}

		public function getResearchPrototypes( groupID:String, subItemID:String ):Vector.<IPrototype>
		{
			_working.length = 0;
			_requirementsCache = new Dictionary(true);
			/*var t:Number                     = getTimer();
			   trace('---------------------------------------------------');*/
			var research:Vector.<IPrototype> = _prototypeModel.getResearchPrototypesByBuilding(subItemID == "Blueprint" ? groupID : groupID + subItemID);
			if (research)
			{
				var blueprint:BlueprintVO;
				var factionMet:Boolean;
				var len:int = research.length;
				var prototype:IPrototype;
				var requirementMet:Boolean;
				for (var i:int = 0; i < len; i++)
				{
					prototype = research[i];
					// match research with blueprint by common key (uiAsset)
					blueprint = _blueprintModel.getBlueprintByUIName(prototype.getValue('uiAsset'));
					factionMet = (prototype.getValue('requiredFaction') == CurrentUser.faction || prototype.getValue('requiredFaction') == '');
					if (factionMet && (prototype.getValue("filterCategory") == subItemID || (subItemID == "Blueprint" && blueprint != null)))
					{
						if (blueprint)
							requirementMet = getRequirementsBoolean(TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, prototype);
						else
							requirementMet = getRequirementsBoolean(TransactionEvent.STARBASE_RESEARCH, prototype);
						if (requirementMet)
							_working.push(prototype);
						else if (!prototype.getValue('hideWhileLocked') || (blueprint && blueprint.partsCollected != 0 || blueprint && blueprint.complete))
							_working.push(prototype);
					}
				}
			}
			if (_working.length > 0)
				_working.sort(orderResearchItems);
			//trace(getTimer() - t);
			return _working;
		}

		public function getRequirementsBoolean( transactionType:String, prototype:IPrototype ):Boolean
		{
			if (_requirementsCache[prototype] != null)
				return _requirementsCache[prototype];

			var requirement:RequirementVO;
			switch (transactionType)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					requirement = _transactionController.canBuild(prototype);
					break;
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					requirement = _transactionController.canUpgrade(BuildingVO(prototype));
					break;
				case TransactionEvent.STARBASE_BLUEPRINT_PURCHASE:
				case TransactionEvent.STARBASE_RESEARCH:
					requirement = _transactionController.canPurchaseResearch(prototype);
					break;
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					requirement = _transactionController.canRefit(prototype);
					break;
			}
			_requirementsCache[prototype] = requirement.allMet;
			return requirement.allMet;
		}

		public function getRequirements( transactionType:String, prototype:IPrototype ):RequirementVO
		{
			var requirement:RequirementVO;
			switch (transactionType)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					requirement = _transactionController.canBuild(prototype);
					break;
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					requirement = _transactionController.canUpgrade(BuildingVO(prototype));
					break;
				case TransactionEvent.STARBASE_BLUEPRINT_PURCHASE:
				case TransactionEvent.STARBASE_RESEARCH:
					requirement = _transactionController.canPurchaseResearch(prototype);
					break;
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					requirement = _transactionController.canRefit(prototype);
					break;
			}
			return requirement;
		}

		private function orderResearchItems( itemOne:IPrototype, itemTwo:IPrototype ):Number
		{
			if (!itemOne)
				return -1;

			if (!itemTwo)
				return 1;

			var sortOne:Number           = itemOne.getValue("sort");
			var sortTwo:Number           = itemTwo.getValue("sort");

			var blueprintOne:BlueprintVO = _blueprintModel.getBlueprintByName(itemOne.name);
			var isResearchedOne:Boolean  = isResearched(itemOne.name);
			var isLockedOne:Boolean      = !((blueprintOne) ? getRequirementsBoolean(TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, itemOne) :
				getRequirementsBoolean(TransactionEvent.STARBASE_RESEARCH, itemOne));

			var blueprintTwo:BlueprintVO = _blueprintModel.getBlueprintByName(itemTwo.name);
			var isResearchedTwo:Boolean  = isResearched(itemTwo.name);
			var isLockedTwo:Boolean      = !((blueprintTwo) ? getRequirementsBoolean(TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, itemTwo) :
				getRequirementsBoolean(TransactionEvent.STARBASE_RESEARCH, itemTwo));

			if (blueprintOne && blueprintTwo)
			{
				if (!isResearchedOne && !isResearchedTwo)
				{
					if (sortOne < sortTwo)
						return -1;
					else if (sortOne > sortTwo)
						return 1;
				}
				if (isResearchedOne && !isResearchedTwo)
					return 1;
				else if (!isResearchedOne && isResearchedTwo)
					return -1;
			}

			if (blueprintOne && !isResearchedOne && (isResearchedTwo || isLockedTwo))
				return -1;
			if (blueprintTwo && !isResearchedTwo && (isResearchedOne || isLockedOne))
				return 1;

			if (!isLockedOne && isLockedTwo)
				return -1;
			else if (isLockedOne && !isLockedTwo)
				return 1;

			if ((isLockedOne && !isResearchedOne) && (isResearchedTwo && !isLockedTwo))
				return -1;
			else if ((!isLockedOne && isResearchedOne) && (!isResearchedTwo && isLockedTwo))
				return 1;

			if (sortOne < sortTwo)
				return -1;
			else if (sortOne > sortTwo)
				return 1;

			return 0;
		}

		public function requirementsMet( proto:IPrototype ):Boolean
		{
			var requirementMet:Boolean;
			var blueprint:BlueprintVO = _blueprintModel.getBlueprintByName(proto.name);

			if (blueprint)
				requirementMet = getRequirementsBoolean(TransactionEvent.STARBASE_BLUEPRINT_PURCHASE, proto);
			else
				requirementMet = getRequirementsBoolean(TransactionEvent.STARBASE_RESEARCH, proto);

			return requirementMet;
		}

		public function isResearched( tech:String ):Boolean
		{
			if (tech != '')
			{
				var requiredBuildingClass:String = _prototypeModel.getResearchPrototypeByName(tech).getValue('requiredBuildingClass');
				return _transactionController.isResearched(tech, requiredBuildingClass);
			} else
				return false;
		}

		public function loadImage( url:String, callback:Function ):void  { _assetModel.getFromCache("assets/" + url, callback); }

		public function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function getBlueprint( name:String ):BlueprintVO  { return _blueprintModel.getBlueprintByName(name); }

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

		public function getResearchItemPrototypeByName( v:String ):IPrototype
		{
			var iproto:IPrototype = _prototypeModel.getShipPrototype(v);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(v);
			return iproto;
		}

		public function getBuildingPrototypes( groupID:String, subItemID:String ):Vector.<IPrototype>
		{
			_working.length = 0;
			var items:Vector.<IPrototype> = _prototypeModel.getBuildableBuildingPrototypes();
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i].getValue("category") == groupID)
					_working.push(items[i]);
			}

			if (_working.length > 0)
				_working.sort(orderBuildings);
			return _working;
		}

		public function getFilterNameByKey( v:String ):String
		{
			var assetVO:AssetVO = _assetModel.getEntityData(v);
			if (assetVO)
				return assetVO.visibleName;

			return '';
		}

		public function getBuildingCount( buildingClass:String ):int  { return _starbaseModel.currentBase.getBuildingCount(buildingClass); }
		public function getBuildingMaxCount( buildingClass:String ):int  { return _starbaseModel.currentBase.getBuildingMaxCount(buildingClass); }
		public function getBuildingUpgrade( upgrade:String ):IPrototype  { return _prototypeModel.getBuildingPrototype(upgrade); }
		public function getBuildingVO( id:String ):BuildingVO  { return _starbaseModel.getBuildingByID(id); }
		public function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO  { return _starbaseModel.getBuildingByClass(itemClass, highestLevel); }
		public function getStarbaseBuildingTransaction( constructionCategory:String = null, buildingID:String = null ):TransactionVO  { return _transactionController.getStarbaseBuildingTransaction(constructionCategory, buildingID); }
		public function getStarbaseResearchTransaction( buildingType:String ):TransactionVO  { return _transactionController.getStarbaseResearchTransactionByBuildingType(buildingType); }

		private function orderBuildings( itemOne:IPrototype, itemTwo:IPrototype ):Number
		{
			var assetVO:AssetVO = AssetModel.instance.getEntityData(itemOne.asset);
			var nameOne:String  = assetVO.visibleName;

			assetVO = AssetModel.instance.getEntityData(itemTwo.asset);
			var nameTwo:String  = assetVO.visibleName;

			if (nameOne < nameTwo)
			{
				return -1;
			} else if (nameOne > nameTwo)
			{
				return 1;
			} else
			{
				return 0;
			}
		}

		public function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number  { return _transactionController.getBlueprintHardCurrencyCost(blueprint, partsPurchased); }
		public function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void  { _transactionController.buyBlueprintTransaction(blueprint, partsPurchased); }
		public function completeBlueprintResearch( blueprint:BlueprintVO):void  { _transactionController.completeBlueprintResearchTransaction(blueprint); }
		
		public function addOnTransactionRemovedListener( callback:Function ):void  { _transactionController.addListener(TransactionSignal.TRANSACTION_REMOVED, callback); }
		public function removeOnTransactionRemovedListener( callback:Function ):void  { _transactionController.removeListener(callback); }

		public function getView( view:Class ):IView  { return _viewController.getView(view); }
		
		public function mintNFT( tokenType:int, tokenAmount:int, tokenPrototype:String ):void
		{
			_transactionController.mintNFTTransaction(tokenType, tokenAmount, tokenPrototype);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set viewController( v:ViewController ):void  { _viewController = v; }

		override public function destroy():void
		{
			super.destroy();

			_assetModel = null;
			_blueprintModel = null;
			_game = null;
			_prototypeModel = null;
			_starbaseFactory = null;
			_starbaseModel = null;
			_transactionController = null;
			_viewController = null;
			_working.length = 0;
			_working = null;
		}
	}
}
