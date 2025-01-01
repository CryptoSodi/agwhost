package com.ui.modal.store
{
	import com.Application;
	import com.enum.server.RequestEnum;
	import com.event.TransactionEvent;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.transaction.TransactionVO;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;

	public class StoreTransactionPage extends StorePage
	{
		private var _enableTransactionLinking:Boolean;
		private var _selectedTransactionButton:StoreTransactionButton;
		private var _transactions:Dictionary;
		private var _freeTimer:Timer;

		private var _repairFleetBtn:StoreTransactionButton;
		private var _baseBtn:StoreTransactionButton;
		private var _defenseBtn:StoreTransactionButton;
		private var _shipBtn:StoreTransactionButton;
		private var _defensesResearchBtn:StoreTransactionButton;
		private var _hullsResearchBtn:StoreTransactionButton;
		private var _modulesResearchBtn:StoreTransactionButton;
		private var _technologyResearchBtn:StoreTransactionButton;
		private var _repairBtns:Vector.<StoreTransactionButton>;

		private var _transactionHolder:Sprite;

		private var _baseHeader:Bitmap;
		private var _defenseHeader:Bitmap;
		private var _shipHeader:Bitmap;
		private var _repairHeader:Bitmap;
		private var _researchHeader:Bitmap;

		private var _baseHeaderText:Label;
		private var _defenseHeaderText:Label;
		private var _shipHeaderText:Label;
		private var _repairHeaderText:Label;
		private var _researchHeaderText:Label;

		private var _transactionMask:Rectangle;
		private var _transactionScrollbar:VScrollbar;
		private var _transactionMaxHeight:Number;

		private var _transactionBG:BitmapData;
		private var _transactionBGRollOver:BitmapData;
		private var _transactionBGSelected:BitmapData;

		private var _instantText:String              = 'CodeString.Store.InstantBtn';
		private var _level:String                    = 'CodeString.Shared.Level'; //Level [[Number.Level]]
		private var _shipText:String                 = 'CodeString.Transaction.State.Ship'; //SHIP
		private var _baseText:String                 = 'CodeString.Transaction.State.Base'; //BASE
		private var _repairText:String               = 'CodeString.Transaction.State.Repair'; //REPAIR
		private var _defenseText:String              = 'CodeString.Transaction.State.Defense'; //DEFENSE
		private var _researchText:String             = 'CodeString.Transaction.State.Research'; //RESEARCH
		private var _repairStateText:String          = 'CodeString.Transaction.BtnText.Repair'; //Repair
		private var _noBuildText:String              = 'CodeString.Transaction.State.NoBuild'; //No Build
		private var _noDefenseText:String            = 'CodeString.Transaction.State.NoDefense'; //No Defense
		private var _noShipText:String               = 'CodeString.Transaction.State.NoShip'; //No Ship
		private var _noShipResearchText:String       = 'CodeString.Transaction.State.NoShipResearch'; //No Ship Research
		private var _noDefenseResearchText:String    = 'CodeString.Transaction.State.NoDefenseResearch'; //No Defense Research
		private var _noWeaponResearchText:String     = 'CodeString.Transaction.State.NoWeaponResearch'; //No Weapon Research
		private var _noTechnologyResearchText:String = 'CodeString.Transaction.State.TechnologyResearch'; //No Technology Research
		private var _noFleetRepairing:String         = 'CodeString.Transaction.State.FleetRepair'; //No Fleet Repairing

		public function StoreTransactionPage( speedUpItems:Vector.<IPrototype> )
		{
			super(speedUpItems);

			_repairBtns = new Vector.<StoreTransactionButton>;

			_transactionHolder = new Sprite();
			_transactionHolder.x = 28;
			_transactionHolder.y = 109;

			_freeTimer = new Timer(300000, 1);
			_freeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerFinished, false, 0, true);

			var transactionBG:Class         = Class(getDefinitionByName(('StoreListBtnUpBMD')));
			var transactionBGRollOver:Class = Class(getDefinitionByName(('StoreListBtnRollOverBMD')));
			var transactionBGSelected:Class = Class(getDefinitionByName(('StoreListBtnSelectedBMD')));
			var storeHeaderClass:Class      = Class(getDefinitionByName(('StoreHeaderBMD')));
			_transactionBG = BitmapData(new transactionBG());
			_transactionBGRollOver = BitmapData(new transactionBGRollOver());
			_transactionBGSelected = BitmapData(new transactionBGSelected());

			var headerBMD:BitmapData        = BitmapData(new storeHeaderClass());

			_repairHeader = new Bitmap(headerBMD);
			_transactionHolder.addChild(_repairHeader);

			_repairHeaderText = new Label(22, 0xf0f0f0, _repairHeader.width, 25);
			_repairHeaderText.align = TextFormatAlign.LEFT;
			_repairHeaderText.text = _repairText;
			_transactionHolder.addChild(_repairHeaderText);

			_repairFleetBtn = new StoreTransactionButton();
			_repairFleetBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_repairFleetBtn.windowID = WINDOW_DOCK_VIEW;
			_repairFleetBtn.onClicked.add(onTransactionClicked);
			_repairFleetBtn.emptyText = _noFleetRepairing;
			_transactionHolder.addChild(_repairFleetBtn);

			_baseHeader = new Bitmap(headerBMD);
			_transactionHolder.addChild(_baseHeader);

			_baseHeaderText = new Label(22, 0xf0f0f0, _baseHeader.width, 25);
			_baseHeaderText.align = TextFormatAlign.LEFT;
			_baseHeaderText.text = _baseText;
			_transactionHolder.addChild(_baseHeaderText);

			_baseBtn = new StoreTransactionButton();
			_baseBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_baseBtn.windowID = WINDOW_BUILDING_VIEW;
			_baseBtn.onClicked.add(onTransactionClicked);
			_baseBtn.emptyText = _noBuildText;
			_transactionHolder.addChild(_baseBtn);

			_defenseHeader = new Bitmap(headerBMD);
			_transactionHolder.addChild(_defenseHeader);

			_defenseHeaderText = new Label(22, 0xf0f0f0, _baseHeader.width, 25);
			_defenseHeaderText.align = TextFormatAlign.LEFT;
			_defenseHeaderText.text = _defenseText;
			_transactionHolder.addChild(_defenseHeaderText);

			_defenseBtn = new StoreTransactionButton();
			_defenseBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_defenseBtn.windowID = WINDOW_DEFENSE_VIEW;
			_defenseBtn.onClicked.add(onTransactionClicked);
			_defenseBtn.emptyText = _noDefenseText;
			_transactionHolder.addChild(_defenseBtn);

			_shipHeader = new Bitmap(headerBMD);
			_transactionHolder.addChild(_shipHeader);

			_shipHeaderText = new Label(22, 0xf0f0f0, _baseHeader.width, 25);
			_shipHeaderText.align = TextFormatAlign.LEFT;
			_shipHeaderText.text = _shipText;
			_transactionHolder.addChild(_shipHeaderText);

			_shipBtn = new StoreTransactionButton();
			_shipBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_shipBtn.windowID = WINDOW_SHIPYARD_VIEW;
			_shipBtn.onClicked.add(onTransactionClicked);
			_shipBtn.emptyText = _noShipText;
			_transactionHolder.addChild(_shipBtn);

			_researchHeader = new Bitmap(headerBMD);
			_transactionHolder.addChild(_researchHeader);

			_researchHeaderText = new Label(22, 0xf0f0f0, _baseHeader.width, 25);
			_researchHeaderText.align = TextFormatAlign.LEFT;
			_researchHeaderText.text = _researchText;
			_transactionHolder.addChild(_researchHeaderText);

			_defensesResearchBtn = new StoreTransactionButton();
			_defensesResearchBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_defensesResearchBtn.windowID = WINDOW_DEFENSE_RESEARCH_VIEW;
			_defensesResearchBtn.onClicked.add(onTransactionClicked);
			_defensesResearchBtn.emptyText = _noDefenseResearchText;
			_transactionHolder.addChild(_defensesResearchBtn);

			_hullsResearchBtn = new StoreTransactionButton();
			_hullsResearchBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_hullsResearchBtn.windowID = WINDOW_SHIP_RESEARCH_VIEW;
			_hullsResearchBtn.onClicked.add(onTransactionClicked);
			_hullsResearchBtn.emptyText = _noShipResearchText;
			_transactionHolder.addChild(_hullsResearchBtn);

			_modulesResearchBtn = new StoreTransactionButton();
			_modulesResearchBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_modulesResearchBtn.windowID = WINDOW_MODULES_RESEARCH_VIEW;
			_modulesResearchBtn.onClicked.add(onTransactionClicked);
			_modulesResearchBtn.emptyText = _noWeaponResearchText;
			_transactionHolder.addChild(_modulesResearchBtn);

			_technologyResearchBtn = new StoreTransactionButton();
			_technologyResearchBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			_technologyResearchBtn.windowID = WINDOW_TECHNOLOGY_RESEARCH_VIEW;
			_technologyResearchBtn.onClicked.add(onTransactionClicked);
			_technologyResearchBtn.emptyText = _noTechnologyResearchText;
			_transactionHolder.addChild(_technologyResearchBtn);

			addChild(_transactionHolder);
			_transactionMaxHeight = _transactionHolder.height;
			_transactionMask = new Rectangle(0, 0, _transactionHolder.width, 427);
			_transactionHolder.scrollRect = _transactionMask;

			_transactionScrollbar = new VScrollbar();
			addChild(_transactionScrollbar);
			var scrollbarXPos:Number        = 268;
			var scrollbarYPos:Number        = 109;
			var dragBarBGRect:Rectangle     = new Rectangle(0, 4, 5, 3);
			_transactionScrollbar.init(7, 427, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _transactionHolder);
			_transactionScrollbar.onScrollSignal.add(onChangedTransactionScroll);
			_transactionScrollbar.updateScrollableHeight(_transactionMaxHeight);
			_transactionScrollbar.updateDisplayedHeight(_transactionMask.height);
			_transactionScrollbar.maxScroll = 18.75;
		}

		override protected function onRemoved( e:Event ):void
		{
			if (_transactionScrollbar)
				_transactionScrollbar.enabled = false;

			super.onRemoved(e);
		}

		override protected function onAdded( e:Event ):void
		{
			if (_transactionScrollbar)
				_transactionScrollbar.enabled = true;

			super.onAdded(e);
		}

		private function onChangedTransactionScroll( percent:Number ):void
		{
			_transactionMask.y = (_transactionMaxHeight - _transactionMask.height) * percent;
			_transactionHolder.scrollRect = _transactionMask;
		}

		override public function setUpStoreItems():void
		{
			if (_items)
			{
				_init = true;
				var len:uint = _items.length;
				var storeItem:StoreItem;
				var currentPrototype:IPrototype;
				for (var i:uint = 0; i < len; ++i)
				{
					currentPrototype = _items[i];
					storeItem = new StoreItem();
					storeItem.setItemDetail(_presenter.getPrototypeUIName(currentPrototype));
					storeItem.setItemDetailSubtext(_presenter.getProtoTypeUIDescriptionText(currentPrototype));
					_presenter.loadIconFromPrototype(currentPrototype, storeItem.setItemIcon);
					storeItem.itemProto = currentPrototype;
					if (currentPrototype.getValue('hardCurrencyCost') == -1 || currentPrototype.getValue('hardCurrencyCost') == 0)
						storeItem.setBuyBtnText(_instantText);

					storeItem.subcategory = currentPrototype.getValue('subcategory');
					storeItem.onClicked.add(buy);
					_itemComponents.push(storeItem);
				}
				updateStoreItems();
				filterItems(null);
			}
		}

		override public function updateStoreItems( added:Boolean = false ):void
		{
			super.updateStoreItems();

			var timeRemaining:int = 0;
			var len:uint          = _itemComponents.length;
			var currentSpeedUpTime:int;
			var enabled:Boolean;
			var currentItem:StoreItem;
			var currentItemPrototype:IPrototype;
			var speedUpCost:int;
			var canAffordSpeedUp:Boolean;
			if (_selectedTransactionButton != null && _selectedTransactionButton.transaction != null)
				timeRemaining = _selectedTransactionButton.timeRemaining;

			for (var i:uint = 0; i < len; ++i)
			{
				currentItem = _itemComponents[i];
				currentItemPrototype = _items[i];
				if (currentItemPrototype.getValue('speedupTime') != null)
				{
					currentSpeedUpTime = currentItemPrototype.getValue('speedupTime');
					if (currentSpeedUpTime == -1)
					{
						speedUpCost = getHardCurrencyCost(timeRemaining / 1000);
						if (speedUpCost == 0)
							speedUpCost = 1;
					} else
					{
						speedUpCost = currentItemPrototype.getValue('hardCurrencyCost');
						currentSpeedUpTime *= 1000;
					}

					canAffordSpeedUp = canAfford(speedUpCost);
				}

				if (timeRemaining > 0)
				{
					if (currentSpeedUpTime == -1)
						enabled = true;
					else if ((currentSpeedUpTime == -1 || speedUpCost == 1) && timeRemaining > 300000)
						enabled = true;
					else if (currentSpeedUpTime > 300000 && currentSpeedUpTime <= timeRemaining)
						enabled = true;
					else if (speedUpCost == 0 && timeRemaining <= 300000)
						enabled = true;
				} else
					enabled = false;
				currentItem.enabled = enabled;
				currentItem.canAfford = canAffordSpeedUp;
				currentItem.setItemCost(speedUpCost);
				canAffordSpeedUp = enabled = false;
			}
		}

		public function addTransactions( transactions:Dictionary ):void
		{
			if (transactions)
			{
				_transactions = transactions;
				var proto:IPrototype;
				for each (var transaction:TransactionVO in _transactions)
				{
					if (transaction)
					{
						var transactionBtn:StoreTransactionButton;
						switch (transaction.type)
						{
							case TransactionEvent.STARBASE_BUILD_SHIP:
							case TransactionEvent.STARBASE_REFIT_SHIP:
								transactionBtn = _shipBtn;
								setUpShipyardBtn(transaction);
								break;
							case TransactionEvent.STARBASE_RESEARCH:
								var research:ResearchVO = _presenter.getResearchByID(transaction.id);
								if (research)
								{
									proto = research.prototype;
									if (proto)
									{
										switch (proto.getValue('requiredBuildingClass'))
										{
											case 'ShipDesignFacility':
												transactionBtn = _hullsResearchBtn;
												break;
											case 'WeaponsDesignFacility':
												transactionBtn = _modulesResearchBtn;
												break;
											case 'AdvancedTechFacility':
												transactionBtn = _technologyResearchBtn;
												break;
											case 'DefenseDesignFacility':
												transactionBtn = _defensesResearchBtn;
												break;
										}
										setUpResearchBtn(transactionBtn, transaction);
									}
								}
								break;
							case TransactionEvent.STARBASE_BUILDING_BUILD:
							case TransactionEvent.STARBASE_BUILDING_UPGRADE:
								var building:BuildingVO = _presenter.getBuildingByID(transaction.id);
								if (building)
								{
									proto = building.prototype;
									if (proto)
									{
										var category:String = proto.getValue('constructionCategory');
										if (category == 'Base')
										{
											setUpBuildBtnBuilding(transaction);
											transactionBtn = _baseBtn;
										} else
										{
											setUpDefenseBtn(transaction);
											transactionBtn = _defenseBtn;
										}
									}
								}
								break;
							case TransactionEvent.STARBASE_REFIT_BUILDING:
								setUpDefenseBtn(transaction);
								transactionBtn = _defenseBtn;
								break;
							case TransactionEvent.STARBASE_REPAIR_FLEET:
								setUpRepairFleetBtn(transaction)
								transactionBtn = _repairFleetBtn;
								break;
							case TransactionEvent.STARBASE_REPAIR_BASE:
								transactionBtn = createRepairBtn(transaction);
								break;
						}


						if (transactionBtn)
						{
							transactionBtn.transaction = transaction;
							transactionBtn.token = transaction.token;
							transactionBtn.enabled = true;
							if (_selectedTransactionButton == null)
								onTransactionClicked(transactionBtn);

							transactionBtn = null;
						}
					}
				}

				layoutTransactionBtns();
				updateStoreItems();
			}
		}

		private function createRepairBtn( transaction:TransactionVO ):StoreTransactionButton
		{
			var proto:IPrototype;

			var repairBtn:StoreTransactionButton = new StoreTransactionButton();
			repairBtn.init(_transactionBG, _transactionBGRollOver, null, null, _transactionBGSelected);
			repairBtn.onClicked.add(onTransactionClicked);

			var bottomText:String;
			if (transaction.id.indexOf('fleet') != -1)
			{
				var fleet:FleetVO = _presenter.getFleetById(transaction.id);
				bottomText = fleet.name;
			} else
			{
				var building:BuildingVO = _presenter.getBuildingByID(transaction.id);
				if (building)
				{
					proto = building.prototype;
					bottomText = presenter.getPrototypeUIName(proto);
				}
			}

			repairBtn.topTransactionText.text = _repairStateText;
			repairBtn.bottomTransactionText.text = bottomText;
			_repairBtns.push(repairBtn);
			_transactionHolder.addChild(repairBtn);

			return repairBtn;
		}

		private function setUpShipyardBtn( transaction:TransactionVO ):void
		{
			var ship:ShipVO = _presenter.getShipById(transaction.id);
			if(ship == null)
				return;
			
			var proto:IPrototype;
			proto = ship.prototypeVO;
			
			if(proto == null)
				return;
			
			_shipBtn.topTransactionText.text = StringUtil.getLocalizedResearch(proto.getValue('itemClass'));
			_shipBtn.bottomTransactionText.text = _presenter.getPrototypeUIName(proto);
		}

		private function setUpResearchBtn( btn:StoreTransactionButton, transaction:TransactionVO ):void
		{
			var research:ResearchVO = _presenter.getResearchByID(transaction.id);
			var proto:IPrototype;
			proto = research.prototype;
			btn.topTransactionText.text = StringUtil.getLocalizedResearch(proto.getValue('itemClass'));
			btn.bottomTransactionText.text = _presenter.getPrototypeUIName(proto);
		}

		private function setUpBuildBtnBuilding( transaction:TransactionVO ):void
		{
			var building:BuildingVO = _presenter.getBuildingByID(transaction.id);
			var proto:IPrototype;
			proto = building.prototype;
			_baseBtn.topTransactionText.setTextWithTokens(_level, {'[[Number.Level]]':proto.getValue('level')});
			_baseBtn.bottomTransactionText.text = _presenter.getPrototypeUIName(proto);
		}

		private function setUpBuildBtnUpgrade( transaction:TransactionVO ):void
		{
			var building:BuildingVO = _presenter.getBuildingByID(transaction.id);
			var proto:IPrototype;
			proto = building.prototype;
			_baseBtn.topTransactionText.setTextWithTokens(_level, {'[[Number.Level]]':(int(proto.getValue('level') + 1))});
			_baseBtn.bottomTransactionText.text = _presenter.getPrototypeUIName(proto);
		}

		private function setUpDefenseBtn( transaction:TransactionVO ):void
		{
			var defense:BuildingVO = _presenter.getBuildingByID(transaction.id);
			var proto:IPrototype;
			defense.refitModules;
			proto = defense.prototype;
			var refitProto:PrototypeVO;
			for each (var refit:PrototypeVO in defense.refitModules)
			{
				refitProto = refit;
			}

			if (refit)
			{
				_defenseBtn.topTransactionText.text = _presenter.getPrototypeUIName(proto);
				_defenseBtn.bottomTransactionText.text = _presenter.getPrototypeUIName(refitProto);
			} else
			{
				proto = defense.prototype;
				_defenseBtn.topTransactionText.setTextWithTokens(_level, {'[[Number.Level]]':proto.getValue('level')});
				_defenseBtn.bottomTransactionText.text = _presenter.getPrototypeUIName(proto);
			}

		}

		private function setUpRepairFleetBtn( transaction:TransactionVO ):void
		{
			var fleet:FleetVO = _presenter.getFleetById(transaction.id);
			if(fleet == null)
				return;
			
			_repairFleetBtn.topTransactionText.text = _repairStateText;
			_repairFleetBtn.bottomTransactionText.text = fleet.name;
		}

		public function onTransactionUpdated( transaction:TransactionVO ):void
		{
			var transactionBtn:StoreTransactionButton = getTransactionBtn(transaction);
			if (transactionBtn != null)
			{
				transactionBtn.update(transaction);
				updateTimer();
				updateStoreItems();
			}
		}

		public function onTransactionRemoved( transaction:TransactionVO ):void
		{
			var transactionBtn:StoreTransactionButton = getTransactionBtn(transaction);
			if (transactionBtn != null)
			{
				_selectedTransactionButton = null;
				updateTimer();

				transactionBtn.selected = false;
				transactionBtn.transaction = null;

				if (transactionBtn != _repairFleetBtn)
					transactionBtn.enabled = _enableTransactionLinking;
				else
					transactionBtn.enabled = true;

				if (transaction.messageID == RequestEnum.STARBASE_REPAIR_BASE)
				{
					var index:int = _repairBtns.indexOf(transactionBtn);
					if (index != -1)
					{
						_transactionHolder.removeChild(transactionBtn);
						transactionBtn.destroy();
						transactionBtn = null;
						_repairBtns.splice(index, 1);
						layoutTransactionBtns();
					}
				}
				selectNextRunningTransaction();
			}
		}

		private function selectNextRunningTransaction():void
		{
			var selectTransactionBtn:StoreTransactionButton;

			if (_repairFleetBtn != null && _repairFleetBtn.transaction != null)
				selectTransactionBtn = _repairFleetBtn;

			if (selectTransactionBtn == null && _repairBtns != null && _repairBtns.length > 0)
				selectTransactionBtn = _repairBtns[0];

			if (selectTransactionBtn == null && _baseBtn != null && _baseBtn.transaction != null)
				selectTransactionBtn = _baseBtn;

			if (selectTransactionBtn == null && _defenseBtn != null && _defenseBtn.transaction != null)
				selectTransactionBtn = _defenseBtn;

			if (selectTransactionBtn == null && _shipBtn != null && _shipBtn.transaction != null)
				selectTransactionBtn = _shipBtn;

			if (selectTransactionBtn == null && _defensesResearchBtn != null && _defensesResearchBtn.transaction != null)
				selectTransactionBtn = _defensesResearchBtn;

			if (selectTransactionBtn == null && _hullsResearchBtn != null && _hullsResearchBtn.transaction != null)
				selectTransactionBtn = _hullsResearchBtn;

			if (selectTransactionBtn == null && _modulesResearchBtn != null && _modulesResearchBtn.transaction != null)
				selectTransactionBtn = _modulesResearchBtn;

			if (selectTransactionBtn == null && _technologyResearchBtn != null && _technologyResearchBtn.transaction != null)
				selectTransactionBtn = _technologyResearchBtn;

			if (selectTransactionBtn != null)
				onTransactionClicked(selectTransactionBtn);
			else
				updateStoreItems();
		}

		private function layoutTransactionBtns():void
		{
			var currentYPos:Number = 0;
			_repairHeaderText.x = _repairHeader.x = _baseHeader.x;
			_repairHeader.y = currentYPos;
			_repairHeaderText.y = _repairHeader.y + (_repairHeader.height - _repairHeaderText.height) * 0.5;

			_repairFleetBtn.x = _repairHeader.x;
			_repairFleetBtn.y = _repairHeader.y + _repairHeader.height + 3;

			currentYPos = _repairFleetBtn.y + _repairFleetBtn.height + 3;
			var repairLen:uint     = _repairBtns.length;
			if (repairLen > 0)
			{
				var currentBtn:StoreTransactionButton;
				for (var i:uint = 0; i < repairLen; ++i)
				{
					currentBtn = _repairBtns[i];
					currentBtn.x = _repairFleetBtn.x;
					currentBtn.y = currentYPos;
					currentYPos = currentBtn.y + currentBtn.height + 3;
				}
			}
			currentYPos += 9;

			_baseHeader.y = currentYPos;
			_baseHeaderText.y = currentYPos + (_baseHeader.height - _baseHeaderText.height) * 0.5;

			_baseBtn.x = _baseHeader.x;
			_baseBtn.y = currentYPos + _baseHeader.height + 3;

			_defenseHeaderText.x = _defenseHeader.x = _baseHeader.x;
			_defenseHeaderText.y = _defenseHeader.y = _baseBtn.y + _baseBtn.height + 11;
			_defenseHeaderText.y = _defenseHeader.y + (_defenseHeader.height - _shipHeaderText.height) * 0.5;

			_defenseBtn.x = _baseHeader.x;
			_defenseBtn.y = _defenseHeader.y + _defenseHeader.height + 3;

			_shipHeaderText.x = _shipHeader.x = _baseHeader.x;
			_shipHeader.y = _defenseBtn.y + _defenseBtn.height + 11;
			_shipHeaderText.y = _shipHeader.y + (_shipHeader.height - _shipHeaderText.height) * 0.5;

			_shipBtn.x = _baseHeader.x;
			_shipBtn.y = _shipHeader.y + _shipHeader.height + 3;

			_researchHeaderText.x = _researchHeader.x = _baseHeader.x;
			_researchHeader.y = _shipBtn.y + _shipBtn.height + 11;
			_researchHeaderText.y = _researchHeader.y + (_researchHeader.height - _researchHeaderText.height) * 0.5;

			_defensesResearchBtn.x = _baseHeader.x;
			_defensesResearchBtn.y = _researchHeader.y + _researchHeader.height + 3;

			_hullsResearchBtn.x = _baseHeader.x;
			_hullsResearchBtn.y = _defensesResearchBtn.y + _defensesResearchBtn.height + 3;

			_modulesResearchBtn.x = _baseHeader.x;
			_modulesResearchBtn.y = _hullsResearchBtn.y + _hullsResearchBtn.height + 3;

			_technologyResearchBtn.x = _baseHeader.x;
			_technologyResearchBtn.y = _modulesResearchBtn.y + _modulesResearchBtn.height + 3;

			_transactionHolder.scrollRect = null;
			_transactionMaxHeight = _technologyResearchBtn.y + _technologyResearchBtn.height;
			_transactionHolder.scrollRect = _transactionMask;
			_transactionScrollbar.updateScrollableHeight(_transactionMaxHeight);
		}

		private function getTransactionBtn( transaction:TransactionVO ):StoreTransactionButton
		{
			var transactionBtn:StoreTransactionButton;
			switch (transaction.type)
			{
				case TransactionEvent.STARBASE_BUILD_SHIP:
				case TransactionEvent.STARBASE_REFIT_SHIP:
					transactionBtn = _shipBtn;
					break;
				case TransactionEvent.STARBASE_RESEARCH:
					var research:ResearchVO = _presenter.getResearchByID(transaction.id);
					if(research == null)
						return null;
					var proto:IPrototype    = research.prototype;
					if(proto == null)
						return null;
					switch (proto.getValue('requiredBuildingClass'))
					{
						case 'ShipDesignFacility':
							transactionBtn = _hullsResearchBtn;
							break;
						case 'WeaponsDesignFacility':
							transactionBtn = _modulesResearchBtn;
							break;
						case 'AdvancedTechFacility':
							transactionBtn = _technologyResearchBtn;
							break;
						case 'DefenseDesignFacility':
							transactionBtn = _defensesResearchBtn;
							break;
					}
					break;
				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					var building:BuildingVO = _presenter.getBuildingByID(transaction.id);
					if(building == null)
						return null;
					proto = building.prototype;
					if(proto == null)
						return null;
					var category:String     = proto.getValue('constructionCategory');
					if (category == 'Base')
					{
						setUpBuildBtnBuilding(transaction);
						transactionBtn = _baseBtn;
					} else
					{
						setUpDefenseBtn(transaction);
						transactionBtn = _defenseBtn;
					}
					break;
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					transactionBtn = _defenseBtn;
					break;
				case TransactionEvent.STARBASE_REPAIR_FLEET:
					transactionBtn = _repairFleetBtn;
					break;
				case TransactionEvent.STARBASE_REPAIR_BASE:
					var repairLen:uint      = _repairBtns.length;
					var currentBtn:StoreTransactionButton;
					for (var i:uint = 0; i < repairLen; ++i)
					{
						currentBtn = _repairBtns[i];
						if (currentBtn.transaction.id == transaction.id)
						{
							transactionBtn = currentBtn;
							break;
						}
					}
					break;
			}

			return transactionBtn;
		}

		private function onTimerFinished( e:TimerEvent ):void
		{
			updateStoreItems();
		}

		private function onTransactionClicked( transaction:StoreTransactionButton ):void
		{
			if (transaction.selectable == true)
			{
				if (_selectedTransactionButton)
					_selectedTransactionButton.selected = false;

				_selectedTransactionButton = transaction;
				_selectedTransactionButton.selected = true;

				updateTimer();

				updateStoreItems();
			} else
			{
				_openWindow(transaction.windowID);
			}
		}

		private function updateTimer():void
		{
			_freeTimer.reset();

			if (_selectedTransactionButton != null && _selectedTransactionButton.transaction != null)
			{
				var timeRemaining:int = _selectedTransactionButton.timeRemaining - 300000;
				if (timeRemaining > 0)
				{
					_freeTimer.delay = timeRemaining;
					_freeTimer.start();
				}
			}
		}

		public function setSelectedTransactionId( transaction:TransactionVO ):void
		{
			if (transaction != null)
			{
				var transactionBtn:StoreTransactionButton = getTransactionBtn(transaction);

				if (transactionBtn != null)
				{
					if (_selectedTransactionButton)
						_selectedTransactionButton.selected = false;

					_selectedTransactionButton = transactionBtn;
					_selectedTransactionButton.selected = true;
					updateStoreItems();
				}
			}

		}

		public function set enableTransactionLinking( v:Boolean ):void
		{
			_enableTransactionLinking = v;

			if (_repairFleetBtn.transaction == null)
				_repairFleetBtn.enabled = _enableTransactionLinking;

			if (_baseBtn.transaction == null)
				_baseBtn.enabled = _enableTransactionLinking;

			if (_defenseBtn.transaction == null)
				_defenseBtn.enabled = _enableTransactionLinking;

			if (_shipBtn.transaction == null)
				_shipBtn.enabled = _enableTransactionLinking;

			if (_defensesResearchBtn.transaction == null)
				_defensesResearchBtn.enabled = (_enableTransactionLinking && _presenter.getBuildingVOByClass('DefenseDesignFacility'))

			if (_hullsResearchBtn.transaction == null)
				_hullsResearchBtn.enabled = (_enableTransactionLinking && _presenter.getBuildingVOByClass('ShipDesignFacility'))

			if (_modulesResearchBtn.transaction == null)
				_modulesResearchBtn.enabled = (_enableTransactionLinking && _presenter.getBuildingVOByClass('WeaponsDesignFacility'))

			if (_technologyResearchBtn.transaction == null)
				_technologyResearchBtn.enabled = (_enableTransactionLinking && _presenter.getBuildingVOByClass('AdvancedTechFacility'))

			var repairLen:uint = _repairBtns.length;
			var currentBtn:StoreTransactionButton;
			for (var i:uint = 0; i < repairLen; ++i)
			{
				currentBtn = _repairBtns[i];
				if (currentBtn.transaction == null)
					currentBtn.enabled = _enableTransactionLinking;

			}
		}

		override protected function buy( item:StoreItem ):void
		{
			if (item.canAfford)
			{
				var itemPrototype:IPrototype = item.itemProto;
				if (itemPrototype.getValue('speedupTime') != null)
				{
					var timeToSpeed:int   = itemPrototype.getValue('speedupTime');
					var instant:Boolean;
					var fromStore:Boolean = true;
					if (timeToSpeed == -1)
						instant = true;
					else
						timeToSpeed *= 1000;

					if (_selectedTransactionButton != null)
					{
						_presenter.speedUpTransaction(_selectedTransactionButton.serverKey, _selectedTransactionButton.token, instant, timeToSpeed, fromStore, item.cost);
					}
				}
			} else
				_openWindow(WINDOW_CANNOT_AFFORD);
		}

		override public function destroy():void
		{
			super.destroy();

			if (_freeTimer.running)
				_freeTimer.stop();

			_freeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerFinished);
			_freeTimer = null;

			_transactionBG = null;
			_transactionBGRollOver = null;
			_transactionBGSelected = null;

			_repairHeaderText.destroy();
			_repairHeaderText = null;

			_repairFleetBtn.destroy();
			_repairFleetBtn = null;

			_baseHeader = null;

			_baseHeaderText.destroy();
			_baseHeaderText = null;

			_baseBtn.destroy();
			_baseBtn = null;

			_defenseHeader = null;

			_defenseHeaderText.destroy();
			_defenseHeaderText = null;

			_defenseBtn.destroy();
			_defenseBtn = null;

			_shipHeader = null;

			_shipHeaderText.destroy();
			_shipHeaderText = null;

			_shipBtn.destroy();
			_shipBtn = null;

			_researchHeader = null;

			_researchHeaderText.destroy();
			_researchHeaderText = null;

			_defensesResearchBtn.destroy();
			_defensesResearchBtn = null;

			_hullsResearchBtn.destroy();
			_hullsResearchBtn = null;

			_modulesResearchBtn.destroy();
			_modulesResearchBtn = null;

			_technologyResearchBtn.destroy();
			_technologyResearchBtn = null;

			_transactionMask = null;

			_transactionHolder = null;

			_transactionScrollbar.onScrollSignal.remove(onChangedTransactionScroll);
			_transactionScrollbar.destroy();
			_transactionScrollbar = null;

			var repairLen:uint = _repairBtns.length;
			if (repairLen > 0)
			{
				var currentBtn:StoreTransactionButton;
				for (var i:uint = 0; i < repairLen; ++i)
				{
					currentBtn = _repairBtns[i];
					currentBtn.destroy();
					currentBtn = null;
				}
				_repairBtns.length = 0;
			}
		}
	}
}
