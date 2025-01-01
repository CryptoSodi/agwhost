package com.ui.modal.intro.characterselect
{
	import com.enum.FactionEnum;
	import com.enum.RaceEnum;
	import com.enum.TimeLogEnum;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.presenter.preload.IPreloadPresenter;
	import com.service.language.Localization;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.ui.modal.intro.FactionSelectView;
	import com.util.CommonFunctionUtil;
	import com.util.TimeLog;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.StyleSheet;
	import flash.text.TextFieldAutoSize;

	public class CharacterSelectView extends View
	{
		private static var ANALYTICS_FIRST_TIME:Boolean = true;

		private var _bg:Bitmap;
		private var _nameInputBg:Bitmap;

		private var _firstRaceSelection:RaceSelection;
		private var _secondRaceSelection:RaceSelection;
		private var _thirdRaceSelection:RaceSelection;

		private var _currentRaceSelection:RaceSelection;

		private var _acceptBtn:BitmapButton;
		private var _backBtn:BitmapButton;
		private var _randomNameBtn:BitmapButton;

		private var _nameInputInBMD:BitmapData;
		private var _nameInputOutBMD:BitmapData;

		private var _title:Label;
		private var _nameInput:Label;

		private var _defaultNameLocString:String;

		private var _raceAudioPrototypes:Vector.<IPrototype>;

		private var _raceDescriptionTerran:String       = 'CodeString.CharacterSelect.IGA.RaceDescription.Terran';
		private var _raceDescriptionOberan:String       = 'CodeString.CharacterSelect.IGA.RaceDescription.Oberan';
		private var _raceDescriptionThanerian:String    = 'CodeString.CharacterSelect.IGA.RaceDescription.Thanerian';
		private var _raceDescriptionMalus:String        = 'CodeString.CharacterSelect.Sov.RaceDescription.Malus';
		private var _raceDescriptionVeil:String         = 'CodeString.CharacterSelect.Sov.RaceDescription.Veil';
		private var _raceDescriptionSototh:String       = 'CodeString.CharacterSelect.Sov.RaceDescription.Sototh';
		private var _raceDescriptionAresMagna:String    = 'CodeString.CharacterSelect.Tyr.RaceDescription.AresMagna';
		private var _raceDescriptionLacerta:String      = 'CodeString.CharacterSelect.Tyr.RaceDescription.Lacerta';
		private var _raceDescriptionRegula:String       = 'CodeString.CharacterSelect.Tyr.RaceDescription.Regula';

		private var _factionNameIGA:String              = 'CodeString.FactionSelect.FactionName.IGA';
		private var _factionNameTyrannar:String         = 'CodeString.FactionSelect.FactionName.Tyrannar';
		private var _factionNameSov:String              = 'CodeString.FactionSelect.FactionName.Sov';

		private var _raceNameSototh:String              = 'CodeString.CharacterSelect.Sov.RaceName.Sototh';

		private var _defaultName:String                 = 'CodeString.CharacterSelect.DefaultName'; //NAME
		private var _acceptBtnText:String               = 'CodeString.Shared.Accept'; //ACCEPT
		private var _backBtnText:String                 = 'CodeString.Shared.Back'; //BACK
		private var _randomBtn:String                   = 'CodeString.Shared.Random'; //BACK

		[PostConstruct]
		override public function init():void
		{
			super.init();

			TimeLog.startTimeLog(TimeLogEnum.CHARACTER_SELECT);
			if (ANALYTICS_FIRST_TIME)
			{
				ANALYTICS_FIRST_TIME = false;
				presenter.trackPlayerProgress(200000);
			}
			var currentFaction:String = CurrentUser.faction;

			var style:StyleSheet      = new StyleSheet();
			var capsFirst:Object      = new Object();
			capsFirst.fontSize = "28";
			capsFirst.display = 'inline';
			style.setStyle("CapsFirst", capsFirst);

			_raceAudioPrototypes = presenter.getAudioProtos();

			_bg = PanelFactory.getPanel('PreloadBGBMD');

			_title = new Label(22, 0xf0f0f0);
			_title.constrictTextToSize = false;
			_title.styleSheet = style;
			_title.autoSize = TextFieldAutoSize.LEFT;
			_title.x = 37;
			_title.y = 12;
			_title.text = getFactionName(currentFaction);

			_nameInputInBMD = PanelFactory.getBitmapData('NameInputBarSelected');
			_nameInputOutBMD = PanelFactory.getBitmapData('NameInputBar');

			_nameInputBg = new Bitmap(_nameInputOutBMD);
			_nameInputBg.x = 21;
			_nameInputBg.y = 563;

			_nameInput = new Label(24, 0xffc377, 285, (_nameInputBg.height - 5));
			_nameInput.text = _defaultName;
			_nameInput.allowInput = true;
			_nameInput.clearOnFocusIn = true;
			_nameInput.restrict = "A-Za-z0-9'_бвгдёжзийклмнптфцчшщъьэюяыБГДЁЖЗИЙЛПУФЦЧШЩЪЬЭЮЯЫäöüßÄÖÜàâæéèêëïîôœùûüçÿÀÂÆÉÈÊËÏÎÔŒÛÙÜÇŸìòÒÙíóúñ¿¡ÁÍÓÚÑıçğşİÖÜÇĞŞåÅæøÆÅØãíõÃÍÕ\\- ";
			_nameInput.maxChars = 20;
			_nameInput.addLabelColor(0xffffff, 0x000000);
			_nameInput.x = _nameInputBg.x + 9
			_nameInput.y = _nameInputBg.y + 4;

			_randomNameBtn = ButtonFactory.getBitmapButton('RandomizeNameBtnNeutral', 315, 569, _randomBtn, 0xf0f0f0, 'RandomizeNameBtnRollover', 'RandomizeNameBtnSelected');
			_randomNameBtn.fontSize = 20;
			_randomNameBtn.label.x -= 1;
			addListener(_randomNameBtn, MouseEvent.CLICK, onRandomNameBtnClick);

			_acceptBtn = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 812, 563, _acceptBtnText, 0xd1e5f7, 'PreloadGenericBtnRollOverBMD');
			_acceptBtn.fontSize = 26;
			_acceptBtn.label.x += 5;
			_acceptBtn.label.y += 1;
			addListener(_acceptBtn, MouseEvent.CLICK, onAcceptBtnClicked);

			_backBtn = ButtonFactory.getBitmapButton('PreloadGenericBtnUpBMD', 661, _acceptBtn.y, _backBtnText, 0xd1e5f7, 'PreloadGenericBtnRollOverBMD');
			_backBtn.fontSize = 26;
			_backBtn.label.x -= 6;
			_backBtn.label.y += 1;
			addListener(_backBtn, MouseEvent.CLICK, onBackBtnClicked);

			var races:Array           = getRaces(currentFaction);
			if (races.length > 0)
			{
				var currentRace:String                 = races[0];
				var currentDescription:String          = getRaceDescription(currentRace);
				var factionBarName:String              = getFactionBar(currentFaction);
				var racePrototypes:Vector.<IPrototype> = presenter.getRacePrototypesByFaction(currentFaction, currentRace);
				racePrototypes.sort(orderItems);
				_firstRaceSelection = new RaceSelection(currentRace, currentDescription, factionBarName, 1);
				_firstRaceSelection.onRaceSelectionClicked.add(onRaceClicked);
				presenter.injectObject(_firstRaceSelection);
				_firstRaceSelection.setUp(racePrototypes, getVoiceOptions(currentFaction, currentRace));
				_firstRaceSelection.x = 21;
				_firstRaceSelection.y = 54;

				currentRace = races[1];
				currentDescription = getRaceDescription(currentRace);
				racePrototypes = presenter.getRacePrototypesByFaction(currentFaction, currentRace);
				racePrototypes.sort(orderItems);
				_secondRaceSelection = new RaceSelection(currentRace, currentDescription, factionBarName, 2);
				_secondRaceSelection.onRaceSelectionClicked.add(onRaceClicked);
				presenter.injectObject(_secondRaceSelection);
				_secondRaceSelection.setUp(racePrototypes, getVoiceOptions(currentFaction, currentRace));
				_secondRaceSelection.x = 334;
				_secondRaceSelection.y = 54;

				currentRace = races[2];
				currentDescription = getRaceDescription(currentRace);
				racePrototypes = presenter.getRacePrototypesByFaction(currentFaction, currentRace);
				racePrototypes.sort(orderItems);
				_thirdRaceSelection = new RaceSelection(currentRace, currentDescription, factionBarName, 3);
				_thirdRaceSelection.onRaceSelectionClicked.add(onRaceClicked);
				presenter.injectObject(_thirdRaceSelection);
				_thirdRaceSelection.setUp(racePrototypes, getVoiceOptions(currentFaction, currentRace));
				_thirdRaceSelection.x = 647;
				_thirdRaceSelection.y = 54;
			}

			addChild(_bg);
			addChild(_nameInputBg);
			addChild(_nameInput);
			addChild(_title);
			addChild(_backBtn);
			addChild(_acceptBtn);
			addChild(_randomNameBtn);

			if (_firstRaceSelection)
				addChild(_firstRaceSelection);

			if (_secondRaceSelection)
				addChild(_secondRaceSelection)

			if (_thirdRaceSelection)
				addChild(_thirdRaceSelection)

			addListener(_nameInput, FocusEvent.FOCUS_IN, onNameInputClicked);
			addListener(_nameInput, FocusEvent.FOCUS_OUT, onNameInputUnclicked);

			_defaultNameLocString = Localization.instance.getString(_defaultName);

			if (_firstRaceSelection)
				onRaceClicked(_firstRaceSelection);

			if (_secondRaceSelection)
				_secondRaceSelection.active = false;

			if (_thirdRaceSelection)
				_thirdRaceSelection.active = false;

			addEffects();
			effectsIN();
		}

		private function onRaceClicked( raceSelection:RaceSelection ):void
		{
			if (_currentRaceSelection && raceSelection.id != _currentRaceSelection.id)
				_currentRaceSelection.active = false;

			_currentRaceSelection = raceSelection;
			_currentRaceSelection.active = true;
		}

		private function onAcceptBtnClicked( e:MouseEvent ):void
		{
			if (_nameInput.text == _defaultNameLocString || _nameInput.text == '' || _nameInput.text.length < 2)
			{
				var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
				buttons.push(new ButtonPrototype('CodeString.Shared.OkBtn'));
				showConfirmation('CodeString.CharacterSelect.NameAlert.Title', 'CodeString.CharacterSelect.NameAlert.Body', buttons);
				return;
			}

			if (_currentRaceSelection == null)
				return;

			var faction:String = CurrentUser.faction;

			var avatar:String  = _currentRaceSelection.selectedAvatarName;

			var totalSoundPlays:int;
			if (_firstRaceSelection != null && _secondRaceSelection != null && _thirdRaceSelection != null)
				totalSoundPlays = _firstRaceSelection.totalSoundPlays + _secondRaceSelection.totalSoundPlays + _thirdRaceSelection.totalSoundPlays;

			CurrentUser.name = _nameInput.text;
			CurrentUser.avatarName = avatar;
			presenter.sendCharacterToServer(faction, avatar);

			destroy();
		}

		private function onBackBtnClicked( e:MouseEvent ):void
		{
			var totalSoundPlays:int;
			if (_firstRaceSelection != null && _secondRaceSelection != null && _thirdRaceSelection != null)
				totalSoundPlays = _firstRaceSelection.totalSoundPlays + _secondRaceSelection.totalSoundPlays + _thirdRaceSelection.totalSoundPlays;

			showView(FactionSelectView);
			destroy();
		}

		private function onRandomNameBtnClick( e:MouseEvent ):void
		{
			if (_currentRaceSelection.selectedAvatarName)
			{
				var currentCharacter:IPrototype          = presenter.getRacePrototypeByName(_currentRaceSelection.selectedAvatarName);

				var firstNameOptions:Vector.<IPrototype> = presenter.getFirstNameOptions(currentCharacter.getValue('race'), currentCharacter.getValue('gender'));
				var firstNameIdx:int                     = Math.floor(Math.random() * firstNameOptions.length);

				var lastNameOptions:Vector.<IPrototype>  = presenter.getLastNameOptions(currentCharacter.getValue('race'), currentCharacter.getValue('gender'));
				var lastNameIdx:int                      = Math.floor(Math.random() * lastNameOptions.length);

				var randName:String;
				var loc:Localization                     = Localization.instance;
				if (firstNameOptions.length > 0 && lastNameOptions.length > 0 && !(currentCharacter.getValue('race') == 'Veil'))
					randName = loc.getString(firstNameOptions[firstNameIdx].getValue('key')) + ' ' + loc.getString(lastNameOptions[lastNameIdx].getValue('key'));
				else if (firstNameOptions.length > 0)
					randName = loc.getString(firstNameOptions[firstNameIdx].getValue('key'));
				else
					randName = loc.getString(lastNameOptions[lastNameIdx].getValue('key'));

				if (randName.length <= 20)
					_nameInput.text = randName;
				else
					_nameInput.text = randName + ' Longer than 20';
			}
		}

		private function onNameInputClicked( e:FocusEvent ):void
		{
			if (_nameInput.text == '<ENTER NAME>')
				_nameInput.text = '';

			_nameInputBg.bitmapData = _nameInputInBMD;
		}

		private function onNameInputUnclicked( e:FocusEvent ):void
		{
			_nameInputBg.bitmapData = _nameInputOutBMD;
		}

		private function getRaces( faction:String ):Array
		{
			var races:Array = new Array();
			switch (faction)
			{
				case FactionEnum.IGA:
					races.push(RaceEnum.IGATERRAN);
					races.push(RaceEnum.IGAOBERAN);
					races.push(RaceEnum.IGATHANERIAN);
					break;
				case FactionEnum.SOVEREIGNTY:
					races.push(RaceEnum.SOVMALUS);
					races.push(RaceEnum.SOVVEIL);
					races.push(RaceEnum.SOVSOTOTH);
					break;
				case FactionEnum.TYRANNAR:
					races.push(RaceEnum.TYRARESMAGNA);
					races.push(RaceEnum.TYRLACERTA);
					races.push(RaceEnum.TYRREGULA);
					break;
			}
			return races;
		}

		private function getRaceDescription( race:String ):String
		{
			switch (race)
			{
				case RaceEnum.IGATERRAN:
					return _raceDescriptionTerran;
					break;
				case RaceEnum.IGAOBERAN:
					return _raceDescriptionOberan;
					break;
				case RaceEnum.IGATHANERIAN:
					return _raceDescriptionThanerian;
					break;
				case RaceEnum.SOVMALUS:
					return _raceDescriptionMalus;
					break;
				case RaceEnum.SOVVEIL:
					return _raceDescriptionVeil;
					break;
				case RaceEnum.SOVSOTOTH:
					return _raceDescriptionSototh;
					break;
				case RaceEnum.TYRARESMAGNA:
					return _raceDescriptionAresMagna;
					break;
				case RaceEnum.TYRLACERTA:
					return _raceDescriptionLacerta;
					break;
				case RaceEnum.TYRREGULA:
					return _raceDescriptionRegula;
					break;
				default:
					return '';
					break;
			}
		}

		private function getFactionName( faction:String ):String
		{
			switch (faction)
			{
				case FactionEnum.IGA:
					return _factionNameIGA;
					break;
				case FactionEnum.TYRANNAR:
					return _factionNameTyrannar;
					break;
				case FactionEnum.SOVEREIGNTY:
					return _factionNameSov;
					break;
				default:
					return '';
					break;
			}
		}

		private function getFactionBar( faction:String ):String
		{
			switch (faction)
			{
				case FactionEnum.IGA:
					return 'RaceIGABarBMD';
					break;
				case FactionEnum.TYRANNAR:
					return 'RaceTYRBarBMD';
					break;
				case FactionEnum.SOVEREIGNTY:
					return 'RaceSOVBarBMD';
					break;
				default:
					return '';
					break;
			}
		}

		private function getVoiceOptions( faction:String, race:String ):Vector.<AssetVO>
		{
			var options:Vector.<AssetVO> = new Vector.<AssetVO>;
			race = race.split(' ').join('');
			for each (var proto:IPrototype in _raceAudioPrototypes)
			{
				if (proto.getValue('audioType') == 'CharacterSelect' && proto.getValue('faction') == faction && proto.getValue('race') == race)
					options.push(presenter.getEntityData(proto.name));
			}

			return options;
		}

		private function orderItems( itemOne:IPrototype, itemTwo:IPrototype ):int
		{
			var sortOrderOne:Number = itemOne.getValue('id');
			var sortOrderTwo:Number = itemTwo.getValue('id');

			if (sortOrderOne < sortOrderTwo)
			{
				return -1;
			} else if (sortOrderOne > sortOrderTwo)
			{
				return 1;
			} else
			{
				return 0;
			}
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IPreloadPresenter ):void  { _presenter = value; }
		public function get presenter():IPreloadPresenter  { return IPreloadPresenter(_presenter); }

		override public function destroy():void
		{
			TimeLog.endTimeLog(TimeLogEnum.CHARACTER_SELECT);
			super.destroy();
			_bg = null;
			_nameInputBg = null;

			_firstRaceSelection.destroy();
			_firstRaceSelection = null;

			_secondRaceSelection.destroy();
			_secondRaceSelection = null;

			_thirdRaceSelection.destroy();
			_thirdRaceSelection = null;

			_currentRaceSelection = null;

			_acceptBtn.destroy();
			_acceptBtn = null;

			_backBtn.destroy();
			_backBtn = null;

			_randomNameBtn.destroy();
			_randomNameBtn = null;

			_nameInputInBMD = null;
			_nameInputOutBMD = null;

			_title.destroy();
			_title = null;

			_nameInput.destroy();
			_nameInput = null;
		}
	}
}
