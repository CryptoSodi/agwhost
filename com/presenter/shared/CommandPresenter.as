package com.presenter.shared
{
	import com.Application;
	import com.event.BattleEvent;
	import com.event.SectorEvent;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Position;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.sector.SectorModel;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;

	import org.ash.core.Entity;
	import org.ash.core.Game;

	public class CommandPresenter extends ImperiumPresenter implements ICommandPresenter
	{
		private var _assetModel:AssetModel;
		private var _fleetModel:FleetModel;
		private var _game:Game;
		private var _sectorModel:SectorModel;
		private var _starbaseModel:StarbaseModel;
		private var _system:SectorInteractSystem;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_system = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
		}

		public function selectFleet( fleetID:String, gotoLocation:Boolean = true, canEnterBattle:Boolean = true ):Boolean
		{
			var fleetVO:FleetVO = getFleetVO(fleetID);
			var sectorEvent:SectorEvent;
			if (fleetVO)
			{
				_sectorModel.focusFleetID = fleetVO.id;
				if (!_fteController.running && fleetVO.inBattle && canEnterBattle)
				{
					var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, fleetVO.battleServerAddress);
					dispatch(battleEvent);
				} else if (fleetVO.sector != '')
				{
					var entity:Entity = _game.getEntity(fleetID);
					if (_system != null && entity != null && fleetVO.sector == _sectorModel.sectorID)
					{
						_system.selectEntity(entity, gotoLocation);
					} else
					{
						if ((fleetVO.sector != _sectorModel.sectorID || Application.STATE == StateEvent.GAME_STARBASE) && gotoLocation)
						{
							sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, fleetVO.sector, fleetID);
							dispatch(sectorEvent);
						}
					}
					return true;
				}
			}
			return false;
		}

		public function getEntity( fleetID:String ):Entity
		{
			return _game.getEntity(fleetID);
		}

		public function jumpToLocation( x:Number, y:Number ):void
		{
			if (_system != null)
				_system.jumpToLocation(x, y);
		}

		public function getFleetVO( id:String ):FleetVO
		{
			return _fleetModel.getFleet(id);
		}

		public function loadIconImageFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			if(!_currentAssetVO)
				return;
			var icon:String             = _currentAssetVO.iconImage;
			loadIcon(icon, callback);
		}

		public function loadSmallImageFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			if(!_currentAssetVO)
				return;
			var icon:String             = _currentAssetVO.smallImage;
			loadIcon(icon, callback);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		override protected function onStateChange( e:StateEvent ):void
		{
			switch (e.type)
			{
				case StateEvent.GAME_SECTOR:
					_system = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
					break;
				case StateEvent.GAME_SECTOR_CLEANUP:
					_system = null;
					break;
			}
			super.onStateChange(e);
		}

		public function getBuildingVOByClass( itemClass:String, highestLevel:Boolean = false ):BuildingVO  { return _starbaseModel.getBuildingByClass(itemClass, highestLevel); }

		public function addListenerForFleetUpdate( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.add(listener); }
		public function removeListenerForFleetUpdate( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.remove(listener); }

		public function addSelectionChangeListener( listener:Function ):void  { if (_system != null) _system.onSelectionChangeSignal.add(listener); }
		public function removeSelectionChangeListener( listener:Function ):void  { if (_system != null) _system.onSelectionChangeSignal.remove(listener); }

		public function get sectorID():String  { return _sectorModel.sectorID; }
		public function get focusFleetID():String  { return _sectorModel.focusFleetID; }
		public function get fleets():Vector.<FleetVO>  { return _fleetModel.fleets; }
		public function get currentBase():BaseVO  { return _starbaseModel.currentBase; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_assetModel = null;
			_fleetModel = null;
			_game = null;
			_sectorModel = null;
			_starbaseModel = null;
			_system = null;
		}
	}
}
