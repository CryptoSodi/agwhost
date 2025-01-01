package com.ui.modal.store
{
	import com.model.transaction.TransactionVO;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;

	public class StoreTransactionButton extends BitmapButton
	{
		public var onClicked:Signal;

		private var _transaction:TransactionVO;
		private var _token:int;
		private var _arrow:Bitmap;
		private var _currentState:String;
		private var _timerText:Label;
		private var _transactionTopText:Label;
		private var _transactionBottomText:Label;
		private var _offlineText:Label;
		private var _timer:Timer;
		private var _windowID:int;

		private var _offlineStatusText:String = 'CodeString.Store.UnavailableBtn'; //Unavailable
		private var _pendingText:String       = 'CodeString.Shared.Pending'; //Pending
		private var _emptyText:String;

		override public function init( upSkin:BitmapData, overSkin:BitmapData = null, downSkin:BitmapData = null, disabledSkin:BitmapData = null, selectSkin:BitmapData = null ):void
		{
			super.init(upSkin, overSkin, downSkin, disabledSkin, selectSkin);

			windowID = -1;

			var arrowClass:Class = Class(getDefinitionByName(('StoreArrowBMD')));

			_timerText = new Label(11, 0xd5eaff, _bitmap.width, 25, true, 1);
			_timerText.align = TextFormatAlign.RIGHT;

			_transactionTopText = new Label(11, 0xd5eaff, _bitmap.width, 25, true, 1);
			_transactionTopText.align = TextFormatAlign.LEFT;

			_transactionBottomText = new Label(14, 0xf0f0f0, _bitmap.width, 25, true, 1);
			_transactionBottomText.align = TextFormatAlign.LEFT;
			_transactionBottomText.y = _bitmap.y + (_bitmap.height - _transactionBottomText.height) * 0.5;

			_offlineText = new Label(24, 0x929699, _bitmap.width, _bitmap.height);
			_offlineText.align = TextFormatAlign.LEFT;
			_offlineText.text = _offlineStatusText;
			_offlineText.visible = false;
			_offlineText.y = _bitmap.y + (_bitmap.height - _offlineText.textHeight) * 0.5;


			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);

			_arrow = new Bitmap(BitmapData(new arrowClass()));
			_arrow.x = _bitmap.width - _arrow.width;
			_arrow.y = (_bitmap.height - _arrow.height) * 0.5
			_arrow.visible = false;

			addChild(_arrow);
			addChild(_timerText);
			addChild(_transactionTopText);
			addChild(_transactionBottomText);
			addChild(_offlineText);

			onClicked = new Signal(StoreTransactionButton);
		}

		public function update( transaction:TransactionVO ):void
		{
			_transaction = transaction;
			var currentTime:int = _transaction.timeRemainingMS;
			if (currentTime >= 0)
				_timerText.setBuildTime(currentTime * 0.001);
			else
				_timerText.text = _pendingText;
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			update(_transaction);
		}

		public function set transaction( transaction:TransactionVO ):void
		{
			_transaction = transaction;
			if (_transaction)
			{
				selectable = true;
				_transaction = transaction;
				_transactionBottomText.y = 19;
				_timerText.visible = true;
				_transactionTopText.visible = true;
				update(_transaction);
				_timer.start();
			} else
			{
				if (_timer.running)
					_timer.stop();

				selectable = false;
				_timerText.visible = false;
				_transactionTopText.visible = false;
				if (_emptyText != null)
					_transactionBottomText.text = _emptyText;

				_transactionBottomText.y = _bitmap.y + (_bitmap.height - _transactionBottomText.height) * 0.5;
			}
		}

		override protected function onMouse( e:MouseEvent ):void
		{
			super.onMouse(e);
			if (mouseEnabled)
			{
				if (e.type == MouseEvent.CLICK)
				{
					onClicked.dispatch(this);
				} else if (e.type == MouseEvent.ROLL_OUT)
				{
					if (_transaction == null && _windowID != -1)
						_arrow.visible = false;
				} else if (e.type == MouseEvent.ROLL_OVER)
				{
					if (_transaction == null && _windowID != -1)
						_arrow.visible = true;
				}
			}
		}

		public function set emptyText( v:String ):void
		{
			_emptyText = v;
			if (_transaction == null)
				_transactionBottomText.text = _emptyText;
		}

		override public function set enabled( value:Boolean ):void
		{
			super.enabled = value;
			if (_transactionBottomText != null)
			{
				if (value)
				{
					_transactionBottomText.visible = true;
					_offlineText.visible = false;
				} else
				{
					_transactionBottomText.visible = false;
					_offlineText.visible = true;
				}
			}
		}

		public function set windowID( v:int ):void  { _windowID = v; }
		public function get windowID():int  { return _windowID; }
		public function get topTransactionText():Label  { return _transactionTopText; }
		public function get bottomTransactionText():Label  { return _transactionBottomText; }
		public function get transaction():TransactionVO  { return _transaction; }
		public function get serverKey():String  { return _transaction.serverKey; }
		public function get timeRemaining():uint  { return _transaction.timeRemainingMS; }
		public function set token( v:int ):void  { _token = v; }
		public function get token():int  { return _token; }

		override public function destroy():void
		{
			super.destroy();
			if (_timer.running)
				_timer.stop()

			_timer = null;

			onClicked.removeAll();
		}
	}
}
