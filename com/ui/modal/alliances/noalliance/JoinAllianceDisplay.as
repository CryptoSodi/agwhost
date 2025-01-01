package com.ui.modal.alliances.noalliance
{
	import com.Application;
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.server.AllianceResponseEnum;
	import com.model.alliance.AllianceVO;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	public class JoinAllianceDisplay extends Sprite
	{
		public var joinAllianceClick:Function;
		public var viewAllianceClick:Function;

		private var _title:Label;
		private var _search:Label;

		private var _alliancesBG:Bitmap;
		private var _searchBG:Bitmap;

		private var _searchBtn:BitmapButton;

		private var _allianceHolder:Sprite;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _alliances:Vector.<AllianceEntry>;
		private var _visibleAlliances:Vector.<AllianceEntry>;

		private var _stage:Stage;
		private var _keyboard:KeyboardController;

		private var _searchAlliances:String = 'CodeString.Shared.SearchAlliances'; //Search Alliances....
		private var _publicAlliances:String = 'CodeString.JoinAlliance.PublicAlliances'; //PUBLIC ALLIANCES

		public function JoinAllianceDisplay()
		{
			super();

			_stage = Application.STAGE;

			_alliances = new Vector.<AllianceEntry>;
			_visibleAlliances = new Vector.<AllianceEntry>;

			_searchBG = PanelFactory.getPanel('AllianceMemberSearchBMD');
			_searchBG.x = 273;
			_searchBG.y = 24;

			_title = new Label(20, 0xf0f0f0, 150, 25);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 3;
			_title.y = 45;
			_title.text = _publicAlliances;

			_alliancesBG = PanelFactory.getPanel('AllianceOpenBGBMD');
			_alliancesBG.x = 3;
			_alliancesBG.y = 70;

			_search = new Label(18, 0xf0f0f0, 184, 30, true);
			_search.align = TextFormatAlign.LEFT;
			_search.text = _searchAlliances;
			_search.x = _searchBG.x + 8;
			_search.y = _searchBG.y;
			_search.maxChars = 20;
			_search.allowInput = true;
			_search.clearOnFocusIn = true;
			_search.letterSpacing = .8;
			_search.addLabelColor(0xbdfefd, 0x000000);
			_search.addEventListener(Event.CHANGE, onChanged, false, 0, true);

			_searchBtn = ButtonFactory.getBitmapButton('AllianceSearchBtnUpBMD', _searchBG.x + 194, _searchBG.y + 3, '', 0, 'AllianceSearchBtnRollOverBMD');

			_allianceHolder = new Sprite();
			_allianceHolder.x = _alliancesBG.x;
			_allianceHolder.y = _alliancesBG.y;
			_maxHeight = 0;

			_scrollRect = new Rectangle(_allianceHolder.x, _allianceHolder.y, 497, 290);
			_scrollRect.y = 0;
			_allianceHolder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _alliancesBG.x + _alliancesBG.width;
			var scrollbarYPos:Number    = _alliancesBG.y;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _allianceHolder);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 29;

			addChild(_title);
			addChild(_alliancesBG);
			addChild(_allianceHolder);
			addChild(_scrollbar);
			addChild(_searchBG);
			addChild(_search);
			addChild(_searchBtn);
		}

		public function handleAllianceMessage( messageEnum:int ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.JOIN_FAILED_TOOMANYPLAYERS:
					enableJoining(true);
					break;
			}
		}

		public function enableJoining( v:Boolean ):void
		{
			var len:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _alliances[i];
				if (currentEntry)
					currentEntry.enabled = v;

			}
		}

		public function onAlliancesUpdated( v:Dictionary ):void
		{
			var i:uint                 = 0;
			var currentEntryCount:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for each (var alliance:AllianceVO in v)
			{
				if (i < currentEntryCount)
				{
					currentEntry = _alliances[i];
					currentEntry.update(alliance);
				} else
				{
					currentEntry = new AllianceEntry(alliance, i + 1, AllianceEntry.TYPE_OPEN_ALLIANCE);
					currentEntry.onAcceptClick.add(onJoinAllianceClick);
					currentEntry.onViewClick.add(onViewAllianceClick);
					_alliances.push(currentEntry);
				}
				_allianceHolder.addChild(currentEntry);
				++i;
			}
			onChanged();
			layout();
		}

		private function onJoinAllianceClick( allianceKey:String ):void
		{

			if (joinAllianceClick != null)
			{
				enableJoining(false);
				joinAllianceClick(allianceKey);
			}
		}

		private function onViewAllianceClick( allianceKey:String ):void
		{
			if (viewAllianceClick != null)
				viewAllianceClick(allianceKey);
		}



		private function layout():void
		{
			var len:uint = _visibleAlliances.length;
			var selection:AllianceEntry;
			var yPos:int = 0;
			var xPos:int = _allianceHolder.x;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _visibleAlliances[i];
				selection.x = xPos;
				selection.y = yPos;
				_maxHeight += selection.height - 1;
				yPos += selection.height - 1;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);
		}


		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_allianceHolder.scrollRect = _scrollRect;
		}		
		
		private function memberSortingFunction(entryA:AllianceEntry, entryB:AllianceEntry):Number 
		{
			if (entryA.memberCount.valueOf() > entryB.memberCount.valueOf())
			{
				return -1;
			}
			else if (entryA.memberCount.valueOf() < entryB.memberCount.valueOf())
			{
				return 1;
			}
			else 
			{
				return 0;
			}
		}
			
		private function filterAlliances( filterBy:String ):void
		{
			if (_allianceHolder.numChildren > 0)
				_allianceHolder.removeChildren(0, (_allianceHolder.numChildren - 1));

			_visibleAlliances.length = 0;

			var len:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _alliances[i];
				if (filterBy == '' || filterBy == _search.inputMessage.toLowerCase() || currentEntry.filterBy.indexOf(filterBy) != -1)
				{
					_allianceHolder.addChild(currentEntry);
					_visibleAlliances.push(currentEntry);
				}
			}

			//sort alliances by member count
			_visibleAlliances.sort(memberSortingFunction);

			layout();
			_scrollbar.resetScroll();
		}

		private function onChanged( e:Event = null ):void
		{
			filterAlliances(_search.text.toLowerCase());
		}

		private function onEnterPress( keyCode:uint ):void
		{
			if (_stage.focus == _search)
			{
				filterAlliances(_search.text.toLowerCase());
				addEventListener(Event.ENTER_FRAME, removeFocus, false, 0, true);
			}
		}

		private function removeFocus( e:Event ):void
		{
			removeEventListener(Event.ENTER_FRAME, removeFocus);
			if (_stage)
				_stage.focus = Application.STAGE;
		}

		[Inject]
		public function set keyboard( value:KeyboardController ):void
		{
			_keyboard = value;
			_keyboard.addKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);
		}


		public function destroy():void
		{
			_alliancesBG = null;
			_searchBG = null;
			_allianceHolder = null;
			_scrollRect = null;
			_stage = null;
			joinAllianceClick = null;
			viewAllianceClick = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_search)
				_search.destroy();

			_search = null;

			if (_searchBtn)
				_searchBtn.destroy();

			_searchBtn = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			_visibleAlliances.length = 0;

			var len:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _alliances[i];
				currentEntry.destroy();
				currentEntry = null;
			}
			_alliances.length = 0;

			if (_keyboard)
				_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			_keyboard = null;
		}
	}
}
