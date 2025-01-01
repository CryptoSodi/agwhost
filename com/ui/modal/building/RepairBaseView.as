package com.ui.modal.building
{
	import com.enum.server.PurchaseTypeEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetModel;
	import com.presenter.starbase.IStarbasePresenter;
	import com.service.language.Localization;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ActionComponent;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.misc.TooltipComponent;
	import com.ui.modal.ButtonFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.shared.ObjectPool;

	public class RepairBaseView extends View
	{
		public static var PLAYER_KNOWS_ABOUT_REPAIR:Boolean = false;

		protected var _actionComponent:ActionComponent;
		protected var _bg:Sprite;
		protected var _buildingInfo:Label;
		protected var _closeBtn:BitmapButton;
		protected var _descriptionInfo:Label;
		protected var _image:ImageComponent;
		protected var _tooltipComponent:TooltipComponent;
		protected var _viewName:Label;

		private var _repair:String                          = "CodeString.Docks.RepairBtn"; //REPAIR
		private var _repairNow:String                       = "CodeString.Docks.RepairNowBtn"; //REPAIR NOW
		private var _getResources:String                    = 'CodeString.Shared.GetResources'; //GET RESOURCES
		private var _getPalladium:String                    = 'CodeString.Shared.GetPalladium' //GET PALLADIUM

		private var _damageReportText:String                = "CodeString.RepairBaseView.DamageReport"; //Damage Report
		private var _damageReportDescription:String         = "CodeString.RepairBaseView.DamageReportDescription"; //Your base has been attacked and needs repairs!
		private var _damageTooltip:String                   = 'CodeString.RepairBaseView.Tooltip.Damage'; //<textformat blockindent="6" rightmargin="13"><font size="13" color="#B3DDF2">Damage Taken:</font><font size="13" color="#f0f0f0"> [[Number.TotalBaseDamage]]%</font><br/>\n<font size="13" color="#B3DDF2">Damaged Buildings:</font><font size="13" color="#f0f0f0">  [[Number.TotalDamagedBuildings]]</font><br/>\n<font size="13" color="#B3DDF2">Destroyed Buildings:</font><font size="13" color="#f0f0f0"> [[Number.TotalDestroyedBuildings]]</font><br/>\n</textformat>

		[PostConstruct]
		override public function init():void
		{
			super.init();
			var windowFrameBGClass:Class = Class(getDefinitionByName("BuildWindowMaxLevelWindowNoSalvageBGMC"));
			_bg = Sprite(new windowFrameBGClass());
			addChild(_bg);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);
			addChild(_closeBtn);

			_image = new ImageComponent();
			_image.init(150, 150);
			_image.x = 51;
			_image.y = 108;
			addChild(_image);

			_viewName = new Label(30, 0xFFFFFF, _bg.width - 100, 40);
			_viewName.y = 17;
			_viewName.x = 29;
			_viewName.align = TextFormatAlign.LEFT;
			_viewName.text = _repair;
			addChild(_viewName);

			_buildingInfo = new Label(20, 0xFFFFFFF, 434, 84);
			_buildingInfo.x = 35;
			_buildingInfo.y = 65;
			_buildingInfo.multiline = false;
			_buildingInfo.align = TextFormatAlign.LEFT;
			_buildingInfo.text = _damageReportText;
			addChild(_buildingInfo);

			_descriptionInfo = new Label(13, 0xFFFFFF, 434, 84, true, 1);
			_descriptionInfo.x = 200;
			_descriptionInfo.y = 115;
			_descriptionInfo.multiline = true;
			_descriptionInfo.align = TextFormatAlign.LEFT;
			_descriptionInfo.text = _damageReportDescription;
			addChild(_descriptionInfo);

			_actionComponent = new ActionComponent(new ButtonPrototype(_repair, onActionBtnClick), new ButtonPrototype(_repairNow, onActionInstantBtnClick),
												   new ButtonPrototype(_getResources, onActionBtnClick),
												   new ButtonPrototype(_getPalladium, popPaywall));
			_actionComponent.x = 320;
			_actionComponent.y = 280;
			_actionComponent.visible = true;
			_actionComponent.timeCost = presenter.getRepairTime();
			_actionComponent.instantCost = presenter.getRepairCost();
			_actionComponent.instantActionBtnEnabled = false;
			_actionComponent.instantActionBtn.visible = false;
			addChild(_actionComponent);

			//stats
			// Add indentation
			var tooltip:String           = Localization.instance.getStringWithTokens(_damageTooltip, {"[[Number.TotalBaseDamage]]":presenter.totalBaseDamage, "[[Number.TotalDamagedBuildings]]":presenter.
																							 totalDamagedBuildings,
																						 "[[Number.TotalDestroyedBuildings]]":presenter.totalDestroyedBuildings});
			tooltip = tooltip.split('<br/>').join('<br/>\n');
			_tooltipComponent = ObjectPool.get(TooltipComponent);
			_tooltipComponent.init(1, 300);
			_tooltipComponent.layoutTooltip(tooltip, 50, 277);
			addChild(_tooltipComponent);

			PLAYER_KNOWS_ABOUT_REPAIR = true;

			AssetModel.instance.getFromCache("assets/CommandCenter5_Icon.png", _image.onImageLoaded);

			addEffects();
			effectsIN();
			removeChild(_closeBtn);
		}

		protected function onActionBtnClick( e:MouseEvent ):void
		{
			PLAYER_KNOWS_ABOUT_REPAIR = false;
			presenter.performTransaction(TransactionEvent.STARBASE_REPAIR_BASE, null, PurchaseTypeEnum.NORMAL);
			destroy();
		}
		protected function onActionInstantBtnClick( e:MouseEvent ):void
		{
			PLAYER_KNOWS_ABOUT_REPAIR = false;
			presenter.performTransaction(TransactionEvent.STARBASE_REPAIR_BASE, null, PurchaseTypeEnum.INSTANT);
			destroy();
		}

		private function popPaywall( e:MouseEvent = null ):void
		{
			CommonFunctionUtil.popPaywall();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IStarbasePresenter ):void  { _presenter = value; }
		public function get presenter():IStarbasePresenter  { return IStarbasePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			if(!PLAYER_KNOWS_ABOUT_REPAIR)
			{
				super.destroy();
	
				_bg = null;
				_closeBtn.destroy();
				_closeBtn = null;
	
				_image.destroy();
				_image = null;
	
				if (_buildingInfo)
				{
					_buildingInfo.destroy();
					_buildingInfo = null;
				}
	
				if (_descriptionInfo)
				{
					_descriptionInfo.destroy();
					_descriptionInfo = null;
				}
	
				if (_viewName)
				{
					_viewName.destroy();
					_viewName = null;
				}
	
				ObjectPool.give(_tooltipComponent);
				_tooltipComponent = null;
			}
		}
	}
}
