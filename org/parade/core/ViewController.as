package org.parade.core
{
	import com.controller.keyboard.KeyboardController;
	import com.controller.keyboard.KeyboardKey;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.parade.enum.ViewEnum;

	public class ViewController
	{
		private var _currentViews:Vector.<IView>;
		private var _eventDispatcher:IEventDispatcher;
		private var _keyboardController:KeyboardController;
		private var _modalCount:int = 0;
		private var _viewQueue:Vector.<IView>;
		private var _ScreenshotModeOn:Boolean = false;
		private var _ControlOn:Boolean = false;

		[PostConstruct]
		public function init():void
		{
			_currentViews = new Vector.<IView>;
			_keyboardController.addKeyUpListener(onEscapePressed, KeyboardKey.ESCAPE.keyCode);
			_keyboardController.addKeyUpListener(onToggleScreenShotMode, KeyboardKey.SLASH.keyCode);
			_keyboardController.addKeyUpListener(onControlReleased, KeyboardKey.CONTROL.keyCode);
			_keyboardController.addKeyDownListener(onControlPressed, KeyboardKey.CONTROL.keyCode);
			_viewQueue = new Vector.<IView>;
		}

		/**
		 * Attempts to add a view to the display
		 * The view can be added if:
		 * 1) If the view is type unique then need to ensure there are no views of that type currently visible
		 * 2) There are no views, currently visible, that are type unique
		 * @param view The view to add
		 * @return true if the view was added or false if not
		 */
		public function addView( view:IView ):Boolean
		{
			if(view && view.screenshotBlocker)
				view.visible = !_ScreenshotModeOn;
			
			if (!canAddView(view))
			{
				_viewQueue.unshift(view);
				return false;
			}
			
			if (view.type == ViewEnum.MODAL || view.type == ViewEnum.ALERT || view.type == ViewEnum.ERROR)
				_modalCount++;
			_currentViews.push(view);
			return true;
		}
		
		public function showView(view:IView, show:Boolean):void
		{
			if(show && view.screenshotBlocker)
				view.visible = !_ScreenshotModeOn;
			else
				view.visible = show;
		}

		public function getView( viewClass:Class ):IView
		{
			var object:*;
			for (var i:int = 0; i < _currentViews.length; i++)
			{
				object = _currentViews[i];
				var type:Class = Class(getDefinitionByName(getQualifiedClassName(object)));
				if (type == viewClass)
					return _currentViews[i];
			}
			for (i = 0; i < _viewQueue.length; i++)
			{
				object = _viewQueue[i];
				type = Class(getDefinitionByName(getQualifiedClassName(object)));
				if (type == viewClass)
					return _viewQueue[i];
			}
			return null;
		}

		public function removeFromQueue( viewClass:Class ):void
		{
			var object:*;
			var i:int = _viewQueue.length - 1;
			while (i >= 0)
			{
				object = _viewQueue[i];
				var type:Class = Class(getDefinitionByName(getQualifiedClassName(object)));
				if (type == viewClass)
				{
					_viewQueue.splice(i, 1);
				}
				i--;
			}
		}

		public function emptyQueue():void  { _viewQueue.length = 0; }

		public function destroyView( view:IView ):void
		{
			var index:int = _currentViews.indexOf(view);
			if (index != -1)
			{
				if (view.type == ViewEnum.MODAL || view.type == ViewEnum.ALERT || view.type == ViewEnum.ERROR)
					_modalCount--;
				var removed:Vector.<IView> = _currentViews.splice(index, 1);
				checkViewQueue(removed[0].type);
			}
		}
		
		public function updateScreenshotMode():void
		{
			setScreenShotMode(_ScreenshotModeOn);
		}
		
		private function checkViewQueue( type:String ):void
		{
			var i:int = _viewQueue.length - 1;
			while (i > -1)
			{
				if (_viewQueue[i].type == type && canAddView(_viewQueue[i]))
				{
					var view:IView          = _viewQueue.splice(i, 1)[0];
					var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
					viewEvent.targetView = view;
					dispatch(viewEvent);
				}
				i--;
			}
		}

		private function canAddView( view:IView ):Boolean
		{
			if (view.typeUnique)
			{
				for (var i:int = 0; i < _currentViews.length; i++)
				{
					if (_currentViews[i].type == view.type)
					{
						return false;
					}
				}
			}
			for (i = 0; i < _currentViews.length; i++)
			{
				if (_currentViews[i].type == view.type)
				{
					if (_currentViews[i].typeUnique)
					{
						return false;
					}
				}
			}
			return true;
		}

		private function onEscapePressed( keyCode:uint ):void
		{
			if (_currentViews.length > 0)
				_currentViews[_currentViews.length - 1].onEscapePressed();
		}
		
		private function onToggleScreenShotMode( keyCode:uint ):void
		{
			if(!_ControlOn)
				return;
			
			setScreenShotMode(!_ScreenshotModeOn);
		}
		private function setScreenShotMode( mode:Boolean ):void
		{
			_ScreenshotModeOn = mode;
			
			for (var i:int = 0; i < _currentViews.length; i++)
			{
				if(_currentViews[i].screenshotBlocker)
					_currentViews[i].visible = !_ScreenshotModeOn;
			}
			for (i = 0; i < _viewQueue.length; i++)
			{
				if(_viewQueue[i].screenshotBlocker)
					_viewQueue[i].visible = !_ScreenshotModeOn;
			}
		}
		
		private function onControlPressed( keyCode:uint ):void
		{
			_ControlOn = true;
		}
		private function onControlReleased( keyCode:uint ):void
		{
			_ControlOn = false;
		}
		
		private function dispatch( event:Event ):void
		{
			_eventDispatcher.dispatchEvent(event);
		}

		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }
		[Inject]
		public function set keyboardController( v:KeyboardController ):void  { _keyboardController = v; }

		public function get currentViews():Vector.<IView>  { return _currentViews; }
		public function get modalHasFocus():Boolean  { return _modalCount > 0; }
		
		public function get screenshotModeOn():Boolean  { return _ScreenshotModeOn; }

	}
}
