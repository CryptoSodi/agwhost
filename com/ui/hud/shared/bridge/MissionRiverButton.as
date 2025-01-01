package com.ui.hud.shared.bridge
{
	import com.enum.ui.ButtonEnum;
	import com.model.mission.MissionVO;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.greensock.TweenLite;
	import org.greensock.easing.Quad;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class MissionRiverButton extends Sprite
	{
		private var _exclamation:Bitmap;
		private var _image:ImageComponent;
		private var _mission:MissionVO;
		private var _question:Bitmap;

		public var onClick:Signal;

		private var _faqBtn:BitmapButton;
		private var _btnText:Label;

		private var _missionText:String = 'CodeString.MissionRiver.Mission'; //MISSION

		public function MissionRiverButton()
		{
			onClick = new Signal();

			_image = ObjectPool.get(ImageComponent);
			_image.mouseEnabled = false;
			_image.init(60, 60);
			_image.center = true;

			_faqBtn = UIFactory.getButton(ButtonEnum.ICON_FRAME, 60, 60);
			_faqBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			_btnText = new Label(20, 0xd1e5f7, 100, 25);
			_btnText.bold = true;
			_btnText.constrictTextToSize = false;
			_btnText.align = TextFormatAlign.CENTER;
			_btnText.text = _missionText;

			_exclamation = UIFactory.getBitmap('IconMissionExclamationBMD');
			_exclamation.x = 60 - _exclamation.width + 7;
			_exclamation.y = -_exclamation.height * .15;
			_exclamation.visible = false;

			_question = UIFactory.getBitmap('IconMissionQuestionBMD');
			_question.x = 60 - _question.width + 7;
			_question.y = -_question.height * .15;
			_question.visible = false;

			addChild(_faqBtn);
			addChild(_image);
			addChild(_exclamation);
			addChild(_question);
			addChild(_btnText);

			layout();
		}

		private function onMouseClick( e:MouseEvent ):void
		{
			if (onClick)
				onClick.dispatch();
		}

		private function layout():void
		{
			if (_btnText)
			{
				_btnText.x = _faqBtn.x + (_faqBtn.width - _btnText.width) * 0.5;
				_btnText.y = _faqBtn.height - 1;
			}
		}

		public function onImageLoaded( asset:BitmapData ):void
		{
			if (_image)
			{
				_image.onImageLoaded(asset);
				layout();
			}
		}

		private function onFadeOut():void
		{
			if (_exclamation.visible)
				TweenLite.to(_exclamation, .5, {alpha:1.0, ease:Quad.easeOut, onComplete:onFadeIn});
			else if (_question.visible)
				TweenLite.to(_question, .5, {alpha:1.0, ease:Quad.easeOut, onComplete:onFadeIn});
		}

		private function onFadeIn():void
		{
			if (_exclamation.visible)
				TweenLite.to(_exclamation, .5, {alpha:0.1, ease:Quad.easeIn, onComplete:onFadeOut});
			else if (_question.visible)
				TweenLite.to(_question, .5, {alpha:0.1, ease:Quad.easeIn, onComplete:onFadeOut});
		}

		public function set mission( v:MissionVO ):void
		{
			_mission = v;
			_exclamation.visible = !_mission.accepted;
			_question.visible = _mission.complete && !_mission.rewardAccepted;
			if (_exclamation.visible)
				TweenLite.to(_exclamation, .5, {alpha:0.1, ease:Quad.easeOut, onComplete:onFadeOut});
			else
				TweenLite.killTweensOf(_exclamation);
			if (_question.visible)
				TweenLite.to(_question, .5, {alpha:0.1, ease:Quad.easeOut, onComplete:onFadeOut});
			else
				TweenLite.killTweensOf(_question);
		}

		public function destroy():void
		{
			if (_exclamation)
				TweenLite.killTweensOf(_exclamation);
			if (_question)
				TweenLite.killTweensOf(_question);
			_exclamation = null;
			_question = null;
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (_image)
				ObjectPool.give(_image);

			_image = null;

			if (_faqBtn)
				_faqBtn.destroy();

			_faqBtn = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

			_mission = null;
		}
	}
}
