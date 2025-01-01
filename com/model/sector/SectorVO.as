package com.model.sector
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.SectorData;

	public class SectorVO
	{
		private var _appearanceSeed:int;
		private var _depotAsset:String;
		private var _id:String;
		private var _neighborhood:int;
		private var _numBackgroundSprites:int;
		private var _numPlanetSprites:int;
		private var _outpostAsset:String;
		private var _sectorEnum:IPrototype;
		private var _sectorFaction:String;
		private var _sectorName:IPrototype;
		private var _sectorPrototype:IPrototype;
		private var _starbaseAsset:String;
		private var _starbaseShieldAsset:String;
		private var _transgateAsset:String;
		private var _splitTestCohortPrototype:IPrototype;

		public function importData( sector:SectorData ):void
		{
			_appearanceSeed = sector.appearanceSeed;
			_id = sector.id;
			_neighborhood = sector.neighborhood;
			_sectorEnum = sector.sectorEnum;
			_sectorName = sector.sectorName;
			_sectorPrototype = sector.prototype;
			_splitTestCohortPrototype = sector.splitTestCohortPrototype;

			//_depotAsset = _sectorPrototype.getValue("depotAsset");
			//_numBackgroundSprites = _sectorPrototype.getValue("numBackgrounds");
			//_numPlanetSprites = _sectorPrototype.getValue("numPlanets");
			//_outpostAsset = _sectorPrototype.getValue("outpostAsset");
			//_sectorFaction = _sectorPrototype.getValue("factionPrototype");
			//_starbaseAsset = _sectorPrototype.getValue("baseAsset");
			//_starbaseShieldAsset = _sectorPrototype.getValue("shieldAsset");
			//_transgateAsset = _sectorPrototype.getValue("transgateAsset");
		}

		public function get appearanceSeed():int  { return _appearanceSeed; }
		public function get depotAsset():String  { return _depotAsset; }
		public function get height():Number  { return _sectorPrototype.getValue("height"); }
		public function get id():String  { return _id; }
		public function get neighborhood():int  { return _neighborhood; }
		public function get numBackgroundSprites():int  { return _numBackgroundSprites; }
		public function get numPlanetSprites():int  { return _numPlanetSprites; }
		public function get outpostAsset():String  { return _outpostAsset; }
		public function get sectorEnum():String  { return 'nameString'; }
		public function get sectorEnumPrototype():IPrototype { return _sectorEnum; }
		public function get splitTestCohortPrototype():IPrototype { return _splitTestCohortPrototype; }
		public function get sectorFaction():String  { return _sectorFaction; }
		public function get sectorName():String  { return 'nameString'; }
		public function get sectorNamePrototype():IPrototype { return _sectorName; }
		public function get sectorPrototype():IPrototype  { return _sectorPrototype; }
		public function get starbaseAsset():String  { return _starbaseAsset; }
		public function get starbaseShieldAsset():String  { return _starbaseShieldAsset; }
		public function get transgateAsset():String  { return _transgateAsset; }
		public function get width():Number  { return _sectorPrototype.getValue("width"); }

		public function destroy():void
		{
			_sectorEnum = null;
			_sectorName = null;
			_sectorPrototype = null;
		}
	}
}
