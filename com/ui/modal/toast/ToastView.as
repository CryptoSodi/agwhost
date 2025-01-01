package com.ui.modal.toast
{
	import com.enum.AudioEnum;
	import com.enum.PositionEnum;
	import com.event.TransactionEvent;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetVO;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.effects.EffectFactory;
	import com.ui.core.effects.ViewEffects;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.localEventMap.impl.EventMap;
	import org.shared.ObjectPool;

	public class ToastView extends View
	{
		protected var _autoLayout:Boolean                = false;
		protected var _bg:Bitmap;
		protected var _hitArea:Sprite                    = new Sprite();
		protected var _holder:Sprite                     = new Sprite();
		protected var _lookup:Dictionary                 = new Dictionary(true);
		protected var _soundToPlay:String;

		private var _researchText:String                 = 'CodeString.Toast.Research'; //Research Complete
		private var _shipConstructionCompleteText:String = 'CodeString.Toast.ShipConstructionComplete'; //Ship Construction Complete
		private var _constructionCompleteText:String     = 'CodeString.Toast.ConstructionComplete'; //Construction Complete
		private var _upgradeCompleteText:String          = 'CodeString.Toast.UpgradeComplete'; //Upgrade Complete
		private var _contactCompleteText:String          = 'CodeString.Toast.ContactComplete'; //Trade Contract Complete
		private var _fleetRepairedText:String            = 'CodeString.Toast.FleetRepaired'; //Fleet Repaired
		private var _buffExpiredText:String              = 'CodeString.Toast.BuffExpired'; //Buff Expired
		private var _buffAddedText:String                = 'CodeString.Toast.BuffAdded'; //Buff Added
		private var _buildingRecycledText:String         = 'CodeString.Toast.BuildingRecycled'; //Building Recycled
		private var _creditsDepositedText:String         = 'CodeString.Toast.CreditsDeposited'; //Credits Deposited
		private var _resourcesDepositedText:String       = 'CodeString.Toast.ResourcesDeposited'; //Resources Deposited
		private var _refitCompleteText:String            = 'CodeString.Toast.RefitComplete'; //Refit Complete
		private var _shipRefitCompleteText:String        = 'CodeString.Toast.ShipRefitComplete'; //Ship Refit Complete

		[PostConstruct]
		override public function init():void
		{
			_eventMap = new EventMap(null);
			_effects = ObjectPool.get(ViewEffects);
			_effects.addInListener(effectsDoneIn);
			_effects.addOutListener(effectsDoneOut);
			_mute = true;
			_presenter && _presenter.highfive();

			x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) / 2;
			y = 90;

			if (_soundToPlay != null)
				presenter.playSound(_soundToPlay);

			mouseEnabled = mouseChildren = false;
			addHitArea();
			addChild(_holder);
			addEffects();
			effectsIN();
			layout();
		}

		override public function onEscapePressed():void  {}

		public function addLabel( id:String, label:Label, x:Number = -1, y:Number = -1, text:String = null, align:String = TextFormatAlign.CENTER ):void
		{
			label.align = align;
			if (text)
				label.text = text;
			label.x = (x != -1) ? x : (_bg.width - label.width) / 2;
			label.y = (y != -1) ? y : (_bg.height - label.textHeight) / 2;
			_lookup[id] = label;
			_holder.addChild(label);
			layout();
		}

		public function addTransactionLabels( transaction:TransactionVO, assetVO:AssetVO, prototype:IPrototype ):void
		{
			addLabel("title", LabelFactory.createLabel(-1, 225, 32, 0xfac973), 130, 10, null, TextFormatAlign.LEFT);
			addLabel("message", LabelFactory.createLabel(-1, 250, 42, 0xf0f0f0, true), 130, 48, null, TextFormatAlign.LEFT);

			switch (transaction.type)
			{
				case TransactionEvent.STARBASE_BUILD_SHIP:
					addTextToLabel("title", _shipConstructionCompleteText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_SHIP_COMPLETE;
					break;
				case TransactionEvent.STARBASE_BUILDING_BUILD:
					addTextToLabel("title", _constructionCompleteText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_BUILDING_COMPLETE;
					break;
				case TransactionEvent.STARBASE_BUILDING_RECYCLE:
					addTextToLabel("title", _buildingRecycledText);
					addTextToLabel("message", assetVO.visibleName);
					break
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					addTextToLabel("title", _upgradeCompleteText);
					addTextToLabel("message", "CodeString.BuildUpgrade.BuildingLevel", {'[[String.BuildingName]]':assetVO.visibleName, '[[Number.BuildingLevel]]':prototype.getValue("level")});
					_soundToPlay = AudioEnum.VO_ALERT_UPGRADE_COMPLETE;
					break;
				case TransactionEvent.STARBASE_BUY_RESOURCES:
					if (prototype.getValue('resourceType') == "credit")
						addTextToLabel("title", _creditsDepositedText);
					else
						addTextToLabel("title", _resourcesDepositedText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_TRANSACTION_COMPLETE;
					break;
				case TransactionEvent.STARBASE_BUY_STORE_ITEM:
					if (transaction.timeRemainingMS == 0 && transaction.timeMS != 0)
					{
						addTextToLabel("title", _buffExpiredText);
						_soundToPlay = AudioEnum.VO_ALERT_BUFF_EXPIRED;
					} else
					{
						addTextToLabel("title", _buffAddedText);
						_soundToPlay = AudioEnum.VO_ALERT_TRANSACTION_COMPLETE;
					}
					addTextToLabel("message", assetVO.visibleName);
					break;
				case TransactionEvent.STARBASE_BUY_OTHER_STORE_ITEM:
					addTextToLabel("title", _resourcesDepositedText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_TRANSACTION_COMPLETE;
					break;
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					addTextToLabel("title", _refitCompleteText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_BUILDING_COMPLETE;
					break;
				case TransactionEvent.STARBASE_REFIT_SHIP:
					addTextToLabel("title", _shipRefitCompleteText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_SHIP_COMPLETE;
					break;
				case TransactionEvent.STARBASE_REPAIR_BASE:
					break;
				case TransactionEvent.STARBASE_REPAIR_FLEET:
					addTextToLabel("title", _fleetRepairedText);
					addTextToLabel("message", FleetVO(prototype).name);
					_soundToPlay = AudioEnum.VO_ALERT_FLEET_REPAIRED;
					break;
				case TransactionEvent.STARBASE_RESEARCH:
					addTextToLabel("title", _researchText);
					addTextToLabel("message", assetVO.visibleName);
					_soundToPlay = AudioEnum.VO_ALERT_RESEARCH_COMPLETE;
					break;
			}
			layout();
		}

		public function addTextToLabel( id:String, text:String, tokens:Object = null, isHtmlText:Boolean = false ):void
		{
			if (_lookup.hasOwnProperty(id))
			{
				if (tokens != null)
					_lookup[id].setTextWithTokens(text, tokens);
				else if (isHtmlText)
					_lookup[id].htmlText = text;
				else
					_lookup[id].text = text;
			}
			layout();
		}

		public function addIcon( libraryName:String, x:Number, y:Number, width:Number = 0, height:Number = 0 ):void
		{
			var panel:Bitmap = PanelFactory.getPanel(libraryName);
			if (panel)
			{
				panel.x = x;
				panel.y = y;
				if (width > 0)
					panel.width = width;
				if (height > 0)
					panel.height = height;
				_holder.addChild(panel);
			}
			layout();
		}

		public function addImage( id:String, image:ImageComponent ):void
		{
			_holder.addChild(image);
			_lookup[id] = image;
			layout();
		}

		public function addBackground( libraryName:String ):void
		{
			_bg = PanelFactory.getPanel(libraryName);
			addChildAt(_bg, 0);
			layout();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP));
			_effects.addEffect(EffectFactory.alphaEffect(0, 1, 0, .3, .3));
		}

		private function layout():void
		{
			if (_autoLayout)
			{
				_holder.x = (_bg.width - _holder.width) / 2;
				_holder.y = (_bg.height - _holder.height) / 2;
			}
		}

		public function set autoLayout( v:Boolean ):void  { _autoLayout = v; }
		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get type():String  { return ViewEnum.HOVER; }

		override public function destroy():void
		{
			super.destroy();

			_autoLayout = false;
			_bg = null;
			_holder.x = _holder.y = 0;
			while (_holder.numChildren > 0)
				_holder.removeChildAt(0);
			for each (var id:String in _lookup)
			{
				delete _lookup[id];
			}
			_soundToPlay = null;
		}
	}
}
