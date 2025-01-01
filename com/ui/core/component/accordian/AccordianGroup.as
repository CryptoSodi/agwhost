package com.ui.core.component.accordian
{
	import com.enum.ui.ButtonEnum;

	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class AccordianGroup extends Sprite
	{
		private var _actionSignal:Signal;
		private var _expanded:Boolean;
		private var _headerButton:AccordianButton;
		private var _height:Number;
		private var _id:String;
		private var _maxHeight:Number;
		private var _subItemHolder:Sprite;
		private var _subItemLookup:Dictionary;
		private var _subItemRect:Rectangle;
		private var _subItems:Vector.<AccordianButton>;
		private var _tempSubItem:AccordianButton;
		private var _width:Number;

		public function init( id:String, title:String, width:Number, height:Number, actionSignal:Signal ):void
		{
			_actionSignal = actionSignal;
			_expanded = false;
			_headerButton = ObjectPool.get(AccordianButton);
			_headerButton.init(id, null, title, 0, _actionSignal, ButtonEnum.HEADER, width, height);
			addChild(_headerButton);

			_id = id;
			_subItemLookup = new Dictionary(true);
			_subItemRect = new Rectangle(0, 0, width, 0);
			_subItemHolder = new Sprite();
			_subItemHolder.scrollRect = _subItemRect;
			_subItemHolder.y = _headerButton.height;
			addChild(_subItemHolder);
			_subItems = new Vector.<AccordianButton>;
			_height = height;
			_width = width;
		}

		public function addSubItem( id:String, title:String, state:int = 0 ):void
		{
			if (!_subItemLookup.hasOwnProperty(id))
			{
				_tempSubItem = ObjectPool.get(AccordianButton);
				_tempSubItem.init(_id, id, title, state, _actionSignal, ButtonEnum.ACCORDIAN_SUBITEM, _width, 28);
				_subItemLookup[id] = _tempSubItem;
				_subItemHolder.addChild(_tempSubItem);
				_subItems.push(_tempSubItem);
				layout();
			}
		}

		public function setSubItemState( id:String, state:int ):void
		{
			if (_subItemLookup.hasOwnProperty(id))
			{
				_tempSubItem = _subItemLookup[id];
				_tempSubItem.state = state;
				layout();
			}
		}

		public function removeSubItem( id:String ):void
		{
			if (_subItemLookup.hasOwnProperty(id))
			{
				_tempSubItem = _subItemLookup[id];
				delete _subItemLookup[id];
				_subItems.splice(_subItems.indexOf(_tempSubItem), 1);
				_subItemHolder.removeChild(_tempSubItem);
				ObjectPool.give(_tempSubItem);
				_tempSubItem = null;
				layout();
			}
		}

		public function update():Boolean
		{
			if (_expanded)
			{
				if (_subItemRect.height < _maxHeight)
				{
					_subItemRect.height += 15;
					if (_subItemRect.height >= _maxHeight)
					{
						_subItemRect.height = _maxHeight;
						_subItemHolder.scrollRect = _subItemRect;
						return false;
					}
				}
			} else
			{
				if (_subItemRect.height > 0)
				{
					_subItemRect.height -= 15;
					if (_subItemRect.height <= 0)
					{
						_subItemRect.height = 0;
						_subItemHolder.scrollRect = _subItemRect;
						return false;
					}
				}
			}
			_subItemHolder.scrollRect = _subItemRect;
			return true;
		}

		public function getSubItem( id:String ):AccordianButton
		{
			if (_subItemLookup.hasOwnProperty(id))
				return _subItemLookup[id];
			return null;
		}

		private function layout():void
		{
			var ypos:Number = 0;
			for (var i:int = 0; i < _subItems.length; i++)
			{
				_subItems[i].y = ypos;
				ypos += _subItems[i].height;
			}
			_maxHeight = ypos;
		}

		public function get expanded():Boolean  { return _expanded; }
		public function set expanded( v:Boolean ):void  { _expanded = v; }

		public function get hasSubItems():Boolean  { return _subItems && _subItems.length > 1; }
		public function get headerButton():AccordianButton  { return _headerButton; }

		override public function get height():Number  { return _headerButton.height + _subItemRect.height - 1; }

		public function get id():String  { return _id; }

		public function get subItems():Vector.<AccordianButton>  { return _subItems; }
		public function get text():String  { return _headerButton.text; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);
			_actionSignal = null;
			ObjectPool.give(_headerButton);
			_headerButton = null;
			for (var i:String in _subItemLookup)
				removeSubItem(i);
			_subItems.length = 0;
			_subItems = null;
			_subItemLookup = null;
			_subItemRect = null;
			_subItemHolder = null;
			_tempSubItem = null;
		}
	}
}
