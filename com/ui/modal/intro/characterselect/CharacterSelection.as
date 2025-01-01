package com.ui.modal.intro.characterselect
{
	import com.model.prototype.IPrototype;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;

	import org.greensock.TweenLite;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class CharacterSelection extends BitmapButton
	{
		private var _raceImage:ImageComponent;
		private var _largeRaceImage:ImageComponent;
		private var _activated:Boolean;
		private var _racePrototype:IPrototype;

		public var onClicked:Signal;
		public var onRollOver:Signal;
		public var onLoadImage:Signal;

		public function CharacterSelection()
		{
			onClicked = new Signal(CharacterSelection, Boolean);
			onRollOver = new Signal(CharacterSelection);
			onLoadImage = new Signal(String, Function);

			var unselected:BitmapData = PanelFactory.getBitmapData('PortraitFrameUnselectedBMD');
			var selected:BitmapData   = PanelFactory.getBitmapData('PortraitFrameSelectedBMD');

			_raceImage = ObjectPool.get(ImageComponent);
			_raceImage.init(53, 53);

			addChild(_raceImage);

			super.init(unselected, unselected, unselected, unselected, selected);
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:
						setUpLargeImage();
						onClicked.dispatch(this, true);
						break;
					case MouseEvent.ROLL_OVER:
						setUpLargeImage();
						onRollOver.dispatch(this);
						break;
				}
			}
		}

		override public function set selected( value:Boolean ):void
		{
			if (value)
				onFadeInComplete();
			else
				TweenLite.killTweensOf(_bitmap);

			super.selected = value;
		}

		private function onFadeOutComplete():void
		{
			TweenLite.to(_bitmap, 0.75, {alpha:1, onComplete:onFadeInComplete});
		}

		private function onFadeInComplete():void
		{
			TweenLite.to(_bitmap, 0.75, {alpha:0.5, onComplete:onFadeOutComplete});
		}

		public function setUpLargeImage():void
		{
			if (_largeRaceImage == null)
			{
				_largeRaceImage = ObjectPool.get(ImageComponent);
				_largeRaceImage.init(300, 300);
				onLoadImage.dispatch(_racePrototype.getUnsafeValue('uiAsset'), _largeRaceImage.onImageLoaded);
			}
		}

		public function onLoadedImage( asset:BitmapData ):void
		{
			if (_raceImage && _bitmap)
			{
				_raceImage.onImageLoaded(asset);
				_raceImage.x = _bitmap.x + (_bitmap.width - _raceImage.width) * 0.5
				_raceImage.y = _bitmap.y + (_bitmap.height - _raceImage.height) * 0.5
			}
		}

		public function set activated( v:Boolean ):void
		{
			_activated = v;
		}

		public function get activated():Boolean
		{
			return _activated;
		}

		public function set racePrototype( v:IPrototype ):void
		{
			_racePrototype = v;
		}

		public function get racePrototype():IPrototype
		{
			return _racePrototype;
		}

		public function get image():ImageComponent
		{
			setUpLargeImage();
			return _largeRaceImage;
		}

		public function get raceName():String
		{
			return _racePrototype.name;
		}

		public function get race():String
		{
			return _racePrototype.getValue('race');
		}

		override public function destroy():void
		{
			if (_bitmap)
				TweenLite.killTweensOf(_bitmap);

			super.destroy();

			onClicked.removeAll();
			onClicked = null;

			onRollOver.removeAll();
			onRollOver = null;

			onLoadImage.removeAll();
			onLoadImage = null;

			if (_raceImage)
			{
				ObjectPool.give(_raceImage);
				_raceImage = null;
			}

			if (_largeRaceImage)
			{
				ObjectPool.give(_largeRaceImage);
				_largeRaceImage = null;
			}
		}

	}
}
