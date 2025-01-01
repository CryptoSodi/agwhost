package com.ui
{
	import com.Application;
	import com.enum.PositionEnum;
	import com.enum.TimeLogEnum;
	import com.event.ServerEvent;
	import com.event.StateEvent;
	import com.presenter.shared.ITransitionPresenter;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.label.Label;
	import com.ui.core.effects.EffectFactory;
	import com.util.TimeLog;
	import com.model.prototype.PrototypeModel;
	import com.model.prototype.IPrototype;
	import com.util.LoadingScreenHelper;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.ui.Keyboard;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import com.service.language.Localization;

	public class TransitionView extends View
	{
		[Embed(source="LoadScreen.jpg")]
		public static var loadingScreen:Class;
		
		[Embed(source="/assets/loading/LS_1.png")]
		public static var LoadingScreenBG:Class;
		
		[Embed(source="/assets/loading/loading_main.png")]
		public static var LoadingMainBG:Class;
		
		[Embed(source="/assets/loading/loading_percentage.png")]
		public static var LoadingPercentageBG:Class;
		
		[Embed(source="/assets/loading/loading_tips_background.png")]
		public static var LoadingTipsBG:Class;
		
		[Embed(source="/assets/loading/loading_screen_boarder_right.png")]
		public static var BorderRight:Class;
		
		[Embed(source="/assets/loading/loading_screen_boarder_left.png")]
		public static var BorderLeft:Class;
		
		private static var LOADING_SCREEN_GROUP_DEFAULT:String = "LoadingScreen_A";
		private static var LOADING_SCREEN_ASSET_PATH:String = "assets\\";
		private static var LOADING_SCREEN_GROUP:String ="loadingScreenGroup";
		
		private var _barSpeedPer100MS:Number = .07;
		private var _destroyed:Boolean       = false;
		private var _label:Label;
		private var _loadBar:ProgressBar;
		private var _loadingImage:Bitmap;
		private var _isEffectComplete:Boolean;
		private var _isServerReady:Boolean;
		private var _timer:Timer;

		private var _loadingImageBG:Bitmap;
		
		private var _loadingMainBG:Bitmap;
		private var _loadingPercentageBG:Bitmap;
		private var _loadingTipsBG:Bitmap;
		private var _tipsLabel:Label;
		private var _infoLabel:Label;
		private var _titleLabel:Label;
		private var _percentageLabel:Label;
		private var _borderRight:Bitmap;
		private var _borderLeft:Bitmap;
		
		private var _loadingView:Sprite;
		private var _borderOverlay:Sprite;
		
		private var _tip:String;
		private var _tipKey:String;
		
		private var _titleKey:String;
		private var _title:String;
		
		private var _loading:String          = 'CodeString.TransitionEvent.Loading'; //Loading
		private var _localizationCheckID:int = -1;
		
		private var _stage:Stage;

		[Inject]
		public var prototypeModel: PrototypeModel;

		[Inject]
		public var assetModel: AssetModel;
		
		[PostConstruct]
		override public function init():void
		{
			
			super.init();
			
			if (presenter.failed)
				return;

			_isEffectComplete = false;
			_isServerReady = false;
			//_loadingImage = new loadingScreen();

			presenter.addCompleteListener(onServerReady);
			presenter.addUpdateListener(resetEvents);
			presenter.removeStateListener(onStateChange);

			_loadingView = new Sprite();
			_borderOverlay = new Sprite();
			
			//primary loading UI
			_getLoadingImageBG();
			
			_loadingTipsBG = new LoadingTipsBG();
			
			_loadingMainBG = new LoadingMainBG();
			_loadingMainBG.x = (_loadingImageBG.width / 2) - (_loadingMainBG.width / 2);			
			_loadingMainBG.y = _loadingImageBG.height - (_loadingMainBG.height + _loadingTipsBG.height);
			
			_loadingTipsBG.x = (_loadingImageBG.width / 2) - (_loadingTipsBG.width / 2);
			_loadingTipsBG.y = _loadingMainBG.y + _loadingMainBG.height;
			
			_loadingPercentageBG = new LoadingPercentageBG();
			_loadingPercentageBG.x = _loadingMainBG.x + 504;
			_loadingPercentageBG.y = _loadingMainBG.y + 206;
			
			_borderRight = new BorderRight();
			_borderRight.x = _loadingImageBG.width - 26;
			
			_borderLeft = new BorderLeft();
			_borderLeft.x = 0;
			
			//loading bar
			_loadBar = new ProgressBar();
			_loadBar.init(ProgressBar.HORIZONTAL, new Bitmap(new BitmapData(1096, 40, false, 0x05ce00)), new Bitmap(new BitmapData(1096, 40, false, 0)), 0);
			_loadBar.setMinMax(0, 1);
			_loadBar.amount = 0;
			_loadBar.base.alpha = 1;
			_loadBar.x = _loadingMainBG.x + 116;
			_loadBar.y = _loadingMainBG.y + 218;
			_loadBar.tweenSpeed = .1;
			
			//text
			
			_infoLabel = new Label(12, 0xFFFFFF, 176, 56, true, 1);
			_infoLabel.multiline = false;
			_infoLabel.constrictTextToSize = false;
			_infoLabel.text = _loading;
			_infoLabel.y = 6;
			
			_titleLabel = new Label(32, 0xFFFFFF, 600, 56, true, 1);
			_titleLabel.multiline = false;
			_titleLabel.constrictTextToSize = false;
			_titleLabel.x = _loadingMainBG.x + 370;
			_titleLabel.y = _loadingMainBG.y + 160;

			_tipsLabel = new Label(42, 0xFFFFFF, 1496, 148, true, 1);
			_tipsLabel.multiline = true;
			_tipsLabel.constrictTextToSize = true;
			_tipsLabel.x = _loadingTipsBG.x;
			_tipsLabel.y = _loadingTipsBG.y + 8;
			
			_percentageLabel = new Label(22, 0xFFFFFF, 62,28, true, 1);
			_percentageLabel.multiline = false;
			_percentageLabel.constrictTextToSize = false;
			_percentageLabel.text = "0%";
			_percentageLabel.x = _loadingPercentageBG.x + 132;
			_percentageLabel.y = _loadingPercentageBG.y + 20;
			
			_timer = new Timer(100, 1);
			addListener(_timer, TimerEvent.TIMER_COMPLETE, checkLoad);
			
			if (!_destroyed)
			{
				addEffects();
				effectsIN();
			} else
			{
				_timer.start();
			}
			Application.STAGE.addChild(this);
			stage.addEventListener(Event.RESIZE, _onResize);
		}
		
		private function _checkForLocalization():void{
			if(_localizationCheckID == -1){
				_localizationCheckID = setInterval(_checkForLocalization,33);
			} else {
				_getTip();
				_getTitle();
				if(_hasTip() && _hasTitle()){
					clearInterval(_localizationCheckID);
					_updateLabels();
					_localizationCheckID = -1;
				}
			}
		}
		
		private function _updateLabels():void{
			_tipsLabel.text = _tip;
			_titleLabel.text = _title;
		}
		
		private function _hasTip():Boolean{
			return (_tip.length > 0);
		}
		
		private function _hasTitle():Boolean{
			return (_title.length > 0);
		}
		
		private function _getTip():void{
			_tip = Localization.instance.getString(_tipKey);
		}
		
		private function _getTitle():void{
			_title = Localization.instance.getString(_titleKey);
		}
		
		private function _getLoadingScreenPrototype():IPrototype{
			var prototypes:Vector.<IPrototype> = _getLoadingScreenPrototypesByGroup(LOADING_SCREEN_GROUP_DEFAULT);
			
			var prototypeSelected:IPrototype;
			
			if(prototypes.length > 0){
				prototypeSelected = LoadingScreenHelper.chooseRandomPrototypeByWeight(prototypes);
				return prototypeSelected;
			}
			
			return null;
		}
		
		private function _getLoadingScreenBG(prototype:IPrototype):Bitmap{
			var uiAsset:String = prototype.uiAsset;
			
			var asset:AssetVO = assetModel.getAssetVOByName(uiAsset);
			_tipKey = asset.descriptionText;
			_titleKey = asset.visibleName;
			_getTip();
			_getTitle();
			
			if(!_hasTip() || !_hasTitle()){
				_checkForLocalization();
			}
			var path:String = LOADING_SCREEN_ASSET_PATH + asset.largeImage;

			return LoadingScreenHelper.getBitmap(path);
		}
		
		//todo probably put this is prototype model, we shouldnt do this kind of logic here but, for 
		//now its going to be ok.
		private function _getLoadingScreenPrototypesByGroup(group:String):Vector.<IPrototype>{
			var groupPrototypes:Vector.<IPrototype> = new Vector.<IPrototype>;
			
			var allPrototypes = prototypeModel.getLoadingScreenGroupPrototypes();
			
			for(var i:int = 0; i < allPrototypes.length; i++)
			{
				var prototype:IPrototype = allPrototypes[i];
				
				if(prototype.getValue(LOADING_SCREEN_GROUP) == group){
					groupPrototypes.push(prototype);
				}
			}
			
			return groupPrototypes;
		}
		
		private function _getLoadingImageBG():void{
			var prototype:IPrototype = _getLoadingScreenPrototype();
			
			if(prototype){
				_loadingImageBG = _getLoadingScreenBG(prototype);
			} else {
				_loadingImageBG = new LoadingScreenBG();
			}
		
		}

		private function _rescaleWithAspectRatio():void {
		var k:Number = stage.stageHeight / stage.stageWidth;
		if (_loadingView.width != 0 && _loadingView.width * k > _loadingView.height) {
			k = stage.stageWidth / _loadingView.width;
		} else {
			if (_loadingView.height != 0) {
				k = stage.stageHeight / _loadingView.height;
			}
		}
		_loadingView.width *= k;
		_loadingView.height *= k;
		
		_borderOverlay.scaleX = _loadingView.scaleX;
		_borderOverlay.scaleY = _loadingView.scaleY;
	}
	
	private function _centerOnStage():void {
		_loadingView.x = (stage.stageWidth / 2) - (_loadingView.width / 2);
		_loadingView.y = (stage.stageHeight / 2) - (_loadingView.height / 2);
		
		_borderOverlay.x = (stage.stageWidth / 2) - (_borderOverlay.width / 2);
		_borderOverlay.y = (stage.stageHeight / 2) - (_borderOverlay.height / 2);
		
		_tipsLabel.x = (_loadingTipsBG.width / 2) - (_tipsLabel.width / 2);
		
		_borderOverlay.visible = _loadingView.width < stage.stageWidth;
	}
	
		override public function onEscapePressed():void  {}

		public function resetEvents():void
		{

			if (presenter)
			{
				if (presenter.failed)
					destroy();
				else if (_isEffectComplete)
				{
					_isServerReady = Application.CONNECTION_STATE == ServerEvent.AUTHORIZED;
					_infoLabel.text = presenter.connectingText;
					presenter.sendEvents();
					if (_timer.running)
						_timer.stop();
					if (_isServerReady)
						onServerReady();
				}
			}
		}

		private function checkLoad( e:TimerEvent ):void
		{
			var current:Number = _loadBar.amount;
			var amount:Number  = presenter.estimatedLoadCompleted;
			if (amount > current ||
				((Application.STATE == StateEvent.GAME_BATTLE || Application.STATE == StateEvent.GAME_SECTOR || Application.STATE == StateEvent.GAME_STARBASE) && presenter.estimatedLoadCompleted == 0))
				_loadBar.amount = current + _barSpeedPer100MS;

			if (_destroyed)
				destroy()
			else if (presenter.hasWaiting)
				_timer.start();
			else if (_loadBar.amount >= 1)
				destroy();
			else
				_timer.start();
			
			_percentageLabel.text = (Math.round(current*100)).toString() + "%";
		}

		private function onServerReady():void
		{
			_isServerReady = true;
			_infoLabel.text = _loading;
			if (_isEffectComplete)
				_timer.start();
		}
		
		private function _onKeyDown(e:KeyboardEvent):void{
			if(e.keyCode == Keyboard.F12){
				_infoLabel.visible = !_infoLabel.visible;
			}
		}
		
		override protected function effectsDoneIn():void
		{
			_stage = stage;
			_infoLabel.visible = false;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			_isEffectComplete = true;
			if (_isServerReady)
				_timer.start();
			else
				_infoLabel.text = presenter.connectingText;
			
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			addChild(_loadingView);
			addChild(_borderOverlay);
			
			_loadingView.addChild(_loadingImageBG);
			
			//addChild(_loadingImage);
			_loadingView.addChild(_loadBar);
			
			
			_updateLabels();
			
			_loadingView.addChild(_loadingMainBG);
			_loadingView.addChild(_loadingTipsBG);
			_loadingView.addChild(_titleLabel);
			_loadingView.addChild(_loadingPercentageBG);
			_loadingView.addChild(_percentageLabel);
			_loadingView.addChild(_tipsLabel);
			_borderOverlay.addChild(_borderLeft);
			_borderOverlay.addChild(_borderRight);
			addChild(_infoLabel);
			this.alpha = 0;
			
			var fadeTimer:Timer = new Timer(20);
			fadeTimer.addEventListener(TimerEvent.TIMER, _fadeIn);
			fadeTimer.start()
			
			
			_onResize(null);

			presenter.sendEvents();
		}

		private function _onDestroy():void
		{
			super.effectsOUT();
			
			_stage.removeEventListener(Event.RESIZE, _onResize);
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown);
			_stage = null;
			
			var fadeTimer:Timer = new Timer(20);
			fadeTimer.addEventListener(TimerEvent.TIMER, _fadeOut);
			fadeTimer.start()
		}
		
		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.fullScreenFadeEffect(.3, .3));
			//_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.CENTER, PositionEnum.CENTER, onResize));
			//_effects.addEffect(EffectFactory.resizeEffect());
		}
		
		private function _onResize(e:Event):void{
			
			_rescaleWithAspectRatio();
			_centerOnStage()
			
			_infoLabel.x = stage.stageWidth - _infoLabel.width;

		}
		
		/*private function onResize():void
		{		
		
			x = (DeviceMetrics.WIDTH_PIXELS - (width * scaleX)) * .5;
			y = (DeviceMetrics.HEIGHT_PIXELS - (height * scaleX)) * .5;
		}*/

		
		
		private function _fadeIn(e:TimerEvent):void{
			var timer:Timer = e.currentTarget as Timer;
			// increase the alpha value by a small amount each time the timer fires
			this.alpha += 0.1;
  
			// stop the animation when the alpha value reaches 1
			if (this.alpha >= 1) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, _fadeOut);
				
			}
		}
		
		private function _fadeOut(e:TimerEvent):void {
			var timer:Timer = e.currentTarget as Timer;
			// decrease the alpha value by a small amount each time the timer fires
			this.alpha -= 0.1;
  
			// stop the animation when the alpha value reaches 0
			if (this.alpha <= 0) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, _fadeOut);
				_destroy();
				
			}
		}
		
		[Inject]
		public function set presenter( value:ITransitionPresenter ):void  { _presenter = value; }
		public function get presenter():ITransitionPresenter  { return ITransitionPresenter(_presenter); }

		override public function get height():Number  { return super.height; }
		override public function get width():Number  { return super.width; }

		override public function get typeUnique():Boolean  { return true; }
		override public function get type():String  { return ViewEnum.ALERT; }

		private function _destroy():void{
			
			_destroyed = true;
			if (presenter == null)
				return;
			if (Application.CONNECTION_STATE != ServerEvent.NEED_CHARACTER_CREATE)
			{
				TimeLog.endTimeLog(TimeLogEnum.GAME_LOAD);
				TimeLog.enabled = false;
			}
			presenter.removeUpdateListener(resetEvents);
			presenter.removeCompleteListener(onServerReady);

			super.destroy();
			_timer.reset();
			_timer = null;
			_infoLabel.destroy();
			_infoLabel = null;
			_percentageLabel.destroy();
			_percentageLabel = null;
			_loadBar.destroy();
			_loadBar = null;
			_tipsLabel.destroy();
			_tipsLabel = null;
			_titleLabel.destroy();
			_titleLabel = null;
			
			
		}
		
		override public function destroy():void
		{			
			_onDestroy();

		}
	}
}
