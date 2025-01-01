package com.game.entity.components.shared
{
	import flash.geom.Point;

	import org.shared.ObjectPool;

	public class Position
	{
		public var depthDirty:Boolean;
		public var dirty:Boolean;
		public var ignoreRotation:Boolean  = false;
		public var linkedTo:Position;
		public var parallaxSpeed:Number;
		public var position:Point          = new Point();

		private var _depth:int;
		private var _layer:int             = 0;
		private var _links:Vector.<Position>;
		private var _oldLayer:int          = -1;
		private var _rotation:Number       = 0;
		private var _rotationDelta:Number  = 0;
		private var _startRotation:Number  = 0;
		private var _targetRotation:Number = 0;

		public function Position()
		{
			_links = new Vector.<Position>;
		}

		public function init( x:Number, y:Number, rotation:Number, layer:int = 10, parallaxSpeed:Number = 1 ):void
		{
			this.rotation = rotation;
			this.targetRotation = rotation;
			_layer = layer;
			this.parallaxSpeed = parallaxSpeed;
			dirty = true;
			_depth = -1;
			depthDirty = false;
			position.setTo(x, y);
		}

		public function addLink( pos:Position ):void
		{
			pos.linkedTo = this;
			_links.push(pos);
		}

		public function removeLink( pos:Position ):void
		{
			var index:int = _links.indexOf(pos);
			if (index > -1)
				_links.splice(index, 1);
		}

		public function clearRotation():void
		{
			_rotation = 0;
			_startRotation = 0;
			_rotationDelta = 0;
			_targetRotation = 0;
		}

		public function clone():Position
		{
			var pos:Position = ObjectPool.get(Position);
			pos.init(position.x, position.y, rotation, layer, parallaxSpeed);
			return pos;
		}

		public function layerSwap( oldLayer:int, newLayer:int ):void
		{
			_oldLayer = oldLayer;
			_layer = newLayer;
			depthDirty = true;
		}

		public function get depth():int  { return _depth; }
		public function set depth( v:int ):void
		{
			if (_links.length > 0)
			{
				var diff:int;
				for (var i:int = 0; i < _links.length; i++)
				{
					diff = _links[i].depth - _depth;
					_links[i].depth = v + diff;
				}
			}
			_depth = v;
			depthDirty = true;
		}

		public function get layer():int
		{
			if (_oldLayer > -1)
			{
				var l:int = _oldLayer;
				_oldLayer = -1;
				return l;
			}
			return _layer;
		}
		public function set layer( v:int ):void  { _layer = v; }

		public function get rotation():Number  { return _rotation; }
		public function set rotation( v:Number ):void
		{
			if (!ignoreRotation)
			{
				_rotation = v;
				dirty = true;
				if (_links.length > 0)
				{
					for (var i:int = 0; i < _links.length; i++)
						_links[i].rotation = v;
				}
			}
		}

		public function get rotationDelta():Number  { return _rotationDelta; }
		public function get startRotation():Number  { return _startRotation; }
		public function get targetRotation():Number  { return _targetRotation; }
		public function set targetRotation( v:Number ):void
		{
			_startRotation = _rotation;
			_rotationDelta = v - _startRotation;
			_rotationDelta = Math.atan2(Math.sin(_rotationDelta), Math.cos(_rotationDelta));
			_targetRotation = _startRotation + _rotationDelta;

			dirty = true;
			if (_links.length > 0)
			{
				for (var i:int = 0; i < _links.length; i++)
					_links[i]._targetRotation = v;
			}
		}

		public function get x():Number  { return position.x; }
		public function set x( v:Number ):void
		{
			position.x = v;
			dirty = true;
			if (_links.length > 0)
			{
				for (var i:int = 0; i < _links.length; i++)
					_links[i].x = v;
			}
		}

		public function get y():Number  { return position.y; }
		public function set y( v:Number ):void
		{
			position.y = v;
			dirty = true;
			if (_links.length > 0)
			{
				for (var i:int = 0; i < _links.length; i++)
					_links[i].y = v;
			}
		}

		public function destroy():void
		{
			ignoreRotation = false;
			if (linkedTo)
				linkedTo.removeLink(this);
			linkedTo = null;
			_links.length = 0;
		}
	}
}
