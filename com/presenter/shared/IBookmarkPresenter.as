package com.presenter.shared
{
	import com.model.player.BookmarkVO;
	import com.presenter.IImperiumPresenter;

	public interface IBookmarkPresenter extends IImperiumPresenter
	{
		function gotoCoords( x:int, y:int, sector:String ):void;
		function fleetGotoCoords( x:int, y:int, sector:String ):void
		function deleteBookmark( index:uint ):void;
		function updateBookmark( bookmark:BookmarkVO ):void;
		function hasSelectedFleet():Boolean;
	}
}
