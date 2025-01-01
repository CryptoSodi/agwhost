package com.ui.core.component.videoplayer
{
	import com.Application;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.modal.ButtonFactory;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.utils.getDefinitionByName;
	
	public class ControlPanel extends Sprite
	{
		private var _controlPanelBG:Sprite;
		
		private var _playBtn:BitmapButton;
		private var _pauseBtn:BitmapButton;
		private var _fullScreenBtn:BitmapButton;
		
		private var _growUp:BitmapData;
		private var _growRollOver:BitmapData;
		
		private var _shrinkUp:BitmapData;
		private var _shrinkRollOver:BitmapData;
		
		private var _isPlaying:Boolean;
		private var _isFullScreen:Boolean;
		
		private var _fullScreenFunction:Function;
		public var startFunction:Function;
		public var pauseFunction:Function;
		public var resumeFunction:Function;
		
		public function ControlPanel( fullScreenFunction:Function = null)
		{
			super();
			_controlPanelBG = new Sprite();
			
			_playBtn = ButtonFactory.getBitmapButton('VideoPlayerPlayBtnUpBMD', 0, 0, '', 0, 'VideoPlayerPlayBtnRollOverBMD', 'VideoPlayerPlayBtnDownBMD');
			_playBtn.addEventListener(MouseEvent.CLICK, onPlayBtnClicked, false, 0, true);
			_playBtn.visible = false;
			
			_pauseBtn = ButtonFactory.getBitmapButton('VideoPlayerPauseBtnUpBMD', 0, 0, '', 0, 'VideoPlayerPauseBtnRollOverBMD');
			_pauseBtn.addEventListener(MouseEvent.CLICK, onPauseBtnClicked, false, 0, true);
			_pauseBtn.visible = false;
			
			addChild(_controlPanelBG);
			addChild(_playBtn);
			addChild(_pauseBtn);
		}
		
		public function init( width:Number, height:Number ):void
		{
			_controlPanelBG.graphics.clear();
			_controlPanelBG.graphics.lineStyle(2, 0x2c598f);
			_controlPanelBG.graphics.beginFill(0x131515);
			_controlPanelBG.graphics.moveTo(1, 0);
			_controlPanelBG.graphics.lineTo(width, 0);
			_controlPanelBG.graphics.lineTo(width, height * 0.1);
			_controlPanelBG.graphics.lineTo(1, height * 0.1);
			_controlPanelBG.graphics.lineStyle(2, 0x131515);
			_controlPanelBG.graphics.lineTo(1, 0);
			_controlPanelBG.graphics.endFill();
			_controlPanelBG.alpha = 0.4;
			_controlPanelBG.cacheAsBitmap = true;
			
			_playBtn.scaleX = 1;
			_playBtn.scaleY = 1;
			
			while(_playBtn.height > _controlPanelBG.height)
			{
				_playBtn.scaleX -= 0.1;
				_playBtn.scaleY -= 0.1;
			}
			
			_pauseBtn.scaleX = 1;
			_pauseBtn.scaleY = 1;
			
			while(_pauseBtn.height > _controlPanelBG.height)
			{
				_pauseBtn.scaleX -= 0.1;
				_pauseBtn.scaleY -= 0.1;
			}
			
			_playBtn.x = _controlPanelBG.x + (_controlPanelBG.width - _playBtn.width) * 0.5;
			_playBtn.y = _controlPanelBG.y + (_controlPanelBG.height - _playBtn.height) * 0.5;
			
			_pauseBtn.height = height * 0.1 - 5;
			_pauseBtn.x = _controlPanelBG.x + (_controlPanelBG.width - _pauseBtn.width) * 0.5;
			_pauseBtn.y = _controlPanelBG.y + (_controlPanelBG.height - _pauseBtn.height) * 0.5;
			
			if(_fullScreenFunction != null)
			{
				_fullScreenBtn.scaleX = 1;
				_fullScreenBtn.scaleY = 1;
				
				while(_fullScreenBtn.height > _controlPanelBG.height)
				{
					_fullScreenBtn.scaleX -= 0.1;
					_fullScreenBtn.scaleY -= 0.1;
				}
				
				_fullScreenBtn.y = _pauseBtn.y + (_pauseBtn.height - _fullScreenBtn.height) * 0.5
				_fullScreenBtn.x = _controlPanelBG.width - _fullScreenBtn.width - 20;
			}

		}
		
		override public function get height():Number
		{
			return _controlPanelBG.height;
		}
		
		override public function get width():Number
		{
			return _controlPanelBG.width;
		}
		
		
		public function set isPlaying( isPlaying:Boolean ):void
		{
			_isPlaying = isPlaying;
			if(_isPlaying)
			{
				_pauseBtn.visible = true;
				_playBtn.visible = false;
			}
			else
			{
				_pauseBtn.visible = false;
				_playBtn.visible = true;
			}
		}
		
		private function onPlayBtnClicked( e:MouseEvent ):void
		{
			play();
		}
		
		public function play():void
		{
			if(!_isPlaying)
			{
				startFunction();
				_isPlaying = true;
			}
			
			if(resumeFunction != null)
				resumeFunction();	
			
			_playBtn.visible = false;
			_pauseBtn.visible = true;
		}
		
		private function onPauseBtnClicked( e:MouseEvent ):void
		{
			if(pauseFunction != null)
				pauseFunction();
	
			_pauseBtn.visible = false;
			_playBtn.visible = true;
		}
		
		private function onFullScreen( e:MouseEvent ):void
		{
			_fullScreenFunction(!_isFullScreen);
		}
		
		public function set fullScreen( isFullScreen:Boolean ):void
		{
			_isFullScreen = isFullScreen;
			
			if(_isFullScreen)
				_fullScreenBtn.updateBackgrounds(_shrinkUp, _shrinkRollOver);
			else
				_fullScreenBtn.updateBackgrounds(_growUp, _growRollOver);
		}
		
		public function destroy():void
		{
			_controlPanelBG = null;
			
			_playBtn.removeEventListener(MouseEvent.CLICK, onPlayBtnClicked);
			_playBtn.destroy();
			_playBtn = null;
			
			_pauseBtn.removeEventListener(MouseEvent.CLICK, onPauseBtnClicked);
			_pauseBtn.destroy();
			_pauseBtn = null;
			
			if(_fullScreenFunction != null)
			{
				_fullScreenBtn.removeEventListener(MouseEvent.CLICK, onFullScreen);
				_fullScreenBtn.destroy();
				_fullScreenBtn = null;
			}
		}
		
		public function set fullScreenFunction( fullScreenFunction:Function ):void
		{
			_fullScreenFunction = fullScreenFunction;
			_fullScreenBtn = ButtonFactory.getBitmapButton('IconMaximizeBMD', 369, 5, '', 0, 'IconMaximizeRollOverBMD');
			_fullScreenBtn.addEventListener(MouseEvent.CLICK, onFullScreen, false, 0, true);
			
			var growUpBG:Class                     = Class(getDefinitionByName('IconMaximizeBMD'));
			var growRollOverBG:Class			   = Class(getDefinitionByName('IconMaximizeRollOverBMD'));
				
			var shrinkBG:Class                     = Class(getDefinitionByName('IconMinimizeBMD'));
			var shrinkRollOverBG:Class			   = Class(getDefinitionByName('IconMinimizeRollOverBMD'));
			
			_growUp = BitmapData(new growUpBG());
			_growRollOver= BitmapData(new growRollOverBG());
			
			_shrinkUp = BitmapData(new shrinkBG());
			_shrinkRollOver = BitmapData(new shrinkRollOverBG());
			
			
			addChild(_fullScreenBtn);
		}
	}
}