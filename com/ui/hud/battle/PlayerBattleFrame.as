package com.ui.hud.battle
{
	import com.enum.ui.PanelEnum;
	import com.model.player.PlayerVO;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class PlayerBattleFrame extends Sprite
	{
		private var _bg:ScaleBitmap;
		private var _barBG:Bitmap;

		private var _firstBubbleMarker:Bitmap;
		private var _secondBubbleMarker:Bitmap;
		private var _thirdBubbleMarker:Bitmap;

		private var _avatarFrame:ScaleBitmap;

		private var _avatar:ImageComponent;

		private var _healthBar:ProgressBar;

		private var _levelLbl:Label;
		private var _nameLbl:Label;

		private var _flipped:Boolean;

		private var _player:PlayerVO;

		private var _redFilter:ColorMatrixFilter;
		private var _orangeFilter:ColorMatrixFilter;
		private var _yellowFilter:ColorMatrixFilter;
		private var _greenFilter:ColorMatrixFilter;

		private var _currentFilter:ColorMatrixFilter;

		private var _level:String = 'CodeString.Shared.Level'; //Level [[Number.Level]];

		public function PlayerBattleFrame( player:PlayerVO, flip:Boolean = false )
		{
			super();

			_player = player;

			mouseEnabled = false;

			_greenFilter = CommonFunctionUtil.getColorMatrixFilter(0x3cf219);
			_yellowFilter = CommonFunctionUtil.getColorMatrixFilter(0xfbe81a);
			_orangeFilter = CommonFunctionUtil.getColorMatrixFilter(0xfa7d0e);
			_redFilter = CommonFunctionUtil.getColorMatrixFilter(0xf81919);

			_currentFilter = _greenFilter;

			_flipped = flip;

			_bg = UIFactory.getScaleBitmap((flip) ? PanelEnum.ENEMY_CONTAINER_NOTCHED : PanelEnum.PLAYER_CONTAINER_NOTCHED);
			_bg.width = 197;
			_bg.height = 76;

			_avatarFrame = UIFactory.getScaleBitmap(PanelEnum.CHARACTER_FRAME);
			_avatarFrame.width = 75;
			_avatarFrame.height = 75;

			_avatar = ObjectPool.get(ImageComponent);
			_avatar.init(70, 70);
			_avatar.center = true;

			_nameLbl = new Label(18, 0xffffff, 190, 33);
			_nameLbl.bold = true;

			_levelLbl = new Label(16, 0xf0f0f0, 190, 34);
			_levelLbl.allCaps = true;

			_barBG = UIFactory.getBitmap(PanelEnum.PLAYER_HEALTH_BG);
			_barBG.width = 186;

			var health:Bitmap = UIFactory.getBitmap(PanelEnum.STATBAR_GREY);
			health.width = 176;
			health.height = 21;

			_healthBar = ObjectPool.get(ProgressBar);
			_healthBar.init(ProgressBar.HORIZONTAL, health, null, 0.15, flip);
			_healthBar.setMinMax(0, 1);
			_healthBar.filters = [_currentFilter];

			addChild(_bg);
			addChild(_avatar);
			addChild(_avatarFrame);
			addChild(_nameLbl);
			addChild(_levelLbl);
			addChild(_barBG);
			addChild(_healthBar);

			layout();
		}

		private function layout():void
		{
			if (!_flipped)
			{
				_bg.x = 78;

				_levelLbl.align = TextFormatAlign.LEFT;

				_nameLbl.align = TextFormatAlign.LEFT;

				_barBG.x = _bg.x + 5;

				_nameLbl.x = _levelLbl.x = _bg.x + 3;

				_healthBar.x = _barBG.x + 5;
			} else
			{

				_bg.x = 0;

				_barBG.x = 5;
				_avatar.x = _avatarFrame.x = _bg.x + _bg.width + 5;

				_healthBar.x = _barBG.x + 5;

				_levelLbl.align = TextFormatAlign.RIGHT;
				_nameLbl.align = TextFormatAlign.RIGHT;

				_levelLbl.x = _nameLbl.x = 2;
			}

			_levelLbl.y = 19;
		}

		public function onAvatarLoaded( asset:BitmapData ):void
		{
			if (_avatar && _avatarFrame && asset)
			{
				_avatar.onImageLoaded(asset);

				_avatar.x = _avatarFrame.x + (_avatarFrame.width - _avatar.width) * 0.5;
				_avatar.y = _avatarFrame.y + (_avatarFrame.height - _avatar.height) * 0.5;
			}
		}

		public function set level( v:String ):void
		{
			if (_levelLbl)
			{
				_levelLbl.setTextWithTokens(_level, {'[[Number.Level]]':v});
				if (_barBG)
					_barBG.y = _levelLbl.y + _levelLbl.textHeight + 4;

				if (_healthBar)
					_healthBar.y = _barBG.y + 4;
			}
		}
		override public function set name( v:String ):void  { _nameLbl.text = v; }
		public function get percent():Number  { return _healthBar.amount; }
		public function set percent( v:Number ):void
		{
			_healthBar.amount = v;
			var newFilter:ColorMatrixFilter = getHealthColor(v);
			if (_currentFilter != newFilter)
			{
				_currentFilter = newFilter
				_healthBar.filters = [_currentFilter];
			}
		}

		public function setBubbleInformation( firstBubblePercent:Number, secondBubblePercent:Number, thirdBubblePercent:Number ):void
		{
			_firstBubbleMarker = UIFactory.getBitmap('TabDivider');
			_firstBubbleMarker.x = _healthBar.x + 176 * firstBubblePercent;
			_firstBubbleMarker.y = _healthBar.y + (_healthBar.height - _firstBubbleMarker.height) * 0.5;

			_secondBubbleMarker = UIFactory.getBitmap('TabDivider');
			_secondBubbleMarker.x = _healthBar.x + 176 * secondBubblePercent;
			_secondBubbleMarker.y = _healthBar.y + (_healthBar.height - _firstBubbleMarker.height) * 0.5;

			_thirdBubbleMarker = UIFactory.getBitmap('TabDivider');
			_thirdBubbleMarker.x = _healthBar.x + 176 * thirdBubblePercent;
			_thirdBubbleMarker.y = _healthBar.y + (_healthBar.height - _firstBubbleMarker.height) * 0.5;

			addChild(_firstBubbleMarker);
			addChild(_secondBubbleMarker);
			addChild(_thirdBubbleMarker);
		}

		private function getHealthColor( healthValue:Number ):ColorMatrixFilter
		{

			if (healthValue >= 0.75)
				return _greenFilter;
			else if (healthValue >= 0.50)
				return _yellowFilter;
			else if (healthValue >= 0.25)
				return _orangeFilter;
			else
				return _redFilter;
		}

		public function get isNPC():Boolean
		{
			return _player.isNPC;
		}

		public function get faction():String  { return _player.faction; }
		public function get id():String  { return _player.id; }

		public function destroy():void
		{
			_bg = null;
			_barBG = null;
			_firstBubbleMarker = null;
			_secondBubbleMarker = null;
			_thirdBubbleMarker = null;

			_avatarFrame = null;

			if (_avatar)
				ObjectPool.give(_avatar);

			_avatar = null;

			if (_healthBar)
				ObjectPool.give(_healthBar);

			_healthBar = null;

			if (_nameLbl)
				_nameLbl.destroy();

			_nameLbl = null;

			if (_levelLbl)
				_levelLbl.destroy();

			_levelLbl = null;
		}
	}
}
