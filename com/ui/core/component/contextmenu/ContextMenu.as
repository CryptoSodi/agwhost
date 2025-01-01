package com.ui.core.component.contextmenu
{
	import com.Application;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.IComponent;
	import com.ui.core.component.label.Label;
	import com.ui.core.effects.ViewEffects;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Dictionary;

	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class ContextMenu extends View implements IComponent
	{
		private var _selections:Vector.<IContextMenuItem>;
		private var _multiChoiceLookup:Dictionary;
		private var _bg:ScaleBitmap;
		private var _title:Label;
		private var _subText:Label;
		private var _width:Number;
		private var _height:Number;
		private var _isEnabled:Boolean;
		private var _clickedXPos:int;
		private var _clickedYPos:int;
		private var _boundsXPos:int;
		private var _boundsYPos:int;

		private var _choiceYPos:Number;

		public function ContextMenu()
		{
			_selections = new Vector.<IContextMenuItem>();
			_bg = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER_DARK);
			_bg.width = width;
			_bg.height = height;

			_title = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, width, 25, _bg.x, 1);
			_title.multiline = true;
			_title.constrictTextToSize = false;
			_title.autoSize = TextFieldAutoSize.CENTER;
			_title.textColor = 0xacd1ff;
			_title.leading = -5;

			_subText = UIFactory.getLabel(LabelEnum.DEFAULT_OPEN_SANS, width, 25, _title.x, _title.y - 3);
			_subText.fontSize = 12;
			_subText.autoSize = TextFieldAutoSize.CENTER;
			_subText.constrictTextToSize = false;
		}

		public function setup( contextMenuTitle:String, xPos:Number = 0, yPos:Number = 0, width:Number = 150, boundsX:int = 0, boundsY:int = 0, contextMenuSubText:String = '' ):void
		{
			if (DeviceMetrics.PLATFORM == PlatformEnum.MOBILE){
				//scaleX = scaleY = DeviceMetrics.DENSITY >= 1 ? DeviceMetrics.DENSITY + .1 : 1;
				
				//scaleX = scaleY = 4;
			}
			
			if(CONFIG::IS_MOBILE){
				scaleX = scaleY = 2;
			}
			
			
			destroyOnRollout = true;

			clearSelections();
			_bg.width = width;
			_width = width;

			_clickedXPos = xPos;
			_clickedYPos = yPos;

			_boundsXPos = boundsX;
			_boundsYPos = boundsY;

			_title.width = width - 6;
			_title.x = (width - _title.width) * .5;

			if (contextMenuTitle != null)
				_title.text = contextMenuTitle;

			_subText.x = (width - _subText.width) * .5;
			_subText.y = _title.height - 3;
			_subText.text = contextMenuSubText;

			_height = _subText.y + _title.height + _subText.textHeight;
			_bg.height = _height;

			_choiceYPos = _subText.y + _subText.textHeight + 8;

			addChild(_bg);
			addChild(_title);
			addChild(_subText);
		}

		public function addContextMenuChoice( displayName:String, callback:Function, args:Array, isEnabled:Boolean = true, tooltipText:String = '', color:uint = 0xffffff ):void
		{
			var newChoice:ContextMenuItem = new ContextMenuItem(displayName, callback, args, isEnabled, tooltipText, color);
			newChoice.onSelectionClicked.add(onSelectionClick);
			newChoice.x = _bg.x + (_bg.width - newChoice.width) * 0.5;
			newChoice.y = _choiceYPos;
			_choiceYPos = newChoice.y + newChoice.height;

			addChild(newChoice);
			_selections.push(newChoice);

			layout();
		}

		public function addContextMenuMultiChoice( category:String, startingIndex:uint, indexChanged:Function = null, heldShift:uint = 26, heldTime:Number = 1500 ):void
		{
			if (!(category in _multiChoiceLookup))
			{
				var newChoice:ContextMenuMultiChoiceItem = new ContextMenuMultiChoiceItem(category, startingIndex, indexChanged, heldShift, heldTime);
				newChoice.onSelectionClicked.add(onSelectionClick);

				if (indexChanged != null)
					newChoice.onSelectedIndexUpdated.add(onMultiChoiceIndexUpdate);

				newChoice.x = _bg.x + (_bg.width - newChoice.width) * 0.5;
				newChoice.y = _choiceYPos;
				_choiceYPos = newChoice.y + newChoice.height;

				addChild(newChoice);
				_selections.push(newChoice);
				_multiChoiceLookup[category] = newChoice;
				layout();
			}
		}

		public function addChoiceToMultiChoice( category:String, displayName:String, callback:Function, args:Array, isEnabled:Boolean, tooltip:String, color:uint = 0xffffff ):void
		{
			if (category in _multiChoiceLookup)
				_multiChoiceLookup[category].addChoiceItem(displayName, callback, args, isEnabled, tooltip, color);
		}

		private function onMultiChoiceIndexUpdate( callback:Function, index:int ):void
		{
			if (callback != null && _presenter != null)
				callback.apply(_presenter, [index]);
		}

		private function layout():void
		{
			var len:uint          = _selections.length;
			var lastChoice:Sprite = Sprite(_selections[len - 1]);
			_height = lastChoice.y + lastChoice.height;
			_bg.height = _height + 15;

			var newXPos:int       = _clickedXPos - _width * 0.5;
			var newYPos:int       = _clickedYPos - _height * 0.5;

			if (newYPos + _height > _boundsYPos)
			{
				newYPos -= (newYPos + _height) - _boundsYPos;
			} else if (newYPos + _height < 0)
			{
				newYPos = 0;
			}

			if (newXPos + _width > _boundsXPos)
			{
				newXPos -= (newXPos + _width) - _boundsXPos;
			} else if (newXPos < 0)
			{
				newXPos = 0;
			}

			x = newXPos;
			y = newYPos;
		}

		private function onSelectionClick( callback:Function, args:Array ):void
		{
			callback.apply(this, args);
			_viewFactory.destroyView(this);
			ObjectPool.give(this);
		}

		private function onRollOut( e:MouseEvent ):void
		{
			_viewFactory.destroyView(this);
			ObjectPool.give(this);
		}

		private function clearSelections():void
		{
			var len:uint = _selections.length;
			for (var i:uint = 0; i < len; ++i)
			{
				_selections[i].destroy();
				removeChild(Sprite(_selections[i]));
				_selections[i] = null;
			}
			_selections.length = 0;

			_multiChoiceLookup = new Dictionary();
		}

		public function set destroyOnRollout( v:Boolean ):void
		{
			removeListener(this, MouseEvent.ROLL_OUT, onRollOut);
			if (v)
			{
				addListener(this, MouseEvent.ROLL_OUT, onRollOut);
				addListener(Application.STAGE, MouseEvent.MOUSE_DOWN, onStageMouseDown);
			}
		}

		private function onStageMouseDown( e:MouseEvent ):void
		{
			if (!hitTestPoint(e.stageX, e.stageY, false))
				onRollOut(e);
		}

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  { _isEnabled = value; }

		override public function get height():Number  { return _height; }
		override public function get width():Number  { return _width; }

		override public function get bounds():Rectangle  { return getBounds(parent); }
		override public function get effects():ViewEffects  { return null; }
		public function get selections():Vector.<IContextMenuItem>  { return _selections; }
		override public function get typeUnique():Boolean  { return false; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }

		override public function destroy():void
		{
			clearSelections();
			super.destroy();
			if (parent)
				parent.removeChild(this);
		}
	}
}
