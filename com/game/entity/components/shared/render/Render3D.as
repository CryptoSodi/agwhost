package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.ui.core.ViewStack3D;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import org.away3d.containers.ObjectContainer3D;
	import org.away3d.entities.Mesh;
	import org.away3d.events.AssetEvent;
	import org.away3d.loaders.Loader3D;
	import org.away3d.materials.TextureMaterial;
	import org.away3d.primitives.CubeGeometry;
	import org.away3d.textures.BitmapTexture;
	import org.starling.display.DisplayObject;

	public class Render3D extends ObjectContainer3D implements IRender
	{
		private static var _cubeMaterial:TextureMaterial;

		private var _cube1:Mesh;
		private var _loader:Loader3D;
		private var _matrix:Matrix;

		//solider ant model
		[Embed(source="/../../../../assets/assets/Ship.3ds", mimeType="application/octet-stream")]
		public static var ShipModel:Class;

		public function Render3D()
		{
			//Create a material for the cubes
			if (_cubeMaterial == null)
			{
				var cubeBmd:BitmapData = new BitmapData(128, 128, false, 0x0);
				cubeBmd.perlinNoise(7, 7, 5, 12345, true, true, 7, true);
				_cubeMaterial = new TextureMaterial(new BitmapTexture(cubeBmd));
				_cubeMaterial.gloss = 20;
				_cubeMaterial.ambientColor = 0x808080;
				_cubeMaterial.ambient = 1;
				_cubeMaterial.lightPicker = ViewStack3D.lightPicker;
			}

			// Build the cubes for view 1
			var cG:CubeGeometry = new CubeGeometry(80, 80, 80);
			_cube1 = new Mesh(cG, _cubeMaterial);

			// Add the cubes to view 1
			//addChild(_cube1);

			_loader = new Loader3D();
			_loader.scale(.8);
			_loader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			_loader.loadData(new ShipModel());
			addChild(_loader);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			_cube1.x = 40;
			_cube1.y = 40;
			_cube1.z = 40;
		}

		public function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void
		{

		}

		public function hitTest( localPoint:Point, forTouch:Boolean = false ):DisplayObject
		{
			return null;
		}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void  {}
		public function removeGlow():void  {}

		private function onAssetComplete( e:AssetEvent ):void
		{
			if (e.asset.assetType == "mesh")
			{
				Mesh(e.asset).material = _cubeMaterial;
			}
		}

		public function get alpha():Number  { return 0; }
		public function set alpha( v:Number ):void  {}

		public function get blendMode():String  { return null; }
		public function set blendMode( v:String ):void  {}

		public function get color():uint  { return 0; }
		public function set color( value:uint ):void  {}

		public function get height():Number  { return 100; }
		public function set height( v:Number ):void  {}

		public function get rotation():Number  { return 0; }
		public function set rotation( v:Number ):void
		{
			v += 90;
			var _tempRotation:Number = Math.atan2(Math.sin(v), Math.cos(v));
			_tempRotation = (_tempRotation / Math.PI) * 180;
			_tempRotation = _tempRotation % 360;
			if (_tempRotation < 0)
				_tempRotation += 360;
			_loader.rotateTo(0, v, 0);
		}

		public function get width():Number  { return 100; }
		public function set width( v:Number ):void  {}

		override public function set x( val:Number ):void  { super.x = -val; }

		override public function set y( val:Number ):void  { super.y = -val; }



		public function destroy():void
		{
			if (_matrix)
			{
				_matrix.identity();
			}
			_matrix = null;
			visible = false;
			dispose();
		}
	}
}
