package com.ui.modal.server
{
	import com.enum.PositionEnum;
	import com.service.ExternalInterfaceAPI;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	
	import com.service.ExternalInterfaceAPI;

	public class ClientCrashView extends View
	{
		private var _bg:Bitmap;
		private var _message:Label;
		private var _refreshButton:BitmapButton;
		private var _title:Label;

		public var errorMsg:String;
		
		private var _triggerTimer:Timer;

		private var _disconnectedStarbaseTitle:String  = 'CodeString.Alert.DisconnectedStarbase.Title'; //Disconnected
		private var _disconnectedStarbaseBody:String   = 'CodeString.Alert.DisconnectedStarbase.Body'; //Your Base server is restarting...
		private var _disconnectedStarbaseAccept:String = 'CodeString.Shared.OkBtn'; //Ok

		private var _titleText:String                  = 'CodeString.ClientCrash.Title'; //CLIENT ERROR OCCURRED
		private var _bodyText:String                   = 'CodeString.ClientCrash.Body'; //Your connection was no match for the Imperium!\nThe client has encountered a problem and needs to be refreshed.\nPlease refresh your browser.\n\nClient Error Message: [[Number:ErrorCount]] Client Error

		[PostConstruct]
		override public function init():void
		{
			
			super.init();

			_bg = PanelFactory.getPanel("ToastLargeBMD");

			_title = LabelFactory.createLabel(-1, _bg.width, 32, 0xfac973)
			_title.y = 10;
			_title.text = _titleText;

			var errorStart:int = errorMsg.indexOf('#');
			var error:String   = errorMsg.slice(errorStart, errorStart + 5);

			_message = LabelFactory.createLabel(-1, _bg.width, 70, 0xf0f0f0, true);
			_message.y = 52;
			_message.setHtmlTextWithTokens(_bodyText, {'[[Number:ErrorCount]]':error});

			x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) / 2;
			y = 90;

			addChild(_bg);
			addChild(_title);
			addChild(_message);

			addEffects();
			effectsIN();
			
			_triggerTimer = new Timer(3000, 1);
			_triggerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, reloadSWF, false, 0, true);
			_triggerTimer.start();
		}
		
		public function reloadSWF( e:TimerEvent = null ):void
		{
			ExternalInterfaceAPI.reloadSWF();
		}
		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.simpleBackingEffect(.7, 0, 0));
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP));
			_effects.addEffect(EffectFactory.alphaEffect(0, 1, 0, .3, .3));
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get type():String  { return ViewEnum.ERROR; }

		override public function destroy():void
		{
			super.destroy();
			_bg = null;
			
			_triggerTimer.stop();
			_triggerTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, reloadSWF);
			_triggerTimer = null;
		}
	}
}
