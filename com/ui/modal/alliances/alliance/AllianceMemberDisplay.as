package com.ui.modal.alliances.alliance
{
	import com.Application;
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	import com.enum.server.AllianceResponseEnum;
	import com.model.alliance.AllianceMemberVO;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class AllianceMemberDisplay extends Sprite
	{
		private var _name:Label;
		private var _rank:Label;
		private var _level:Label;
		private var _actions:Label;
		private var _search:Label;

		private var _alliancesBG:Bitmap;
		private var _searchBG:Bitmap;

		private var _allianceHolder:Sprite;

		private var _searchBtn:BitmapButton;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _members:Vector.<AllianceMemberEntry>;
		private var _visibleMembers:Vector.<AllianceMemberEntry>;

		private var _allianceKey:String;

		private var _stage:Stage;
		private var _keyboard:KeyboardController;

		public var onPromoteMember:Function;
		public var onDemoteMember:Function;
		public var onRemoveMember:Function;
		public var onShowProfile:Function;

		private var _nameText:String   = 'CodeString.AllianceMemberDisplay.Name'; //NAME
		private var _rankText:String   = 'CodeString.AllianceMemberDisplay.Rank'; //RANK
		private var _levelText:String  = 'CodeString.AllianceMemberDisplay.Level'; //LEVEL
		private var _actionText:String = 'CodeString.AllianceMemberDisplay.Actions'; //ACTIONS
		private var _searchText:String = 'CodeString.AllianceMemberDisplay.Search'; //Search Members....

		public function AllianceMemberDisplay()
		{
			super();

			_stage = Application.STAGE;

			_visibleMembers = new Vector.<AllianceMemberEntry>;
			_members = new Vector.<AllianceMemberEntry>;

			_searchBG = PanelFactory.getPanel('AllianceMemberSearchBMD');
			_searchBG.x = 273;
			_searchBG.y = 24;

			_name = new Label(18, 0xfbefaf, 150, 25);
			_name.align = TextFormatAlign.LEFT;
			_name.x = 51;
			_name.y = 68;
			_name.text = _nameText;

			_rank = new Label(18, 0xfbefaf, 150, 25);
			_rank.align = TextFormatAlign.LEFT;
			_rank.x = 217;
			_rank.y = 68;
			_rank.text = _rankText;

			_level = new Label(18, 0xfbefaf, 150, 25);
			_level.align = TextFormatAlign.LEFT;
			_level.x = 337;
			_level.y = 68;
			_level.text = _levelText;

			_actions = new Label(18, 0xfbefaf, 150, 25);
			_actions.align = TextFormatAlign.LEFT;
			_actions.x = 391;
			_actions.y = 68;
			_actions.text = _actionText;

			_search = new Label(18, 0xf0f0f0, 184, 30);
			_search.align = TextFormatAlign.LEFT;
			_search.text = _searchText;
			_search.x = _searchBG.x + 8;
			_search.y = _searchBG.y;
			_search.maxChars = 20;
			_search.allowInput = true;
			_search.clearOnFocusIn = true;
			_search.letterSpacing = .8;
			_search.addLabelColor(0xbdfefd, 0x000000);
			_search.addEventListener(Event.CHANGE, onChanged, false, 0, true);

			_searchBtn = ButtonFactory.getBitmapButton('AllianceSearchBtnUpBMD', _searchBG.x + 194, _searchBG.y + 3, '', 0, 'AllianceSearchBtnRollOverBMD');

			_alliancesBG = PanelFactory.getPanel('AllianceMemberBGBMD');
			_alliancesBG.x = 36;
			_alliancesBG.y = 95;

			_allianceHolder = new Sprite();
			_allianceHolder.x = _alliancesBG.x;
			_allianceHolder.y = _alliancesBG.y;
			_maxHeight = 0;

			_scrollRect = new Rectangle(_allianceHolder.x, _allianceHolder.y, 460, 287);
			_scrollRect.y = 0;
			_allianceHolder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _alliancesBG.x + _alliancesBG.width + 5;
			var scrollbarYPos:Number    = _alliancesBG.y;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _allianceHolder);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 23;

			addChild(_name);
			addChild(_rank);
			addChild(_level);
			addChild(_actions);
			addChild(_alliancesBG);
			addChild(_allianceHolder);
			addChild(_searchBG);
			addChild(_search);
			addChild(_searchBtn);
			addChild(_scrollbar);
		}

		public function handleAllianceMessage( messageEnum:int ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.JOIN_FAILED_TOOMANYPLAYERS:
					break;
			}
		}

		private function filterMember( filterBy:String ):void
		{
			if (_allianceHolder.numChildren > 0)
				_allianceHolder.removeChildren(0, (_allianceHolder.numChildren - 1));

			_visibleMembers.length = 0;

			var len:uint = _members.length;
			var currentEntry:AllianceMemberEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _members[i];
				if (filterBy == '' || filterBy == _search.inputMessage.toLowerCase() || currentEntry.filterBy.indexOf(filterBy) != -1)
				{
					_allianceHolder.addChild(currentEntry);
					_visibleMembers.push(currentEntry);
				}
			}
			_visibleMembers.sort(memberSortingFunction);
			layout();
			_scrollbar.resetScroll();
		}

		private function memberSortingFunction(entryA:AllianceMemberEntry, entryB:AllianceMemberEntry):Number 
		{
			if (entryA.rank < entryB.rank) return 1;
			if (entryA.rank > entryB.rank) return -1;

			//same rank so let's check xp (implicitly level)
			if (entryA.xp > entryB.xp) return -1;
			if (entryA.xp < entryB.xp) return 1;
			
			return 0;
		}
		
		public function onMembersUpdated( v:Vector.<AllianceMemberVO> ):void
		{
			var len:uint               = v.length;
			var currentEntryCount:uint = _members.length;
			var currentEntry:AllianceMemberEntry;
			var i:uint                 = 0;
			for (; i < len; ++i)
			{
				if (i < currentEntryCount)
				{
					currentEntry = _members[i];
					currentEntry.update(v[i])
				} else
				{
					currentEntry = new AllianceMemberEntry(i + 1, v[i], _allianceKey);
					currentEntry.onShowProfile.add(onShowProfile);
					currentEntry.onPromoteMember.add(onPromoteMember);
					currentEntry.onDemoteMember.add(onDemoteMember);
					currentEntry.onRemoveMember.add(onRemoveMember);
					_members.push(currentEntry);
				}
				_allianceHolder.addChild(currentEntry);

			}

			if (i < currentEntryCount)
			{
				var startIndex:uint = i;
				for (; i < currentEntryCount; ++i)
				{
					currentEntry = _members[i];
					currentEntry.destroy();
					currentEntry = null;
				}
				_members.splice(startIndex, i - startIndex);
			}

			onChanged();
			layout();
		}

		private function layout():void
		{
			var len:uint = _visibleMembers.length;
			var selection:AllianceMemberEntry;
			var yPos:int = 0;
			var xPos:int = _allianceHolder.x;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _visibleMembers[i];
				selection.x = xPos;
				selection.y = yPos;
				_maxHeight += selection.height - 1;
				yPos += selection.height - 1;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChanged( e:Event = null ):void
		{
			filterMember(_search.text.toLowerCase());
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_allianceHolder.scrollRect = _scrollRect;
		}

		[Inject]
		public function set keyboard( value:KeyboardController ):void
		{
			_keyboard = value;
			_keyboard.addKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);
		}

		private function onEnterPress( keyCode:uint ):void
		{
			if (_stage.focus == _search)
			{
				filterMember(_search.text.toLowerCase());
				addEventListener(Event.ENTER_FRAME, removeFocus, false, 0, true);
			}
		}

		private function removeFocus( e:Event ):void
		{
			removeEventListener(Event.ENTER_FRAME, removeFocus);
			if (_stage)
				_stage.focus = Application.STAGE;
		}

		public function set allianceKey( v:String ):void
		{
			_allianceKey = v;
		}

		public function destroy():void
		{
			_alliancesBG = null;
			_searchBG = null;
			_allianceHolder = null;
			_scrollRect = null;

			onPromoteMember = null;
			onDemoteMember = null;
			onRemoveMember = null;

			if (_name)
				_name.destroy();

			_name = null;

			if (_rank)
				_rank.destroy();

			_rank = null;

			if (_level)
				_level.destroy();

			_level = null;

			if (_actions)
				_actions.destroy();

			_actions = null;

			if (_search)
				_search.destroy();

			_search = null;

			if (_searchBtn)
				_searchBtn.destroy();

			_searchBtn = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			_visibleMembers.length = 0;
			var len:uint = _members.length;
			var currentEntry:AllianceMemberEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _members[i];
				currentEntry.destroy();
				currentEntry = null;
			}
			_members.length = 0;

			_allianceKey = '';

			_stage = null;

			if (_keyboard)
				_keyboard.removeKeyUpListener(onEnterPress, KeyboardKey.ENTER.keyCode);

			_keyboard = null;
		}
	}
}
