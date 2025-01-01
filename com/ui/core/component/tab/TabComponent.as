package com.ui.core.component.tab
{
	import com.ui.UIFactory;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.BitmapButton;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class TabComponent extends Sprite implements IComponent
	{
		private var _automaticLayoutHorizontal:Boolean = false;
		private var _automaticLayoutVertical:Boolean   = false;
		private var _panel:Sprite;
		private var _switchTabSignal:Signal            = new Signal(String);
		private var _tabLookup:Dictionary;
		private var _tabs:Vector.<BitmapButton>        = new Vector.<BitmapButton>;

		public function init( panelType:String, headerType:String, width:Number = 0, height:Number = 0, headerSize:Number = 0 ):void
		{
			if (panelType && headerType)
			{
				_panel = UIFactory.getHeaderPanel(panelType, headerType, width, height, headerSize);
				addChild(_panel);
			}
			_switchTabSignal = new Signal(String);

			_tabLookup = new Dictionary(false);
		}

		/**
		 * Adds a tab, with a text label, to the component
		 *
		 * @param name Name is the value that is returned when the user switches tabs. It is also used to get the tab element from the tab component.
		 * @param type The type of tab button to create. Any button in ButtonEnum can be used as a tab button
		 * @param width Width to resize the button to
		 * @param height Height to resize the button to
		 * @param x X position of the tab in the component
		 * @param y Y position of the tab in the component
		 * @param text The text to display in the tab
		 * @param labelType The text format of the label in the tab
		 */
		public function addTab( name:String, type:String, width:int = 0, height:int = 0, x:int = 0, y:int = 0, text:String = null, labelType:String = null ):void
		{
			if (!_tabLookup.hasOwnProperty(name))
			{
				var tab:BitmapButton = UIFactory.getButton(type, width, height, 0, 0, text, labelType);
				tab.x = x;
				tab.y = y;
				tab.addEventListener(MouseEvent.CLICK, onTabClicked, false, 0, true);
				_tabLookup[name] = tab;
				_tabLookup[tab] = name;
				_tabs.push(tab);
				addChild(tab);

				//add the divider
				var divider:Bitmap = UIFactory.getBitmap("TabDivider");
				divider.height = tab.height;
				divider.x = tab.width;
				tab.addChild(divider);
				layoutTabs();
			}
		}

		public function getTab( name:String ):BitmapButton
		{
			if (_tabLookup.hasOwnProperty(name))
				return _tabLookup[name];
			return null;
		}

		public function setSelectedTab( name:String ):void
		{
			if (_tabLookup.hasOwnProperty(name))
				onTabClicked(null, _tabLookup[name]);
		}

		public function removeTab( name:String ):void
		{
			if (_tabLookup.hasOwnProperty(name))
			{
				var tab:BitmapButton = _tabLookup[name];
				tab.removeEventListener(MouseEvent.CLICK, onTabClicked);
				UIFactory.destroyButton(tab);
				delete _tabLookup[name];
				delete _tabLookup[tab];
				var index:int        = _tabs.indexOf(tab);
				if (index != -1)
					_tabs.splice(index, 1);
				removeChild(tab);
				layoutTabs();
			}
		}

		public function addSwitchTabListener( listener:Function ):void  { _switchTabSignal.add(listener); }
		public function removeSwitchTabListener( listener:Function ):void  { _switchTabSignal.remove(listener); }

		private function onTabClicked( e:MouseEvent = null, target:BitmapButton = null ):void
		{
			var tab:BitmapButton = e ? BitmapButton(e.currentTarget) : target;
			if (_tabLookup[tab])
			{
				for (var i:int = 0; i < _tabs.length; i++)
					_tabs[i].selected = _tabs[i] == tab;
				_switchTabSignal.dispatch(_tabLookup[tab]);
			}
			if (e)
				e.stopPropagation();
		}

		private function layoutTabs():void
		{
			if (_automaticLayoutHorizontal || _automaticLayoutVertical)
			{
				var pos:Number = 0;
				for (var i:int = 0; i < _tabs.length; i++)
				{
					if (_automaticLayoutHorizontal)
					{
						_tabs[i].x = pos;
						pos += _tabs[i].width;
					} else
					{
						_tabs[i].y = pos;
						pos += _tabs[i].height;
					}
				}

			}
		}

		override public function set width( value:Number ):void
		{
			if (_panel)
			{
				var bg:DisplayObject = _panel.getChildAt(0);
				if (bg)
					bg.width = value;
			}
		}

		override public function set height( value:Number ):void
		{
			if (_panel)
			{
				var bg:DisplayObject = _panel.getChildAt(0);
				if (bg)
					bg.height = value;
			}
		}

		public function get panelBG():DisplayObject
		{
			if (_panel)
			{
				var bg:DisplayObject = _panel.getChildAt(0);
				if (bg)
					return bg;
			}
			return null;
		}

		public function set automaticLayoutHorizontal( v:Boolean ):void  { _automaticLayoutHorizontal = v; _automaticLayoutVertical = false; layoutTabs(); }
		public function set automaticLayoutVertical( v:Boolean ):void  { _automaticLayoutVertical = v; _automaticLayoutHorizontal = false; layoutTabs(); }

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  {}

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			_automaticLayoutHorizontal = false;
			_automaticLayoutVertical = false;
			_panel = UIFactory.destroyPanel(_panel);
			_switchTabSignal.removeAll();
			_tabLookup = null;
			for (var name:String in _tabLookup)
				removeTab(name);
			_tabs.length = 0;
		}
	}
}

