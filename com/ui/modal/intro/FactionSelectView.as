package com.ui.modal.intro
{
	import com.Application;
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.enum.FactionEnum;
	import com.enum.TimeLogEnum;
	import com.event.LoadEvent;
	import com.model.player.CurrentUser;
	import com.presenter.preload.IPreloadPresenter;
	import com.service.language.Localization;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.videoplayer.YouTubeVideoPlayer;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.intro.characterselect.CharacterSelectView;
	import com.util.CommonFunctionUtil;
	import com.util.TimeLog;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	
	import flash.external.*;
	import flash.net.*;
	import flash.display.*; 
	import flash.net.*;

	import org.parade.util.DeviceMetrics;

	public class FactionSelectView extends View
	{
		public static var ANALYTICS_FIRST_TIME:Boolean = true;

		private var _bg:Bitmap;
		private var _eventDispatcher:IEventDispatcher;
		private var _title:Label;
		private var _choose:Label;

		private var _sovBG:Sprite;
		private var _tyrBG:Sprite;
		private var _igaBG:Sprite;

		private var _sovTitle:Label;
		private var _tyrTitle:Label;
		private var _igaTitle:Label;

		private var _sovFlavor:Label;
		private var _tyrFlavor:Label;
		private var _igaFlavor:Label;

		private var _sovDescription:Label;
		private var _tyrDescription:Label;
		private var _igaDescription:Label;

		private var _sovVideo:BitmapButton;
		private var _tyrVideo:BitmapButton;
		private var _igaVideo:BitmapButton;

		private var _sovSelect:BitmapButton;
		private var _tyrSelect:BitmapButton;
		private var _igaSelect:BitmapButton;

		private var _glowFilter:GlowFilter;
		private var _youTubeVideo:YouTubeVideoPlayer;
		private var _closeVideoBtn:BitmapButton;
		private var _videoBG:Sprite;

		private var _factionNameSov:String             = 'CodeString.FactionSelect.FactionName.Sov';
		private var _factionNameTyr:String             = 'CodeString.FactionSelect.FactionName.Tyrannar';
		private var _factionNameIGA:String             = 'CodeString.FactionSelect.FactionName.IGA';

		private var _factionDescriptionSov:String      = 'CodeString.FactionSelect.FactionDescription.Sov';
		private var _factionDescriptionTyr:String      = 'CodeString.FactionSelect.FactionDescription.Tyrannar';
		private var _factionDescriptionIGA:String      = 'CodeString.FactionSelect.FactionDescription.IGA';

		private var _factionFlavorTextSov:String       = 'CodeString.FactionSelect.FlavorText.Sov';
		private var _factionFlavorTextTyr:String       = 'CodeString.FactionSelect.FlavorText.Tyrannar';
		private var _factionFlavorTextIGA:String       = 'CodeString.FactionSelect.FlavorText.IGA';

		private var _titleText:String                  = 'CodeString.FactionSelect.Title';
		private var _subTitleText:String               = 'CodeString.FactionSelect.SubTitle';

		private var _selectBtnText:String              = 'CodeString.FactionSelect.SelectBtn';
		private var _videoBtnText:String               = 'CodeString.FactionSelect.VideoBtn';

		[PostConstruct]
		override public function init():void
		{
			super.init();

			TimeLog.startTimeLog(TimeLogEnum.FACTION_SELECT);
			if (ANALYTICS_FIRST_TIME)
			{
				ANALYTICS_FIRST_TIME = false;
				presenter.trackPlayerProgress(100000);
			}

			_bg = PanelFactory.getPanel('PreloadBGBMD');
			_glowFilter = CommonFunctionUtil.createGlow(0x73bdf0, true, 25, 25);

			_title = new Label(30, 0xf0f0f0);
			_title.constrictTextToSize = false;
			_title.allCaps = true;
			_title.autoSize = TextFieldAutoSize.CENTER;
			_title.text = "Loading...";
			_title.x = (_bg.width - _title.width) * .5;
			_title.y = (_bg.height - _title.height) * .5;

			addChild(_bg);
			addChild(_title);

			if (Localization.loaded)
				layout();
			else
				_eventDispatcher.addEventListener(LoadEvent.LOCALIZATION_COMPLETE, layout);
			addListener(Application.STAGE, Event.RESIZE, onResize);

			addEffects();
			effectsIN();
		}

		private function layout( e:Event = null ):void
		{
			var style:StyleSheet = new StyleSheet();
			var capsFirst:Object = new Object();
			capsFirst.fontSize = "24";
			capsFirst.display = 'inline';
			style.setStyle("CapsFirst", capsFirst);

			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.x = 37;
			_title.y = 9;
			_title.text = _titleText;

			_choose = new Label(26, 0xfbefaf);
			_choose.constrictTextToSize = false;
			_choose.allCaps = true;
			_choose.autoSize = TextFieldAutoSize.LEFT;
			_choose.x = _title.x + _title.textWidth + 9;
			_choose.y = 13;
			_choose.text = _subTitleText;

			var sovBitmap:Bitmap = PanelFactory.getPanel('FactionSOVBMD');
			_sovBG = new Sprite();
			_sovBG.addChild(sovBitmap);
			_sovBG.buttonMode = true;
			_sovBG.useHandCursor = true;
			_sovBG.x = 28;
			_sovBG.y = 55;
			addListener(_sovBG, MouseEvent.CLICK, onButtonClick);
			addListener(_sovBG, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_sovBG, MouseEvent.ROLL_OUT, onButtonRollout);

			var tyrBitmap:Bitmap = PanelFactory.getPanel('FactionTYRBMD');
			_tyrBG = new Sprite();
			_tyrBG.addChild(tyrBitmap);
			_tyrBG.buttonMode = true;
			_tyrBG.useHandCursor = true;
			_tyrBG.x = 338;
			_tyrBG.y = 55;
			addListener(_tyrBG, MouseEvent.CLICK, onButtonClick);
			addListener(_tyrBG, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_tyrBG, MouseEvent.ROLL_OUT, onButtonRollout);

			var igaBitmap:Bitmap = PanelFactory.getPanel('FactionIGABMD');
			_igaBG = new Sprite();
			_igaBG.addChild(igaBitmap);
			_igaBG.buttonMode = true;
			_igaBG.useHandCursor = true;
			_igaBG.x = 648;
			_igaBG.y = 55;
			addListener(_igaBG, MouseEvent.CLICK, onButtonClick);
			addListener(_igaBG, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_igaBG, MouseEvent.ROLL_OUT, onButtonRollout);

			_sovTitle = new Label(18, 0xd1e5f7, 296, 32, true, 1);
			_sovTitle.constrictTextToSize = false;
			_sovTitle.styleSheet = style;
			_sovTitle.x = _sovBG.x;
			_sovTitle.y = _sovBG.y - 5;
			_sovTitle.htmlText = _factionNameSov;

			_tyrTitle = new Label(18, 0xd1e5f7, 296, 32, true, 1);
			_tyrTitle.constrictTextToSize = false;
			_tyrTitle.styleSheet = style;
			_tyrTitle.x = _tyrBG.x;
			_tyrTitle.y = _tyrBG.y - 5;
			_tyrTitle.htmlText = _factionNameTyr;

			_igaTitle = new Label(18, 0xd1e5f7, 296, 32, true, 1);
			_igaTitle.constrictTextToSize = false;
			_igaTitle.styleSheet = style;
			_igaTitle.x = _igaBG.x;
			_igaTitle.y = _igaBG.y - 5;
			_igaTitle.htmlText = _factionNameIGA;

			_sovFlavor = new Label(28, 0xf0f0f0, 207, 30);
			_sovFlavor.constrictTextToSize = false;
			_sovFlavor.align = TextFormatAlign.LEFT;
			_sovFlavor.x = 121;
			_sovFlavor.y = 458;
			_sovFlavor.text = _factionFlavorTextSov;

			_tyrFlavor = new Label(28, 0xf0f0f0, 207, 30);
			_tyrFlavor.constrictTextToSize = false;
			_tyrFlavor.align = TextFormatAlign.LEFT;
			_tyrFlavor.x = 426;
			_tyrFlavor.y = 458;
			_tyrFlavor.text = _factionFlavorTextTyr;

			_igaFlavor = new Label(28, 0xf0f0f0, 207, 30);
			_igaFlavor.constrictTextToSize = false;
			_igaFlavor.align = TextFormatAlign.LEFT;
			_igaFlavor.x = 738;
			_igaFlavor.y = 458;
			_igaFlavor.text = _factionFlavorTextIGA;

			_sovDescription = new Label(12, 0xf0f0f0, 268, 61, true, 1);
			_sovDescription.constrictTextToSize = false;
			_sovDescription.multiline = true;
			_sovDescription.align = TextFormatAlign.LEFT;
			_sovDescription.x = 38;
			_sovDescription.y = 495;
			_sovDescription.text = _factionDescriptionSov;

			_tyrDescription = new Label(12, 0xf0f0f0, 268, 61, true, 1);
			_tyrDescription.constrictTextToSize = false;
			_tyrDescription.multiline = true;
			_tyrDescription.align = TextFormatAlign.LEFT;
			_tyrDescription.x = 350;
			_tyrDescription.y = 495;
			_tyrDescription.text = _factionDescriptionTyr;

			_igaDescription = new Label(12, 0xf0f0f0, 268, 61, true, 1);
			_igaDescription.constrictTextToSize = false;
			_igaDescription.multiline = true;
			_igaDescription.align = TextFormatAlign.LEFT;
			_igaDescription.x = 656;
			_igaDescription.y = 495;
			_igaDescription.text = _factionDescriptionIGA;

			_sovVideo = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 31, 565, _videoBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_sovVideo, MouseEvent.CLICK, onButtonClick);

			_sovSelect = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 185, 565, _selectBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_sovSelect, MouseEvent.CLICK, onButtonClick);
			addListener(_sovSelect, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_sovSelect, MouseEvent.ROLL_OUT, onButtonRollout);

			_tyrVideo = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 339, 565, _videoBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_tyrVideo, MouseEvent.CLICK, onButtonClick);

			_tyrSelect = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 493, 565, _selectBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_tyrSelect, MouseEvent.CLICK, onButtonClick);
			addListener(_tyrSelect, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_tyrSelect, MouseEvent.ROLL_OUT, onButtonRollout);

			_igaVideo = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 650, 565, _videoBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_igaVideo, MouseEvent.CLICK, onButtonClick);

			_igaSelect = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 804, 565, _selectBtnText, 0xf0f0f0, 'PreloadGenericBtnRollOverBMD', 'PreloadGenericBtnDownBMD', null, 'PreloadGenericBtnDownBMD');
			addListener(_igaSelect, MouseEvent.CLICK, onButtonClick);
			addListener(_igaSelect, MouseEvent.ROLL_OVER, onButtonRollover);
			addListener(_igaSelect, MouseEvent.ROLL_OUT, onButtonRollout);

			_youTubeVideo = new YouTubeVideoPlayer(915, 549, true);
			_youTubeVideo.x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) * 0.5 + 29;
			_youTubeVideo.y = (DeviceMetrics.HEIGHT_PIXELS - _bg.height) * 0.5 + 55;
			_youTubeVideo.onFullScreenChanged.add(onVideoFullScreen);
			_youTubeVideo.onVideoEnd = onVideoEnd;
			_youTubeVideo.visible = false;

			_closeVideoBtn = ButtonFactory.getCloseButton(_bg.x + _bg.width - 40, _bg.y + 16);
			_closeVideoBtn.visible = false;
			addListener(_closeVideoBtn, MouseEvent.CLICK, onCloseVideo);

			_videoBG = new Sprite();
			_videoBG.graphics.beginFill(0x000000, 1.0);
			_videoBG.graphics.drawRect(30, 57, 915, 549);
			_videoBG.graphics.endFill();
			_videoBG.visible = false;

			addChild(_title);
			addChild(_choose);
			addChild(_sovBG);
			addChild(_tyrBG);
			addChild(_igaBG);
			addChild(_sovTitle);
			addChild(_tyrTitle);
			addChild(_igaTitle);
			addChild(_sovFlavor);
			addChild(_tyrFlavor);
			addChild(_igaFlavor);
			addChild(_sovDescription);
			addChild(_tyrDescription);
			addChild(_igaDescription);
			addChild(_sovVideo);
			addChild(_tyrVideo);
			addChild(_igaVideo);
			addChild(_sovSelect);
			addChild(_tyrSelect);
			addChild(_igaSelect);

			Application.STAGE.addChild(_youTubeVideo);
			addChild(_closeVideoBtn);
			addChild(_videoBG);
		}

		private function onButtonClick( e:MouseEvent ):void
		{
			switch (e.target)
			{
				case _sovVideo:
					if(CONFIG::IS_DESKTOP)
					{
						var urlRequest:URLRequest = new URLRequest("https://www.youtube.com/embed/vpwvNWG06jc");
						navigateToURL(urlRequest);
					}
					else
						ExternalInterface.call("vidinjector(\"https://www.youtube.com/embed/vpwvNWG06jc\",80)");
					//todo uncomment later
					//openVideo('e6nEVTVtUzs', 57);
					break;
				case _tyrVideo:
					if(CONFIG::IS_DESKTOP)
					{
						var urlRequest:URLRequest = new URLRequest("https://www.youtube.com/embed/-006qEfda-c");
						navigateToURL(urlRequest);
					}
					else
						ExternalInterface.call("vidinjector(\"https://www.youtube.com/embed/-006qEfda-c\",80)");
					//navigateToURL("https://www.youtube.com/embed/-006qEfda-c");
					//todo uncomment later
					//openVideo('Gdz4VDXCl5M', 41);
					break;
				case _igaVideo:
					if(CONFIG::IS_DESKTOP)
					{
						var urlRequest:URLRequest = new URLRequest("https://www.youtube.com/embed/4r__6056VJg");
						navigateToURL(urlRequest);
					}
					else
						ExternalInterface.call("vidinjector(\"https://www.youtube.com/embed/4r__6056VJg\",80)");
					//navigateToURL("https://www.youtube.com/embed/4r__6056VJg");
					//todo uncomment later
					//openVideo('SImP_rSg3KE', 61);
					break;
				case _sovBG:
				case _sovSelect:
					selectFaction(FactionEnum.SOVEREIGNTY);
					break;
				case _tyrBG:
				case _tyrSelect:
					selectFaction(FactionEnum.TYRANNAR);
					break;
				case _igaBG:
				case _igaSelect:
					selectFaction(FactionEnum.IGA);
					break;
			}
		}

		private function onButtonRollover( e:MouseEvent ):void
		{
			switch (e.target)
			{
				case _sovBG:
					SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_2, 0.5);
				case _sovSelect:
					_sovBG.filters = [_glowFilter];
					_sovSelect.state = "over";
					break;
				case _igaBG:
					SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_2, 0.5);
				case _igaSelect:
					_igaBG.filters = [_glowFilter];
					_igaSelect.state = "over";
					break;
				case _tyrBG:
					SoundController.instance.playSound(AudioEnum.AFX_MOUSE_DOWN_CLICK_2, 0.5);
				case _tyrSelect:
					_tyrBG.filters = [_glowFilter];
					_tyrSelect.state = "over";
					break;
			}
		}

		private function onButtonRollout( e:MouseEvent ):void
		{
			switch (e.target)
			{
				case _sovBG:
				case _sovSelect:
					_sovBG.filters = [];
					_sovSelect.state = "normal";
					break;
				case _igaBG:
				case _igaSelect:
					_igaBG.filters = [];
					_igaSelect.state = "normal";
					break;
				case _tyrBG:
				case _tyrSelect:
					_tyrBG.filters = [];
					_tyrSelect.state = "normal";
					break;
			}
		}

		private function onVideoFullScreen( isFullScreen:Boolean ):void
		{
			if (isFullScreen)
			{
				if (_youTubeVideo)
				{
					_youTubeVideo.x = 0;
					_youTubeVideo.y = 0;
				}

				if (_closeVideoBtn)
					_closeVideoBtn.visible = false;

			} else
			{

				if (_youTubeVideo)
				{
					_youTubeVideo.x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) * 0.5 + 29;
					_youTubeVideo.y = (DeviceMetrics.HEIGHT_PIXELS - _bg.height) * 0.5 + 55;
				}

				if (_closeVideoBtn)
					_closeVideoBtn.visible = true;
			}
		}

		private function selectFaction( faction:String ):void
		{
			CurrentUser.faction = faction;
			showView(CharacterSelectView);
			destroy();
		}

		private function openVideo( video:String, volume:int ):void
		{
			if (_youTubeVideo)
			{
				_youTubeVideo.updateVideo(video);
				_youTubeVideo.volume = volume;
				_youTubeVideo.visible = true;
			}

			if (_videoBG)
				_videoBG.visible = true;

			if (_closeVideoBtn)
				_closeVideoBtn.visible = true;
		}

		private function onVideoEnd():void
		{
			if (_videoBG)
				_videoBG.visible = false;

			if (_closeVideoBtn)
				_closeVideoBtn.visible = false;

			if (_youTubeVideo)
				_youTubeVideo.visible = false;
		}

		private function onCloseVideo( e:MouseEvent ):void
		{
			if (_youTubeVideo)
				_youTubeVideo.stopVideo();

			onVideoEnd();
		}

		private function onResize( e:Event ):void
		{
			if (_youTubeVideo)
			{
				_youTubeVideo.x = (DeviceMetrics.WIDTH_PIXELS - _bg.width) * 0.5 + 29;
				_youTubeVideo.y = (DeviceMetrics.HEIGHT_PIXELS - _bg.height) * 0.5 + 55;
			}
		}

		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
		[Inject]
		public function set presenter( value:IPreloadPresenter ):void  { _presenter = value; }
		public function get presenter():IPreloadPresenter  { return IPreloadPresenter(_presenter); }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			_eventDispatcher.removeEventListener(LoadEvent.LOCALIZATION_COMPLETE, layout);
			TimeLog.endTimeLog(TimeLogEnum.FACTION_SELECT);
			removeListener(Application.STAGE, Event.RESIZE, onResize);
			_bg = null;
			_eventDispatcher = null;

			_title.destroy();
			_title = null;

			_choose.destroy();
			_choose = null;

			_sovBG = null;

			_tyrBG = null;

			_igaBG = null;

			_sovTitle.destroy();
			_sovTitle = null;

			_tyrTitle.destroy();
			_tyrTitle = null;

			_igaTitle.destroy();
			_igaTitle = null;

			_sovFlavor.destroy();
			_sovFlavor = null;

			_tyrFlavor.destroy();
			_tyrFlavor = null;

			_igaFlavor.destroy();
			_igaFlavor = null;

			_sovDescription.destroy();
			_sovDescription = null;

			_tyrDescription.destroy();
			_tyrDescription = null;

			_igaDescription.destroy();
			_igaDescription = null;

			_sovVideo.destroy();
			_sovVideo = null;

			_tyrVideo.destroy();
			_tyrVideo = null;

			_igaVideo.destroy();
			_igaVideo = null;

			_sovSelect.destroy();
			_sovSelect = null;

			_tyrSelect.destroy();
			_tyrSelect = null;

			_igaSelect.destroy();
			_igaSelect = null;

			Application.STAGE.removeChild(_youTubeVideo);
			_youTubeVideo.destroy();
			_youTubeVideo = null;

			_glowFilter = null;
			_videoBG = null;

			_closeVideoBtn.destroy();
			_closeVideoBtn = null;

			super.destroy()
		}
	}
}
