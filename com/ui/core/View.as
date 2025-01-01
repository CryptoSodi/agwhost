package com.ui.core
{
	import com.Application;
	import com.controller.keyboard.KeyboardController;
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.event.ToastEvent;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;
	import com.ui.alert.ConfirmationView;
	import com.ui.alert.InputAlertView;
	import com.ui.core.effects.EffectFactory;
	import com.ui.core.effects.GenericMoveEffect;
	import com.ui.core.effects.ViewEffects;

	import flash.display.Sprite;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.parade.enum.ViewEnum;
	import org.robotlegs.extensions.localEventMap.api.IEventMap;
	import org.robotlegs.extensions.localEventMap.impl.EventMap;
	import org.shared.ObjectPool;

	public class View extends Sprite implements IView
	{
		protected var _effects:ViewEffects;
		protected var _eventMap:IEventMap = new EventMap(null);
		protected var _keyboard:KeyboardController;
		protected var _mute:Boolean       = false;
		protected var _presenter:IImperiumPresenter;
		protected var _viewFactory:IViewFactory;

		[PostConstruct]
		public function init():void
		{
			// PR: Removing the creation of the event map that was here. No longer nulling eventMap out on destroy
			// all events will be removed from the map so when object pooling we can reuse the existing one without having to create a new one
			_presenter && _presenter.addStateListener(onStateChange) && _presenter.highfive();
			addListener(this, MouseEvent.RIGHT_MOUSE_DOWN, onRightMouse);
			addListener(this, MouseEvent.MOUSE_DOWN, onMouseDown);
			addListener(this, MouseEvent.MOUSE_WHEEL, onMouseDown);
			_effects = ObjectPool.get(ViewEffects);
			_effects.addInListener(effectsDoneIn);
			_effects.addOutListener(effectsDoneOut);
		}

		protected function onMouseDown( e:MouseEvent ):void
		{
			e.stopPropagation();
		}

		protected function onRightMouse( e:MouseEvent ):void
		{
			e.stopPropagation();
		}

		public function onEscapePressed():void
		{
			if ((type == ViewEnum.MODAL || type == ViewEnum.HOVER || type == ViewEnum.ALERT) && _presenter && !_presenter.inFTE)
				destroy();
		}

		protected function addHitArea( hitArea:Sprite = null ):void
		{
			if (hitArea == null)
			{
				hitArea = new Sprite();
				hitArea.mouseEnabled = false;
			}
			this.hitArea = hitArea;
		}

		protected function onStateChange( state:String ):void  { destroy(); }

		protected function onClose( e:MouseEvent = null ):void  { destroy(); }

		//- EFFECT CONTROLS -----------------------------------------------------------------------------

		protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.resizeEffect());
			_effects.addEffect(EffectFactory.simpleBackingEffect(.75, 0, 0));
			_effects.addEffect(EffectFactory.genericMoveEffect(GenericMoveEffect.UP, GenericMoveEffect.UP, .5, .3));
		}

		protected function effectsIN():void  { _effects && _effects.effectsIn(this); }
		protected function effectsDoneIn():void  {}
		protected function effectsOUT():void  { _effects && _effects.effectsOut(this); }
		protected function effectsDoneOut():void
		{
			if (_viewFactory)
			{
				ObjectPool.give(_effects);
				_effects = null;

				while (numChildren > 0)
					removeChildAt(0);

				if (this.parent != null)
					this.parent.removeChild(this);

				_viewFactory.destroyView(this);
				_viewFactory = null;
			}
		}

		//- --------------------------------------------------------------------------------------------

		protected function showView( view:Class, notify:Boolean = true ):IView
		{
			var nview:IView = _viewFactory.createView(view);
			if (notify)
				_viewFactory.notify(nview);

			if (!_mute)
				SoundController.instance.playSound(AudioEnum.AFX_UI_WINDOW_OPEN, 0.5);

			return nview;
		}

		protected function showInputAlert( alertTitle:String, alertBody:String, btnOneText:String, btnOneCallback:Function, btnOneArgs:Array, btnTwoText:String, btnTwoCallback:Function, btnTwoArgs:Array,
										   onCloseUseBtnTwo:Boolean = false, maxCharacters:int = 12, defaultInputText:String = '', clearInputOnFocus:Boolean = false, restrict:String = '', notify:Boolean =
										   true ):IView
		{
			return _viewFactory.createAlert(alertTitle, alertBody, btnOneText, btnOneCallback, btnOneArgs, btnTwoText, btnTwoCallback, btnTwoArgs, onCloseUseBtnTwo, maxCharacters, defaultInputText, clearInputOnFocus,
											restrict,
											notify, InputAlertView);
		}

		protected function showConfirmation( title:String, body:String, buttons:Vector.<ButtonPrototype> ):IView
		{
			var view:ConfirmationView = ConfirmationView(_viewFactory.createView(ConfirmationView));
			view.setup(title, body, buttons);
			_viewFactory.notify(view);
			return view;
		}

		protected function showToast( type:Object, prototype:IPrototype = null, ... strings ):void
		{
			if (!_presenter)
				return;

			var toastEvent:ToastEvent = new ToastEvent();
			toastEvent.toastType = type;
			toastEvent.prototype = prototype;
			if (strings)
				toastEvent.addStringsFromArray(strings);
			_presenter.dispatch(toastEvent);
		}

		public function addListener( dispatcher:IEventDispatcher, type:String, listener:Function, eventClass:Class = null, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true ):void
		{
			_eventMap.mapListener(dispatcher, type, listener, eventClass, useCapture, priority, useWeakReference);
		}

		public function removeListener( dispatcher:IEventDispatcher, type:String, listener:Function ):void
		{
			_eventMap.unmapListener(dispatcher, type, listener);
		}

		public function get bounds():Rectangle  { if (!parent) return getBounds(Application.STAGE); return getBounds(parent); }
		public function get effects():ViewEffects  { return _effects; }
		public function get type():String  { return ViewEnum.MODAL; }
		public function get typeUnique():Boolean  { return false; }
		public function get screenshotBlocker():Boolean {return false;}

		[Inject]
		public function set keyboard( value:KeyboardController ):void  { _keyboard = value; }
		[Inject]
		public function set viewFactory( value:IViewFactory ):void  { _viewFactory = value; }

		public function destroy():void
		{
			_eventMap && _eventMap.unmapListeners();

			_presenter && _presenter.removeStateListener(onStateChange) && _presenter.shun();
			_presenter = null;

			if (!_mute)
				SoundController.instance.playSound(AudioEnum.AFX_UI_WINDOW_CLOSE, 0.5);

			_keyboard = null;
			effectsOUT();

			_mute = false;
		}
	}
}
