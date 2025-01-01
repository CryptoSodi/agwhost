// This is an actionscript port of the JSI Library.
// Credit goes to the original developers
// http://jsi.sourceforge.net/
package com.util.rtree
{

	/**
	 * <p>The RRectangle is the data type used in our rTree. RRectangles can be inserted and searched for efficiently.</p>
	 * This is an actionscript port of the JSI Library. Credit goes to the original developers.
	 * @see http://en.wikipedia.org/wiki/Rtree
	 * @see http://jsi.sourceforge.net/
	 *
	 */
	public class RRectangle
	{

		/**
		 * Number of dimensions in a RRectangle. In theory this
		 * could be exended to three or more dimensions.
		 */
		public static const DIMENSIONS:int = 2;

		/**
		 * Array containing the maximum value for each dimension; ie { max(x), max(y) }
		 * @private
		 */
		public var max:Array;

		/**
		 * Array containing the minimum value for each dimension; ie { min(x), min(y) }
		 * @private
		 */
		public var min:Array;

		/**
		 * Constructor.
		 *
		 * @param x1 coordinate of any corner of the RRectangle
		 * @param y1 (see x1)
		 * @param x2 coordinate of the opposite corner
		 * @param y2 (see x2)
		 */
		public function RRectangle( x1:Number, y1:Number, x2:Number, y2:Number ):void
		{
			this.min = new Array(RRectangle.DIMENSIONS)
			this.max = new Array(RRectangle.DIMENSIONS)
			setValues(x1, y1, x2, y2)
		}


		/**
		 * Sets the size of the RRectangle.
		 *
		 * @param x1 coordinate of any corner of the RRectangle
		 * @param y1 (see x1)
		 * @param z1 (see x1)
		 * @param x2 coordinate of the opposite corner
		 * @param y2 (see x2)
		 * @param z2 (see x2)
		 * @private
		 */
		public function setValues( x1:Number, y1:Number, x2:Number, y2:Number ):void
		{
			this.min[0] = Math.min(x1, x2)
			this.min[1] = Math.min(y1, y2)
			this.max[0] = Math.max(x1, x2)
			this.max[1] = Math.max(y1, y2)
		}

		/**
		 * Sets the size of the RRectangle.
		 *
		 * @param min array containing the minimum value for each dimension; ie { min(x), min(y) }
		 * @param max array containing the maximum value for each dimension; ie { max(x), max(y) }
		 * @private
		 */
		public function setArrays( min:Array, max:Array ):void
		{
			for (var i:int = 0; i < min.length; i++)
				this.min[i] = min[i]
			for (i = 0; i < max.length; i++)
				this.max[i] = max[i]
		}

		/**
		 * Make a copy of this RRectangle
		 *
		 * @return copy of this RRectangle
		 */
		public function copy():RRectangle
		{
			return new RRectangle(this.min[0], this.min[1], this.max[0], this.max[1])
		}

		/**
		 * Determine whether an edge of this RRectangle overlies the equivalent
		 * edge of the passed RRectangle
		 * @private
		 */
		public function edgeOverlaps( r:RRectangle ):Boolean
		{
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (this.min[i] == r.min[i] || this.max[i] == r.max[i])
				{
					return true;
				}
			}
			return false;
		}

		/**
		 * Determine whether this RRectangle intersects the passed RRectangle
		 *
		 * @param r The RRectangle that might intersect this RRectangle
		 *
		 * @return true if the rectangles intersect, false if they do not intersect
		 */
		public function intersects( r:RRectangle ):Boolean
		{
			// Every dimension must intersect. If any dimension
			// does not intersect, return false immediately.
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (this.max[i] < r.min[i] || this.min[i] > r.max[i])
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Determine whether this RRectangle contains the passed RRectangle
		 *
		 * @param r The RRectangle that might be contained by this RRectangle
		 *
		 * @return true if this RRectangle contains the passed RRectangle, false if
		 *         it does not
		 */
		public function contains( r:RRectangle ):Boolean
		{
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (this.max[i] < r.max[i] || this.min[i] > r.min[i])
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Determine whether this RRectangle is contained by the passed RRectangle
		 *
		 * @param r The RRectangle that might contain this RRectangle
		 *
		 * @return true if the passed RRectangle contains this RRectangle, false if
		 *         it does not
		 */
		public function containedBy( r:RRectangle ):Boolean
		{
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (this.max[i] > r.max[i] || this.min[i] < r.min[i])
				{
					return false;
				}
			}
			return true;
		}

		/**
		 * Return the distance between this RRectangle and the passed point.
		 * If the RRectangle contains the point, the distance is zero.
		 *
		 * @param p Point to find the distance to, as an array of coordinates [x,y,z]
		 *
		 * @return distance beween this RRectangle and the passed point.
		 */
		public function distanceToPoint( p:Array ):Number
		{
			var distanceSquared:Number = 0;
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				var greatestMin:Number = Math.max(min[i], p[i])
				var leastMax:Number    = Math.min(max[i], p[i])
				if (greatestMin > leastMax)
				{
					distanceSquared += ((greatestMin - leastMax) * (greatestMin - leastMax))
				}
			}
			return Math.sqrt(distanceSquared)
		}

		/**
		 * Return the distance between this RRectangle and the passed RRectangle.
		 * If the rectangles overlap, the distance is zero.
		 *
		 * @param r fRRectangle to find the distance to
		 *
		 * @return distance between this RRectangle and the passed RRectangle
		 */
		public function distanceToRRectangle( r:RRectangle ):Number
		{
			var distanceSquared:Number = 0;
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				var greatestMin:Number = Math.max(min[i], r.min[i])
				var leastMax:Number    = Math.min(max[i], r.max[i])
				if (greatestMin > leastMax)
				{
					distanceSquared += ((greatestMin - leastMax) * (greatestMin - leastMax))
				}
			}
			return Math.sqrt(distanceSquared)
		}

		/**
		 * Return the squared distance from this RRectangle to the passed point
		 */
		private function getDistanceSquared( dimension:int, point:Number ):Number
		{
			var distanceSquared:Number = 0
			var tempDistance:Number    = point - max[dimension]
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (tempDistance > 0)
				{
					distanceSquared = (tempDistance * tempDistance)
					break;
				}
				tempDistance = min[dimension] - point
			}
			return distanceSquared
		}

		/**
		 * Return the furthest possible distance between this RRectangle and
		 * the passed RRectangle.
		 *
		 * Find the distance between this RRectangle and each corner of the
		 * passed RRectangle, and use the maximum.
		 * @private
		 *
		 */
		public function furthestDistance( r:RRectangle ):Number
		{
			var distanceSquared:Number = 0
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				distanceSquared += Math.max(this.getDistanceSquared(i, r.min[i]), this.getDistanceSquared(i, r.max[i]))
			}
			return Math.sqrt(distanceSquared)
		}

		/**
		 * Calculate the volume by which this RRectangle would be enlarged if
		 * added to the passed RRectangle. Neither RRectangle is altered.
		 *
		 * @param r fRRectangle to union with this RRectangle, in order to
		 *          compute the difference in volume of the union and the
		 *          original RRectangle
		 * @private
		 */
		public function enlargement( r:RRectangle ):Number
		{
			var enlargedArea:Number = 1
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				enlargedArea *= (Math.max(this.max[i], r.max[i]) - Math.min(this.min[i], r.min[i]))
			}
			return enlargedArea - this.volume()
		}

		/**
		 * Compute the volume of this RRectangle.
		 *
		 * @return The volume of this RRectangle
		 */
		public function volume():Number
		{
			var volume:Number = 1
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				volume *= (this.max[i] - this.min[i])
			}
			return volume
		}

		/**
		 * Computes the union of this RRectangle and the passed RRectangle, storing
		 * the result in this RRectangle.
		 *
		 * @param r RRectangle to add to this RRectangle
		 */
		public function add( r:RRectangle ):void
		{
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (r.min[i] < this.min[i])
				{
					this.min[i] = r.min[i]
				}
				if (r.max[i] > this.max[i])
				{
					this.max[i] = r.max[i]
				}
			}
		}

		/**
		 * Find the the union of this RRectangle and the passed RRectangle.
		 * Neither RRectangle is altered
		 *
		 * @param r The RRectangle to union with this RRectangle
		 */
		public function union( r:RRectangle ):RRectangle
		{
			var union:RRectangle = this.copy()
			union.add(r)
			return union
		}

		/**
		 * Determine whether this RRectangle is equal to a given object.
		 * Equality is determined by the bounds of the RRectangle.
		 *
		 * @param o The object to compare with this RRectangle
		 */
		public function equals( o:Object ):Boolean
		{

			if (o is RRectangle)
			{
				var r:RRectangle = o as RRectangle
				for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
				{
					if (r.min[i] != this.min[i] || r.max[i] != this.max[i])
						return false
				}
				return true
			} else
				return false

		}

		/**
		 * Return a string representation of this RRectangle, in the form:
		 * (1.2, 3.4), (5.6, 7.8)
		 *
		 * @return String String representation of this RRectangle.
		 */
		public function toString():String
		{

			var sb:String = ""

			// min coordinates
			sb += "("
			for (var i:int = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (i > 0)
				{
					sb += ", "
				}
				sb += this.min[i]
			}
			sb += "), ("

			// max coordinates
			for (i = 0; i < RRectangle.DIMENSIONS; i++)
			{
				if (i > 0)
				{
					sb += ", "
				}
				sb += this.max[i]
			}
			sb += ")"

			return sb

		}

	}

}
