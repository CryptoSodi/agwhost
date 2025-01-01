package com.ui.hud.shared.engineering
{
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetVO;
	import com.model.fleet.ShipVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.ResearchVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IEngineeringPresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;

	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class GroupTray extends Sprite
	{
		public static const REPAIR_BASE:int    = 0;
		public static const REPAIR_SHIP:int    = 1;
		public static const RESEARCH_A:int     = 2;
		public static const RESEARCH_B:int     = 3;
		public static const SHIP_BUILD:int     = 4;
		public static const STARBASE_BUILD:int = 5;

		private var _actionSignal:Signal;
		private var _bg:ScaleBitmap;
		private var _buttonLeft:GroupButton;
		private var _buttonRight:GroupButton;
		private var _numButtons:int;
		private var _parentID:int;
		private var _presenter:IEngineeringPresenter;
		private var _titleLeft:Label;
		private var _titleRight:Label;
		private var _type:int;
		private var _tooltip:Tooltips;

		private var _repairText:String         = 'CodeString.EngineeringView.Repair' //REPAIR
		private var _weaponsText:String        = 'CodeString.EngineeringView.Weapons' //WEAPONS
		private var _techText:String           = 'CodeString.EngineeringView.Tech' //TECH
		private var _defenseText:String        = 'CodeString.EngineeringView.Defense' //DEFENSE
		private var _hullsText:String          = 'CodeString.EngineeringView.Hulls' //HULLS
		private var _buildText:String          = 'CodeString.EngineeringView.Build' //BUILD

		public function init( parentID:int, type:int, actionSignal:Signal, presenter:IEngineeringPresenter ):void
		{
			_actionSignal = actionSignal;
			_parentID = parentID;
			_presenter = presenter;
			_type = type;

			var panelType:String;
			switch (_type)
			{
				case REPAIR_BASE:
					titleLeft = _repairText;
					_numButtons = 2;
					panelType = PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL;
					break;
				case REPAIR_SHIP:
					titleLeft = _repairText;
					_numButtons = 1;
					panelType = PanelEnum.CONTAINER_DOUBLE_NOTCHED;
					break;
				case RESEARCH_A:
					titleLeft = _weaponsText;
					titleRight = _techText;
					_numButtons = 2;
					panelType = PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL;
					break;
				case RESEARCH_B:
					titleLeft = _defenseText;
					titleRight = _hullsText;
					_numButtons = 2;
					panelType = PanelEnum.CONTAINER_DOUBLE_NOTCHED;
					break;
				case SHIP_BUILD:
					titleLeft = _buildText;
					_numButtons = 1;
					panelType = PanelEnum.CONTAINER_DOUBLE_NOTCHED;
					break;
				case STARBASE_BUILD:
					titleLeft = _buildText;
					_numButtons = 2;
					panelType = PanelEnum.CONTAINER_DOUBLE_NOTCHED;
					break;
			}

			_bg = UIFactory.getPanel(panelType, 143, 111, 4, 24);
			addChild(_bg);
			if (_numButtons > 0)
			{
				_buttonLeft = ObjectPool.get(GroupButton);
				_buttonLeft.init(_parentID, _type, 0, _actionSignal, _presenter);
				_buttonLeft.x = 12;
				_buttonLeft.y = 28;
				addChild(_buttonLeft);
			}
			if (_numButtons > 1)
			{
				_buttonRight = ObjectPool.get(GroupButton);
				_buttonRight.init(_parentID, _type, 1, _actionSignal, _presenter);
				_buttonRight.x = 78;
				_buttonRight.y = 28;
				addChild(_buttonRight);
			}
		}

		public function addTransaction( transaction:TransactionVO ):void
		{
			var research:ResearchVO;
			var assetVO:AssetVO;
			switch (_type)
			{
				case RESEARCH_A:
					research = _presenter.getResearchByID(transaction.id);

					if (research)
					{
						assetVO = _presenter.getAssetVO(research.uiAsset);

						if (research.requiredBuildingClass == TypeEnum.WEAPONS_FACILITY)
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonLeft, this, null, Localization.instance.getString(assetVO.visibleName));
						} else if (research.requiredBuildingClass == TypeEnum.ADVANCED_TECH)
						{
							_buttonRight.addTransaction(transaction);
							_tooltip.addTooltip(_buttonRight, this, null, Localization.instance.getString(assetVO.visibleName));
						}
					}
					break;
				case RESEARCH_B:
					research = _presenter.getResearchByID(transaction.id);
					if (research)
					{
						assetVO = _presenter.getAssetVO(research.uiAsset);
						if (research.requiredBuildingClass == TypeEnum.DEFENSE_DESIGN)
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonLeft, this, null, Localization.instance.getString(assetVO.visibleName));
						} else if (research.requiredBuildingClass == TypeEnum.SHIPYARD)
						{
							_buttonRight.addTransaction(transaction);
							_tooltip.addTooltip(_buttonRight, this, null, Localization.instance.getString(assetVO.visibleName));
						}
					}
					break;
				case STARBASE_BUILD:
					//if (transaction.type == TransactionEvent.STARBASE_REPAIR_BASE)
					//	return;
					var building:BuildingVO       = _presenter.getBuildingByID(transaction.id);
					if (building)
					{
						assetVO = _presenter.getAssetVO(building.uiAsset);
						if (building.constructionCategory == StarbaseConstructionEnum.DEFENSE)
						{
							_buttonRight.addTransaction(transaction);
							_tooltip.addTooltip(_buttonRight, this, null, Localization.instance.getString(assetVO.visibleName));
						} else
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonLeft, this, null, Localization.instance.getString(assetVO.visibleName));
						}
					}
					break;

				case SHIP_BUILD:
					var ship:ShipVO               = _presenter.getShipVOByID(transaction.id);

					if (ship)
					{
						assetVO = _presenter.getAssetVO(ship.uiAsset);
						if (_numButtons > 0 && _buttonLeft.transaction == null)
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonLeft, this, null, Localization.instance.getString(assetVO.visibleName));
						} else if (_numButtons > 1 && _buttonRight.transaction == null)
						{
							_buttonRight.addTransaction(transaction);
							_tooltip.addTooltip(_buttonRight, this, null, Localization.instance.getString(assetVO.visibleName));
						}
					}
					break;
				case REPAIR_BASE:
					if (transaction.type != TransactionEvent.STARBASE_REPAIR_BASE)
						return;
					var repairBuilding:BuildingVO = _presenter.getBuildingByID(transaction.id);

					if (building)
					{
						assetVO = _presenter.getAssetVO(repairBuilding.uiAsset);
						if (_numButtons > 0 && _buttonLeft.transaction == null)
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonLeft, this, null, Localization.instance.getString(assetVO.visibleName));
						} else if (_numButtons > 1 && _buttonRight.transaction == null)
						{
							_buttonLeft.addTransaction(transaction);
							_tooltip.addTooltip(_buttonRight, this, null, Localization.instance.getString(assetVO.visibleName));
						}
					}
					break;
				case REPAIR_SHIP:
					var fleet:FleetVO             = _presenter.getRepairFleetByID(transaction.id);

					if (fleet)
					{
						if (_numButtons > 0 && _buttonLeft.transaction == null)
							_tooltip.addTooltip(_buttonLeft, this, null, fleet.name);
						else if (_numButtons > 1 && _buttonRight.transaction == null)
							_tooltip.addTooltip(_buttonRight, this, null, fleet.name);
					}


				default:
					if (_numButtons > 0 && _buttonLeft.transaction == null)
						_buttonLeft.addTransaction(transaction);
					else if (_numButtons > 1 && _buttonRight.transaction == null)
						_buttonRight.addTransaction(transaction);
					break;

			}
		}

		public function removeTransaction( transaction:TransactionVO ):void
		{
			if (_numButtons > 0 && _buttonLeft.transaction == transaction)
				_buttonLeft.removeTransaction(transaction);
			else if (_numButtons > 1 && _buttonRight.transaction == transaction)
				_buttonRight.removeTransaction(transaction);
			if (_type == REPAIR_BASE)
			{
				//find a new repair transaction
				var transactions:Dictionary = _presenter.transactions;
				for each (var trans:TransactionVO in transactions)
				{
					if (trans.type == TransactionEvent.STARBASE_REPAIR_BASE)
					{
						if (_buttonLeft.transaction == null && _buttonRight.transaction != trans)
							_buttonLeft.addTransaction(trans);
						else if (_buttonRight.transaction == null && _buttonLeft.transaction != trans)
							_buttonRight.addTransaction(trans);
					}
				}
			}
		}

		public function updateTransactionTime():void
		{
			if (_buttonLeft)
				_buttonLeft.updateTransactionTime();
			if (_buttonRight)
				_buttonRight.updateTransactionTime();
		}

		protected function set titleLeft( v:String ):void
		{
			if (v)
			{
				if (!_titleLeft)
				{
					_titleLeft = UIFactory.getLabel(LabelEnum.SUBTITLE, 70, 30, 3, 0);
					_titleLeft.align = TextFormatAlign.LEFT;
					_titleLeft.bold = false;
					_titleLeft.constrictTextToSize = true;
				}
				_titleLeft.text = v;
				addChild(_titleLeft);
			} else if (_titleLeft)
			{
				removeChild(_titleLeft);
				_titleLeft = UIFactory.destroyLabel(_titleLeft);
			}
		}

		protected function set titleRight( v:String ):void
		{
			if (v)
			{
				if (!_titleRight)
				{
					_titleRight = UIFactory.getLabel(LabelEnum.SUBTITLE, 70, 30, 74, 0);
					_titleRight.align = TextFormatAlign.LEFT;
					_titleRight.bold = false;
					_titleRight.constrictTextToSize = true;
				}
				_titleRight.text = v;
				addChild(_titleRight);
			} else if (_titleRight)
			{
				removeChild(_titleRight);
				_titleRight = UIFactory.destroyLabel(_titleRight);
			}
		}

		[Inject]
		public function set tooltip( value:Tooltips ):void  { _tooltip = value; }

		public function destroy():void
		{
			_actionSignal = null;
			_presenter = null;
			titleLeft = null;
			titleRight = null;
			x = y = 0;
			_tooltip.removeTooltip(null, this);
			_tooltip = null;
		}
	}
}
