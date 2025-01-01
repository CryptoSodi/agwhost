package com.model.starbase
{
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.game.entity.factory.IStarbaseFactory;

	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.ash.core.Game;

	public class StarbaseGrid
	{
		public static const ALL_CLEAR:int                 = 0;
		public static const GRID_OCCUPIED:int             = 1;

		public static const PLAY_SPACE_WIDTH:int          = 5000;
		public static const PLAY_SPACE_NOBUILD_WIDTH:int  = 540;
		public static const PLAY_SPACE_HEIGHT:int         = 5000;
		public static const PLAY_SPACE_NOBUILD_HEIGHT:int = 540;

		private const OPEN_SPACE:int                      = 0;
		private const PLATFORM:int                        = 1;
		private const BUILDING:int                        = 2;
		private const WALL:int                            = 3;

		private const GRID_SIZE:Number                    = 18;
		private const CELL_SIZE_SMALL_HALF:int            = GRID_SIZE * .5;
		private const CELL_SIZE:int                       = 90; //90 is size of a single platform

		private var COLUMNS_SMALL:int;
		private var CONVERSION_SMALL:Number;
		private var COLUMNS:int;
		private var CONVERSION:Number;
		private var REAL_SIZE:int;

		private const REAL_OFFSET:Point                   = new Point();
		private const ISO_SCALE:Number                    = 0.5;
		private const ISO_ROTATION:Number                 = 45 * 0.0174532925;
		private const PIVOT:Point                         = new Point();

		private var _columnSpan:Point;
		private var _position:Point;
		private var _rect:Rectangle;
		private var _rowSpan:Point;
		private var _space:Dictionary;
		private var _testSpan:Point;

		public function StarbaseGrid()
		{
			_space = new Dictionary();
			_columnSpan = new Point();
			_position = new Point();
			_rect = new Rectangle();
			_rowSpan = new Point();
			_testSpan = new Point();

			CONVERSION = 1 / CELL_SIZE;
			CONVERSION_SMALL = 1 / GRID_SIZE;

			initIso(PLAY_SPACE_WIDTH, PLAY_SPACE_HEIGHT);
			COLUMNS_SMALL = Math.ceil(REAL_SIZE / GRID_SIZE);
			COLUMNS = Math.ceil(REAL_SIZE / CELL_SIZE);

			placeBase();
		}

		public function addToGrid( vo:BuildingVO, ignoreChecks:Boolean = false ):int
		{
			var target:int = (vo.constructionCategory == StarbaseConstructionEnum.PLATFORM || vo.itemClass == TypeEnum.PYLON) ? OPEN_SPACE : PLATFORM;
			var result:int = ALL_CLEAR;
			if (ignoreChecks)
				addOrRemoveFromGrid(vo, target, false, false, ignoreChecks);
			else
			{
				result = confirmAddToGrid(vo);
				if (result == ALL_CLEAR)
					addOrRemoveFromGrid(vo, target, false, false);
			}
			return result;
		}

		public function showGrid( game:Game, factory:IStarbaseFactory ):void
		{
			var p:Point = new Point();
			for (var i:int = 0; i < COLUMNS_SMALL; i += 5)
			{
				for (var j:int = 0; j < COLUMNS_SMALL; j += 5)
				{
					p.setTo(i, j);
					convertGridToIso(p);
					factory.createGridSquare(TypeEnum.ISO_1x1_SOVEREIGNTY, p.x, p.y);
				}
			}
		}

		public function confirmAddToGrid( vo:BuildingVO ):int
		{
			var target:int = (vo.constructionCategory == StarbaseConstructionEnum.PLATFORM || vo.itemClass == TypeEnum.PYLON) ? OPEN_SPACE : PLATFORM;
			return addOrRemoveFromGrid(vo, target, true);
		}

		public function removeFromGrid( vo:BuildingVO ):void
		{
			addOrRemoveFromGrid(vo, (vo.constructionCategory == StarbaseConstructionEnum.PLATFORM || vo.itemClass == TypeEnum.PYLON) ? OPEN_SPACE : PLATFORM, false, true);
		}

		public function snapToGrid( position:Point, vo:BuildingVO, snapToSmallCells:Boolean = true ):void
		{
			if (!snapToSmallCells)
			{
				convertPointFromIsometric(position);
				getKey(getHash(position.x, position.y), position);
				//center on the grid position if an odd size
				if (vo.sizeX % 10 != 0)
					position.x += 45;
				if (vo.sizeY % 10 != 0)
					position.y += 45;
				convertPointToIsometric(position);
				convertBuildingIsoToGrid(position, vo);
			} else
			{
				convertPointFromIsometric(position);
				getSmallKey(getSmallHash(position.x, position.y), position);
				//center on the grid position if an odd size
				if (vo.sizeX % 10 != 0)
				{
					position.x += CELL_SIZE_SMALL_HALF;
					position.y += CELL_SIZE_SMALL_HALF;
				}
				convertPointToIsometric(position);
				convertBuildingIsoToGrid(position, vo);
			}
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

		public function getSmallHash( keyX:Number, keyY:Number ):int
		{
			return (keyX * CONVERSION_SMALL | 0) + (keyY * CONVERSION_SMALL | 0) * COLUMNS_SMALL;
		}

		public function getSmallKey( hash:int, point:Point ):void
		{
			point.x = (hash % COLUMNS_SMALL) * GRID_SIZE;
			point.y = (hash / COLUMNS_SMALL | 0) * GRID_SIZE;
		}

		//We only want the player to move a platform if a building is not sitting on top of it
		//and if moving it won't create a narrow channel
		public function canMovePlatform( vo:BuildingVO ):Boolean
		{
			//check for buildings
			_position.setTo(vo.baseX * GRID_SIZE, vo.baseY * GRID_SIZE);
			var hashTL:int = getSmallHash(_position.x, _position.y);
			var hashBR:int = getSmallHash(_position.x + ((vo.sizeX - 1) * GRID_SIZE), _position.y + ((vo.sizeY - 1) * GRID_SIZE));
			var len:int    = hashBR % COLUMNS_SMALL;
			var i:int      = hashTL;
			while (i <= hashBR)
			{
				if (_space[i] == BUILDING)
					return false;
				if (i % COLUMNS_SMALL == len)
				{
					hashTL += COLUMNS_SMALL;
					i = hashTL;
				} else
					i++;
			}

			return true;
		}

		private function addOrRemoveFromGrid( vo:BuildingVO, target:int, checking:Boolean = false, remove:Boolean = false, ignoreChecks:Boolean = false ):int
		{
			//check within buildable bounds
			convertBuildingGridToIso(_position, vo);
			if (_position.x < PLAY_SPACE_NOBUILD_WIDTH || _position.x > (PLAY_SPACE_WIDTH - PLAY_SPACE_NOBUILD_WIDTH)
				|| _position.y < PLAY_SPACE_NOBUILD_HEIGHT || _position.y > (PLAY_SPACE_HEIGHT - PLAY_SPACE_NOBUILD_HEIGHT))
				return GRID_OCCUPIED;

			_position.setTo(vo.baseX * GRID_SIZE, vo.baseY * GRID_SIZE);
			var hashTL:int = getSmallHash(_position.x, _position.y);
			var hashBR:int = getSmallHash(_position.x + ((vo.sizeX - 1) * GRID_SIZE), _position.y + ((vo.sizeY - 1) * GRID_SIZE));
			var len:int    = hashBR % COLUMNS_SMALL;
			var i:int      = hashTL;
			var fill:int   = (remove) ? target : (vo.itemClass == TypeEnum.PYLON) ? 3 : target + 1;
			while (i <= hashBR)
			{
				if (remove)
				{
					if (_space[i])
					{
						_space[i] = fill;
					}
				} else if (_space[i] == target || (_space[i] == null && target == OPEN_SPACE))
				{
					if (!checking)
					{
						_space[i] = fill;
					}
				} else if (!checking && ignoreChecks && (_space[i] == null || _space[i] < fill))
					_space[i] = fill;
				else if (!ignoreChecks)
					return GRID_OCCUPIED;
				if (i % COLUMNS_SMALL == len)
				{
					hashTL += COLUMNS_SMALL;
					i = hashTL;
				} else
					i++;
			}

			return ALL_CLEAR;
		}

		private function placeBase():void
		{
			//add the no build area
			buildGrid(197690, 242450, BUILDING); //201420, 238720, 2);
			//243196;325

			//add the buildable space for buildings
			buildGrid(205150, 238720, PLATFORM);

			//add back the open space around the starbase since it is an odd shape
			buildGrid(208865, 234204, OPEN_SPACE);
			buildGrid(197705, 204444, OPEN_SPACE);
			buildGrid(208920, 234259, OPEN_SPACE);
			buildGrid(238680, 245419, OPEN_SPACE);
		}

		private function buildGrid( hashTL:int, hashBR:int, value:int ):void
		{
			var len:int = hashBR % COLUMNS_SMALL;
			var i:int   = hashTL;
			while (i <= hashBR)
			{
				_space[i] = value;
				if (i % COLUMNS_SMALL == len)
				{
					hashTL += COLUMNS_SMALL;
					i = hashTL;
				} else
					i++;
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//												ISO Conversions 
		//************************************************************************************************************
		//============================================================================================================

		//determine the size of the square that we would need to fill the visible view area in iso
		public function initIso( width:int, height:int ):void
		{
			PIVOT.setTo(width / 2, height / 2);
			var p:Point = new Point(0, 0);
			convertPointFromIsometric(p);
			REAL_OFFSET.setTo(Math.abs(p.x), Math.abs(p.x));
			p.setTo(width, height);
			convertPointFromIsometric(p);
			REAL_SIZE = p.x + REAL_OFFSET.x;
		}

		//Converts the passed grid-based point to an isometric point.
		public function convertPointToIsometric( point:Point ):void
		{
			var p:Point = point.subtract(REAL_OFFSET)

			p = p.subtract(PIVOT);

			//Do the actual rotation with the point.
			rotate(p, Math.cos(ISO_ROTATION), Math.sin(ISO_ROTATION));

			//Scale the Y position so it looks like it's squished into the distance.
			p.y *= ISO_SCALE;

			//Now we want to go back to the top left corner (we don't want to start from the pivot).
			p = p.add(PIVOT);

			point.setTo(p.x, p.y);
		}

		//Converts the passed isometric point to a grid-based point.
		//This is literally exactly the same except everything is done in reverse order and opposite operations.
		public function convertPointFromIsometric( point:Point ):void
		{
			//Go from the corner to the pivot.
			var p:Point = point.subtract(PIVOT);

			//Unscale the Y position so it's back to grid proportions.
			p.y /= ISO_SCALE;

			//Do the actual rotation with the point.
			rotate(p, Math.cos(ISO_ROTATION), -Math.sin(ISO_ROTATION));

			//Now that we're back to normal, un-apply the pivot.
			p = p.add(PIVOT);

			p = p.add(REAL_OFFSET);

			point.setTo(p.x, p.y);
		}

		public function convertIsoToGrid( point:Point ):void
		{
			convertPointFromIsometric(point);
			point.x = (point.x / GRID_SIZE) | 0;
			point.y = (point.y / GRID_SIZE) | 0;
		}

		public function convertGridToIso( point:Point ):void
		{
			point.x = point.x * GRID_SIZE;
			point.y = point.y * GRID_SIZE;
			convertPointToIsometric(point);
		}

		public function convertBuildingGridToIso( point:Point, vo:BuildingVO ):void
		{
			if (vo.prototype)
			{
				if (vo.itemClass == TypeEnum.FORCEFIELD)
				{
					point.x = (vo.baseX + 5 * .5);
					point.y = (vo.baseY + 5 * .5);
				} else
				{
					point.x = (vo.baseX + vo.sizeX * .5);
					point.y = (vo.baseY + vo.sizeY * .5);
				}
				convertGridToIso(point);
			}
		}

		public function convertBuildingIsoToGrid( point:Point, vo:BuildingVO ):void
		{
			if (vo.prototype)
			{
				var p:Point = new Point(point.x, point.y);
				convertPointFromIsometric(p);
				//building is centered... get the top left corner of the building base
				p.x -= vo.sizeX * .49 * GRID_SIZE;
				p.y -= vo.sizeY * .49 * GRID_SIZE;
				convertPointToIsometric(p);
				convertIsoToGrid(p);
				vo.baseX = p.x;
				vo.baseY = p.y;
			}
		}

		private function rotate( point:Point, cosine:Number, sine:Number ):void
		{
			var newX:Number = point.x * cosine - point.y * sine;
			var newY:Number = point.x * sine + point.y * cosine;

			point.x = newX;
			point.y = newY;
		}

		public function destroy():void
		{
			_space = null;
			_columnSpan = null;
			_rowSpan = null;
			_testSpan = null;
		}
	}
}
