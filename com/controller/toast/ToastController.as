package com.controller.toast
{
	import com.controller.fte.FTEController;
	import com.controller.sound.SoundController;
	import com.enum.ToastEnum;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.ToastEvent;
	import com.event.TransactionEvent;
	import com.model.prototype.IPrototype;
	import com.model.transaction.TransactionVO;
	import com.util.priorityqueue.IPriorityQueue;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	import org.parade.core.IView;
	import org.parade.core.ViewEvent;
	import org.shared.ObjectPool;

	public class ToastController
	{
		private var _currentToast:Toast;
		private var _dispatcher:IEventDispatcher;
		private var _fteController:FTEController;
		private var _limitLookup:Dictionary;
		private var _soundController:SoundController;
		private var _timer:Timer;
		private var _toasts:IPriorityQueue;

		[PostConstruct]
		public function init():void
		{
			_dispatcher.addEventListener(StateEvent.GAME_BATTLE, onStateChange)
			_dispatcher.addEventListener(StateEvent.GAME_SECTOR, onStateChange)
			_dispatcher.addEventListener(StarbaseEvent.WELCOME_BACK, onStateChange)
			_limitLookup = new Dictionary();
			_timer = new Timer(0, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			_toasts = new ToastPriorityQueue();
		}

		public function addTransactionToast( prototype:IPrototype, transaction:TransactionVO ):void
		{
			if (prototype && transaction && !_fteController.running)
			{
				var toastEvent:ToastEvent = new ToastEvent();
				toastEvent.prototype = prototype;
				toastEvent.toastType = transaction.type == TransactionEvent.STARBASE_REPAIR_FLEET ? ToastEnum.FLEET_REPAIRED : ToastEnum.TRANSACTION_COMPLETE;
				toastEvent.transaction = transaction;
				_dispatcher.dispatchEvent(toastEvent);
			}
		}

		public function addToast( type:Object, view:IView ):void
		{
			//if there is a limit to how many of these toasts we can have at once, keep track of it
			if (type.limit > 0)
			{
				if (_limitLookup[type] == null)
					_limitLookup[type] = 0;
				if (_limitLookup[type] == type.limit)
					return;
				_limitLookup[type] += _limitLookup[type] + 1;
			}
			//create a new toast object for storage and tracking
			var toast:Toast = ObjectPool.get(Toast);
			toast.init(type, view);
			//add the toast to the queue
			_toasts.add(toast);
			if (_currentToast == null)
				showToast();
		}

		public function killCurrentToast():void
		{
			if (_currentToast)
				onTimerComplete(null);
		}

		private function onTimerComplete( e:TimerEvent ):void
		{
			_timer.reset()
			//tell the toast to remove itself from the view stack
			_currentToast.view.destroy();
			//if there was a limit to this toast, reduce the count
			if (_currentToast.limit > 0)
			{
				_limitLookup[_currentToast.type] = _limitLookup[_currentToast.type] - 1;
			}
			ObjectPool.give(_currentToast);
			_currentToast = null;
			//show the next toast
			showToast();
		}

		private function showToast():void
		{
			_currentToast = Toast(_toasts.getNext());
			if (_currentToast)
			{
				_timer.delay = _currentToast.duration;
				var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
				viewEvent.targetView = _currentToast.view;
				_dispatcher.dispatchEvent(viewEvent);
				if (_currentToast.sound != null)
					_soundController.playSound(_currentToast.sound, .49);
				_timer.start();
			}
		}

		private function onStateChange( e:Event ):void
		{
			if (!_fteController.running && !_timer.running && _currentToast == null)
				showToast();
		}

		[Inject]
		public function set dispatcher( v:IEventDispatcher ):void  { _dispatcher = v; }
		[Inject]
		public function set fteController( v:FTEController ):void  { _fteController = v; }
		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v; }
	}
}
