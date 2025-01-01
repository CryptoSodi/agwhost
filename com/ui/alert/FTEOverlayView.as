package com.ui.alert
{
	import com.Application;
	import com.controller.fte.FTEStepVO;
	import com.enum.PositionEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.effects.EffectFactory;
	import com.ui.core.effects.ViewEffects;
	import com.ui.modal.mission.FTEDialogueView;
	import com.ui.modal.store.StoreTransactionPage;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;

	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;

	public class FTEOverlayView extends View
	{
		private var _arrow:MovieClip;
		private var _clickToContinue:Boolean    = false;
		private var _dialogueView:FTEDialogueView;
		private var _fteStepVO:FTEStepVO;
		private var _ignoreStoreOffset:Boolean  = false;
		private var _originalApplicationSize:Point;
		private var _overlay:Sprite;
		private var _rolloverListener:Boolean   = false;
		private var _trigger:DisplayObject;
		private var _triggerTimer:Timer;
		private var _view:*;
		private var _viewAlreadyExisted:Boolean = false;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_mute = true;
			_overlay = new Sprite();
			addChild(_overlay);

			var arrowClass:Class = Class(getDefinitionByName('ArrowMC'));
			_arrow = MovieClip(new arrowClass());
			_arrow.visible = false;
			addChild(_arrow);

			_originalApplicationSize = new Point(DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
			_triggerTimer = new Timer(500, 1);
			_triggerTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showCutout, false, 0, true);

			//see if the view has any effects. we want to listen to the done event of the effect to reposition the cutout
			if (_view && _view.effects != null)
			{
				ViewEffects(_view.effects).addInListener(onEffectDoneIn);
			}

			if (_view && DisplayObject(_view).visible == false)
				DisplayObject(_view).visible = true;

			if (!_view || !_view.effects || _view.effects.numEffects == 0 || _view.effects.isDoneIn || _viewAlreadyExisted)
			{
				//go ahead and show the cutout since we dont have to wait for the view to animate in or the view was already done
				onEffectDoneIn();
				if (!_view && (_fteStepVO.cutout != null || _fteStepVO.arrowPosition != null))
				{
					Application.STAGE.removeEventListener(Event.RESIZE, onResize);
					Application.STAGE.addEventListener(Event.RESIZE, onResize, false, 0, true);
				}
			}

			removeListener(Application.STAGE, MouseEvent.CLICK, onTriggerClicked);
			if (_clickToContinue)
				addListener(Application.STAGE, MouseEvent.CLICK, onTriggerClicked, null, false, 2);

			effectsIN();
		}

		/**
		 * Called when the target view is done animating in
		 */
		protected function onEffectDoneIn():void
		{
			showCutout();
			showArrow();
		}

		private function onTriggerClicked( e:MouseEvent ):void
		{
			if (_clickToContinue && _dialogueView)
			{
				presenter.fteNextStep();
			} else if ((_clickToContinue && !e.currentTarget is FTEOverlayView) || e.currentTarget == _trigger)
			{
				presenter.fteNextStep();
			}
		}

		/**
		 * Recursively crawls through the view to try and determine what the trigger is supposed to be
		 * @param cutout The region of the overlay that the user can click through
		 * @param container A display object that has one or more children
		 * @return The target trigger
		 */
		private function findTrigger( cutout:Rectangle, container:DisplayObjectContainer ):DisplayObject
		{
			var displayObject:DisplayObject;
			var intersection:Rectangle;
			var rect:Rectangle;
			var newRect:Rectangle;
			var testObj:DisplayObject;
			for (var i:int = 0; i < container.numChildren; i++)
			{
				displayObject = container.getChildAt(i);

				if (!displayObject.visible)
					continue;

				rect = displayObject.getRect(_view);
				intersection = rect.intersection(cutout);
				var diff:Number = (intersection.width / cutout.width) * (intersection.height / cutout.height);
				var xml:XML     = describeType(displayObject);
				if (String(xml.@name) == "com.ui.modal.store::StoreTransactionPage")
				{
					var page:StoreTransactionPage = StoreTransactionPage(displayObject);
					if (page.visibleItemsContainer && page.visibleItemsContainer.scrollRect && !_ignoreStoreOffset)
						return findTrigger(cutout, page.visibleItemsContainer);
				}

				if (cutout.intersects(rect) && diff > .9)
				{
					switch (String(xml.@name))
					{
						case "com.ui.core.component.page::PageComponent":
						case "com.ui.core.component.page::Page":
						case "flash.display::Sprite":
						case "com.ui.hud.shared.bridge.right::TransactionRiver":
						case "com.ui.modal.store::StoreTransactionPage":
							testObj = findTrigger(cutout, DisplayObjectContainer(displayObject));
							if (testObj)
								return testObj;
							break;
						case "com.ui.core.component.page::PageIcon":
						case "com.ui.core.component.contextmenu::ContextMenuComponent":
						case "com.ui.modal.dock::ShipButton":
						case "com.ui.modal.store::StoreTransactionButton":
						case "com.ui.modal.store::StoreItem":
						case "com.ui.hud.shared.bridge.right::TransactionButton":
						case "com.ui.modal.construction::ConstructionItem":
							return displayObject;
						case "com.ui.core.component.button::BitmapButton":
							testObj = findTrigger(cutout, DisplayObjectContainer(displayObject));
							if (testObj)
								return testObj;
							else
								return displayObject;
							break;
						case "flash.display::Bitmap":
							break;
					}
					switch (String(xml.@base))
					{
						case "com.ui.modal.store::StorePage":
							newRect = cutout.clone();
							newRect.left += 300;
							testObj = findTrigger(newRect, DisplayObjectContainer(displayObject));
							if (testObj)
								return testObj;
							break;

						case "com.ui.core.component.page::PageComponent":
						case "com.ui.core.component.page::Page":
						case "flash.display::Sprite":
						case "com.ui.modal.store::StorePage":
							testObj = findTrigger(cutout, DisplayObjectContainer(displayObject));
							if (testObj)
								return testObj;
							break;
						//							return StorePage(displayObject).itemsComponents[0].buyBtn;
						case "com.ui.core.component.page::PageIcon":
						case "com.ui.core.component.contextmenu::ContextMenuComponent":
							return displayObject;
						case "com.ui.core.component.button::BitmapButton":
							testObj = findTrigger(cutout, DisplayObjectContainer(displayObject));
							if (testObj)
								return testObj;
							else
								return displayObject;
							break;
						case "flash.display::DisplayObject":
							break;
					}
				}
			}
			return null;
		}

		override protected function addEffects():void
		{
			_effects.addEffect(EffectFactory.repositionEffect(PositionEnum.LEFT, PositionEnum.TOP, onResize));
		}

		/**
		 * Called when the stage is resized to hide the cutout until the target view is done repositioning
		 */
		protected function onResize( e:Event = null ):void
		{
			_overlay.graphics.clear();
			_overlay.graphics.beginFill(0xffffff, 0.0);
			_overlay.graphics.drawRect(0, 0, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
			if (!_view)
			{
				var xdiff:Number = (_originalApplicationSize.x - DeviceMetrics.WIDTH_PIXELS) * .5;
				var ydiff:Number = (_originalApplicationSize.y - DeviceMetrics.HEIGHT_PIXELS) * .5;
				if (_fteStepVO.cutout)
				{
					_fteStepVO.cutout.x = _fteStepVO.cutout.x - xdiff;
					_fteStepVO.cutout.y = _fteStepVO.cutout.y - ydiff;
					_overlay.graphics.drawRect(_fteStepVO.cutout.x, _fteStepVO.cutout.y, _fteStepVO.cutout.width, _fteStepVO.cutout.height);
				}
				if (_fteStepVO.arrowPosition)
				{
					_fteStepVO.arrowPosition.x = _fteStepVO.arrowPosition.x - xdiff;
					_fteStepVO.arrowPosition.y = _fteStepVO.arrowPosition.y - ydiff;
					_arrow.x = _fteStepVO.arrowPosition.x;
					_arrow.y = _fteStepVO.arrowPosition.y;
				}
				_originalApplicationSize.setTo(DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
			}
			_overlay.graphics.endFill();
		}

		public function showCutout( e:TimerEvent = null ):void
		{
			//remove the listener from the current trigger
			if (_trigger)
			{
				//remove the glow filter
				if (_trigger.filters.length > 0)
					_trigger.filters = [];
				removeListener(_trigger, MouseEvent.CLICK, onTriggerClicked);
			}

			_overlay.graphics.clear();
			_overlay.graphics.beginFill(0xffffff, 0.0);
			_overlay.graphics.drawRect(0, 0, DeviceMetrics.WIDTH_PIXELS, DeviceMetrics.HEIGHT_PIXELS);
			if (_fteStepVO.cutout)
			{
				if (_view)
				{
					// Enable for cutout debugging
					// _overlay.graphics.lineStyle(2, Color.rgb(0, 255, 0));
					_trigger = findTrigger(_fteStepVO.cutout, _view);
					_overlay.graphics.drawRect(_view.x + (_fteStepVO.cutout.x * _view.scaleX), _view.y + (_fteStepVO.cutout.y * _view.scaleY), _fteStepVO.cutout.width * _view.scaleX, _fteStepVO.cutout.
											   height *
											   _view.scaleY);
					if (_trigger)
					{
						if (_rolloverListener)
							addListener(_trigger, MouseEvent.ROLL_OVER, onTriggerClicked);
						else
							addListener(_trigger, MouseEvent.CLICK, onTriggerClicked);
					} else
						_triggerTimer.start();
				} else
				{
					_overlay.graphics.drawRect(_fteStepVO.cutout.x, _fteStepVO.cutout.y, _fteStepVO.cutout.width, _fteStepVO.cutout.height);
					Application.STAGE.removeEventListener(Event.RESIZE, onResize);
					Application.STAGE.addEventListener(Event.RESIZE, onResize, false, 0, true);
				}
			}

			_overlay.graphics.endFill();
		}

		public function showArrow():void
		{
			if (_arrow && _fteStepVO.arrowPosition != null)
			{
				_arrow.x = _fteStepVO.arrowPosition.x * ((_view) ? _view.scaleX : 1);
				_arrow.y = _fteStepVO.arrowPosition.y * ((_view) ? _view.scaleY : 1);
				if (_view)
				{
					_arrow.x += _view.x;
					_arrow.y += _view.y;
				}
				_arrow.rotation = _fteStepVO.arrowRotation;
				_arrow.visible = true;

				if (!_view)
				{
					Application.STAGE.removeEventListener(Event.RESIZE, onResize);
					Application.STAGE.addEventListener(Event.RESIZE, onResize, false, 0, true);
				}
			}
		}

		public function hideArrow():void
		{
			_arrow.visible = false;
		}

		public function rolloverTrigger():void
		{
			if (_trigger)
			{
				removeListener(_trigger, MouseEvent.CLICK, onTriggerClicked);
				addListener(_trigger, MouseEvent.ROLL_OVER, onTriggerClicked);
			} else
				_rolloverListener = true;
		}

		override public function get typeUnique():Boolean  { return false; }
		override public function get type():String  { return ViewEnum.ALERT; }

		public function set clickToContinue( v:Boolean ):void  { _clickToContinue = v; }

		public function set dialogueView( v:FTEDialogueView ):void  { _dialogueView = v; }
		public function set fteStepVO( v:FTEStepVO ):void  { _fteStepVO = v; }
		public function set ignoreStoreOffset( v:Boolean ):void  { _ignoreStoreOffset = v; }
		public function set trigger( v:DisplayObject ):void
		{
			if (_trigger && _trigger.filters.length > 0)
				_trigger.filters = [];

			_trigger = v;
		}

		public function set view( v:* ):void  { _view = v; }
		public function set viewAlreadyExisted( v:Boolean ):void  { _viewAlreadyExisted = v; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			_arrow = null;
			_fteStepVO = null;
			_ignoreStoreOffset = false;
			_overlay.graphics.clear();
			_overlay = null;
			_rolloverListener = false;
			_trigger = null;
			_triggerTimer.stop();
			_triggerTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, showCutout);
			_triggerTimer = null;
			if (_view && _view.effects != null)
			{
				ViewEffects(_view.effects).removeInListener(onEffectDoneIn);
			}
			_view = null;
			_dialogueView = null;
			Application.STAGE.removeEventListener(Event.RESIZE, onResize);
		}
	}
}


