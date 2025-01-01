package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.leaderboards.LeaderboardVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;

	public interface ILeaderboardPresenter extends IImperiumPresenter
	{
		function getLeaderboardData():LeaderboardVO;

		function getLeaderboardDataByType( type:int, scope:int ):LeaderboardVO;
		function requestPlayer( id:String, name:String = '' ):void;
		function addOnLeaderboardDataUpdatedListener( callback:Function ):void;
		function removeOnLeaderboardDataUpdatedListener( callback:Function ):void;
		function getFactionPrototypesByName( name:String ):IPrototype
		function getRacePrototypeByName( name:String ):IPrototype;
		function getCommendationRankPrototypesByName( name:String ):IPrototype;
		function loadIcon( url:String, callback:Function ):void;
		function getAssetVO( assetName:String ):AssetVO;
		function getSectorName( sectorID:String ):String;
		function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO;

		function set currentLeaderboardType( v:int ):void;
		function get currentLeaderboardType():int;

		function set currentLeaderboardScope( v:int ):void;
		function get currentLeaderboardScope():int;

	}
}
