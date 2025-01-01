// This is an actionscript port of the JSI Library.
// Credit goes to the original developers
// http://jsi.sourceforge.net/
package com.util.rtree
{

	/**
	 * This is an actionscript port of the JSI Library. Credit goes to the original developers.
	 * @see http://jsi.sourceforge.net/
	 *
	 * @private
	 */
	public class RTreeNode
	{

		// Properties
		public var nodeId:String  = '0';
		public var mbr:RRectangle = null;
		public var entries:Array  = null;
		public var ids:Array      = null;
		public var level:int;
		public var entryCount:int = 0;

		// Constructor
		public function RTreeNode( nodeId:String, level:int, maxNodeEntries:int ):void
		{
			this.nodeId = nodeId;
			this.level = level;
			this.entries = [];
			this.ids = [];
		}

		// Methods
		//////////

		// Add entry to the node
		public function addEntry( r:RRectangle, id:String ):void
		{
			this.ids[this.entryCount] = id
			this.entries[this.entryCount] = r.copy()
			this.entryCount++;
			if (this.mbr == null)
			{
				this.mbr = r.copy()
			} else
			{
				this.mbr.add(r)
			}
		}

		// Add entry to the node
		public function addEntryNoCopy( r:RRectangle, id:String ):void
		{
			this.ids[this.entryCount] = id;
			this.entries[this.entryCount] = r;
			this.entryCount++;
			if (this.mbr == null)
			{
				this.mbr = r.copy();
			} else
			{
				this.mbr.add(r);
			}
		}


		// Return the index of the found entry, or -1 if not found
		public function findEntry( r:RRectangle, id:String ):int
		{
			var ec:int = this.entryCount;
			for (var i:int = 0; i < ec; i++)
			{
				if (id == this.ids[i] && r.equals(this.entries[i]))
				{
					return i;
				}
			}
			return -1;
		}

		// delete entry. This is done by setting it to null and copying the last entry into its space.
		public function deleteEntry( i:int, minNodeEntries:int ):void
		{
			var lastIndex:int               = this.entryCount - 1
			var deletedRectangle:RRectangle = this.entries[i]
			this.entries[i] = null
			if (i != lastIndex)
			{
				this.entries[i] = this.entries[lastIndex]
				this.ids[i] = this.ids[lastIndex]
				this.entries[lastIndex] = null
			}
			this.entryCount--

			// if there are at least minNodeEntries, adjust the MBR.
			// otherwise, don't bother, as the node will be 
			// eliminated anyway.
			if (this.entryCount >= minNodeEntries)
				this.recalculateMBR(deletedRectangle)
		}

		// oldRectangle is a RRectangle that has just been deleted or made smaller.
		// Thus, the MBR is only recalculated if the OldRectangle influenced the old MBR
		public function recalculateMBR( deletedRectangle:RRectangle ):void
		{

			if (this.mbr.edgeOverlaps(deletedRectangle))
			{

				var n:RRectangle = this.entries[0]
				this.mbr.setArrays(n.min, n.max)

				var ec:int       = this.entryCount
				for (var i:int = 1; i < ec; i++)
					this.mbr.add(this.entries[i])

			}
		}

		public function getEntry( index:int ):RRectangle
		{
			if (index < this.entryCount)
				return this.entries[index]
			return null
		}

		public function getId( index:int ):String
		{
			if (index < this.entryCount)
				return this.ids[index]
			return null;
		}

		// Eliminate null entries, move all entries to the start of the source node
		public function reorganize( rtree:RTree ):void
		{

			var countdownIndex:int = rtree.maxNodeEntries - 1
			var ec:int             = this.entryCount
			for (var index:int = 0; index < ec; index++)
			{
				if (this.entries[index] == null)
				{
					while (this.entries[countdownIndex] == null && countdownIndex > index)
						countdownIndex--
					this.entries[index] = this.entries[countdownIndex]
					this.ids[index] = this.ids[countdownIndex]
					this.entries[countdownIndex] = null
				}
			}

		}

		public function isLeaf():Boolean
		{
			return (this.level == 1)
		}


	}


}
