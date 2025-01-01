package com.model.asset
{
	import com.model.prototype.IPrototype;

	import flash.geom.Rectangle;

	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;

	public class AssetVO
	{
		private var _audio:String;
		private var _bbox:Rectangle;
		private var _type:String;
		private var _isMesh:Boolean     = false;
		private var _iconImage:String;
		private var _smallImage:String;
		private var _mediumImage:String;
		private var _largeImage:String;
		private var _profileImage:String;
		private var _loops:int;
		private var _descriptionText:String;
		private var _radius:Number      = 1;
		private var _scale:Number       = 1;
		private var _spriteName:String;
		private var _sprites:Array;
		private var _spriteXML:Array;
		private var _schematicLayoutData:Array;
		private var _shieldScale:Number = 1;
		private var _spriteSheetsString:String;
		private var _spriteSheetsMobileString:String;
		private var _usedBy:int;
		private var _visibleName:String;
		private var _volume:Number;
		
		
		private var _key:String;

		//Filters
		private var _sort:Number;
		private var _filterIcon:String;
		private var _filterIconSelected:String;
		private var _filterIconHover:String;

		public function AssetVO()
		{
			_sprites = [];
			_spriteXML = [];
			_schematicLayoutData = [];
		}

		public function addGameAssetData( data:IPrototype ):void
		{
			_type = data.name;
			_key = data.getUnsafeValue('key');
			if (String(data.getValue('spriteSheets')).length > 0)
			{
				_spriteSheetsString = data.getValue("spriteSheets");
				_spriteSheetsMobileString = data.getValue("spriteSheetsMobile");
				var ss:Array = (DeviceMetrics.PLATFORM == PlatformEnum.MOBILE && _spriteSheetsMobileString != null && _spriteSheetsMobileString != '') ?
					_spriteSheetsMobileString.split(',') :
					_spriteSheetsString.split(',');
				var ext:String = data.getUnsafeValue('jpg') == true ? '.jpg' : '.png';
				for (var i:int = 0; i < ss.length; i++)
				{
					_sprites.push('sprite/' + ss[i] + ext);
					_spriteXML.push('sprite/' + ss[i] + '.xml');
				}
			}
			if (data.getUnsafeValue('bbox') != null && data.getUnsafeValue('bbox') != '')
			{
				var tmp:Array = String(data.getUnsafeValue('bbox')).split(',');
				_bbox = new Rectangle(tmp[0], tmp[1], tmp[2], tmp[3]);
			}
			/*
			   var mesh:String = data.getUnsafeValue('mesh');
			   if (mesh != '' && mesh != null)
			   {
			   trace("made it");
			   _isMesh = true;
			   _spriteXML.length = 0;
			   _sprites.length = 0;
			   _sprites.push('mesh/' + mesh);
			   }*/
			_spriteName = data.getUnsafeValue('spriteName');
			_radius = data.getUnsafeValue('radius');
			_scale = (data.getUnsafeValue('scale') != null) ? data.getUnsafeValue('scale') : 1;
			_shieldScale = (data.getUnsafeValue('shieldScale') != null) ? data.getUnsafeValue('shieldScale') : 1;
			_usedBy = data.getUnsafeValue('usedBy');
		}

		public function addUIAssetData( data:IPrototype ):void
		{
			_type = data.name;
			_iconImage = data.getValue('imageIcon');
			_smallImage = data.getUnsafeValue('imageSmall');
			_mediumImage = data.getUnsafeValue('imageMedium');
			_largeImage = data.getValue('imageLarge');
			_profileImage = data.getValue('imageProfile');
			_visibleName = data.getValue('localizedUIName');
			_descriptionText = data.getValue('localizedDescriptionText');
		}

		public function addAudioAssetData( data:IPrototype ):void
		{
			_audio = data.getValue('audio');
			if (_audio == "")
				_audio = null;
			_loops = data.getValue('loops');
			_volume = data.getValue('volume');
		}

		public function addFilterAssetData( data:IPrototype ):void
		{
			_type = data.name;
			_sort = data.getValue('sort');
			_visibleName = data.getValue('uiName');
			_filterIcon = data.getValue('icon');
			_filterIconSelected = data.getValue('iconSelected');
			_filterIconHover = data.getValue('iconHover');
		}
		
		public function setOneSpriteXML(value:String):void
		{
			while( _spriteXML.length >0)
				_spriteXML.pop();
			
			_spriteXML.push(value);
		}
		public function setSpriteXML(id:int, value:String):void { if(id < _spriteXML.length){_spriteXML[id] = value;}}
		public function set spriteSheetsString(value:String):void { _spriteSheetsString =value;}

		public function get iconImage():String  { return _iconImage; }
		public function get smallImage():String  { return _smallImage; }
		public function get mediumImage():String  { return _mediumImage; }
		public function get largeImage():String  { return _largeImage; }
		public function get profileImage():String  { return _profileImage; }
		public function get bbox():Rectangle  { return _bbox; }
		public function get type():String  { return _type; }
		public function get radius():Number  { return _radius; }
		public function get scale():Number  { return _scale; }
		public function get isMesh():Boolean  { return _isMesh; }
		public function get spriteName():String  { return _spriteName; }
		public function get sprites():Array  { return _sprites; }
		public function get spriteXML():Array  { return _spriteXML; }
		public function get spriteSheetsString():String  { return _spriteSheetsString; }
		public function get schematicLayoutData():Array  { return _schematicLayoutData; }
		public function get visibleName():String  { return _visibleName; }
		public function get shieldScale():Number  { return _shieldScale; }
		public function get descriptionText():String  { return _descriptionText; }
		public function get usedBy():int  { return _usedBy; }
		
		public function get key():String  { return _key; }
		
		//audio
		public function get audio():String  { return _audio; }
		public function get loops():int  { return _loops; }
		public function get volume():Number  { return _volume; }

		//filter
		public function get sort():Number  { return _sort; }
		public function get filterIcon():String  { return _filterIcon; }
		public function get filterIconSelected():String  { return _filterIconSelected; }
		public function get FilterIconHover():String  { return _filterIconHover; }

	}
}
