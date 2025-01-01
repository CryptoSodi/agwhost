package com.game.entity.systems.battle
{
	import com.enum.TypeEnum;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.DebugLineNode;
	import com.model.asset.AssetModel;
	import com.service.server.incoming.data.DebugLineData;
	import com.service.server.incoming.data.RemovedObjectData;
	import com.util.InteractEntityUtil;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class DebugLineSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.DebugLineNode")]
		public var nodes:NodeList;

		private const UPDATE_INTERVAL_TICKS:int = 4;

		private var _assetModel:AssetModel;
		private var _game:Game;
		private var _lastUpdateTick:int;
		private var _vfxFactory:IVFXFactory;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			nodes.nodeAdded.add(onNodeAdded);

			//build the debug line asset data if it does not exist
			if (_assetModel.getEntityData(TypeEnum.DEBUG_LINE) == null)
			{
				_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.DEBUG_LINE, 1, "DebugLine"));
			}
		}

		public function addLine( lines:Vector.<DebugLineData> ):void
		{
			for (var i:int = 0; i < lines.length; i++)
			{
				_vfxFactory.createDebugLine(lines[i]);
			}
		}

		public function removeLine( lines:Vector.<RemovedObjectData> ):void
		{
			var entity:Entity;
			for (var i:int = 0; i < lines.length; i++)
			{
				entity = _game.getEntity(lines[i].id);
				if (entity)
					_vfxFactory.destroyDebugLine(entity);
			}
		}

		protected function matchPosition( entityId:String, position:Position ):void
		{
			var followEntity:Entity = _game.getEntity(entityId);

			if (followEntity)
			{
				var followPosition:Position = followEntity.get(Position);
				if (followPosition)
				{
					position.x = followPosition.x;
					position.y = followPosition.y;
				}
			}
		}

		protected function onNodeAdded( node:DebugLineNode ):void
		{
			node.render.setVertexColor(0, node.debugLine.startColor);
			node.render.setVertexColor(1, node.debugLine.startColor);
			node.render.setVertexColor(2, node.debugLine.endColor);
			node.render.setVertexColor(3, node.debugLine.endColor);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }

		public override function removeFromGame( game:Game ):void
		{
			nodes.nodeAdded.remove(onNodeAdded);
			nodes = null;
			_assetModel = null;
			_game = null;
			_vfxFactory = null;
		}
	}
}
