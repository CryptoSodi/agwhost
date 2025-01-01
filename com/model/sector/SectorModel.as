package com.model.sector
{
	import com.model.Model;
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;
	import com.service.server.incoming.data.SectorData;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class SectorModel extends Model
	{
		public var focusLocation:Point              = new Point();
		public var targetSector:String;
		public var viewBase:Boolean                 = false;

		private var _focusFleetID:String; //used when going to a new sector to specify which fleet to focus on when the player gets there

		private var _destinations:Vector.<SectorVO>;
		private var _privateDestinations:Vector.<SectorVO>;
		private var sectorIDToSector:Dictionary;
		private var _sectorChangeSignal:Signal;
		private var _selectedFleetIDChanged:Signal;
		private var _sector:SectorVO                = new SectorVO();

		private var _igaContextMenuDefaultIndex:int = -1;
		private var _tyrContextMenuDefaultIndex:int = -1;
		private var _sovContextMenuDefaultIndex:int = -1;
		private var _csContextMenuDefaultIndex:int = -1;


		[PostConstruct]
		public function init():void
		{
			_sectorChangeSignal = new Signal(String);
			_selectedFleetIDChanged = new Signal();
			sectorIDToSector = new Dictionary();
		}

		public function updateSector( sector:SectorData ):void
		{
			_sector.importData(sector);
			_sectorChangeSignal.dispatch(sector.id);
		}

		public function addDestinations( sectors:Vector.<SectorData> ):void
		{
			sectorIDToSector = new Dictionary();
			//clear up any old destination
			if (_destinations != null)
			{
				for (var i:int = 0; i < _destinations.length; i++)
					ObjectPool.give(_destinations[i]);
				_destinations.length = 0;
			} else
				_destinations = new Vector.<SectorVO>;

			//add the new destinations
			var sector:SectorVO;
			for (i = 0; i < sectors.length; i++)
			{
				sector = ObjectPool.get(SectorVO);
				sector.importData(sectors[i]);
				sectorIDToSector[sector.id] = sector;
				_destinations.push(sector);
			}
		}
		
		public function addPrivateDestinations( sectors:Vector.<SectorData> ):void
		{
			sectorIDToSector = new Dictionary();
			//clear up any old destination
			if (_privateDestinations != null)
			{
				for (var i:int = 0; i < _privateDestinations.length; i++)
					ObjectPool.give(_privateDestinations[i]);
				_privateDestinations.length = 0;
			} else
				_privateDestinations = new Vector.<SectorVO>;
			
			//add the new destinations
			var sector:SectorVO;
			for (i = 0; i < sectors.length; i++)
			{
				sector = ObjectPool.get(SectorVO);
				sector.importData(sectors[i]);
				sectorIDToSector[sector.id] = sector;
				_privateDestinations.push(sector);
			}
		}

		public function addSectorChangeListener( listener:Function ):void  { _sectorChangeSignal.add(listener); }
		public function removeSectorChangeListener( listener:Function ):void  { _sectorChangeSignal.remove(listener); }

		public function addSelectedFleetIDChangedListener( listener:Function ):void  { _selectedFleetIDChanged.add(listener); }
		public function removeSelectedFleetIDChangedListener( listener:Function ):void  { _selectedFleetIDChanged.remove(listener); }

		public function get currentSectorVO():SectorVO  { return _sector; }
		public function get appearanceSeed():int  { return _sector.appearanceSeed; }
		public function get depotAsset():String  { return _sector.depotAsset; }
		public function get destinations():Vector.<SectorVO>  { return _destinations; }
		public function get privateDestinations():Vector.<SectorVO>  { return _privateDestinations; }
		public function get height():Number  { return 400; }
		public function get neighborhood():int  { return _sector.neighborhood; }
		public function get numBackgroundSprites():int  { return _sector.numBackgroundSprites; }
		public function get numPlanetSprites():int  { return _sector.numPlanetSprites; }
		public function get outpostAsset():String  { return _sector.outpostAsset; }
		public function get sectorEnum():String  { return _sector.sectorEnum; }
		public function get sectorFaction():String  { return _sector.sectorFaction; }
		public function get sectorID():String  { return _sector.id; }
		public function get sectorName():String  { return _sector.sectorName; }
		public function get sectorPrototype():IPrototype  { return _sector.sectorPrototype; }
		public function get starbaseAsset():String  { return _sector.starbaseAsset; }
		public function get starbaseShieldAsset():String  { return _sector.starbaseShieldAsset; }
		public function get transgateAsset():String  { return _sector.transgateAsset; }
		public function get width():Number  { return 500; }

		public function set focusFleetID( v:String ):void
		{
			_focusFleetID = v;
			_selectedFleetIDChanged.dispatch();
		}

		public function get focusFleetID():String  { return _focusFleetID; }

		public function getSectorNameFromID( sectorID:String ):String
		{
			if (sectorID in sectorIDToSector)
			{
				var sector:SectorVO           = sectorIDToSector[sectorID];
				var localization:Localization = Localization.instance;
				return localization.getString(sector.sectorName) + ' ' + localization.getString(sector.sectorEnum);
			}

			return '';
		}

		public function get igaContextMenuDefaultIndex():int  { return _igaContextMenuDefaultIndex; }
		public function set igaContextMenuDefaultIndex( v:int ):void  { _igaContextMenuDefaultIndex = v; }

		public function get tyrContextMenuDefaultIndex():int  { return _tyrContextMenuDefaultIndex; }
		public function set tyrContextMenuDefaultIndex( v:int ):void  { _tyrContextMenuDefaultIndex = v; }

		public function get sovContextMenuDefaultIndex():int  { return _sovContextMenuDefaultIndex; }
		public function set sovContextMenuDefaultIndex( v:int ):void  { _sovContextMenuDefaultIndex = v; }
		
		public function get csContextMenuDefaultIndex():int  { return _csContextMenuDefaultIndex; }
		public function set csContextMenuDefaultIndex( v:int ):void  { _csContextMenuDefaultIndex = v; }

	}
}
