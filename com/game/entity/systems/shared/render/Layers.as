package com.game.entity.systems.shared.render
{
	import com.game.entity.nodes.shared.RenderNode;

	public class Layers
	{
		private static const LAYERS:int = 16;

		private var _allowDepth:Boolean;
		private var _depth:int;
		private var _depths:Array       = [];
		private var _gameLayer:*;
		private var _i:int;
		private var _layer:int;
		private var _layers:Vector.<int>;
		private var _length:int;
		private var _render:*;

		public function Layers( gameLayer:*, allowDepth:Boolean = true )
		{
			_allowDepth = allowDepth;
			_gameLayer = gameLayer;
			_layers = new Vector.<int>;
			for (_i = 0; _i < LAYERS; _i++)
			{
				_depths[_i] = new Vector.<RenderNode>;
				_layers[_i] = 0;
			}
		}

		public function add( node:RenderNode ):void
		{
			_layer = node.position.layer;
			if (_layer <= LAYERS)
			{
				//add to the correct depth
				if (node.position.depth > -1)
				{
					_depth = node.position.depth;
					_length = _depths[_layer].length;
					for (_i = 0; _i < _length; _i++)
					{
						if (_depths[_layer][_i].position.depth > _depth || _depths[_layer][_i].position.depth == -1)
						{
							break;
						}
					}
					_depths[_layer].splice(_i, 0, node);
					if (_layer > 0)
						_depth = _layers[_layer - 1] + _i;
					else
						_depth = _i;
				} else
					_depth = _layers[_layer];
				//add to the layer
				_render = node.animation.render;
				if (_allowDepth)
				{
					if(_gameLayer.numChildren <= _depth)
						_gameLayer.addChild(_render);
					else
						_gameLayer.addChildAt(_render, _depth);
				}
				else
					_gameLayer.addChild(_render);
				//update the next highest depths of subsequent layers
				for (_i = _layer; _i < LAYERS; _i++)
				{
					_layers[_i]++;
				}
			}
		}

		public function remove( node:RenderNode ):void
		{
			_layer = node.position.layer;
			if (_layer <= LAYERS)
			{
				//remove the depth entry
				if (node.position.depth > -1)
				{
					_length = _depths[_layer].length;
					for (_i = 0; _i < _length; _i++)
					{
						if (_depths[_layer][_i] == node)
						{
							_depths[_layer].splice(_i, 1);
							break;
						}
					}
				}
				_render = node.animation.render;
				_gameLayer.removeChild(_render);
				for (_i = _layer; _i < LAYERS; _i++)
				{
					_layers[_i]--;
					if (_layers[_i] < 0)
						throw new Error("wtf");
				}
			}
		}

		public function get scale():Number  { return _gameLayer.scaleX }
		public function set scale( v:Number ):void
		{
			if (_gameLayer)
			{
				_gameLayer.scaleX = v;
				_gameLayer.scaleY = v;
			}
		}

		public function destroy():void
		{
			_gameLayer = null;
		}
	}
}
