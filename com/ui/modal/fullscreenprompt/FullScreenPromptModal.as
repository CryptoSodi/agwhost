package com.ui.modal.fullscreenprompt
{
	import com.enum.TypeEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StarbaseEvent;
	import com.model.asset.AssetModel;
	import com.presenter.shared.IUIPresenter;
	import com.service.loading.LoadPriority;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.traderoute.overview.TradeRouteOverviewView;

	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	import org.parade.core.IView;
	import org.shared.ObjectPool;

	public class FullScreenPromptModal extends View
	{
		private var _bg:DefaultWindowBG;
		private var _message:Label;

		private var _yesBtn:BitmapButton;
		private var _noBtn:BitmapButton;

		private var _titleString:String   = "CodeString.FullscreenView.Body"; //FULLSCREEN
		private var _messageString:String = "CodeString.FullscreenView.Title"; //Imperium is best played in fullscreen.<BR><BR>Would you like to fullscreen?

		private var _yesBtnString:String  = "CodeString.Shared.YesBtn"; //YES
		private var _noBtnText:String     = 'CodeString.Shared.NoBtn'; //NO

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.addTitle(_titleString, 180);
			_bg.setBGSize(435, 220);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_message = new Label(24, 0xf0f0f0, 400, 140);
			_message.constrictTextToSize = false;
			_message.multiline = true;
			_message.x = 25;
			_message.y = 65;
			_message.htmlText = _messageString;

			_yesBtn = UIFactory.getButton(ButtonEnum.GREEN_A, 180, 40, 20, _bg.height + 8, _yesBtnString);
			addListener(_yesBtn, MouseEvent.CLICK, onOkButtonClick);

			_noBtn = UIFactory.getButton(ButtonEnum.RED_A, 180, 40, _yesBtn.x + _yesBtn.width + 60, _bg.height + 8, _noBtnText);
			addListener(_noBtn, MouseEvent.CLICK, onCancelButtonClick);

			addChild(_bg);
			addChild(_message);
			addChild(_yesBtn);
			addChild(_noBtn);

			addEffects();
			effectsIN();
		}

		private function onOkButtonClick( e:MouseEvent ):void
		{
			presenter.toggleFullScreen();
			destroy();
		}

		private function onCancelButtonClick( e:MouseEvent ):void
		{
			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.dispatch(new StarbaseEvent(StarbaseEvent.WELCOME_BACK));
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);
			_bg = null;

			if (_message)
				_message.destroy();
			_message = null;

			if (_yesBtn)
				_yesBtn.destroy();
			_yesBtn = null;

			if (_noBtn)
				_noBtn.destroy();
			_noBtn = null;
		}
	}
}
