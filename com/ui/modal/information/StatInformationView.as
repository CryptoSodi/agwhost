package com.ui.modal.information
{
	import com.enum.server.PurchaseTypeEnum;
	import com.event.TransactionEvent;
	import com.model.starbase.BuildingVO;
	import com.presenter.starbase.IStarbasePresenter;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.component.misc.TooltipComponent;
	import com.ui.modal.ButtonFactory;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	public class StatInformationView extends View
	{
		private const DIALOG_MARGIN:int = 120;

		private var _bg:Sprite;
		private var _title:Label;
		private var _body:Label;

		private var _btnX:Number;
		private var _btnY:Number;
		private var _building:BuildingVO;
		private var _bmOkBtn:BitmapButton;
		private var _bmCancelBtn:BitmapButton;

		private var _buttonProtos:Vector.<ButtonPrototype>;

		[PostConstruct]
		public override function init():void
		{
			super.init();
			_buttonProtos = new Vector.<ButtonPrototype>;

			buildBtns(_btnX, _btnY);

			addEffects();
			effectsIN();
		}

		public function SetUp( toolTip:TooltipComponent, title:String = 'CodeString.Shared.Stats', btnX:Number = 235, btnY:Number = 50, bg:String = 'StatWindowBGMC' ):void
		{
			var windowBG:Class = Class(getDefinitionByName(bg));
			_bg = Sprite(new windowBG());
			addChild(_bg);

			_title = LabelFactory.createLabel(LabelFactory.LABEL_TYPE_DIALOG_TITLE, _bg.width - DIALOG_MARGIN);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 20;
			_title.y = 12;
			_title.text = title;
			addChild(_title);

			addChild(toolTip);

			_btnX = btnX;
			_btnY = btnY;
		}

		private function onRecycleClick( e:MouseEvent ):void
		{
			//trace('recycled');
			presenter.performTransaction(TransactionEvent.STARBASE_BUILDING_RECYCLE, _building, PurchaseTypeEnum.INSTANT);
			onButtonClicked(null);
		}

		private function buildBtns( btnX:Number, btnY:Number ):void
		{
			//				_okBtn = new ButtonPrototype('CodeString.Shared.OkBtn');
			//				addButton(_okBtn.text, SIZE_SMALL, _bg.width - btnX, _bg.height - 10);
			_bmOkBtn = ButtonFactory.getBitmapButton('MiddleBtnUpBMD', 127, 356, 'CodeString.Shared.OkBtn', 0xc9e6f6, 'MiddleBtnRollOverBMD', '', '', 'MiddleBtnDownBMD', 0, 0);
			//_bmOkBtn.fontSize = 26;
			addChild(_bmOkBtn);
			addListener(_bmOkBtn, MouseEvent.CLICK, onButtonClicked);
		}

		protected function onButtonClicked( e:MouseEvent ):int
		{
			//			var idx:int = super.onButtonClicked(e);
			//			
			//			var proto:ButtonPrototype = _buttonProtos[idx];
			//			
			//			if (proto.callback != null)
			//				proto.callback.apply(null, proto.args);
			//			
			//			if (proto.doClose)
			destroy();

			return 0;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function get building():BuildingVO  { return _building; }
		public function set building( value:BuildingVO ):void  { _building = value; }

		[Inject]
		public function set presenter( value:IStarbasePresenter ):void  { _presenter = value; }
		public function get presenter():IStarbasePresenter  { return IStarbasePresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();
			_bg = null;
			_title.destroy();
			_title = null;
			_bmOkBtn.destroy();
			_bmOkBtn = null;
			if (_bmCancelBtn)
			{
				_bmCancelBtn.destroy();
				_bmCancelBtn = null;
			}
		}
	}
}
