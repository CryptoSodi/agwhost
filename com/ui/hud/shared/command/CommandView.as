package com.ui.hud.shared.command
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.event.StateEvent;
	import com.presenter.shared.ICommandPresenter;
	import com.ui.UIFactory;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.tab.TabComponent;
	import com.ui.core.effects.EffectFactory;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import org.greensock.TweenLite;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class CommandView extends View
	{
		public static const TRADE_TAB:String = "TradeRoutesTab";
		public static const FLEET_TAB:String = "FleetTab";

		private const MAXIMIZED:Number       = 1;
		private const MIN_X_POS:Number       = 271;
		private const MIN_Y_POS:Number       = 452;
		private const MINIMIZED:Number       = 0;

		private var _minimizeButton:BitmapButton;
		private var _maximizeButton:BitmapButton;
		private var _selectedView:View;
		private var _tabComponent:TabComponent;
		private var _windowState:int;

		private var _fleetView:FleetCommandView;
		private var _tradeView:ResourceTradeCommandView;

		private var _resourcesTabText:String = 'CodeString.CommandView.Resources'; //RESOURCES
		private var _fleetsTabText:String    = 'CodeString.CommandView.Fleets'; //FLEETS


		[PostConstruct]
		override public function init():void
		{
			super.init();
			_windowState = MAXIMIZED;

			var headerSize:int = 32;
			_tabComponent = ObjectPool.get(TabComponent);
			_tabComponent.init(PanelEnum.CONTAINER_DOUBLE_NOTCHED_ARROWS, PanelEnum.HEADER_NOTCHED, 355, 210, headerSize);
			_tabComponent.automaticLayoutHorizontal = true;
			_tabComponent.addTab(TRADE_TAB, ButtonEnum.HEADER_NOTCHED, 126, headerSize, 0, 0, _resourcesTabText, LabelEnum.H2);
			_tabComponent.addTab(FLEET_TAB, ButtonEnum.HEADER, 100, headerSize, 0, 0, _fleetsTabText, LabelEnum.H2);
			_tabComponent.addSwitchTabListener(onTabSwitched);

			_minimizeButton = UIFactory.getButton(ButtonEnum.ICON_WINDOW_MIN, 0, 0, 330, 13);
			_maximizeButton = UIFactory.getButton(ButtonEnum.ICON_WINDOW_FULL, 0, 0, 330, 13);
			_maximizeButton.visible = false;

			_tradeView = new ResourceTradeCommandView();
			_tradeView.y = headerSize;

			_fleetView = new FleetCommandView();
			_fleetView.y = headerSize;

			presenter.injectObject(_tradeView);
			presenter.injectObject(_fleetView);

			addListener(_minimizeButton, MouseEvent.CLICK, onMinimize);
			addListener(_maximizeButton, MouseEvent.CLICK, onMaximize);

			addChild(_tabComponent);
			addChild(_minimizeButton);
			addChild(_maximizeButton);
			addChild(_tradeView);
			addChild(_fleetView);

			onStateChange(Application.STATE);

			onStageResized();
			addHitArea();
			addEffects();
			effectsIN();

			visible = !presenter.inFTE;
		}

		private function onTabSwitched( name:String ):void
		{
			if (name == TRADE_TAB)
			{
				_tradeView.visible = true;
				_fleetView.visible = false;
			} else
			{
				_fleetView.visible = true;
				_tradeView.visible = false;
			}

		}

		override protected function onStateChange( state:String ):void
		{
			if (state == StateEvent.GAME_SECTOR)
				_tabComponent.setSelectedTab(FLEET_TAB);
			else if (state == StateEvent.GAME_STARBASE)
				_tabComponent.setSelectedTab(TRADE_TAB);
			if (state == StateEvent.GAME_BATTLE)
				destroy();
		}

		private function onMinimize( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			_windowState = MINIMIZED;
			_minimizeButton.visible = false;
			_maximizeButton.visible = true;
			TweenLite.to(this, .2, {y:DeviceMetrics.HEIGHT_PIXELS - (32 * Application.SCALE)});
		}

		private function onMaximize( e:MouseEvent ):void
		{
			if (!presenter.hudEnabled)
				return;
			_windowState = MAXIMIZED;
			_minimizeButton.visible = true;
			_maximizeButton.visible = false;
			TweenLite.to(this, .2, {y:DeviceMetrics.HEIGHT_PIXELS - height});
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.BOTTOM, onStageResized));
		}

		private function onStageResized( e:Event = null ):void
		{
			this.scaleX = this.scaleY = Application.SCALE;
			TweenLite.killTweensOf(this);
			var yPos:Number;
			switch (_windowState)
			{
				case MAXIMIZED:
					yPos = DeviceMetrics.HEIGHT_PIXELS - height;
					break;
				case MINIMIZED:
					yPos = DeviceMetrics.HEIGHT_PIXELS - (32 * Application.SCALE);
					break;
			}
			y = (yPos < MIN_Y_POS) ? MIN_Y_POS : yPos;
			x = (DeviceMetrics.WIDTH_PIXELS - width < MIN_X_POS) ? MIN_X_POS : DeviceMetrics.WIDTH_PIXELS - width;
			if (_fleetView)
				_fleetView.layoutFleets();
		}

		override public function get height():Number  { return _tabComponent ? _tabComponent.height * Application.SCALE : this.height * Application.SCALE; }
		override public function get width():Number  { return _tabComponent ? _tabComponent.width * Application.SCALE : this.width * Application.SCALE; }

		[Inject]
		public function set presenter( value:ICommandPresenter ):void  { _presenter = value; }
		public function get presenter():ICommandPresenter  { return ICommandPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI }
		
		override public function get screenshotBlocker():Boolean {return true;}

		override public function destroy():void
		{
			TweenLite.killTweensOf(this);

			super.destroy();

			_maximizeButton = UIFactory.destroyButton(_maximizeButton);
			_minimizeButton = UIFactory.destroyButton(_minimizeButton);

			ObjectPool.give(_tabComponent);
			_tabComponent = null;

			if (_fleetView)
				_fleetView.destroy();

			_fleetView = null;

			if (_tradeView)
				_tradeView.destroy();

			_tradeView = null;
		}
	}
}
