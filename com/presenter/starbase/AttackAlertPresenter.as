package com.presenter.starbase
{
	import com.event.BattleEvent;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;

	import org.parade.core.ViewController;

	public class AttackAlertPresenter extends ImperiumPresenter implements IAttackAlertPresenter
	{
		private var _fleetModel:FleetModel;
		private var _sectorModel:SectorModel;
		private var _starbaseModel:StarbaseModel;
		private var _viewController:ViewController;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function joinBattle( battleServerAddress:String, fleetID:String = null ):void
		{
			if (!hasBattleEnded(battleServerAddress, fleetID))
			{
				if (fleetID)
					_sectorModel.focusFleetID = fleetID;
				var event:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, battleServerAddress);
				dispatch(event);
			}
		}

		public function removeAllAlerts( viewClass:Class ):void
		{
			_viewController.removeFromQueue(viewClass);
		}

		public function hasBattleEnded( battleServerAddress:String, fleetID:String = null ):Boolean
		{
			if (fleetID != null)
			{
				var fleetVO:FleetVO = _fleetModel.getFleet(fleetID);
				if (fleetVO && fleetVO.battleServerAddress == battleServerAddress)
					return false;
				else
					return true;
			}
			if (_starbaseModel.homeBase.battleServerAddress == battleServerAddress || _starbaseModel.homeBase.instancedMissionAddress == battleServerAddress || (_starbaseModel.centerSpaceBase && _starbaseModel.centerSpaceBase.battleServerAddress == battleServerAddress))
				return false;
			return true;
		}

		public function addFleetUpdateListener( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.add(listener); }
		public function removeFleetUpdateListener( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.remove(listener); }

		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set viewController( v:ViewController ):void  { _viewController = v; }

		override public function destroy():void
		{
			super.destroy();
			_fleetModel = null;
			_sectorModel = null;
			_starbaseModel = null;
			_viewController = null;
		}
	}
}
