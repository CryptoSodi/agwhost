package com.ui.core.component.page
{
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.ui.core.component.misc.ImageComponent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class PageIcon extends Sprite
	{
		protected var _onRollOverSound:String = 'sounds/sfx/AFX_UI_Mouse2_V001A.mp3';
		protected var _onClickSound:String    = 'sounds/sfx/AFX_UI_Mouse1_V001A.mp3';
		protected var _enabled:Boolean;

		public function init():void
		{
			enabled = true;
		}

		public function update( vo:* ):void
		{

		}

		public function destroy():void
		{

		}

		public function set enabled( enabled:Boolean ):void
		{
			_enabled = enabled;
		}

		protected function onMouseClick( e:MouseEvent ):void
		{
			if (_onClickSound != '')
				SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_1, 0.5);
		}

		protected function onMouseRollOver( e:MouseEvent ):void
		{
			if (_onRollOverSound != '')
				SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_2, 0.5);
		}
	}
}
