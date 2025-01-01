package com.ui.alert
{
	import com.model.fleet.FleetVO;
	import com.presenter.starbase.IAttackAlertPresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class AttackAlert extends View
	{
		public var battleServerAddress:String;
		public var fleetID:String;
		public var fleetName:String;

		private var _bg:Bitmap;
		private var _bodyText:Label;
		private var _closeButton:BitmapButton;
		private var _defendButton:BitmapButton;
		private var _ignoreButton:BitmapButton;
		private var _margin:int                  = 30;
		private var _title:Label;

		private var _fleetBattleTitleText:String = 'CodeString.Alert.Battle.Title'; //INCOMING ATTACK
		private var _fleetBattleBodyText:String  = 'CodeString.Alert.FleetBattle.Body'; //Your fleet is under attack! Would you like to defend it?
		private var _baseBattleTitleText:String  = 'CodeString.Alert.Battle.Title'; //INCOMING ATTACK
		private var _baseBattleBodyText:String   = 'CodeString.Alert.BaseBattle.Body'; //Your fleet is under attack! Would you like to defend it?
		private var _viewBtnText:String          = 'CodeString.Alert.Battle.ViewBtn'; //Defend
		private var _dontViewBtnText:String      = 'CodeString.Alert.Battle.DontViewBtn'; //Ignore

		[PostConstruct]
		public override function init():void
		{
			super.init();
			presenter.addFleetUpdateListener(onUpdate);

			_bg = PanelFactory.getPanel("WindowContextMenuBMD");

			_title = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DIALOG_TITLE, _bg.width - _margin);
			_title.align = TextFormatAlign.LEFT;
			_title.text = (fleetID != null) ? _fleetBattleTitleText : _baseBattleTitleText;
			_title.x = _margin;
			_title.y = 13;

			_bodyText = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DYNAMIC, _bg.width - 2 * _margin - 10, 18);
			_bodyText.align = TextFormatAlign.CENTER;
			_bodyText.constrictTextToSize = false;
			_bodyText.multiline = true;
			_bodyText.htmlText = (fleetID != null) ? _fleetBattleBodyText : _baseBattleBodyText;
			_bodyText.setSize(_bodyText.width, _bodyText.textHeight);
			_bodyText.x = _margin;
			_bodyText.y = _title.x + _title.height + 15;

			_closeButton = ButtonFactory.getCloseButton(_bg.width - 40, 15);

			_defendButton = ButtonFactory.getBitmapButton('LeftBtnUpBMD', x, y, _viewBtnText, 0xFFFFFFF, 'LeftBtnRollOverBMD', 'LeftBtnDownBMD', '', '', 12, 0);
			_defendButton.x = (_bg.width * .5) - _defendButton.width - _margin;
			_defendButton.y = _bg.height - _defendButton.height - _margin;

			_ignoreButton = ButtonFactory.getBitmapButton('RightBtnUpBMD', x, y, _dontViewBtnText, 0xFFFFFFF, 'RightBtnRollOverBMD', 'RightBtnDownBMD', '', '', 12, 0);
			_ignoreButton.x = (_bg.width * .5) + _margin;
			_ignoreButton.y = _bg.height - _ignoreButton.height - _margin;

			addListener(_closeButton, MouseEvent.CLICK, onIgnore);
			addListener(_defendButton, MouseEvent.CLICK, onDefend);
			addListener(_ignoreButton, MouseEvent.CLICK, onIgnore);

			addChild(_bg);
			addChild(_title);
			addChild(_bodyText);
			addChild(_closeButton);
			addChild(_defendButton);
			addChild(_ignoreButton);

			addEffects();
			effectsIN();
		}

		private function onDefend( e:MouseEvent ):void
		{
			presenter.removeAllAlerts(AttackAlert);
			presenter.joinBattle(battleServerAddress, fleetID);
			destroy();
		}

		private function onIgnore( e:MouseEvent ):void
		{
			destroy();
		}

		private function onUpdate( fleet:FleetVO = null ):void
		{
			if (presenter.hasBattleEnded(battleServerAddress, fleetID))
				destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IAttackAlertPresenter ):void  { _presenter = value; }
		public function get presenter():IAttackAlertPresenter  { return IAttackAlertPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.ALERT; }
		override public function get typeUnique():Boolean  { return true; }

		override public function destroy():void
		{
			presenter.removeFleetUpdateListener(onUpdate);
			super.destroy();

			_bg = null;
			_bodyText.destroy();
			_bodyText = null;
			ObjectPool.give(_closeButton);
			_closeButton = null;
			ObjectPool.give(_defendButton);
			_defendButton = null;
			ObjectPool.give(_ignoreButton);
			_ignoreButton = null;
			_title.destroy();
			_title = null;
		}
	}
}
