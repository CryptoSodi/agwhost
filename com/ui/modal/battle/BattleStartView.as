package com.ui.modal.battle
{
	import com.presenter.battle.IBattlePresenter;
	import com.ui.core.View;
	import com.ui.core.component.label.Label;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	public class BattleStartView extends View
	{
		private var _bg:Bitmap;
		private var _endTick:int;
		private var _seconds:int;
		private var _startLabel:Label;
		private var _timerLabel:Label;
		private var _startTick:int;
		private var _timer:Timer;

		private var _startingBattle:String = 'CodeString.BattleBegin.Count'; //Starting battle in:

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addCleanupListener(destroy);
			presenter.addStartListener(destroy);


			_bg = PanelFactory.getPanel("CombatCountdownBGBMD");
			addChild(_bg);

			_startLabel = new Label(20, 0xf0f0f0, _bg.width, 100);
			_startLabel.text = _startingBattle;
			_startLabel.textColor = 0xf0f0f0;
			_startLabel.align = TextFormatAlign.CENTER;
			_startLabel.x = 0;
			_startLabel.y = 45;
			addChild(_startLabel);

			_timerLabel = new Label(30, 0xf0f0f0, 100, 40);
			_timerLabel.text = "00:00:00";
			_timerLabel.textColor = 0xf0f0f0;
			_timerLabel.x = 107;
			_timerLabel.y = 107;
			addChild(_timerLabel);

			onTimer(null);
			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();

			addEffects();
			effectsIN();
		}

		public function update( start:int, end:int ):void
		{
			_startTick = start;
			_endTick = end;
			_seconds = (_endTick - _startTick) * .1 + 1;
			if (_timer)
			{
				onTimer(null);
				_timer.reset();
				_timer.start();
			}
		}

		private function onTimer( e:TimerEvent ):void
		{
			_seconds--;

			if (_seconds < 0)
				_seconds = 0;

			var secondsString:String = "00:00:";

			if (_seconds.toString().length > 1)
				secondsString += _seconds.toString();

			else
				secondsString += "0" + _seconds.toString();

			_timerLabel.text = secondsString;
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IBattlePresenter ):void  { _presenter = value; }
		public function get presenter():IBattlePresenter  { return IBattlePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function destroy():void
		{
			presenter.removeCleanupListener(destroy);
			presenter.removeStartListener(destroy);
			super.destroy();
			_bg = null;
			_startLabel = null;
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.stop();
			_timer = null;
		}
	}
}
