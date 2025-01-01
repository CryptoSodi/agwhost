package com.ui.modal.construction
{
	import com.enum.FilterEnum;
	import com.enum.SlotComponentEnum;
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.IConstructionPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.accordian.AccordianComponent;
	import com.ui.core.component.accordian.AccordianGroup;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.tooltips.Tooltips;

	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.shared.ObjectPool;
	
	import com.util.CommonFunctionUtil;

	/**
	 * ConstructionView is a multipurpose view that handles building, research and component selection.
	 * To use this view, create a new instance and then call the openOn method passing in the state
	 * (BUILD, COMPONENT, or RESEARCH) and the groupID and subItemID for the accordian.
	 */
	public class ConstructionView extends View
	{
		public static const BUILD:int               = 0;
		public static const COMPONENT:int           = 1;
		public static const RESEARCH:int            = 2;

		private static const LAST_VIEWED:Dictionary = new Dictionary();

		private var _accordian:AccordianComponent;
		private var _bg:DefaultWindowBG;
		private var _closeButton:BitmapButton;
		private var _componentSlot:String;
		private var _groupID:String;
		private var _highestButton:BitmapButton;
		private var _advancedButton:BitmapButton;
		private var _commonButton:BitmapButton;
		private var _uncommonButton:BitmapButton;
		private var _rareButton:BitmapButton;
		private var _epicButton:BitmapButton; 
		private var _legendaryButton:BitmapButton;
		private var _list:ConstructionList;
		private var _specialButton:BitmapButton;
		private var _state:int;
		private var _subItemID:String;
		private var _tooltips:Tooltips;

		//localized code strings
		private var _infrastructureButton:String    = 'CodeString.Build.InfrastructureBtn';
		private var _defenseButton:String           = 'CodeString.Build.DefenseBtn';
		private var _researchButton:String          = 'CodeString.Build.ResearchBtn';
		private var _fleetsButton:String            = 'CodeString.Build.FleetsBtn';
		private var _starbaseStructureButton:String = 'CodeString.Build.StarbaseStructureBtn';
		private var _clearSlot:String               = "CodeString.Shared.ClearSlot";
		private var _showHighest:String             = "CodeString.Shared.ShowHighest";
		private var _showAdvancedOnly:String        = "CodeString.Shared.ShowAdvancedOnly";
		private var _showCommonOnly:String    		= "CodeString.Shared.ShowCommonOnly";
		private var _showUncommonOnly:String    	= "CodeString.Shared.ShowUncommonOnly";
		private var _showRareOnly:String    		= "CodeString.Shared.ShowRareOnly";
		private var _showEpicOnly:String    		= "CodeString.Shared.ShowEpicOnly";
		private var _showLegendaryOnly:String       = "CodeString.Shared.ShowLegendaryOnly";
		private var _construction:String            = 'CodeString.BuildInformation.Title.Construction'; //CONSTRUCTION

		private var _arcWeapons:String              = 'CodeString.ComponentSelection.Title.ArcWeapons'; //ARC WEAPONS
		private var _spinalWeapons:String           = 'CodeString.ComponentSelection.Title.SpinalWeapons'; //SPINAL WEAPONS
		private var _weapons:String                 = 'CodeString.ComponentSelection.Title.Weapons'; //WEAPONS
		private var _technology:String              = 'CodeString.ComponentSelection.Title.Technology'; //TECHNOLOGY
		private var _defense:String                 = 'CodeString.ComponentSelection.Title.Defense'; //DEFENSE
		private var _structure:String               = 'CodeString.ComponentSelection.Title.Structure'; //STRUCTURE
		private var _baseTurrets:String             = 'CodeString.ComponentSelection.Title.BaseTurrets'; //TURRETS WEAPONS
		private var _baseShields:String             = 'CodeString.ComponentSelection.Title.BaseShields'; //SHIELDS
		private var _droneBay:String                = 'CodeString.ModuleClass.DroneBay'; //Drone Bay

		private var _blueprints:String              = 'CodeString.Research.Blueprints';
		private var _research:String                = 'CodeString.Research.Title';

		private var _componentText:String           = 'CodeString.ConstructionView.Component'; //COMPONENT
		private var _closeText:String               = 'CodeString.ConstructionView.Close'; //CLOSE
		private var _defenseText:String             = 'CodeString.ConstructionView.Defense'; //DEFENSE
		private var _hullsText:String               = 'CodeString.ConstructionView.Hulls'; //HULLS
		private var _techText:String                = 'CodeString.ConstructionView.Tech'; //TECH
		private var _weaponsText:String             = 'CodeString.ConstructionView.Weapons'; //WEAPONS


		[Inject]
		override public function init():void
		{
			super.init();
			presenter.addOnTransactionRemovedListener(onTransactionChanged);
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(894, 535);

			_accordian = ObjectPool.get(AccordianComponent);
			_accordian.init(244, 52);
			_accordian.x = _bg.bg.x + 14;
			_accordian.y = _bg.bg.y + 5;
			_accordian.addListener(onAccordianSelected);

			_closeButton = UIFactory.getButton(ButtonEnum.BLUE_A, 240, 40, _bg.width - 263, _bg.height + 9, _closeText);

			var rarityButtonOffset:int = 60;
			var rarityButtonInitialOffset:int = 130;
			var rarityButtonWidth:int = 60;
			
			_highestButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showHighest, LabelEnum.DEFAULT_OPEN_SANS);
			_highestButton.label.setSize(100, 25);
			_highestButton.label.align = TextFormatAlign.RIGHT;
			_highestButton.label.x -= _highestButton.width - 15;
			_highestButton.label.y -= 4;
			_highestButton.x = _bg.x + _bg.width - 30;
			_highestButton.y = _accordian.y + 4;
			_highestButton.selected = true;
			
			_legendaryButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showLegendaryOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_legendaryButton.label.setSize(rarityButtonWidth, 25);
			_legendaryButton.label.textColor = CommonFunctionUtil.getRarityColor('Legendary');
			_legendaryButton.label.align = TextFormatAlign.LEFT;
			_legendaryButton.label.x -= _legendaryButton.width - 15;
			_legendaryButton.label.y -= 4;
			_legendaryButton.x = _bg.x + _bg.width - rarityButtonOffset - rarityButtonInitialOffset;
			_legendaryButton.y = _accordian.y + 4;
			_legendaryButton.selected = false;			
	
			_commonButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showCommonOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_commonButton.label.setSize(rarityButtonWidth, 25);
			_commonButton.label.textColor = CommonFunctionUtil.getRarityColor('Common');
			_commonButton.label.align = TextFormatAlign.LEFT;
			_commonButton.label.x -= _commonButton.width - 15;
			_commonButton.label.y -= 4;
			_commonButton.x = _bg.x + _bg.width - 6*rarityButtonOffset - rarityButtonInitialOffset;
			_commonButton.y = _accordian.y + 4;
			_commonButton.selected = false;
			
			_advancedButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showAdvancedOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_advancedButton.label.setSize(rarityButtonWidth, 25);
			_advancedButton.label.textColor = CommonFunctionUtil.getRarityColor('Advanced1');
			_advancedButton.label.align = TextFormatAlign.LEFT;
			_advancedButton.label.x -= _advancedButton.width - 15;
			_advancedButton.label.y -= 4;
			_advancedButton.x = _bg.x + _bg.width - 5*rarityButtonOffset - rarityButtonInitialOffset;
			_advancedButton.y = _accordian.y + 4;
			_advancedButton.selected = false;
			
			_uncommonButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showUncommonOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_uncommonButton.label.setSize(rarityButtonWidth, 25);
			_uncommonButton.label.textColor = CommonFunctionUtil.getRarityColor('Uncommon');
			_uncommonButton.label.align = TextFormatAlign.LEFT;
			_uncommonButton.label.x -= _uncommonButton.width - 15;
			_uncommonButton.label.y -= 4;
			_uncommonButton.x = _bg.x + _bg.width - 4*rarityButtonOffset - rarityButtonInitialOffset;
			_uncommonButton.y = _accordian.y + 4;
			_uncommonButton.selected = false;
			
			_rareButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showRareOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_rareButton.label.setSize(rarityButtonWidth, 25);
			_rareButton.label.textColor = CommonFunctionUtil.getRarityColor('Rare');
			_rareButton.label.align = TextFormatAlign.LEFT;
			_rareButton.label.x -= _rareButton.width - 15;
			_rareButton.label.y -= 4;
			_rareButton.x = _bg.x + _bg.width - 3*rarityButtonOffset - rarityButtonInitialOffset;
			_rareButton.y = _accordian.y + 4;
			_rareButton.selected = false;
			
			_epicButton = UIFactory.getButton(ButtonEnum.CHECKBOX, 0, 0, 0, 0, _showEpicOnly, LabelEnum.DEFAULT_OPEN_SANS);
			_epicButton.label.setSize(rarityButtonWidth, 25);
			_epicButton.label.textColor = CommonFunctionUtil.getRarityColor('Epic');
			_epicButton.label.align = TextFormatAlign.LEFT;
			_epicButton.label.x -= _epicButton.width - 15;
			_epicButton.label.y -= 4;
			_epicButton.x = _bg.x + _bg.width - 2*rarityButtonOffset - rarityButtonInitialOffset;
			_epicButton.y = _accordian.y + 4;
			_epicButton.selected = false;

			_list = ObjectPool.get(ConstructionList);
			_list.init(presenter, _state, _tooltips, _viewFactory);
			_list.x = _accordian.x + 248;
			_list.y = _accordian.y;
			_list.addCloseListener(onClose);

			addChild(_bg);
			addChild(_closeButton);
			addChild(_list);
			addChild(_accordian);
			addChild(_highestButton);
			addChild(_advancedButton);
			addChild(_commonButton);
			addChild(_uncommonButton);
			addChild(_rareButton);
			addChild(_epicButton);
			addChild(_legendaryButton);

			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);
			addListener(_closeButton, MouseEvent.CLICK, onClose);
			addListener(_highestButton, MouseEvent.CLICK, onHighestSelected);
			addListener(_commonButton, MouseEvent.CLICK, onCommonOnlySelected);
			addListener(_advancedButton, MouseEvent.CLICK, onAdvancedOnlySelected);			
			addListener(_uncommonButton, MouseEvent.CLICK, onUncommonOnlySelected);
			addListener(_rareButton, MouseEvent.CLICK, onRareOnlySelected);
			addListener(_epicButton, MouseEvent.CLICK, onEpicOnlySelected);
			addListener(_legendaryButton, MouseEvent.CLICK, onLegendaryOnlySelected);

			showState();
			addEffects();
			effectsIN();
		}
		/**
		 * Must be called before the view is passed to ViewFactory to be shown.
		 * This method defines the state of the view and specifies which group and
		 * subItem the accordian should focus on.
		 * @param state	BUILD, COMPONENT or RESEARCH
		 * @param groupID The group that the accordian should default to
		 * @param subItemID The subItem that the accordian should default to
		 */
		public function openOn( state:int, groupID:String, subItemID:String ):void
		{
			_groupID = groupID;
			_state = state;
			if (_state == COMPONENT)
			{
				_componentSlot = subItemID;
				subItemID = null;
			} else
				_subItemID = subItemID;
		}

		private function onAccordianSelected( groupID:String, subItemID:String, data:* ):void
		{
			var group:AccordianGroup = _accordian.getGroup(groupID);
			if (!subItemID && group.hasSubItems)
			{
				subItemID = group.subItems[0].id;
				_accordian.setSelected(groupID, subItemID)
			}
			_list.title = (group.hasSubItems) ? group.getSubItem(subItemID).text.toUpperCase() : group.text.toUpperCase();
			switch (_state)
			{
				case COMPONENT:
					_list.update(presenter.getComponents(groupID, subItemID, _componentSlot, _highestButton.selected, _advancedButton.selected, _commonButton.selected,_uncommonButton.selected,
						_rareButton.selected, _epicButton.selected, _legendaryButton.selected));
					break;

				case RESEARCH:
					_list.update(presenter.getResearchPrototypes(groupID, subItemID));
					break;

				case BUILD:
				default:
					_list.update(presenter.getBuildingPrototypes(groupID, subItemID));
					break;
			}

			_groupID = groupID;
			_subItemID = subItemID;

			//save the last viewed so that it can be reshown later
			if (!LAST_VIEWED.hasOwnProperty(_state))
				LAST_VIEWED[_state] = {};
			LAST_VIEWED[_state].groupID = _groupID;
			LAST_VIEWED[_state].subItemID = _subItemID;
			LAST_VIEWED[_state].showHighest = _highestButton.selected;
			LAST_VIEWED[_state].showCommonOnly = _commonButton.selected;
			LAST_VIEWED[_state].showAdvancedOnly = _advancedButton.selected;
			LAST_VIEWED[_state].showUncommonOnly = _uncommonButton.selected;
			LAST_VIEWED[_state].showRareOnly = _rareButton.selected;
			LAST_VIEWED[_state].showEpicOnly = _epicButton.selected;
			LAST_VIEWED[_state].showLegendaryOnly = _legendaryButton.selected;
		}

		private function showState():void
		{
			_highestButton.visible = false;			
			_commonButton.visible = false;
			_advancedButton.visible = false;
			_uncommonButton.visible = false;
			_rareButton.visible = false;
			_epicButton.visible = false;
			_legendaryButton.visible = false;
			switch (_state)
			{
				case COMPONENT:
					_bg.addTitle(_componentText, 300);
					_highestButton.visible = true;					
					_commonButton.visible = true;
					_advancedButton.visible = true;
					_uncommonButton.visible = true;
					_rareButton.visible = true;
					_epicButton.visible = true;
					_legendaryButton.visible = true;
					switch (_groupID)
					{
						case SlotComponentEnum.SLOT_TYPE_ARC:
							_bg.addTitle(_arcWeapons, 300);
							_accordian.addGroup(_groupID, _arcWeapons);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.ARC_WEAPONS, presenter.getFilterNameByKey(FilterEnum.ARC_WEAPONS), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_SPINAL:
							_bg.addTitle(_spinalWeapons, 300);
							_accordian.addGroup(_groupID, _spinalWeapons);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.SPINAL_WEAPONS, presenter.getFilterNameByKey(FilterEnum.SPINAL_WEAPONS), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_WEAPON:
							_bg.addTitle(_weapons, 300);
							_accordian.addGroup(_groupID, _weapons);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.PROJECTILE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.PROJECTILE_WEAPONS), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.BEAM_WEAPONS, presenter.getFilterNameByKey(FilterEnum.BEAM_WEAPONS), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.GUIDED_WEAPON, presenter.getFilterNameByKey(FilterEnum.GUIDED_WEAPON), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.LEGACY_WEAPONS, presenter.getFilterNameByKey(FilterEnum.LEGACY_WEAPONS), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_TECH:
							_bg.addTitle(_technology, 300);
							_accordian.addGroup(_groupID, _technology);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.SHIP_TECH, presenter.getFilterNameByKey(FilterEnum.SHIP_TECH), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.WEAPONS_TECH, presenter.getFilterNameByKey(FilterEnum.WEAPONS_TECH), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.BEAM_TECH, presenter.getFilterNameByKey(FilterEnum.BEAM_TECH), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.PROJECTILE_TECH, presenter.getFilterNameByKey(FilterEnum.PROJECTILE_TECH), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.GUIDED_TECH, presenter.getFilterNameByKey(FilterEnum.GUIDED_TECH), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.LEGACY_TECH, presenter.getFilterNameByKey(FilterEnum.LEGACY_TECH), 0);
							//PR: Disabling Secondary Tech for the release
							//_accordian.addSubItemToGroup(_groupID, FilterEnum.SECONDARY_TECH, presenter.getFilterNameByKey(FilterEnum.SECONDARY_TECH), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_DEFENSE:
							_bg.addTitle(_defense, 300);
							_accordian.addGroup(_groupID, _defense);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.ARMOR, presenter.getFilterNameByKey(FilterEnum.ARMOR), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.SHIP_SHIELDS, presenter.getFilterNameByKey(FilterEnum.SHIP_SHIELDS), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.ACTIVE_DEFENSES, presenter.getFilterNameByKey(FilterEnum.ACTIVE_DEFENSES), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.LEGACY_DEFENSE, presenter.getFilterNameByKey(FilterEnum.LEGACY_DEFENSE), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_STRUCTURE:
							_bg.addTitle(_structure, 300);
							_accordian.addGroup(_groupID, _structure);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.INTEGRITY_FIELD, presenter.getFilterNameByKey(FilterEnum.INTEGRITY_FIELD), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_TURRET:
							_bg.addTitle(_baseTurrets, 300);
							_accordian.addGroup(_groupID, _baseTurrets);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.BASE_WEAPONS), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.LEGACY_BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.LEGACY_BASE_WEAPONS), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_SHIELD:
							_bg.addTitle(_baseShields, 300);
							_accordian.addGroup(_groupID, _baseShields);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.BASE_SHIELDS, presenter.getFilterNameByKey(FilterEnum.BASE_SHIELDS), 0);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.LEGACY_BASE_SHIELDS, presenter.getFilterNameByKey(FilterEnum.LEGACY_BASE_SHIELDS), 0);
							break;
						case SlotComponentEnum.SLOT_TYPE_DRONE:
							_bg.addTitle(_droneBay, 300);
							_accordian.addGroup(_groupID, _droneBay);
							_accordian.addSubItemToGroup(_groupID, FilterEnum.DRONE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.DRONE_WEAPONS), 0);
							break;
					}
					if (LAST_VIEWED.hasOwnProperty(_state))
					{
						_highestButton.selected = LAST_VIEWED[_state].showHighest;
						_commonButton.selected = LAST_VIEWED[_state].showCommonOnly;
						_advancedButton.selected = LAST_VIEWED[_state].showAdvancedOnly;
						_uncommonButton.selected = LAST_VIEWED[_state].showUncommonOnly;
						_rareButton.selected = LAST_VIEWED[_state].showRareOnly;
						_epicButton.selected = LAST_VIEWED[_state].showEpicOnly;
						_legendaryButton.selected = LAST_VIEWED[_state].showLegendaryOnly;
						_highestButton.selected = LAST_VIEWED[_state].showHighest;
					}
					_accordian.addSubItemToGroup(_groupID, "Blueprint", _blueprints, 0);
					onAccordianSelected(_groupID, null, null);

					_specialButton = UIFactory.getButton(ButtonEnum.RED_A, 240, 40, _closeButton.x - 250, _closeButton.y, _clearSlot);
					break;

				case RESEARCH:
					_bg.addTitle(_research, 300);
					_accordian.addGroup(TypeEnum.DEFENSE_DESIGN, _defenseText);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.ARMOR, presenter.getFilterNameByKey(FilterEnum.ARMOR), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.SHIP_SHIELDS, presenter.getFilterNameByKey(FilterEnum.SHIP_SHIELDS), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.ACTIVE_DEFENSES, presenter.getFilterNameByKey(FilterEnum.ACTIVE_DEFENSES), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.BASE_SHIELDS, presenter.getFilterNameByKey(FilterEnum.BASE_SHIELDS), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.LEGACY_DEFENSE, presenter.getFilterNameByKey(FilterEnum.LEGACY_DEFENSE), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, FilterEnum.LEGACY_BASE_SHIELDS, presenter.getFilterNameByKey(FilterEnum.LEGACY_BASE_SHIELDS), 0);
					_accordian.addSubItemToGroup(TypeEnum.DEFENSE_DESIGN, "Blueprint", _blueprints, 0);
					_accordian.addGroup(TypeEnum.SHIPYARD, _hullsText);
					_accordian.addSubItemToGroup(TypeEnum.SHIPYARD, FilterEnum.SHIP_HULLS, presenter.getFilterNameByKey(FilterEnum.SHIP_HULLS), 0);
					_accordian.addSubItemToGroup(TypeEnum.SHIPYARD, FilterEnum.SHIP_HULLS_SPECIAL, presenter.getFilterNameByKey(FilterEnum.SHIP_HULLS_SPECIAL), 0);
					_accordian.addSubItemToGroup(TypeEnum.SHIPYARD, FilterEnum.INTEGRITY_FIELD, presenter.getFilterNameByKey(FilterEnum.INTEGRITY_FIELD), 0);
					_accordian.addSubItemToGroup(TypeEnum.SHIPYARD, "Blueprint", _blueprints, 0);
					_accordian.addGroup(TypeEnum.ADVANCED_TECH, _techText);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.BASE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.SHIP_TECH, presenter.getFilterNameByKey(FilterEnum.SHIP_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.WEAPONS_TECH, presenter.getFilterNameByKey(FilterEnum.WEAPONS_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.BEAM_TECH, presenter.getFilterNameByKey(FilterEnum.BEAM_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.PROJECTILE_TECH, presenter.getFilterNameByKey(FilterEnum.PROJECTILE_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.GUIDED_TECH, presenter.getFilterNameByKey(FilterEnum.GUIDED_TECH), 0);
					//PR: Disabling Secondary Tech for the release
					//_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.SECONDARY_TECH, presenter.getFilterNameByKey(FilterEnum.SECONDARY_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.DRONE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.DRONE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.LEGACY_TECH, presenter.getFilterNameByKey(FilterEnum.LEGACY_TECH), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, FilterEnum.LEGACY_BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.LEGACY_BASE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.ADVANCED_TECH, "Blueprint", _blueprints, 0);
					_accordian.addGroup(TypeEnum.WEAPONS_FACILITY, _weaponsText);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.PROJECTILE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.PROJECTILE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.BEAM_WEAPONS, presenter.getFilterNameByKey(FilterEnum.BEAM_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.GUIDED_WEAPON, presenter.getFilterNameByKey(FilterEnum.GUIDED_WEAPON), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.ARC_WEAPONS, presenter.getFilterNameByKey(FilterEnum.ARC_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.SPINAL_WEAPONS, presenter.getFilterNameByKey(FilterEnum.SPINAL_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.BASE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.LEGACY_WEAPONS, presenter.getFilterNameByKey(FilterEnum.LEGACY_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, FilterEnum.LEGACY_BASE_WEAPONS, presenter.getFilterNameByKey(FilterEnum.LEGACY_BASE_WEAPONS), 0);
					_accordian.addSubItemToGroup(TypeEnum.WEAPONS_FACILITY, "Blueprint", _blueprints, 0);

					if (!_groupID)
					{
						if (LAST_VIEWED.hasOwnProperty(_state))
						{
							_groupID = LAST_VIEWED[_state].groupID;
							_subItemID = LAST_VIEWED[_state].subItemID;
						} else
							_groupID = TypeEnum.DEFENSE_DESIGN;
					}
					if (!_subItemID)
						onAccordianSelected(_groupID, null, null);
					else
					{
						_accordian.setSelected(_groupID, _subItemID);
						onAccordianSelected(_groupID, _subItemID, null);
					}
					break;

				case BUILD:
				default:
					_bg.addTitle(_construction, 300);
					_accordian.addGroup(StarbaseCategoryEnum.STARBASE_STRUCTURE, _starbaseStructureButton);
					_accordian.addGroup(StarbaseCategoryEnum.INFRASTRUCTURE, _infrastructureButton);
					_accordian.addGroup(StarbaseCategoryEnum.RESEARCH, _researchButton);
					_accordian.addGroup(StarbaseCategoryEnum.DEFENSE, _defenseButton);
					_accordian.addGroup(StarbaseCategoryEnum.FLEETS, _fleetsButton);

					//set default
					if (!_groupID)
					{
						if (LAST_VIEWED.hasOwnProperty(_state))
						{
							_groupID = LAST_VIEWED[_state].groupID;
							_subItemID = LAST_VIEWED[_state].subItemID;
						} else
							_groupID = StarbaseCategoryEnum.INFRASTRUCTURE;
					}
					_accordian.setSelected(_groupID, null);
					onAccordianSelected(_groupID, null, null);
					break;
			}

			if (_specialButton)
			{
				addListener(_specialButton, MouseEvent.CLICK, onSpecialButtonClicked);
				addChild(_specialButton);
			}
		}

		private function onHighestSelected( e:MouseEvent ):void 
		{
			if(_highestButton.selected)
			{
				_advancedButton.selected = false;
				_commonButton.selected = false;
				_uncommonButton.selected = false;
				_rareButton.selected = false;
				_epicButton.selected = false;
				_legendaryButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null);
		}
		private function onAdvancedOnlySelected( e:MouseEvent ):void
		{
			if(_advancedButton.selected)
			{
				_commonButton.selected = false;
				_uncommonButton.selected = false;
				_rareButton.selected = false;
				_epicButton.selected = false;
				_legendaryButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onCommonOnlySelected( e:MouseEvent ):void
		{
			if(_commonButton.selected)
			{
				_advancedButton.selected = false;
				_uncommonButton.selected = false;
				_rareButton.selected = false;
				_epicButton.selected = false;
				_legendaryButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onUncommonOnlySelected( e:MouseEvent ):void
		{
			if(_uncommonButton.selected)
			{
				_advancedButton.selected = false;
				_commonButton.selected = false;
				_rareButton.selected = false;
				_epicButton.selected = false;
				_legendaryButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onRareOnlySelected( e:MouseEvent ):void
		{
			if(_rareButton.selected)
			{
				_advancedButton.selected = false;
				_commonButton.selected = false;
				_uncommonButton.selected = false;
				_epicButton.selected = false;
				_legendaryButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onEpicOnlySelected( e:MouseEvent ):void
		{
			if(_epicButton.selected)
			{
				_advancedButton.selected = false;
				_commonButton.selected = false;
				_uncommonButton.selected = false;
				_rareButton.selected = false;
				_legendaryButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onLegendaryOnlySelected( e:MouseEvent ):void
		{
			if(_legendaryButton.selected)
			{
				_advancedButton.selected = false;
				_commonButton.selected = false;
				_uncommonButton.selected = false;
				_rareButton.selected = false;
				_epicButton.selected = false;
				_highestButton.selected = false;
			}
			onAccordianSelected(_groupID, _subItemID, null); 
		}
		private function onSpecialButtonClicked( e:MouseEvent ):void  { _list.onSpecialButtonClicked(e); }
		private function onTransactionChanged( transaction:TransactionVO ):void  { onAccordianSelected(_groupID, _subItemID, null); }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function get state():int  { return _state; }

		[Inject]
		public function set presenter( v:IConstructionPresenter ):void  { _presenter = v; }
		public function get presenter():IConstructionPresenter  { return IConstructionPresenter(_presenter); }

		[Inject]
		public function set tooltips( v:Tooltips ):void  { _tooltips = v; }

		override public function destroy():void
		{
			presenter.removeOnTransactionRemovedListener(onTransactionChanged);
			super.destroy();

			ObjectPool.give(_accordian);
			_accordian = null;
			ObjectPool.give(_bg);
			_bg = null;
			_closeButton = UIFactory.destroyButton(_closeButton);
			
			_advancedButton = UIFactory.destroyButton(_advancedButton);
			_commonButton = UIFactory.destroyButton(_commonButton);
			_uncommonButton = UIFactory.destroyButton(_uncommonButton);
			_rareButton = UIFactory.destroyButton(_rareButton);
			_epicButton = UIFactory.destroyButton(_epicButton);
			_legendaryButton = UIFactory.destroyButton(_legendaryButton);
			_highestButton = UIFactory.destroyButton(_highestButton);
			ObjectPool.give(_list);
			_list = null;
			_groupID = _subItemID = null;
			_specialButton = UIFactory.destroyButton(_specialButton);
			_tooltips.removeTooltip(null, this);
			_tooltips = null;
		}
	}
}
