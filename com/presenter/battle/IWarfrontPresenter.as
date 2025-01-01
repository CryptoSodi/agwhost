package com.presenter.battle
{
	import com.model.warfrontModel.WarfrontVO;
	import com.presenter.IImperiumPresenter;

	public interface IWarfrontPresenter extends IImperiumPresenter
	{
		function watchBattle( battle:WarfrontVO ):void;

		function loadPortraitSmall( portraitName:String, callback:Function ):void;

		function addUpdateListener( listener:Function ):void;
		function removeUpdateListener( listener:Function ):void;

		function get battles():Vector.<WarfrontVO>;
	}
}
