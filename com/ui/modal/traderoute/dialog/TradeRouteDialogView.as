package com.ui.modal.traderoute.dialog
{
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.core.ScaleBitmap;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class TradeRouteDialogView extends View
	{
		public static var AGENT:int  = 0;
		public static var CORP:int   = 1;

		protected var _bg:ScaleBitmap;
		protected var _closeBtn:BitmapButton;
		protected var _closeCallback:Function;
		protected var _viewName:Label;
		protected var _bodyText:Label;
		private var _image:ImageComponent;

		private var _proto:IPrototype;

		private var _currentState:int;

		protected var _okBtn:BitmapButton;

		protected var _MAX_WIDTH:int = 300;

		private var bmp:Bitmap;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var tmp:BitmapData = new BitmapData(300, 300);
			tmp.fillRect(tmp.rect, 0xff00ff);

			_bg = new ScaleBitmap(tmp);
			addChild(_bg);

			bmp = new Bitmap();
			bmp.alpha = 0.5;
			addChild(bmp);

			_viewName = new Label(18, 0xffffff, 220, 30);
			_viewName.align = TextFormatAlign.LEFT;
			addChild(_viewName);

			_image = ObjectPool.get(ImageComponent);
			_image.init(2000, 2000);
			addChild(_image);

			_closeBtn = ButtonFactory.getCloseButton(0, 0);
			_closeBtn.scaleX = _closeBtn.scaleY = .75;
			addListener(_closeBtn, MouseEvent.CLICK, onClose);
			addChild(_closeBtn);

			_bodyText = new Label(13, 0xf0f0f0, 100, 20, true, 1);
			_bodyText.constrictTextToSize = false;
			_bodyText.multiline = true;
			addChild(_bodyText);

			_okBtn = ButtonFactory.getBitmapButton('MiddleBtnUpBMD', 0, 0, 'agent', 0xffffff, 'MiddleBtnRollOverBMD', 'MiddleBtnDownBMD', 'MiddleBtnDownBMD', null, 10);
			_okBtn.addEventListener(MouseEvent.CLICK, onClicked, false, 0, true);
			addChild(_okBtn);

			addEffects();
		}

		public function setUpDialog( type:int, proto:IPrototype, bodyText:String, btnText:String, onCloseCallback:Function = null ):void
		{
			_currentState = type;
			_proto = proto;
			_viewName.text = presenter.getProtoTypeUIName(_proto);
			_viewName.text = _viewName.text.toUpperCase(); //we're not pulling anything from the localization that I can see.

			_bodyText.setTextWithTokens(bodyText, {'[[String.PlayerName]]':CurrentUser.name});
			_okBtn.text = btnText;
			_closeCallback = onCloseCallback;

			presenter.loadIconFromPrototype('mediumImage', _proto, onImageLoaded);
		}

		private function onImageLoaded( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				layout();
			}
		}

		override protected function onClose( e:MouseEvent = null ):void
		{
			if (_closeCallback != null)
				_closeCallback();
			super.onClose(e);
		}

		private function onClicked( e:MouseEvent ):void
		{
			destroy();
		}

		protected function layout():void
		{
			_viewName.x = 28;
			_viewName.y = 14;

			switch (_currentState)
			{
				case AGENT:
				{
					var WindowBGClass:Class = Class(getDefinitionByName(('GreetingsWindowBMD')));
					_bg.bitmapData = BitmapData(new WindowBGClass());

					_image.x = 25;
					_image.y = 55;

					_bodyText.x = 142;
					_bodyText.y = 53;
					_bodyText.align = TextFormatAlign.JUSTIFY;
					_bodyText.setSize(245, _bodyText.textHeight);

					_bg.scale9Grid = new Rectangle(140, 55, 250, 105);

					var th:Number           = _bodyText.textHeight < 110 ? 110 : _bodyText.textHeight;
					_okBtn.y = _bodyText.y + th + 15;

					break;
				}

				case CORP:
				{
					WindowBGClass = Class(getDefinitionByName(('CorpWindowBMD')));
					_bg.bitmapData = BitmapData(new WindowBGClass());

					_image.x = 0.5 * (_bg.width - _image.width);
					_image.y = 50;
					_image.height = 60;

					_bodyText.y = 122;
					_bodyText.x = 25;
					_bodyText.align = TextFormatAlign.JUSTIFY;
					_bodyText.setSize(370, _bodyText.textHeight);

					_bg.scale9Grid = new Rectangle(25, 122, 375, 93);

					//TESTING
					//					var bmpd:BitmapData = new BitmapData(_bg.width, _bg.height, true, 0x00000000);
					//					bmpd.fillRect(_bg.scale9Grid, 0xccff0000);
					//					bmp.bitmapData = bmpd;
					//END TESTING

					_okBtn.y = _bodyText.y + _bodyText.textHeight + 15;

					break;
				}
			}

			_okBtn.x = (_bg.width - _okBtn.width) / 2;
			_bg.height = _okBtn.y + _okBtn.height + 30;

			if (_closeBtn)
			{
				_closeBtn.x = _bg.width - 33;
				_closeBtn.y = _viewName.y + 5;
			}

			effectsIN();
		}

		[Inject]
		public function set presenter( value:ITradePresenter ):void  { _presenter = value; }
		public function get presenter():ITradePresenter  { return ITradePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_closeCallback = null;

			_okBtn.removeEventListener(MouseEvent.CLICK, destroy);
			_okBtn.destroy();
			_okBtn = null;

			_viewName.destroy();
			_viewName = null;

			_bodyText.destroy();
			_bodyText = null;
			super.destroy()
		}
	}
}
