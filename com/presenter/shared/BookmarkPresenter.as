package com.presenter.shared
{
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.enum.server.OrderEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.SectorEvent;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.player.BookmarkVO;
	import com.model.player.CurrentUser;
	import com.model.sector.SectorModel;
	import com.presenter.ImperiumPresenter;
	import com.service.server.outgoing.sector.SectorOrderRequest;

	import org.ash.core.Game;

	public class BookmarkPresenter extends ImperiumPresenter implements IBookmarkPresenter
	{
		private var _game:Game;
		private var _sectorModel:SectorModel;
		private var _fleetModel:FleetModel;
		private var _gameController:GameController;
		private var _serverController:ServerController;
		private var _system:SectorInteractSystem;

		public function deleteBookmark( index:uint ):void
		{
			CurrentUser.removeBookmark(index);
			_gameController.bookmarkDelete(index);
		}

		public function updateBookmark( bookmark:BookmarkVO ):void
		{
			_gameController.bookmarkUpdate(bookmark);
		}

		public function fleetGotoCoords( x:int, y:int, sector:String ):void
		{
			if (_sectorModel.focusFleetID != null && _sectorModel.focusFleetID != '')
			{
				var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
				order.entityId = _sectorModel.focusFleetID;
				order.orderType = OrderEnum.REMOTE_MOVE;
				order.destinationSector = sector;
				order.targetLocationX = x;
				order.targetLocationY = y;
				_serverController.send(order);
			}
		}

		public function hasSelectedFleet():Boolean
		{
			var hasASelectedFleet:Boolean;

			if (_sectorModel.focusFleetID != null && _sectorModel.focusFleetID != '')
			{
				var fleet:FleetVO = _fleetModel.getFleet(_sectorModel.focusFleetID);
				if (fleet && fleet.sector != '')
					hasASelectedFleet = true;
			}

			return hasASelectedFleet;
		}

		public function gotoCoords( x:int, y:int, sector:String ):void
		{

			if (sector != _sectorModel.sectorID)
			{
				jumpToSector(x, y, sector);
			} else
			{
				var system:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
				if (system != null)
					system.moveToLocation(x, y);
				else
				{
					jumpToSector(x, y, sector);
				}
			}

		}

		private function jumpToSector( x:int, y:int, sector:String ):void
		{
			var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sector, null, x, y);
			dispatch(sectorEvent);
		}

		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
