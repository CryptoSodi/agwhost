package com.presenter.shared
{
	import com.controller.GameController;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.leaderboards.LeaderboardModel;
	import com.model.leaderboards.LeaderboardVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.presenter.ImperiumPresenter;

	public class LeaderboardPresenter extends ImperiumPresenter implements ILeaderboardPresenter
	{
		private var _gameController:GameController;
		private var _leaderboardModel:LeaderboardModel;
		private var _prototypeModel:PrototypeModel;
		private var _sectorModel:SectorModel;
		private var _assetModel:AssetModel;

		public function getLeaderboardData():LeaderboardVO
		{
			var currentEntry:LeaderboardVO = _leaderboardModel.getLeaderboardData;

			if (currentEntry == null || (currentEntry && currentEntry.needsUpdate()))
				_gameController.leaderboardRequest(_leaderboardModel.lastRequestedType, _leaderboardModel.lastLeaderboardScope);

			return currentEntry;
		}

		public function getLeaderboardDataByType( type:int, scope:int ):LeaderboardVO
		{
			var currentEntry:LeaderboardVO = _leaderboardModel.getLeaderboardDataByType(type, scope);

			if (currentEntry == null || (currentEntry && currentEntry.needsUpdate()))
				_gameController.leaderboardRequest(type, scope);

			return currentEntry;
		}

		public function requestPlayer( id:String, name:String = '' ):void
		{
			_gameController.leaderboardRequestPlayerProfile(id, name);
		}

		public function getFactionPrototypesByName( name:String ):IPrototype
		{
			return _prototypeModel.getFactionPrototypeByName(name);
		}

		public function getRacePrototypeByName( name:String ):IPrototype
		{
			return _prototypeModel.getRacePrototypeByName(name);
		}

		public function getCommendationRankPrototypesByName( name:String ):IPrototype
		{
			return _prototypeModel.getCommendationRankPrototypesByName(name);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function getAssetVO( assetName:String ):AssetVO
		{
			return _assetModel.getEntityData(assetName);
		}

		public function getSectorName( sectorID:String ):String
		{
			return _sectorModel.getSectorNameFromID(sectorID);
		}

		public function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function addOnLeaderboardDataUpdatedListener( callback:Function ):void  { _leaderboardModel.onLeaderboardDataUpdated.add(callback); }
		public function removeOnLeaderboardDataUpdatedListener( callback:Function ):void  { _leaderboardModel.onLeaderboardDataUpdated.remove(callback); }

		public function set currentLeaderboardType( v:int ):void  { _leaderboardModel.lastRequestedType = v; }

		public function get currentLeaderboardType():int  { return _leaderboardModel.lastRequestedType; }

		public function set currentLeaderboardScope( v:int ):void  { _leaderboardModel.lastLeaderboardScope = v; }

		public function get currentLeaderboardScope():int  { return _leaderboardModel.lastLeaderboardScope; }

		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }

		[Inject]
		public function set leaderboardModel( v:LeaderboardModel ):void  { _leaderboardModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }

	}
}
