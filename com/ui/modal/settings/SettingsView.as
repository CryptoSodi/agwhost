package com.ui.modal.settings
{
	import com.service.ExternalInterfaceAPI;
	
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.Slider;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.credits.CreditsView;
	import com.service.language.Localization;
	import com.model.asset.AssetModel;
	import com.ui.core.component.misc.ImageComponent;
	
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class SettingsView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _audioBG:Sprite;
		private var _languageBG:Sprite;
		private var _otherBG:Sprite;
		private var _miscBG:Sprite;

		private var _musicBtn:BitmapButton;
		private var _sfxBtn:BitmapButton;
		private var _creditsBtn:BitmapButton;
		
		//Language Check Boxes
		private var _englishBtn:BitmapButton;
		private var _frenchBtn:BitmapButton;
		private var _spanishBtn:BitmapButton;
		private var _germanBtn:BitmapButton;
		private var _italianBtn:BitmapButton;
		private var _polishBtn:BitmapButton;


		private var _musicSlider:Slider;
		private var _sfxSlider:Slider;

		private var _musicLabel:Label;
		private var _sfxLabel:Label;

		private var _titleText:String              = 'CodeString.SettingsView.Title'; //SETTINGS
		private var _audioSettingsTitleText:String = 'CodeString.SettingsView.AudioSettingsTitle'; //AUDIO SETTINGS
		private var _miscSettingsTitleText:String  = 'CodeString.SettingsView.MiscTitle'; //MISC SETTINGS
		private var _musicText:String              = 'CodeString.SettingsView.Music'; //Music
		private var _soundEffectsText:String       = 'CodeString.SettingsView.SoundEffects'; //Sound Effects
		private var _creditsText:String            = 'CodeString.SettingsView.Credits'; //CREDITS
		
		
		//Language Labels
		private var _englishLabel:Label;
		private var _frenchLabel:Label;
		private var _spanishLabel:Label;
		private var _germanLabel:Label;
		private var _italianLabel:Label;
		private var _polishLabel:Label;
		
		//Flag Icons
		public var _imageFlagEn:ImageComponent;
		public var _imageFlagFr:ImageComponent;
		public var _imageFlagEs:ImageComponent;
		public var _imageFlagDe:ImageComponent;
		public var _imageFlagIt:ImageComponent;
		public var _imageFlagPl:ImageComponent;
		
		private var _languageSettingsTitleText:String = 'CodeString.SettingsView.LanguageSettingsTitle'; //LANGUAGE SETTINGS
		private var _englishText:String            = 'CodeString.SettingsView.English'; //English
		private var _frenchText:String             = 'CodeString.SettingsView.French'; //Français
		private var _spanishText:String            = 'CodeString.SettingsView.Spanish'; //Español
		private var _germanText:String             = 'CodeString.SettingsView.German'; //Deutsche
		private var _italianText:String            = 'CodeString.SettingsView.Italian'; //Italiano
		private var _polishText:String             = 'CodeString.SettingsView.Polish'; //Polskie
		
		private var _logOutBtn:BitmapButton;
		private var _repairBtn:BitmapButton;
		private var _otherSettingsTitleText:String = 'CodeString.SettingsView.OtherSettingsTitle'; //Other SETTINGS
		private var _logOutText:String       = 'CodeString.SettingsView.LogOutBtn'; //Log Out
		private var _repairText:String       = 'CodeString.SettingsView.RepairBtn'; //Repair
	
		[PostConstruct]
		override public function init():void
		{
			super.init();
			
			
			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(455, 480);
			_bg.addTitle(_titleText, 75);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_audioBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER, 430, 200, 30, 27, 47, _audioSettingsTitleText, LabelEnum.SUBTITLE);
			//Language BG Panel
			_languageBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER, 430, 105, 30, 25, 279, _languageSettingsTitleText, LabelEnum.SUBTITLE);
			//Other BG Panel
			_otherBG = UIFactory.getHeaderPanel(PanelEnum.CONTAINER_INNER, PanelEnum.HEADER, 430, 70, 30, 25, 416, _otherSettingsTitleText, LabelEnum.SUBTITLE);
	
			_musicLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_musicLabel.align = TextFormatAlign.LEFT;
			_musicLabel.text = _musicText;

			_musicBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_musicBtn.selectable = true;
			_musicBtn.selected = !presenter.isMusicMuted;
			addListener(_musicBtn, MouseEvent.CLICK, onToggleMusicMute);

			_musicSlider = new Slider();
			_musicSlider.init(400, 24, 0, 100, this);
			_musicSlider.currentValue = presenter.musicVolume * 100;
			_musicSlider.onSliderUpdate.add(onMusicVolumeUpdate);

			_sfxLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_sfxLabel.align = TextFormatAlign.LEFT;
			_sfxLabel.text = _soundEffectsText;

			_sfxBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);

			_sfxBtn.selectable = true;
			_sfxBtn.selected = !presenter.isSFXMuted;
			addListener(_sfxBtn, MouseEvent.CLICK, onToggleSFXMute);

			_sfxSlider = new Slider();
			_sfxSlider.init(400, 24, 0, 100, this);
			_sfxSlider.currentValue = presenter.sfxVolume * 100;
			_sfxSlider.onSliderUpdate.add(onSFXVolumeUpdate);

			//Language Labels & Buttons
			_englishLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_englishLabel.align = TextFormatAlign.LEFT;
			_englishLabel.text = _englishText;
			
			_englishBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_englishBtn.selectable = true;
			_englishBtn.selected = Localization._languageEn;
			addListener(_englishBtn, MouseEvent.CLICK, onToggleLanguageEn);
			
			_frenchLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_frenchLabel.align = TextFormatAlign.LEFT;
			_frenchLabel.text = _frenchText;
			
			_frenchBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_frenchBtn.selectable = true;
			_frenchBtn.selected = Localization._languageFr;
			addListener(_frenchBtn, MouseEvent.CLICK, onToggleLanguageFr);
			
			_spanishLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_spanishLabel.align = TextFormatAlign.LEFT;
			_spanishLabel.text = _spanishText;
			
			_spanishBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_spanishBtn.selectable = true;
			_spanishBtn.selected = Localization._languageEs;
			addListener(_spanishBtn, MouseEvent.CLICK, onToggleLanguageEs);
			
			_germanLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_germanLabel.align = TextFormatAlign.LEFT;
			_germanLabel.text = _germanText;
			
			_germanBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_germanBtn.selectable = true;
			_germanBtn.selected = Localization._languageDe;
			addListener(_germanBtn, MouseEvent.CLICK, onToggleLanguageDe);
			
			_italianLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_italianLabel.align = TextFormatAlign.LEFT;
			_italianLabel.text = _italianText;
			
			_italianBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_italianBtn.selectable = true;
			_italianBtn.selected = Localization._languageIt;
			addListener(_italianBtn, MouseEvent.CLICK, onToggleLanguageIt);
			
			_polishLabel = new Label(14, 0xd1e5f7, 150, 30, true, 1);
			_polishLabel.align = TextFormatAlign.LEFT;
			_polishLabel.text = _polishText;
			
			_polishBtn = UIFactory.getButton(ButtonEnum.CHECKBOX_LARGE);
			_polishBtn.selectable = true;
			_polishBtn.selected = Localization._languagePl;
			addListener(_polishBtn, MouseEvent.CLICK, onToggleLanguagePl);
			

			
			//Flag Icons & Layout
			_imageFlagEn = new ImageComponent();
			_imageFlagEn.init(48, 48);
			_imageFlagEn.x = 50;
			_imageFlagEn.y = 325;
			
			_imageFlagFr= new ImageComponent();
			_imageFlagFr.init(48, 48);
			_imageFlagFr.x = 112.5;
			_imageFlagFr.y = 325;
			
			_imageFlagEs = new ImageComponent();
			_imageFlagEs.init(48, 48);
			_imageFlagEs.x = 175;
			_imageFlagEs.y = 325;
			
			_imageFlagDe = new ImageComponent();
			_imageFlagDe.init(48, 48);
			_imageFlagDe.x = 236.5;
			_imageFlagDe.y = 325;
			
			_imageFlagIt = new ImageComponent();
			_imageFlagIt.init(48, 48);
			_imageFlagIt.x = 299;
			_imageFlagIt.y = 325;
			
			_imageFlagPl = new ImageComponent();
			_imageFlagPl.init(48, 48);
			_imageFlagPl.x = 360.5;
			_imageFlagPl.y = 325;
			
			//Flag Icon Initialization
			AssetModel.instance.getFromCache("assets/Flag_En_Icon.png", _imageFlagEn.onImageLoaded);
			AssetModel.instance.getFromCache("assets/Flag_Fr_Icon.png", _imageFlagFr.onImageLoaded);
			AssetModel.instance.getFromCache("assets/Flag_Es_Icon.png", _imageFlagEs.onImageLoaded);
			AssetModel.instance.getFromCache("assets/Flag_De_Icon.png", _imageFlagDe.onImageLoaded);
			AssetModel.instance.getFromCache("assets/Flag_It_Icon.png", _imageFlagIt.onImageLoaded);
			AssetModel.instance.getFromCache("assets/Flag_Pl_Icon.png", _imageFlagPl.onImageLoaded);
			
			_logOutBtn = UIFactory.getButton(ButtonEnum.RED_A, 100, 40, 50, 462, _logOutText, LabelEnum.H1);
			addListener(_logOutBtn, MouseEvent.CLICK, onLogOut);
			_repairBtn = UIFactory.getButton(ButtonEnum.GREEN_A, 100, 40, 190, 462, _repairText, LabelEnum.H1);
			addListener(_repairBtn, MouseEvent.CLICK, onRefresh);
			//_creditsBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 150, 25, 0, 0, _creditsText);
			//addListener(_creditsBtn, MouseEvent.CLICK, onCreditsBtnClick);

			addChild(_bg);
			addChild(_audioBG);
			addChild(_musicLabel);
			addChild(_musicBtn);
			addChild(_musicSlider);
			addChild(_sfxLabel);
			addChild(_sfxBtn);
			addChild(_sfxSlider);
			//Add Language Settings To Panel
			addChild(_languageBG); 
			addChild(_englishLabel);
			addChild(_englishBtn);
			addChild(_frenchLabel);
			addChild(_frenchBtn);
			addChild(_spanishLabel);
			addChild(_spanishBtn);
			addChild(_germanLabel);
			addChild(_germanBtn);
			addChild(_italianLabel);
			addChild(_italianBtn);
			addChild(_otherBG);
			addChild(_logOutBtn);
			addChild(_repairBtn);
			//addChild(_polishLabel);
			//addChild(_polishBtn);
			
			//Add Flag Icons To Panel
			addChild(_imageFlagEn);
			addChild(_imageFlagFr);
			addChild(_imageFlagEs);
			addChild(_imageFlagDe);
			addChild(_imageFlagIt);
			//addChild(_imageFlagPl);
			
			//addChild(_miscBG);
			//addChild(_creditsBtn);

			layout();

			addEffects();
			effectsIN();
		}

		private function layout():void
		{
			_audioBG.x = 25;
			_audioBG.y = 47;

			_musicBtn.x = 34;
			_musicBtn.y = 100;

			_musicLabel.x = 60;
			_musicLabel.y = _musicBtn.y + (_musicBtn.height - _musicLabel.textHeight) * 0.5 - 3;

			_musicSlider.x = 36;
			_musicSlider.y = 129;

			_sfxBtn.x = 34;
			_sfxBtn.y = 187;

			_sfxLabel.x = 60;
			_sfxLabel.y = _sfxBtn.y + (_sfxBtn.height - _sfxLabel.textHeight) * 0.5 - 3;

			_sfxSlider.x = 36;
			_sfxSlider.y = 216;
			
			
			//Language Layout
			//TODO Relative Layout
			_englishLabel.x = 62.5;
			_englishLabel.y = 360;
			_englishBtn.x = 62.5;
			_englishBtn.y = 380;
			
			_frenchLabel.x = 125;
			_frenchLabel.y = 360;
			_frenchBtn.x = 125;
			_frenchBtn.y = 380;

			_spanishLabel.x = 187.5;
			_spanishLabel.y = 360;
			_spanishBtn.x = 187.5;
			_spanishBtn.y = 380;

			_germanLabel.x = 250;
			_germanLabel.y = 360;
			_germanBtn.x = 250;
			_germanBtn.y = 380;

			_italianLabel.x = 312.5;
			_italianLabel.y = 360;
			_italianBtn.x = 312.5;
			_italianBtn.y = 380;

			_polishLabel.x = 375;
			_polishLabel.y = 360;
			_polishBtn.x = 375;
			_polishBtn.y = 380;
			
			
			
			
			//_creditsBtn.x = _miscBG.x + (_miscBG.width - _creditsBtn.width) * 0.5;
			//_creditsBtn.y = 323;
		}
		//Language Toggle
		public function onToggleLanguageEn( e:MouseEvent ):void
		{
			Localization.toggleLanguage("en");
		}	
		public function onToggleLanguageFr( e:MouseEvent ):void
		{
			Localization.toggleLanguage("fr");
		}	
		public function onToggleLanguageEs( e:MouseEvent ):void
		{
			Localization.toggleLanguage("es");
		}	
		public function onToggleLanguageDe( e:MouseEvent ):void
		{
			Localization.toggleLanguage("de");
		}	
		public function onToggleLanguageIt( e:MouseEvent ):void
		{
			Localization.toggleLanguage("it");
		}	
		public function onToggleLanguagePl( e:MouseEvent ):void
		{
			Localization.toggleLanguage("pl");
		}
		
		
		private function onToggleSFXMute( e:MouseEvent ):void
		{
			presenter.toggleSFXMute()
		}

		private function onToggleMusicMute( e:MouseEvent ):void
		{
			presenter.toggleMusicMute()
		}

		private function onCreditsBtnClick( e:MouseEvent ):void
		{
			var creditsView:CreditsView = CreditsView(_viewFactory.createView(CreditsView));
			_viewFactory.notify(creditsView);
			destroy();
		}
		private function onLogOut( e:MouseEvent ):void
		{
			ExternalInterfaceAPI.logOut();
		}
		private function onRefresh( e:MouseEvent ):void
		{
			ExternalInterfaceAPI.refresh();
		}

		private function onSFXVolumeUpdate( currentValue:Number, percent:Number ):void
		{
			presenter.setSFXVolume(currentValue * 0.01);
		}

		private function onMusicVolumeUpdate( currentValue:Number, percent:Number ):void
		{
			presenter.setMusicVolume(currentValue * 0.01);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			if (_bg)
				ObjectPool.give(_bg);
			_bg = null;
			
			_audioBG = null;
			_languageBG = null;
			_otherBG = null;
			
			if (_musicLabel)
				_musicLabel.destroy();
			_musicLabel = null;

			if (_musicBtn)
				_musicBtn.destroy();
			_musicBtn = null;

			if (_musicSlider)
				_musicSlider.destroy();
			_musicSlider = null;

			if (_sfxLabel)
				_sfxLabel.destroy();

			if (_sfxBtn)
				_sfxBtn.destroy();
			_sfxBtn = null;

			if (_sfxSlider)
				_sfxSlider.destroy();
			_sfxSlider = null;

			if (_creditsBtn)
				_creditsBtn.destroy();
			_creditsBtn = null;
			
			
			if (_englishLabel)
				_englishLabel.destroy();
			_englishLabel = null;
			
			if (_englishBtn)
				_englishBtn.destroy();
			_englishBtn = null;
			
			if (_frenchLabel)
				_frenchLabel.destroy();
			_frenchLabel = null;
			
			if (_frenchBtn)
				_frenchBtn.destroy();
			_frenchBtn = null;
			
			if (_spanishLabel)
				_spanishLabel.destroy();
			_spanishLabel = null;
			
			if (_spanishBtn)
				_spanishBtn.destroy();
			_spanishBtn = null;
			
			if (_germanLabel)
				_germanLabel.destroy();
			_germanLabel = null;
			
			if (_germanBtn)
				_germanBtn.destroy();
			_germanBtn = null;
			
			if (_italianLabel)
				_italianLabel.destroy();
			_italianLabel = null;
			
			if (_italianBtn)
				_italianBtn.destroy();
			_italianBtn = null;
			
			if (_polishLabel)
				_polishLabel.destroy();
			_polishLabel = null;
			
			if (_polishBtn)
				_polishBtn.destroy();
			_polishBtn = null;
			
			_imageFlagEn.destroy();
			_imageFlagEn = null;
			_imageFlagFr.destroy();
			_imageFlagFr = null;
			_imageFlagEs.destroy();
			_imageFlagEs = null;
			_imageFlagDe.destroy();
			_imageFlagDe = null;
			_imageFlagIt.destroy();
			_imageFlagIt = null;
			_imageFlagPl.destroy();
			_imageFlagPl = null;
		}
	}
}
