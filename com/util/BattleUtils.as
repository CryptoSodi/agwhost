package com.util
{
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;

	import flash.geom.Point;
	import flash.geom.Vector3D;

	import org.ash.core.Entity;

	public class BattleUtils
	{
		public static const ISOPITCH_YSCALE:Number = 0.5; // sin(cameraPitch)
		public static const ISOPITCH_ZSCALE:Number = 0.866025; // sin(90-cameraPitch)

		public static var instance:BattleUtils;

		private var _assetModel:AssetModel;
		private var _attachAngle:Number;
		private var _attachPoint3D:Vector3D        = new Vector3D();
		private var _attachRadius:Number;
		private var _prototypeModel:PrototypeModel;
		private var _rotationRads:Number;

		public function BattleUtils()  { instance = this; }

		public function getAttachPointLocation( entity:Entity, attachPointName:String, attachPointLoc:Point ):void
		{
			var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPointName);
			var entityPosition:Position     = entity.get(Position);

			//set the initial value of this point to the entity position just in case there is not protoype data to offset it
			if (!attachPointProto)
			{
				attachPointLoc.x = entityPosition.x;
				attachPointLoc.y = entityPosition.y;
				return;
			}
			var detail:Detail               = entity.get(Detail);
			var shipPrototype:IPrototype    = detail.prototypeVO;
			if (!shipPrototype)
			{
				attachPointLoc.x = entityPosition.x;
				attachPointLoc.y = entityPosition.y;
				return;
			}
			_attachPoint3D.setTo(attachPointProto.getValue("x"), attachPointProto.getValue("y"), attachPointProto.getValue("z"));
			if (attachPointName == "BaseTurret")
				_attachPoint3D.z *= -1;
			var assetVO:AssetVO             = _assetModel.getEntityData(shipPrototype.getValue("asset"));

			// Rotate the attach point around the entity
			attachPointLoc.setTo(_attachPoint3D.x, _attachPoint3D.y);
			_attachRadius = attachPointLoc.length;
			_attachAngle = (attachPointLoc.x != 0) ? Math.atan2(attachPointLoc.y, attachPointLoc.x) : 0.0;
			_rotationRads = entityPosition.rotation + _attachAngle;

			// On the client, squash the circle for perspective and offset for the vertical axis
			attachPointLoc.x = (Math.cos(_rotationRads) * _attachRadius) * assetVO.scale;
			attachPointLoc.y = (((Math.sin(_rotationRads) * _attachRadius) * ISOPITCH_YSCALE) + (_attachPoint3D.z * ISOPITCH_ZSCALE)) * assetVO.scale;

			// Position the point relative to the entity
			attachPointLoc.x += entityPosition.x;
			attachPointLoc.y += entityPosition.y;
		}

		public function getAttachPointRotation( entity:Entity, attachPointName:String ):Number
		{
			var entityPosition:Position     = entity.get(Position);
			var entityRotation:Number       = entityPosition.rotation;

			var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPointName);
			//return the entities rotation if there is no prototype data to alter it
			if (!attachPointProto)
				return entityRotation;
			var attachPointRotation:Number  = attachPointProto.getValue("rotation") * 0.0174532925;

			var angle:Number                = entityRotation + attachPointRotation;
			return Math.atan2(Math.sin(angle) * 0.5, Math.cos(angle));
		}

		public function isoCrunchAngle( angle:Number ):Number  { return Math.atan2(Math.sin(angle) * 0.5, Math.cos(angle)); }

		public function moveToAttachPoint( parent:Entity, child:Entity, rotate:Boolean = true ):void
		{
			if(child == null)
				return;
			
			var detail:Detail = child.get(Detail);
			var loc:Point     = new Point();
			if (detail.prototypeVO)
			{
				getAttachPointLocation(parent, detail.prototypeVO.name, loc);
				var pos:Position = child.get(Position);
				pos.x = loc.x;
				pos.y = loc.y;
				if (rotate)
					pos.rotation = getAttachPointRotation(parent, detail.prototypeVO.name);
			}
		}

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
	}
}
