package com.ui.hud.sector.bookmarks
{
	import com.enum.ui.ButtonEnum;
	import com.model.player.BookmarkVO;
	import com.model.player.CurrentUser;
	import com.presenter.shared.IBookmarkPresenter;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.label.Label;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class BookmarksView extends View
	{
		private var _bg:DefaultWindowBG;
		private var _totalBookmarks:Label;

		private var _bookmarkEntries:Vector.<BookmarkEntry>;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;

		private var _stage:Stage;

		private var MAX_BOOKMARKS:uint                    = 35;

		private var _titleText:String                     = 'CodeString.Bookmarks.Title'; //Bookmarks
		private var _outOfString:String                   = 'CodeString.Shared.OutOf'; //[[Number.MinValue]]/[[Number.MaxValue]]

		private var _totalBookmarkText:String             = 'CodeString.Bookmarks.TotalBookmarks'; //Total Bookmarks: [[Number.MinValue]]/[[Number.MaxValue]]
		private var _deleteBookmarkNoBtnText:String       = 'CodeString.Bookmarks.AddBookmark.NoBtn'; //NO
		private var _deleteBookmarkRemoveBtnText:String   = 'CodeString.Bookmarks.AddBookmark.Remove'; //REMOVE
		private var _deleteBookmarkRemoveTitleText:String = 'CodeString.Bookmarks.AddBookmark.Title'; //DELETE BOOKMARK
		private var _deleteBookmarkRemoveBodyText:String  = 'CodeString.Bookmarks.AddBookmark.Body'; //Are you sure you want to remove this bookmark?

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_bookmarkEntries = new Vector.<BookmarkEntry>;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(563, 245);
			_bg.addTitle(_titleText, 114);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_totalBookmarks = new Label(16, 0xf0f0f0, 572, 25);
			_totalBookmarks.align = TextFormatAlign.CENTER;
			_totalBookmarks.y = 260;

			_holder = new Sprite();
			_holder.x = 25;
			_holder.y = 53;
			_maxHeight = 0;

			_scrollRect = new Rectangle(_holder.x, _holder.y, 522, 197);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bg.x + _bg.width - 28;
			var scrollbarYPos:Number    = _bg.y + 52;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 7;

			addChild(_bg);
			addChild(_holder);
			addChild(_scrollbar);
			addChild(_totalBookmarks);

			setUp(CurrentUser.bookmarks);

			addEffects();
			effectsIN();
		}

		private function setUp( v:Vector.<BookmarkVO> ):void
		{
			var len:uint = v.length;
			var currentEntry:BookmarkEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = new BookmarkEntry(v[i]);
				currentEntry.stage = _stage;
				currentEntry.selectedFleet(presenter.hasSelectedFleet());
				currentEntry.gotoCoordsClicked.add(onGotoCoordsClicked);
				currentEntry.fleetGotoCoords.add(onFleetGotoCoordsClicked);
				currentEntry.changedBookmarkName.add(onChangedBookmarkName);
				currentEntry.deleteBookmark.add(onDeleteBookmark);
				presenter.injectObject(currentEntry);
				_holder.addChild(currentEntry);
				_bookmarkEntries.push(currentEntry);
			}
			layout();
		}

		protected function layout():void
		{
			var len:uint = _bookmarkEntries.length;
			var selection:BookmarkEntry;
			var yPos:int = 0;
			var xPos:int = _holder.x;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _bookmarkEntries[i];
				selection.x = xPos;
				selection.y = yPos;
				_maxHeight += selection.height - 1;
				yPos += selection.height - 1;
			}
			_maxHeight += 1
			_scrollbar.updateScrollableHeight(_maxHeight);
			_totalBookmarks.setTextWithTokens(_totalBookmarkText, {'[[Number.MinValue]]':len, '[[Number.MaxValue]]':MAX_BOOKMARKS});

			if (_maxHeight <= _scrollRect.height)
				_scrollbar.resetScroll();
			else
				onChangedScroll(_scrollbar.percent);

		}

		private function onGotoCoordsClicked( v:BookmarkVO ):void
		{
			presenter.gotoCoords(v.x, v.y, v.sector);
			destroy();
		}

		private function onFleetGotoCoordsClicked( v:BookmarkVO ):void
		{
			presenter.fleetGotoCoords(v.x, v.y, v.sector);
			destroy();
		}

		private function onChangedBookmarkName( v:BookmarkVO ):void
		{
			presenter.updateBookmark(v);
		}

		private function onDeleteBookmark( v:uint ):void
		{
			var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
			buttons.push(new ButtonPrototype(_deleteBookmarkRemoveBtnText, deleteBookmark, [v], true, ButtonEnum.GREEN_A));
			buttons.push(new ButtonPrototype(_deleteBookmarkNoBtnText));
			showConfirmation(_deleteBookmarkRemoveTitleText, _deleteBookmarkRemoveBodyText, buttons);
		}

		private function deleteBookmark( v:uint ):void
		{
			var len:uint = _bookmarkEntries.length;
			var selection:BookmarkEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _bookmarkEntries[i];
				if (selection.index == v)
				{
					_holder.removeChild(selection);
					_bookmarkEntries.splice(i, 1);
					selection.destroy();
					selection = null;
					presenter.deleteBookmark(v);
					layout();
					break;
				}
			}
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IBookmarkPresenter ):void  { _presenter = v; }
		public function get presenter():IBookmarkPresenter  { return IBookmarkPresenter(_presenter); }

		[Inject]
		public function set stage( value:Stage ):void  { _stage = value; }

		override public function destroy():void
		{
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_totalBookmarks)
				_totalBookmarks.destroy();

			_totalBookmarks = null;

			var len:uint = _bookmarkEntries.length;
			var currentEntry:BookmarkEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentEntry = _bookmarkEntries[i];
				currentEntry.destroy();
				currentEntry = null;
			}
			_bookmarkEntries.length = 0;

			_scrollbar = null;
			_maxHeight = 0;

			_scrollRect = null;

			_holder = null;
		}
	}
}
