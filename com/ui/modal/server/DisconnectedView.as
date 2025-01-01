package com.ui.modal.server
{
	import com.enum.PositionEnum;
	import com.service.ExternalInterfaceAPI;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.effects.EffectFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.UIFactory;
	
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;

	public class DisconnectedView extends View
	{
		private var _bg:Bitmap;
		private var _message:Label;
		private var _refreshButton:BitmapButton;
		private var _title:Label;
		private var _refreshBtn:BitmapButton;

		public var messageText:String;
		public var titleText:String;

		private var _disconnectedStarbaseTitle:String  = 'CodeString.Alert.DisconnectedStarbase.Title'; //Disconnected
		private var _disconnectedStarbaseBody:String   = 'CodeString.Alert.DisconnectedStarbase.Body'; //Your Base server is restarting...
		private var _disconnectedStarbaseRefreshButton:String   = 'CodeString.Alert.DisconnectedStarbase.RefreshBtn'; //Your Base server is restarting...
		private var _disconnectedStarbaseAccept:String = 'CodeString.Shared.OkBtn'; //Ok

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_bg = PanelFactory.getPanel("ToastLargeBMD");

			_title = LabelFactory.createLabel(-1, _bg.width, 32, 0xfac973)
			_title.y = 10;
			_title.text = titleText;

			_message = LabelFactory.createLabel(-1, _bg.width, 70, 0xf0f0f0, true);
			_message.y = 57;
			_message.text = messageText;

			x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) / 2;
			y = 90;
			
			_refreshBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 140, 40, _bg.width/2 - 70, 200, _disconnectedStarbaseRefreshButton, LabelEnum.H1);
			addListener(_refreshBtn, MouseEvent.CLICK, onRefresh);

			addChild(_bg);
			addChild(_title);
			addChild(_message);
			addChild(_refreshBtn);

			addEffects();
			effectsIN();
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.simpleBackingEffect(.7, 0, 0));
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.TOP));
			_effects.addEffect(EffectFactory.alphaEffect(0, 1, 0, .3, .3));
		}
		private function onRefresh( e:MouseEvent ):void
		{
			ExternalInterfaceAPI.reloadSWF();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get type():String  { return ViewEnum.ERROR; }

		override public function destroy():void
		{
			super.destroy();
			_bg = null;
		}
	}
}
