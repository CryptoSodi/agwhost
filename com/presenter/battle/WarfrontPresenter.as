package com.presenter.battle
{
	import com.event.BattleEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.sector.SectorModel;
	import com.model.warfrontModel.WarfrontModel;
	import com.model.warfrontModel.WarfrontVO;
	import com.presenter.ImperiumPresenter;

	public class WarfrontPresenter extends ImperiumPresenter implements IWarfrontPresenter
	{
		private var _assetModel:AssetModel;
		private var _sectorModel:SectorModel;
		private var _warfrontModel:WarfrontModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function watchBattle( battle:WarfrontVO ):void
		{
			var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, battle.battleServerAddress);
			dispatch(battleEvent);
		}

		public function loadPortraitSmall( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(AssetModel.instance.getFromCache(portraitName));
			_assetModel.getFromCache('assets/' + avatarVO.smallImage, callback);
		}

		public function addUpdateListener( listener:Function ):void  { _warfrontModel.addUpdateListener(listener); }
		public function removeUpdateListener( listener:Function ):void  { _warfrontModel.removeUpdateListener(listener); }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		public function get battles():Vector.<WarfrontVO>  { return _warfrontModel.battles; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set warfrontModel( v:WarfrontModel ):void  { _warfrontModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_assetModel = null;
			_sectorModel = null;
			_warfrontModel = null;
		}
	}
}
