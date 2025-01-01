package com.game.entity.systems.shared.grid
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class GridField
	{
		public var CELL_SIZE:int;
		public var COLUMNS:int;
		public var CONVERSION:Number;
		public var ROWS:int;

		private var _cells:Dictionary;
		private var _columnSpan:Point;
		private var _lookup:Dictionary;
		private var _rowSpan:Point;
		private var _testSpan:Point;

		public function GridField( cellSize:int, bounds:Rectangle )
		{
			_cells = new Dictionary();
			_columnSpan = new Point();
			_lookup = new Dictionary();
			_rowSpan = new Point();
			_testSpan = new Point();

			CELL_SIZE = cellSize;
			CONVERSION = 1 / CELL_SIZE;
			COLUMNS = Math.ceil(bounds.width / CELL_SIZE);
			ROWS = Math.ceil(bounds.height / CELL_SIZE);
		}

		public function addToCell( object:*, hash:int ):void
		{
			if (hash < 0)
				return;
			//create a new cell if needed
			if (!_cells.hasOwnProperty(hash))
				createCell(hash);
			//add the object to the cell
			_cells[hash].push(object);
			//add a lookup to the cells the object is in
			if (!_lookup[object])
				_lookup[object] = new Vector.<int>;
			_lookup[object].push(hash);
		}

		public function removeFromCell( object:*, hash:int ):void
		{
			//remove the object
			var index:int = _cells[hash].indexOf(object);
			if (index != -1)
			{
				_cells[hash].splice(index, 1);
				if (_cells[hash].length == 0)
				{
					_cells[hash] = null;
					delete _cells[hash];
				}
			}
			//remove the hash
			index = _lookup[object].indexOf(hash);
			if (index != -1)
			{
				_lookup[object].splice(index, 1);
			}
		}

		public function removeFromAllCells( object:* ):void
		{
			if (!_lookup[object])
				return;
			while (_lookup[object].length > 0)
			{
				removeFromCell(object, _lookup[object][0]);
			}
			_lookup[object] = null;
			delete _lookup[object];
		}

		public function getHash( keyX:Number, keyY:Number ):int
		{
			return (keyX * CONVERSION | 0) + (keyY * CONVERSION | 0) * COLUMNS;
		}

		public function getKey( hash:int, point:Point ):void
		{
			point.x = (hash % COLUMNS) * CELL_SIZE;
			point.y = (hash / COLUMNS | 0) * CELL_SIZE;
		}

		/**
		 * Returns the hash of a cell that is offset from a starting cell, respecting the bounds of the grid.
		 *
		 * @param hash 		The hash of the starting cell
		 * @param xOffset	The number of cells to offset in x. Positive & negative offsets are honored.
		 * @param yOffset	The number of cells to offset in y. Positive & negative offsets are honored.
		 * @return 			The hash of the cell that is offset from the starting cell, if within the grid bounds, or
		 * 					the cell at the edge of the grid bounds otherwise.
		 */
		public function getClampedCellByOffset( hash:int, xOffset:int, yOffset:int ):int
		{
			var result:int      = hash;
			result += xOffset;
			var leftClamp:int   = hash - hash % COLUMNS;
			var rightClamp:int  = leftClamp + COLUMNS - 1;
			if (result < leftClamp)
				result = leftClamp;
			if (result > rightClamp)
				result = rightClamp;

			var topClamp:int    = result % COLUMNS;
			var bottomClamp:int = (ROWS - 1) * COLUMNS + topClamp;
			result += (yOffset * COLUMNS);
			if (result < topClamp)
				result = topClamp;
			if (result > bottomClamp)
				result = bottomClamp;

			return result;
		}

		public function withinBounds( hash:int, boundMin:int, boundMax:int ):Boolean
		{
			_columnSpan.x = boundMin % COLUMNS;
			_columnSpan.y = boundMax % COLUMNS;
			_rowSpan.x = (boundMin / COLUMNS | 0);
			_rowSpan.y = (boundMax / COLUMNS | 0);
			_testSpan.x = hash % COLUMNS;
			_testSpan.y = (hash / COLUMNS | 0);
			if (_testSpan.x >= _columnSpan.x && _testSpan.x <= _columnSpan.y && _testSpan.y >= _rowSpan.x && _testSpan.y <= _rowSpan.y)
				return true;
			return false;
		}

		public function getHashesInRect( rect:Rectangle ):Array
		{
			var result:Array = [];
			var hashTL:int   = getHash(rect.left, rect.top);
			var hashTR:int   = getHash(rect.right, rect.top);
			var hashBR:int   = getHash(rect.right, rect.bottom);
			var x:int, y:int;
			while (hashTL + x + y <= hashBR)
			{
				for (; hashTL + x <= hashTR; ++x)
				{
					result.push(hashTL + x + y);
					trace("Quadrant cell: " + String(hashTL + x + y));
				}

				x = 0;
				y += ROWS;
			}

			return result;
		}

		public function getObjects( hash:int ):Array
		{
			if (_cells.hasOwnProperty(hash))
				return _cells[hash];
			return null;
		}

		private function createCell( hash:int ):void
		{
			if (hash < 0)
				return;
			if (_cells[hash])
				return;
			_cells[hash] = [];
		}

		private function removeCell( hash:int ):void
		{
			if (!_cells[hash])
				return;
			while (_cells[hash])
			{
				removeFromCell(_cells[hash][0], hash);
			}
			_cells[hash] = null;
			delete _cells[hash];
		}

		public function get cells():Dictionary  { return _cells; }

		public function get lookup():Dictionary  { return _lookup; }

		public function destroy():void
		{
			for (var i:* in _cells)
			{
				removeCell(i);
			}
			_cells = null;
			_columnSpan = null;
			_rowSpan = null;
			_testSpan = null;
			_lookup = null;
		}
	}
}
