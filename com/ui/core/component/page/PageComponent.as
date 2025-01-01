package com.ui.core.component.page
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	import org.greensock.TweenLite;
	import org.shared.ObjectPool;

	/**
	 *  @author Phillip Reagan
	 */
	public class PageComponent extends Sprite
	{
		private static const PAGE_SPACING:int  = 15;
		private static const FLIP_RIGHT:String = "flipRight";
		private static const FLIP_LEFT:String  = "flipLeft";

		//set these before calling init
		public var iconWidth:int               = 0;
		public var iconHeight:int              = 0;
		public var iconSpacing:int             = 0;
		public var iconVertSpacing:int         = 0;
		public var iconsPerPage:int            = 0;
		public var iconsPerRow:int             = 0;
		public var iconClass:Class;

		private var _page1:Page;
		private var _page2:Page;
		private var _visiblePage:Page;
		private var _scrollRect:Rectangle;
		private var _animating:Boolean         = false;
		private var _data:*;
		private var _pageIndex:int;
		private var _nextMove:String;

		public function init():void
		{
			_page1 = ObjectPool.get(Page);
			_page1.init(this, iconClass);
			_page2 = ObjectPool.get(Page);
			_page2.init(this, iconClass);
			_page2.x = _page1.width + PAGE_SPACING;
			_visiblePage = _page1;

			addChild(_page1);
			addChild(_page2);

			_scrollRect = new Rectangle(0, 0, _page1.width, _page1.height);
			scrollRect = _scrollRect;
		}

		public function format( icon_width:int,
								icon_height:int,
								icon_spacing:int,
								icon_VertSpacing:int,
								icons_PerPage:int,
								icons_PerRow:int,
								icon_class:Class ):void
		{
			iconWidth = icon_width;
			iconHeight = icon_height;
			iconSpacing = icon_spacing;
			iconVertSpacing = icon_VertSpacing;
			iconsPerPage = icons_PerPage;
			iconsPerRow = icons_PerRow;
			iconClass = icon_class;
		}

		//got new data so reset and show it starting from the supplied pageIndex
		public function update( data:*, pageIndex:int = 0 ):void
		{
			try
			{
				var test:int = data.length;
			} catch ( e:Error )
			{
				return;
			}

			_data = data;
			_pageIndex = pageIndex;
			TweenLite.killTweensOf(_page1);
			TweenLite.killTweensOf(_page2);
			_page1.x = 0;
			_page2.x = _page1.width + PAGE_SPACING;
			_visiblePage = _page1;
			_animating = false;
			flipToPage(_pageIndex);
		}

		public function flipToPage( pageIndex:int ):void
		{
			if (_pageIndex == pageIndex)
				_visiblePage.update(_data, _pageIndex);
			else
			{
				var goRight:Boolean = _pageIndex < pageIndex;
				_pageIndex = pageIndex
				if (goRight)
					flipRight();
				else
					flipLeft();
			}
		}

		public function gotoItem( item:* ):*
		{
			if (_data.length)
			{
				for (var i:int = 0; i < _data.length; i++)
				{
					if (_data[i] == item)
					{
						var pageIndex:int = Math.floor(i / iconsPerPage);
						var iconIndex:int = i - (pageIndex * iconsPerPage);
						flipToPage(pageIndex);
						return _visiblePage.icons[iconIndex];
					}
				}
			}
			return null;
		}

		private function flipRight():void
		{
			if (_animating)
				_nextMove = FLIP_RIGHT;
			else
			{
				var targetPage:Page = (_visiblePage == _page1) ? _page2 : _page1;
				if (targetPage.x < _visiblePage.x)
					targetPage.x = _visiblePage.width + PAGE_SPACING;
				targetPage.update(_data, _pageIndex);
				TweenLite.to(_visiblePage, .7, {x:-targetPage.x});
				TweenLite.to(targetPage, .7, {x:0, onComplete:animationComplete});
				_visiblePage = targetPage;
				_animating = true;
			}
		}

		private function flipLeft():void
		{
			if (_animating)
				_nextMove = FLIP_LEFT;
			else
			{
				var targetPage:Page = (_visiblePage == _page1) ? _page2 : _page1;
				if (targetPage.x > _visiblePage.x)
					targetPage.x = -targetPage.x;
				targetPage.update(_data, _pageIndex);
				TweenLite.to(_visiblePage, .7, {x:_visiblePage.width + PAGE_SPACING});
				TweenLite.to(targetPage, .7, {x:0, onComplete:animationComplete});
				_visiblePage = targetPage;
				_animating = true;
			}
		}

		private function animationComplete():void
		{
			_animating = false;
			if (_nextMove)
			{
				if (_nextMove == FLIP_RIGHT)
					flipRight();
				else
					flipLeft();
				_nextMove = null;
			}
		}

		public function get page1():Page  { return _page1; }
		public function get page2():Page  { return _page2; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			TweenLite.killTweensOf(_page1);
			TweenLite.killTweensOf(_page2);

			ObjectPool.give(_page1);
			ObjectPool.give(_page2);

			_page1 = null;
			_page2 = null;
			_visiblePage = null;
			_scrollRect = null;
			_data = null;
		}
	}
}
