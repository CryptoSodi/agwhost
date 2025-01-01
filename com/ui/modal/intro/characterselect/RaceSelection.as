package com.ui.modal.intro.characterselect
{
	import com.controller.sound.SoundController;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.presenter.preload.IPreloadPresenter;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class RaceSelection extends Sprite
	{
		private var _bg:Bitmap;
		private var _factionBar:Bitmap;

		private var _raceName:Label;
		private var _raceDescription:Label;
		private var _rolledOver:Boolean;

		private var _selectedRaceImage:ImageComponent;

		private var _selectedCharacter:CharacterSelection;
		private var _rolledOverCharacter:CharacterSelection;

		private var _maleSelections:Vector.<CharacterSelection>;
		private var _femaleSelections:Vector.<CharacterSelection>;

		private var _selectionHolder:Sprite;
		private var _selectionHitArea:Sprite;

		private var _racePrototypes:Vector.<IPrototype>;
		private var _raceAudioVO:Vector.<AssetVO>;

		private var _presenter:IPreloadPresenter;

		private var _soundController:SoundController;

		private var _isActive:Boolean;

		private var _currentAudioIndex:int;
		private var _id:int;

		private var _totalSoundPlays:int = 0;

		public var onRaceSelectionClicked:Signal;

		public function RaceSelection( raceName:String, raceDescription:String, factionBar:String, id:int )
		{
			onRaceSelectionClicked = new Signal(RaceSelection);
			_maleSelections = new Vector.<CharacterSelection>;
			_femaleSelections = new Vector.<CharacterSelection>;

			_rolledOver = false;

			_selectionHitArea = new Sprite();
			_selectionHitArea.x = 39;
			_selectionHitArea.y = 386;
			_selectionHitArea.graphics.beginFill(0x000000, 0.0);
			_selectionHitArea.graphics.drawRect(0, 0, 225, 110);
			_selectionHitArea.graphics.endFill();
			_selectionHitArea.mouseEnabled = false;

			_selectionHolder = new Sprite();
			_selectionHolder.x = 39;
			_selectionHolder.y = 386;
			_selectionHolder.hitArea = _selectionHitArea;
			_selectionHolder.addEventListener(MouseEvent.ROLL_OUT, onCharacterSelectionRollOut, false, 0, true);

			super();

			_id = id;

			_bg = PanelFactory.getPanel('RaceSelectionBGBMD');

			_factionBar = PanelFactory.getPanel(factionBar);
			_factionBar.x = 1;
			_factionBar.y = 331;

			_raceName = new Label(18, 0xd1e5f7, 296, 32, true, 1);
			_raceName.constrictTextToSize = false;
			_raceName.align = TextFormatAlign.CENTER;
			_raceName.x = 0;
			_raceName.y = 0;
			_raceName.text = raceName;

			_raceDescription = new Label(12, 0xf0f0f0, 287, 61, true, 1);
			_raceDescription.constrictTextToSize = false;
			_raceDescription.multiline = true;
			_raceDescription.align = TextFormatAlign.LEFT;
			_raceDescription.x = 10;
			_raceDescription.y = 333;
			_raceDescription.text = raceDescription;

			addChild(_bg);
			addChild(_factionBar);
			addChild(_selectionHolder);
			addChild(_selectionHitArea);
			addChild(_raceName);
			addChild(_raceDescription);

			this.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}

		public function setUp( racePrototypes:Vector.<IPrototype>, raceAudioVO:Vector.<AssetVO> ):void
		{
			_presenter && _presenter.highfive();
			_racePrototypes = racePrototypes;
			_raceAudioVO = raceAudioVO;

			var len:uint = _racePrototypes.length;
			var currentRacePrototype:IPrototype;
			var currentCharacterSelection:CharacterSelection;
			for (var i:uint = 0; i < len; ++i)
			{
				currentRacePrototype = racePrototypes[i];
				currentCharacterSelection = new CharacterSelection();
				currentCharacterSelection.racePrototype = currentRacePrototype;
				currentCharacterSelection.selectable = true;
				currentCharacterSelection.onClicked.add(onCharacterSelectionClicked);
				currentCharacterSelection.onRollOver.add(onCharacterSelectionRollOver);
				currentCharacterSelection.onLoadImage.add(presenter.loadPortraitLarge);

				if (_presenter)
					_presenter.loadPortraitIcon(currentRacePrototype.getUnsafeValue('uiAsset'), currentCharacterSelection.onLoadedImage);

				if (currentRacePrototype.getUnsafeValue('gender') == 'Male')
					_maleSelections.push(currentCharacterSelection);
				else
					_femaleSelections.push(currentCharacterSelection);

				_selectionHolder.addChild(currentCharacterSelection);

				if (_selectedCharacter == null)
					onCharacterSelectionClicked(currentCharacterSelection);
			}

			layout();

		}

		private function layout():void
		{
			var xPos:Number = 0;
			var yPos:Number = 0;

			var i:uint;
			var len:uint    = _maleSelections.length;
			var currentCharacterSelection:CharacterSelection;
			for (; i < len; ++i)
			{
				currentCharacterSelection = _maleSelections[i];
				currentCharacterSelection.x = xPos;
				currentCharacterSelection.y = yPos;
				xPos += currentCharacterSelection.width + 4;
			}

			xPos = 0;
			yPos = 56;
			len = _femaleSelections.length;
			for (i = 0; i < len; ++i)
			{
				currentCharacterSelection = _femaleSelections[i];
				currentCharacterSelection.x = xPos;
				currentCharacterSelection.y = yPos;
				xPos += currentCharacterSelection.width + 4;
			}
		}

		private function onCharacterSelectionClicked( v:CharacterSelection, playSound:Boolean = false ):void
		{
			if (_selectedCharacter)
				_selectedCharacter.selected = false;

			_selectedCharacter = v;
			_selectedCharacter.selected = true;

			if (playSound)
				playRaceSound();

			selectedImage = _selectedCharacter.image;
		}

		private function onCharacterSelectionRollOver( v:CharacterSelection ):void
		{
			_rolledOver = true;
			if (_presenter && v)
				selectedImage = v.image;
		}

		private function onCharacterSelectionRollOut( e:MouseEvent ):void
		{
			_rolledOver = false;
			if (_selectedCharacter)
				selectedImage = _selectedCharacter.image;
		}

		public function set active( v:Boolean ):void
		{

			_isActive = v;

			var i:uint;
			var len:uint = _maleSelections.length;
			var currentCharacterSelection:CharacterSelection;
			for (; i < len; ++i)
			{
				currentCharacterSelection = _maleSelections[i];
				currentCharacterSelection.activated = v;
			}

			len = _femaleSelections.length;
			for (i = 0; i < len; ++i)
			{
				currentCharacterSelection = _femaleSelections[i];
				currentCharacterSelection.activated = v;
			}

			if (_selectedCharacter)
				_selectedCharacter.selected = v;

		}

		private function playRaceSound():void
		{
			if (_raceAudioVO && _raceAudioVO.length > 0)
			{
				var currentAudio:AssetVO = _raceAudioVO[_currentAudioIndex++];

				if (currentAudio)
				{
					_soundController.playSound(currentAudio.audio, currentAudio.volume, 0, currentAudio.loops);

					++_totalSoundPlays;

					if (_currentAudioIndex >= _raceAudioVO.length)
						_currentAudioIndex = 0;
				}
			}

		}

		private function onClick( e:MouseEvent ):void
		{
			onRaceSelectionClicked.dispatch(this);
		}

		public function get totalSoundPlays():int  { return _totalSoundPlays; }

		public function get selectedAvatarName():String
		{
			if (_selectedCharacter == null)
				return '';

			return _selectedCharacter.raceName;
		}

		public function get id():int  { return _id; }

		private function set selectedImage( v:ImageComponent ):void
		{
			if (_selectedRaceImage)
				removeChild(_selectedRaceImage);

			_selectedRaceImage = v;

			_selectedRaceImage.x = 1;
			_selectedRaceImage.y = 32;

			addChild(_selectedRaceImage);
		}

		[Inject]
		public function set presenter( value:IPreloadPresenter ):void  { _presenter = value; }
		public function get presenter():IPreloadPresenter  { return IPreloadPresenter(_presenter); }
		[Inject]
		public function set soundController( value:SoundController ):void  { _soundController = value; }

		public function destroy():void
		{
			this.removeEventListener(MouseEvent.CLICK, onClick);

			_presenter && _presenter.shun();
			_presenter = null;

			var i:uint;
			var len:uint = _maleSelections.length;
			var currentCharacterSelection:CharacterSelection;
			for (; i < len; ++i)
			{
				currentCharacterSelection = _maleSelections[i];
				currentCharacterSelection.destroy();
				currentCharacterSelection = null;
			}
			_maleSelections.length = 0;

			len = _femaleSelections.length;
			for (i = 0; i < len; ++i)
			{
				currentCharacterSelection = _femaleSelections[i];
				currentCharacterSelection.destroy();
				currentCharacterSelection = null;
			}
			_femaleSelections.length = 0;

			_selectionHolder.removeEventListener(MouseEvent.ROLL_OUT, onCharacterSelectionRollOut);
			_selectionHolder = null;

			_selectedRaceImage = null;

			_bg = null;
			_factionBar = null;

			_selectionHitArea = null;
		}

	}
}
