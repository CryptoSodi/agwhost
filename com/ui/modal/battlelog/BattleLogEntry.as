package com.ui.modal.battlelog
{
	import com.enum.ui.ButtonEnum;
	import com.model.battlelog.BattleLogBaseInfoVO;
	import com.model.battlelog.BattleLogPlayerInfoVO;
	import com.model.battlelog.BattleLogVO;
	import com.model.player.CurrentUser;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class BattleLogEntry extends BitmapButton
	{
		private var _bg:Bitmap;

		private var _currentUserImage:ImageComponent;
		private var _currentUserPortraitFrame:Bitmap;
		private var _currentUserName:Label;
		private var _currentUserOutcome:Label;
		private var _currentUserRating:Label;

		private var _enemyPlayerImage:ImageComponent;
		private var _enemyPlayerPortraitFrame:Bitmap;
		private var _enemyPlayerName:Label;
		private var _enemyPlayerOutcome:Label;
		private var _enemyRating:Label;

		private var _viewReplayBtn:BitmapButton;

		private var _battleOutcome:Label;
		private var _timeSinceBattle:Label;

		private var _battleLog:BattleLogVO;

		public var onClicked:Signal;
		public var onReplayClicked:Signal;
		public var onLoadImage:Signal;

		private var _victory:String             = 'CodeString.BattleLog.Victory';
		private var _defeat:String              = 'CodeString.BattleLog.Defeat';
		private var _draw:String                = 'CodeString.BattleLog.Draw';
		private var _victoryParens:String       = 'CodeString.BattleLog.VictoryParens';
		private var _defeatParens:String        = 'CodeString.BattleLog.DefeatParens';
		private var _drawParens:String          = 'CodeString.BattleLog.DrawParens';
		private var _fleetRatingText:String     = 'CodeString.BattleLogs.FleetRating';
		private var _baseRatingText:String      = 'CodeString.BattleLogs.BaseRating';
		private var _timeSinceBattleText:String = 'CodeString.BattleLog.TimeSinceBattle';
		private var _viewReplayText:String      = 'CodeString.BattleLog.ViewReplay'; //VIEW REPLAY

		public function BattleLogEntry( battleLog:BattleLogVO )
		{
			onClicked = new Signal(BattleLogVO);
			onReplayClicked = new Signal(BattleLogVO);
			onLoadImage = new Signal(String, Function);

			_battleLog = battleLog;
			var windowBGClass:Class = Class(getDefinitionByName('BattleLogContainerBMD'));

			_currentUserImage = ObjectPool.get(ImageComponent);
			_currentUserImage.init(2000, 2000);
			_currentUserImage.x = 6;
			_currentUserImage.y = 9;

			_currentUserPortraitFrame = new Bitmap();
			_currentUserPortraitFrame.x = 2;
			_currentUserPortraitFrame.y = 6;

			_currentUserName = new Label(24, 0xf0f0f0, 300, 25, false);
			_currentUserName.x = 95;
			_currentUserName.y = 15;
			_currentUserName.align = TextFormatAlign.LEFT;

			_currentUserRating = new Label(20, 0xfbefaf, 300, 25);
			_currentUserRating.x = 95;
			_currentUserRating.y = 38;
			_currentUserRating.align = TextFormatAlign.LEFT;

			_currentUserOutcome = new Label(20, 0xf0f0f0, 300, 25);
			_currentUserOutcome.x = 95;
			_currentUserOutcome.y = 64;
			_currentUserOutcome.align = TextFormatAlign.LEFT;

			var replayButtonWidth:int = 130;

			_enemyPlayerImage = ObjectPool.get(ImageComponent);
			_enemyPlayerImage.init(2000, 2000);
			_enemyPlayerImage.x = 601-replayButtonWidth;
			_enemyPlayerImage.y = 9;

			_enemyPlayerPortraitFrame = new Bitmap();
			_enemyPlayerPortraitFrame.x = 597-replayButtonWidth;
			_enemyPlayerPortraitFrame.y = 6;

			_enemyPlayerName = new Label(24, 0xf0f0f0, 300, 25, false);
			_enemyPlayerName.x = 289-replayButtonWidth;
			_enemyPlayerName.y = 15;
			_enemyPlayerName.align = TextFormatAlign.RIGHT;

			_enemyRating = new Label(20, 0xfbefaf, 300, 25);
			_enemyRating.x = 289-replayButtonWidth;
			_enemyRating.y = 38;
			_enemyRating.align = TextFormatAlign.RIGHT;

			_enemyPlayerOutcome = new Label(20, 0xf0f0f0, 300, 25);
			_enemyPlayerOutcome.x = 289-replayButtonWidth;
			_enemyPlayerOutcome.y = 64;
			_enemyPlayerOutcome.align = TextFormatAlign.RIGHT;

			super.init(BitmapData(new windowBGClass()));

			if( battleLog.hasReplay )
			{
				_viewReplayBtn = UIFactory.getButton(ButtonEnum.BLUE_A, replayButtonWidth-8, 50, _bitmap.width - replayButtonWidth, 20, _viewReplayText);
				_viewReplayBtn.visible = true;
				_viewReplayBtn.addEventListener(MouseEvent.MOUSE_UP, onViewReplayButtonClick, false, 0, true);
			}
			
			_battleOutcome = new Label(40, 0xf0f0f0);
			_battleOutcome.constrictTextToSize = false;
			_battleOutcome.autoSize = TextFieldAutoSize.CENTER;
			_battleOutcome.x = _bitmap.x + _bitmap.width * 0.5 - replayButtonWidth * 0.5;

			_timeSinceBattle = new Label(16, 0xfbefaf, 200);
			_timeSinceBattle.align = TextFormatAlign.LEFT;
			_timeSinceBattle.constrictTextToSize = false;
			_timeSinceBattle.x = 10;
			_timeSinceBattle.y -= _timeSinceBattle.height;

			addChild(_currentUserImage);
			addChild(_currentUserPortraitFrame);
			addChild(_currentUserName);
			addChild(_currentUserRating);
			addChild(_currentUserOutcome);

			addChild(_enemyPlayerImage);
			addChild(_enemyPlayerPortraitFrame);
			addChild(_enemyPlayerName);
			addChild(_enemyRating);
			addChild(_enemyPlayerOutcome);

			if( _viewReplayBtn )
			{
				addChild( _viewReplayBtn );
			}

			addChild(_battleOutcome);
			addChild(_timeSinceBattle);
		}

		public function setUp():void
		{
			var i:uint;
			var currentPlayer:BattleLogPlayerInfoVO;
			var winners:Vector.<BattleLogPlayerInfoVO> = _battleLog.winners;
			var losers:Vector.<BattleLogPlayerInfoVO>  = _battleLog.losers;
			var len:uint                               = winners.length;
			var enemyPlayer:BattleLogPlayerInfoVO;
			var currentUser:BattleLogPlayerInfoVO;
			var currentUsersIndex:int;
			var currentUserInWinners:Boolean;
			for (; i < len; ++i)
			{
				currentPlayer = winners[i];
				if (currentPlayer.playerKey == CurrentUser.id)
				{
					currentUserInWinners = true;
					currentUser = currentPlayer;
					currentUsersIndex = i;
					break;
				}

			}

			if (currentUser == null)
			{
				len = losers.length;
				for (i = 0; i < len; ++i)
				{
					currentPlayer = losers[i];
					if (currentPlayer.playerKey == CurrentUser.id)
					{
						currentUser = currentPlayer;
						currentUsersIndex = i;
						break;
					}
				}
			}
			
			if( currentUser == null && winners.length)
			{
				currentUser = winners[0];
				currentUserInWinners = true;
			}
			else if( currentUser == null && losers.length)
			{
				currentUser = losers[0];
				currentUserInWinners = false;
			}

			if (currentUserInWinners)
			{
				enemyPlayer = losers[0];
				_currentUserOutcome.text = _victoryParens;
				_battleOutcome.text = _victory;
				_battleOutcome.textColor = _currentUserOutcome.textColor = 0xffdd3d;
				_enemyPlayerOutcome.text = _defeatParens;
				_enemyPlayerOutcome.textColor = 0xec1f1f;
			} else if (!currentUserInWinners && winners.length < 1)
			{
				enemyPlayer = (currentUsersIndex + 1 > (losers.length - 1)) ? losers[0] : losers[currentUsersIndex + 1];
				_currentUserOutcome.text = _drawParens;
				_battleOutcome.text = _draw;
				_battleOutcome.textColor = _currentUserOutcome.textColor = 0xec1f1f;
				_enemyPlayerOutcome.text = _drawParens;
				_enemyPlayerOutcome.textColor = 0xec1f1f;
			} else
			{
				enemyPlayer = winners[0];
				_currentUserOutcome.text = _defeatParens;
				_battleOutcome.text = _defeat;
				_battleOutcome.textColor = _currentUserOutcome.textColor = 0xec1f1f;
				_enemyPlayerOutcome.text = _victoryParens;
				_enemyPlayerOutcome.textColor = 0xffdd3d;
			}

			_timeSinceBattle.setBuildTime(_battleLog.timeSince / 1000, 3);
			_timeSinceBattle.setTextWithTokens(_timeSinceBattleText, {'[[String.TimeSinceLastBattle]]':_timeSinceBattle.text});

			var currentUserFactionColor:uint           = CommonFunctionUtil.getFactionColor(currentUser.faction);
			var enemyUserFactionColor:uint             = CommonFunctionUtil.getFactionColor(enemyPlayer.faction);

			var portraitFrameClass:Class               = Class(getDefinitionByName('BattleLogSmallPortraitFrameBMD'));

			var playerBMD:BitmapData                   = BitmapData(new portraitFrameClass());
			playerBMD.applyFilter(playerBMD, playerBMD.rect, new Point(0, 0), CommonFunctionUtil.getColorMatrixFilter(currentUserFactionColor));

			var enemyBMD:BitmapData                    = BitmapData(new portraitFrameClass());
			enemyBMD.applyFilter(enemyBMD, enemyBMD.rect, new Point(0, 0), CommonFunctionUtil.getColorMatrixFilter(enemyUserFactionColor));

			onLoadImage.dispatch(currentUser.race, _currentUserImage.onImageLoaded);
			var rating:String                          = (currentUser.wasBase) ? _baseRatingText : _fleetRatingText;
			_currentUserName.text = currentUser.name;
			_currentUserName.textColor = currentUserFactionColor;
			_currentUserPortraitFrame.bitmapData = playerBMD;
			_currentUserRating.setTextWithTokens(rating, {'[[Number.Rating]]':currentUser.rating});


			onLoadImage.dispatch(enemyPlayer.race, _enemyPlayerImage.onImageLoaded);
			rating = (enemyPlayer.wasBase) ? _baseRatingText : _fleetRatingText;
			_enemyPlayerName.text = enemyPlayer.name;
			_enemyPlayerName.textColor = enemyUserFactionColor;
			_enemyPlayerPortraitFrame.bitmapData = enemyBMD;
			_enemyRating.setTextWithTokens(rating, {'[[Number.Rating]]':enemyPlayer.rating});


			_battleOutcome.y = _bitmap.y + (_bitmap.height - _battleOutcome.textHeight) * 0.5;
		}

		public function get timeOccurred():Number  { return _battleLog.timeSince; }
		public function get battleKey():String  { return _battleLog.battleKey; }

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				switch (e.type)
				{
					case MouseEvent.CLICK:
						onClicked.dispatch(_battleLog);
						break;
				}
			}
		}

		private function onViewReplayButtonClick( e:MouseEvent ):void
		{
			onReplayClicked.dispatch( _battleLog );
		}		

		override public function destroy():void
		{
			super.destroy();

			onClicked.removeAll();
			onClicked = null;

			onReplayClicked.removeAll();
			onReplayClicked = null;

			onLoadImage.removeAll();
			onLoadImage = null;

			_bg = null;

			ObjectPool.give(_currentUserImage);

			_currentUserPortraitFrame = null;

			_currentUserName.destroy();
			_currentUserName = null;

			_currentUserOutcome.destroy();
			_currentUserOutcome = null;

			_currentUserRating.destroy();
			_currentUserRating = null;


			ObjectPool.give(_enemyPlayerImage);

			_enemyPlayerPortraitFrame = null;

			_enemyPlayerName.destroy();
			_enemyPlayerName = null;

			_enemyPlayerOutcome.destroy();
			_enemyPlayerOutcome = null;

			_enemyRating.destroy();
			_enemyRating = null;

			_battleOutcome.destroy();
			_battleOutcome = null;

			_timeSinceBattle.destroy();
			_timeSinceBattle = null;
			
			if (_viewReplayBtn)
			{
				_viewReplayBtn.destroy();
			}
			_viewReplayBtn = null;
			

			_battleLog = null;
		}
	}
}
