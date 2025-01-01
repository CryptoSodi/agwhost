package com.ui.modal.ignore
{
	import com.model.player.PlayerVO;
	import com.presenter.shared.IChatPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class IgnoreListView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;

		private var _title:String = 'CodeString.IgnoreList.Title'; //IGNORE LIST

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(335, 235);
			_bg.addTitle(_title, 114);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_holder = new Sprite();
			_holder.x = 26;
			_holder.y = 60;

			_scrollRect = new Rectangle(_holder.x, _holder.y, 300, 200);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _bg.width - 24;
			var scrollbarYPos:Number    = 61;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 34;

			addChild(_bg);
			addChild(_holder);
			addChild(_scrollbar);

			presenter.addOnPlayerVOAddedListener(addPlayer);

			setUp();
			addEffects();
			effectsIN();
		}

		private function setUp():void
		{
			var blockedUsers:Vector.<String> = presenter.blockedUsers;
			for (var i:uint = 0; i < blockedUsers.length; ++i)
			{
				presenter.requestPlayer(blockedUsers[i]);
			}
		}

		private function addPlayer( v:PlayerVO ):void
		{
			var entry:IgnoreEntry = new IgnoreEntry(v);
			entry.onUnignoreClicked.add(removePlayer);
			_holder.addChild(entry);

			layout();
		}

		private function removePlayer( v:IgnoreEntry ):void
		{
			if (v)
			{
				presenter.blockOrUnblockPlayer(v.playerID);
				_holder.removeChild(v);
				v.destroy();
				v = null;

				layout();
			}
		}

		private function layout():void
		{
			var entry:IgnoreEntry;
			var yPos:int = 0;
			var xPos:int = _holder.x;
			var len:uint = _holder.numChildren;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				entry = IgnoreEntry(_holder.getChildAt(i));
				entry.x = xPos;
				entry.y = yPos;

				yPos += entry.height + 4;

				if (i == (len - 1))
					_maxHeight += entry.height;
				else
					_maxHeight += entry.height + 4;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);

			if (_maxHeight <= _scrollRect.height)
				_scrollbar.resetScroll();
			else
				onChangedScroll(_scrollbar.percent);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		override public function get width():Number  { return _bg.width }
		override public function get height():Number  { return _bg.width }

		[Inject]
		public function set presenter( v:IChatPresenter ):void  { _presenter = v; }
		public function get presenter():IChatPresenter  { return IChatPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnPlayerVOAddedListener(addPlayer);
			super.destroy();
			_bg = null;
		}
	}
}
