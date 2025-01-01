package com.ui.modal.alliances.noalliance
{
	import com.enum.server.AllianceResponseEnum;
	import com.model.alliance.AllianceInviteVO;
	import com.model.alliance.AllianceVO;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;

	public class AllianceInvitesDisplay extends Sprite
	{
		private var _title:Label;

		private var _alliancesBG:Bitmap;

		private var _allianceHolder:Sprite;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _alliances:Vector.<AllianceEntry>;

		public var joinAllianceClick:Function;
		public var viewAllianceClick:Function;

		private var _pendingInvites:String = 'CodeString.Alliance.PendingInvites'; //Pending Invites

		public function AllianceInvitesDisplay()
		{
			super();

			_alliances = new Vector.<AllianceEntry>;

			_title = new Label(20, 0xf0f0f0, 150, 25);
			_title.align = TextFormatAlign.LEFT;
			_title.allCaps = true;
			_title.x = 3;
			_title.y = 45;
			_title.text = _pendingInvites;

			_alliancesBG = _alliancesBG = PanelFactory.getPanel('AllianceOpenBGBMD');
			_alliancesBG.x = 3;
			_alliancesBG.y = 70;

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
		
		public function onInvitesUpdated( v:Dictionary ):void
		{
			var i:uint                 = 0;
			var currentEntryCount:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for each (var invite:AllianceInviteVO in v)
			{
				if (i < currentEntryCount)
				{
					currentEntry = _alliances[i];
					currentEntry.update(invite.alliance);
				} else
				{
					currentEntry = new AllianceEntry(invite.alliance, i + 1, AllianceEntry.TYPE_OPEN_ALLIANCE);
					currentEntry.onAcceptClick.add(onJoinAllianceClick);
					currentEntry.onViewClick.add(onViewAllianceClick);
					_alliances.push(currentEntry);
				}
				_allianceHolder.addChild(currentEntry);
				++i;
			}
			
			//sort alliances by member count
			_alliances.sort(memberSortingFunction);
			
			layout();
		}

		private function layout():void
		{
			var len:uint = _alliances.length;
			var selection:AllianceEntry;
			var yPos:int = 0;
			var xPos:int = _allianceHolder.x;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _alliances[i];
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

		public function destroy():void
		{
			_alliancesBG = null;
			_allianceHolder = null;
			_scrollRect = null;
			joinAllianceClick = null;
			viewAllianceClick = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			var len:uint = _alliances.length;
			var currentEntry:AllianceEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _alliances[i];
				currentEntry.destroy();
				currentEntry = null;
			}
			_alliances.length = 0;
		}
	}
}
