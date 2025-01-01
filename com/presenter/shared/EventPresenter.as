package com.presenter.shared
{
	import com.controller.GameController;
	import com.model.achievements.AchievementModel;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.event.EventModel;
	import com.model.event.EventVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.presenter.ImperiumPresenter;

	public class EventPresenter extends ImperiumPresenter implements IEventPresenter
	{
		private var _eventModel:EventModel;
		private var _achievementModel:AchievementModel;
		private var _assetModel:AssetModel;
		private var _prototypeModel:PrototypeModel;
		private var _gameController:GameController;

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function getResearchItemPrototypeByName( v:String ):IPrototype
		{
			var researchProto:IPrototype = _prototypeModel.getResearchPrototypeByName(v);
			var refName:String;

			if (researchProto)
				refName = researchProto.getValue("referenceName");
			else
				refName = v;

			var iproto:IPrototype        = _prototypeModel.getShipPrototype(refName);
			if (!iproto)
				iproto = _prototypeModel.getWeaponPrototype(refName);
			return iproto;

			return null;
		}

		public function getAssetVO( prototype:IPrototype ):AssetVO
		{
			var assetName:String = prototype.uiAsset;
			if (!assetName)
				assetName = prototype.asset;
			return _assetModel.getEntityData(assetName);
		}

		public function getScoreValueByName( v:String ):uint
		{
			return _achievementModel.getScoreValueByName(v);
		}

		public function requestAchievements():void
		{
			_gameController.requestAchievements();
		}
		
		public function requestAllScores():void
		{
			_gameController.requestAllScores();
		}

		public function addEventUpdatedListener( callback:Function ):void  { _eventModel.onEventsUpdated.add(callback); }
		public function removeEventUpdatedListener( callback:Function ):void  { _eventModel.onEventsUpdated.remove(callback); }

		public function onAddAchievementsUpdatedListener( Listener:Function ):void  { _achievementModel.onAchievementsUpdated.add(Listener); }
		public function onRemoveAchievementsUpdatedListener( Listener:Function ):void  { _achievementModel.onAchievementsUpdated.remove(Listener); }
		
		public function onAddAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.add(Listener); }
		public function onRemoveAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.remove(Listener); }

		public function get currentActiveEvent():EventVO  { return _eventModel.currentActiveEvent; }
		public function get activeEvents():Vector.<EventVO>  { return _eventModel.activeEvents; }
		public function get upcomingEvents():Vector.<EventVO>  { return _eventModel.upcomingEvents; }

		[Inject]
		public function set eventModel( v:EventModel ):void  { _eventModel = v; }

		[Inject]
		public function set achievementModel( v:AchievementModel ):void  { _achievementModel = v; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }

		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }

	}
}
