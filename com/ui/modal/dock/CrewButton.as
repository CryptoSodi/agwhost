package com.ui.modal.dock
{
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.misc.ImageComponent;
	
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	
	import org.greensock.TweenLite;
	import org.osflash.signals.Signal;
	
	public class CrewButton extends BitmapButton
	{
		private var _image:ImageComponent;
		
		public var onSelectCrew:Signal;
		
		public function CrewButton()
		{
			super.init(UIFactory.getBitmapData('BtnShipUpBMD'), UIFactory.getBitmapData('BtnShipROBMD'), UIFactory.getBitmapData('BtnShipDownBMD'), UIFactory.getBitmapData('BtnShipDisabledBMD'), UIFactory.
				getBitmapData('BtnShipSelectedBMD'));
			
			onSelectCrew = new Signal(CrewButton);
			
			_image = new ImageComponent();
			_image.init(_bitmap.width, _bitmap.height);
			
			addChild(_image);
			
			mouseChildren = false;	
		}
		
		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:	
						onSelectCrew.dispatch(this);
						break;
				}
				
			}
		}
		
		public function onImageLoaded( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				_image.smoothing = true;
				_image.x = _bitmap.x + (_bitmap.width - _image.width) * 0.5;
				_image.y = _bitmap.y + (_bitmap.height - _image.height) * 0.5;
			}
		}
		
		public function clearImageBitmap():void
		{
			_image.clearBitmap();
		}
		
		override public function destroy():void
		{	
			onSelectCrew.removeAll();
			onSelectCrew = null;
			
			_image.destroy();
			_image = null;
			
			super.destroy();
		}
		
	}
}