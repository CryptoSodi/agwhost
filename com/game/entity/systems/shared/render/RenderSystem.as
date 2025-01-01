package com.game.entity.systems.shared.render
{
	import com.Application;
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.event.signal.InteractSignal;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.render.BarRender;
	import com.game.entity.components.shared.render.BarRenderStarling;
	import com.game.entity.components.shared.render.NameRender;
	import com.game.entity.components.shared.render.NameRenderStarling;
	import com.game.entity.components.shared.render.Render;
	import com.game.entity.components.shared.render.RenderSprite;
	import com.game.entity.components.shared.render.RenderSpriteStarling;
	import com.game.entity.components.shared.render.RenderStarling;
	import com.game.entity.nodes.shared.RenderNode;
	import com.model.player.PlayerModel;
	import com.model.scene.SceneModel;
	
	import flash.geom.Rectangle;
	
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;
	import org.parade.core.IViewStack;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class RenderSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.shared.RenderNode")]
		public var nodes:NodeList;
		[Inject]
		public var interactSignal:InteractSignal;
		[Inject]
		public var playerModel:PlayerModel;
		[Inject]
		public var sceneModel:SceneModel;
		[Inject]
		public var viewStack:IViewStack;

		private var _backgroundLayer:Layers;
		private var _dirty:Boolean;
		private var _gameLayer:Layers;
		//private var _away3D:Scene3D;
		private var _zoomDirty:Boolean;

		override public function addToGame( game:Game ):void
		{
			//_away3D = viewStack.getLayer(ViewEnum.AWAY3D_LAYER);
			_backgroundLayer = new Layers(viewStack.getLayer(ViewEnum.BACKGROUND_LAYER));
			_gameLayer = new Layers(viewStack.getLayer(ViewEnum.GAME_LAYER));
			nodes.nodeRemoved.add(onEntityRemoved);

			_dirty = _zoomDirty = false;
			_gameLayer.scale = sceneModel.zoom;
			interactSignal.add(onInteract);
		}

		override public function update( time:Number ):void
		{
			if (!sceneModel.ready)
				return;

			if (_zoomDirty)
			{
				_gameLayer.scale = sceneModel.zoom;
				_zoomDirty = false;
			}

			var viewArea:Rectangle = sceneModel.viewArea;
			for (var node:RenderNode = nodes.head; node; node = node.next)
			{
				if (!node.animation.visible)
				{
					if (node.render)
						onEntityRemoved(node);
				} else if (node.render || node.animation.visible)
				{
					if (!node.render)
						renderNode(node);
					else if (_dirty)
						position(node, viewArea);
					else if (node.position.dirty)
					{
						position(node, viewArea);
						node.position.dirty = false;
					}
					if (node.position.depthDirty)
					{
						_gameLayer.remove(node);
						_gameLayer.add(node);
						node.position.depthDirty = false;
					}
				}
			}
			_dirty = false;
		}

		private function renderNode( node:RenderNode ):void
		{
			var rclass:Class = getRenderClass(node.detail);
			node.render = ObjectPool.get(rclass);
			/*if (node.detail.category == CategoryEnum.SHIP)
			   {
			   _gameLayer.add(node);
			   node.render3D = new Render3D();
			   _away3D.addChild(Render3D(node.render3D));
			   } else*/
			if (node.detail.category == CategoryEnum.BACKGROUND)
				_backgroundLayer.add(node);
			else
				_gameLayer.add(node);
			position(node, sceneModel.viewArea);
			node.render.alpha = node.animation.alpha;
			if (node.animation.color != 0 && node.animation.color != 0xffffff && node.animation.color != node.render.color)
				node.render.color = node.animation.color;
			if (node.animation.blendMode != null)
				node.render.blendMode = node.animation.blendMode;
			node.render.updateFrame(node.animation.sprite, node.animation);
			node.entity.add(node.render, rclass);
		}

		private function onEntityRemoved( node:RenderNode ):void
		{
			if (node.render)
			{
				/*if (node.detail.category == CategoryEnum.SHIP)
				   {
				   _gameLayer.remove(node);
				   //_away3D.removeChild(Render3D(node.render3D));
				   //node.render3D = null;
				   } else*/
				if (node.detail.category == CategoryEnum.BACKGROUND)
					_backgroundLayer.remove(node);
				else
					_gameLayer.remove(node);
				ObjectPool.give(node.entity.remove(getRenderClass(node.detail)));
				node.render = null;
			}
		}

		private function position( node:RenderNode, viewArea:Rectangle ):void
		{
			node.render.x = node.position.x - node.animation.offsetX - viewArea.x * node.position.parallaxSpeed;
			node.render.y = node.position.y - node.animation.offsetY - viewArea.y * node.position.parallaxSpeed;
			/*if (node.render3D)
			   {
			   node.render3D.x = node.position.x - viewArea.x * node.position.parallaxSpeed;
			   node.render3D.y = node.position.y - viewArea.y * node.position.parallaxSpeed;
			   node.render3D.rotation = node.position.rotation * (180 / Math.PI);
			   }*/
			if (node.animation.allowTransform)
				node.render.applyTransform(node.position.rotation, node.animation.scaleX, node.animation.scaleY, node.animation.transformScaleFirst, node.animation.offsetX, node.animation.offsetY);
		}

		private function onInteract( type:String, dx:Number, dy:Number ):void
		{
			if (type == InteractSignal.SCROLL)
				_dirty = true;
			else if (type == InteractSignal.ZOOM)
			{
				_dirty = true;
				_zoomDirty = true;
			}
		}

		private function getRenderClass( detail:Detail ):Class
		{
			if (detail.category == CategoryEnum.BUILDING || detail.type == TypeEnum.FORCEFIELD || detail.category == CategoryEnum.DEBUFF)
				return (Application.STARLING_ENABLED) ? RenderSpriteStarling : RenderSprite;
			if (detail.type == TypeEnum.HEALTH_BAR || detail.type == TypeEnum.STATE_BAR)
				return (Application.STARLING_ENABLED) ? BarRenderStarling : BarRender;
			if (detail.type == TypeEnum.NAME)
				return (Application.STARLING_ENABLED) ? NameRenderStarling : NameRender;
			return (Application.STARLING_ENABLED) ? RenderStarling : Render;
		}

		public function get layers():Layers  { return _gameLayer; }

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeRemoved.remove(onEntityRemoved);
			nodes = null;
			sceneModel = null;
			viewStack = null;
			interactSignal.remove(onInteract);
			interactSignal = null;
		}
	}
}
