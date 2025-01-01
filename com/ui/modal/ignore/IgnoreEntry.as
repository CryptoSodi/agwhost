package com.ui.modal.ignore
{
	import com.enum.ui.ButtonEnum;
	import com.model.player.PlayerVO;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.ScaleBitmap;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class IgnoreEntry extends Sprite
	{
		public var onUnignoreClicked:Signal;

		private var _player:PlayerVO;

		private var _bg:ScaleBitmap;

		private var _name:Label;

		private var _unignoreBtn:BitmapButton;

		public function IgnoreEntry( player:PlayerVO )
		{
			super();

			onUnignoreClicked = new Signal(IgnoreEntry);

			_player = player;

			_bg = UIFactory.getScaleBitmap('BtnEmptyUpBMD');
			_bg.scale9Grid = new Rectangle(10, 10, 2, 2);
			_bg.width = 300;
			_bg.height = 20;

			_name = new Label(16, 0xf0f0f0, 213, 39, false);
			_name.x = 4;
			_name.y = 4;
			_name.constrictTextToSize = false;
			_name.align = TextFormatAlign.LEFT;
			_name.text = _player.name;

			_unignoreBtn = UIFactory.getButton(ButtonEnum.CLOSE);
			_unignoreBtn.x = 267;
			_unignoreBtn.y = _bg.y + (_bg.height - _unignoreBtn.height) * 0.5;
			_unignoreBtn.addEventListener(MouseEvent.CLICK, onUnignoreBtnClicked)

			addChild(_bg);
			addChild(_name);
			addChild(_unignoreBtn);
		}

		private function onUnignoreBtnClicked( e:MouseEvent ):void  { onUnignoreClicked.dispatch(this); }

		public function get playerID():String  { return _player.id; }

		override public function get height():Number  { return _bg.height; }

		override public function get width():Number  { return _bg.width; }

		public function destroy():void
		{
			if (onUnignoreClicked)
				onUnignoreClicked.removeAll();

			onUnignoreClicked = null;

			if (_name)
				_name.destroy();

			_name = null;

			_bg = null;
		}
	}
}
