package com.presenter.shared
{
	import com.controller.GameController;
	import com.model.achievements.AchievementModel;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BaseVO;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;

	public class AchievementPresenter extends ImperiumPresenter implements IAchievementPresenter
	{
		private var _assetModel:AssetModel;
		private var _prototypeModel:PrototypeModel;
		private var _achievementModel:AchievementModel;
		private var _starbaseModel:StarbaseModel;
		private var _gameController:GameController;
		
		public function getAchievementPrototypes():Vector.<IPrototype>
		{
			return _prototypeModel.getAchievementPrototypes();
		}

		public function getFilterAchievementPrototypes():Vector.<IPrototype>
		{
			return _prototypeModel.getFilterAchievementPrototypes();
		}
		
		public function getScoreValueByName( v:String ):uint
		{
			return _achievementModel.getScoreValueByName(v);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function requestAchievements():void
		{
			_gameController.requestAchievements();
		}
		
		public function requestAllScores():void
		{
			_gameController.requestAllScores();
		}

		public function claimAchievementReward( achievement:String ):void
		{
			_gameController.claimAchievementReward(achievement);
		}

		public function maxCredits():int
		{
			var currentBase:BaseVO = _starbaseModel.currentBase;
			if (currentBase)
				return currentBase.maxCredits;

			return 0;
		}

		public function onAddAchievementsUpdatedListener( Listener:Function ):void  { _achievementModel.onAchievementsUpdated.add(Listener); }
		public function onRemoveAchievementsUpdatedListener( Listener:Function ):void  { _achievementModel.onAchievementsUpdated.remove(Listener); }
		
		public function onAddAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.add(Listener); }
		public function onRemoveAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.remove(Listener); }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set achievementModel( v:AchievementModel ):void  { _achievementModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }
	}
}
