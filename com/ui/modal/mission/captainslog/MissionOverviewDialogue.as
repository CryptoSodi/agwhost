package com.ui.modal.mission.captainslog
{
	import com.enum.ui.PanelEnum;
	import com.model.mission.MissionInfoVO;
	import com.ui.UIFactory;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.label.LabelFactory;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.ScaleBitmap;
	import com.controller.sound.SoundController;

	import flash.display.Sprite;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class MissionOverviewDialogue extends Sprite
	{
		private const _imageWidth:int = 121;
		private const _padding:int    = 4;

		private var _bg:ScaleBitmap;
		private var _message:Label;
		private var _npc:ImageComponent;
		private var _soundToPlay:String;
		[Inject]
		public var soundController:SoundController;

		public function init( info:MissionInfoVO, imageLoadCallback:Function ):void
		{
			_bg = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED, 678, 130, 0, 0);

			_message = new Label(13, 0xf0f0f0, _bg.width - (_imageWidth + _padding * 2), 87, true, 1);
			_message.align = TextFormatAlign.LEFT;
			_message.multiline = true;
			_message.x = _padding + _imageWidth + _padding;
			_message.y = _padding;
			_message.useLocalization = false;
			_message.text = info.dialog;

			_npc = ObjectPool.get(ImageComponent);
			_npc.init(_imageWidth, _imageWidth);
			_npc.x = _padding;
			_npc.y = _padding;
			_npc.center = true;
			imageLoadCallback(info.mediumImage, _npc.onImageLoaded);

			addChild(_bg);
			addChild(_message);
			addChild(_npc);
			
			/*if(info.hasSound)
			{
				_soundToPlay = info.sound;
				if (_soundToPlay && _soundToPlay.length > 0)
					soundController.playSound(_soundToPlay);
			}*/
		}

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			_bg = UIFactory.destroyPanel(_bg);
			_message.destroy();
			_message = null;
			ObjectPool.give(_npc);
			_npc = null;
		}
	}
}
