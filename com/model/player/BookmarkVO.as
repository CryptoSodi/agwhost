package com.model.player
{
	import com.model.prototype.IPrototype;

	public class BookmarkVO
	{
		private var _name:String;
		private var _sector:String;
		private var _sectorPrototype:IPrototype;
		private var _sectorNamePrototype:IPrototype;
		private var _sectorEnumPrototype:IPrototype;
		private var _x:int;
		private var _y:int;
		private var _index:int;

		public function BookmarkVO( name:String, sector:String, sectorPrototype:IPrototype, sectorNamePrototype:IPrototype, sectorEnumPrototype:IPrototype, x:int, y:int, index:uint )
		{
			_name = name;
			_sector = sector;
			_sectorPrototype = sectorPrototype;
			_sectorNamePrototype = sectorNamePrototype;
			_sectorEnumPrototype = sectorEnumPrototype;
			_x = x;
			_y = y;
			_index = index;
		}

		public function get name():String  { return _name; }
		public function set name( v:String ):void  { _name = v; }
		public function get sector():String  { return _sector; }
		public function get sectorName():String  { return (_sectorNamePrototype != null) ? _sectorNamePrototype.getValue('nameString') : '' }
		public function get sectorEnum():String  { return (_sectorEnumPrototype != null) ? _sectorEnumPrototype.getValue('nameString') : '' }
		public function get sectorPrototype():IPrototype  { return _sectorPrototype; }
		public function get sectorNamePrototype():IPrototype  { return _sectorNamePrototype; }
		public function get sectorEnumPrototype():IPrototype  { return _sectorEnumPrototype; }
		public function get x():int  { return _x; }
		public function get y():int  { return _y; }
		public function get displayX():String  { return String(int(_x * 0.01)); }
		public function get displayY():String  { return String(int(_y * 0.01)); }
		public function get index():int  { return _index; }
	}
}
