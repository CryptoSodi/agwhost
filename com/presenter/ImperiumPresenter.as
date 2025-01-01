package com.presenter
{
	import com.controller.fte.FTEController;
	import com.controller.sound.SoundController;
	import com.event.StateEvent;

	import org.osflash.signals.Signal;
	import org.robotlegs.extensions.presenter.impl.Presenter;

	public class ImperiumPresenter extends Presenter implements IImperiumPresenter
	{
		protected static var _hudEnabled:Boolean = true;

		protected var _fteController:FTEController;
		protected var _soundController:SoundController;
		protected var _stateChangeSignal:Signal;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_stateChangeSignal = new Signal(String);

			addContextListener(StateEvent.GAME_STARBASE_CLEANUP, onStateChange, StateEvent);
			addContextListener(StateEvent.GAME_BATTLE_CLEANUP, onStateChange, StateEvent);
			addContextListener(StateEvent.GAME_SECTOR_CLEANUP, onStateChange, StateEvent);
			addContextListener(StateEvent.GAME_STARBASE, onStateChange, StateEvent);
			addContextListener(StateEvent.GAME_BATTLE, onStateChange, StateEvent);
			addContextListener(StateEvent.GAME_SECTOR, onStateChange, StateEvent);
		}

		public function playSound( sound:String, volume:Number = 0.5 ):void  { _soundController.playSound(sound, volume); }

		public function addStateListener( callback:Function ):Boolean  { _stateChangeSignal.add(callback); return true; }
		public function removeStateListener( callback:Function ):Boolean  { _stateChangeSignal.remove(callback); return true; }

		protected function removeContextListeners():Boolean
		{
			removeContextListener(StateEvent.GAME_STARBASE_CLEANUP, onStateChange, StateEvent);
			removeContextListener(StateEvent.GAME_BATTLE_CLEANUP, onStateChange, StateEvent);
			removeContextListener(StateEvent.GAME_SECTOR_CLEANUP, onStateChange, StateEvent);
			removeContextListener(StateEvent.GAME_STARBASE, onStateChange, StateEvent);
			removeContextListener(StateEvent.GAME_BATTLE, onStateChange, StateEvent);
			removeContextListener(StateEvent.GAME_SECTOR, onStateChange, StateEvent);
			return true;
		}

		protected function onStateChange( e:StateEvent ):void
		{
			_hudEnabled = true;
			_stateChangeSignal.dispatch(e.type);
		}

		public function get hudEnabled():Boolean  { return _hudEnabled; }
		public function set hudEnabled( value:Boolean ):void  { _hudEnabled = value; }

		public function get inFTE():Boolean  { return _fteController.running; }

		[Inject]
		public function set fteController( v:FTEController ):void  { _fteController = v; }
		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v; }

		override public function destroy():void
		{
			removeContextListeners();
			super.destroy();

			_fteController = null;
			_soundController = null;
			_stateChangeSignal.removeAll();
			_stateChangeSignal = null;
		}
	}
}
