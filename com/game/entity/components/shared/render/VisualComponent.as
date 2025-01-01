package com.game.entity.components.shared.render
{
	import org.ash.core.Entity;

	public class VisualComponent
	{
		public var parent:Entity;

		private var _children:Array = [];

		public function init( parent:Entity ):void
		{
			this.parent = parent;
		}

		public function addChild( child:* ):void  { _children.push(child); }

		public function getChildAt( index:int ):*
		{
			if (index < _children.length)
				return _children[index];
			return null;
		}

		public function removeChildAt( index:int ):*
		{
			if (index < _children.length)
				return _children.splice(index, 1)[0]
			return null;
		}

		public function get numChildren():int  { return _children.length; }

		public function destroy():void
		{
			_children.length = 0;
			parent = null;
		}
	}
}
