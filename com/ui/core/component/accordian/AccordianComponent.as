package com.ui.core.component.accordian
{
	import com.ui.core.component.IComponent;
	import com.ui.core.component.button.ButtonLabelFormat;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class AccordianComponent extends Sprite implements IComponent
	{
		private var _actionSignal:Signal;
		private var _enabled:Boolean;
		private var _height:Number;
		private var _groupLookup:Dictionary;
		private var _groups:Vector.<AccordianGroup>;
		private var _tempGroup:AccordianGroup;
		private var _width:Number;

		public function init( width:Number, height:Number ):void
		{
			_actionSignal = new Signal(String, String, Object);
			_actionSignal.add(onAction);
			enabled = true;
			_groupLookup = new Dictionary(true);
			_groups = new Vector.<AccordianGroup>;
			_height = height;
			_width = width;
		}

		public function addGroup( id:String, title:String ):void
		{
			if (!_groupLookup.hasOwnProperty(id))
			{
				_tempGroup = ObjectPool.get(AccordianGroup);
				_tempGroup.init(id, title, _width, _height, _actionSignal);
				addChild(_tempGroup);
				_groupLookup[id] = _tempGroup;
				_groups.push(_tempGroup);
				layout();
			}
		}

		public function getGroup( id:String ):AccordianGroup
		{
			if (_groupLookup.hasOwnProperty(id))
				return _groupLookup[id];
			return null;
		}

		public function setGroupTitle( id:String, title:String, labelFormat:ButtonLabelFormat = null ):void
		{
			if (_groupLookup.hasOwnProperty(id))
			{
				_tempGroup = _groupLookup[id];
				_tempGroup.headerButton.text = title;
				if (labelFormat)
					_tempGroup.headerButton.labelFormat = labelFormat;
			}
		}

		public function setSelected( groupID:String, subItemID:String ):void
		{
			onAction(groupID, subItemID, null);
		}

		public function setSelectedSubItemByIndex( groupID:String, index:int ):void
		{
			if (_groupLookup.hasOwnProperty(groupID))
			{
				_tempGroup = _groupLookup[groupID];
				if (_tempGroup.hasSubItems && _tempGroup.subItems.length > index)
					setSelected(groupID, _tempGroup.subItems[index].id);
			}
		}

		public function addSubItemToGroup( groupID:String, subItemID:String, title:String, state:int ):void
		{
			if (_groupLookup.hasOwnProperty(groupID))
			{
				_tempGroup = _groupLookup[groupID];
				_tempGroup.addSubItem(subItemID, title, state);
				layout();
			}
		}

		public function setSubItemState( groupID:String, subItemID:String, state:int ):void
		{
			if (_groupLookup.hasOwnProperty(groupID))
			{
				_tempGroup = _groupLookup[groupID];
				_tempGroup.setSubItemState(subItemID, state);
				layout();
			}
		}

		public function removeSubItemFromGroup( groupID:String, subItemID:String ):void
		{
			if (_groupLookup.hasOwnProperty(groupID))
			{
				_tempGroup = _groupLookup[groupID];
				_tempGroup.removeSubItem(subItemID);
				layout();
			}
		}

		public function removeGroup( id:String ):void
		{
			if (_groupLookup.hasOwnProperty(id))
			{
				_tempGroup = _groupLookup[id];
				delete _groupLookup[id];
				_groups.splice(_groups.indexOf(_tempGroup), 1);
				removeChild(_tempGroup);
				ObjectPool.give(_tempGroup);
				layout();
			}
		}

		private function onAction( groupID:String, subItemID:String, data:* ):void
		{
			for (var i:int = 0; i < _groups.length; i++)
			{
				_tempGroup = _groups[i];
				_tempGroup.headerButton.selected = _tempGroup.id == groupID;
				_tempGroup.expanded = _tempGroup.id == groupID;
				if (_tempGroup.subItems && (subItemID || groupID != _tempGroup.id))
				{
					for (var j:int = 0; j < _tempGroup.subItems.length; j++)
					{
						_tempGroup.subItems[j].selected = _tempGroup.subItems[j].id == subItemID && _tempGroup.id == groupID;
					}
				}
			}
			removeEventListener(Event.ENTER_FRAME, update);
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}

		private function update( e:Event ):void
		{
			var active:Boolean = false;
			for (var i:int = 0; i < _groups.length; i++)
			{
				if (_groups[i].update())
					active = true;
			}
			layout();
			if (!active)
				removeEventListener(Event.ENTER_FRAME, update);
		}

		private function layout():void
		{
			var ypos:Number = 0;
			for (var i:int = 0; i < _groups.length; i++)
			{
				_groups[i].y = ypos;
				ypos += _groups[i].height + 2;
			}
		}

		public function addListener( listener:Function ):void  { _actionSignal.add(listener); }
		public function removeListener( listener:Function ):void  { _actionSignal.remove(listener); }

		public function get enabled():Boolean  { return false; }
		public function set enabled( value:Boolean ):void  { _enabled = value; }

		public function destroy():void
		{
			x = y = 0;
			_actionSignal.removeAll();
			_actionSignal = null;
			removeEventListener(Event.ENTER_FRAME, update);
			for (var id:String in _groupLookup)
				removeGroup(id);
			_groupLookup = null;
			_groups.length = 0;
			_groups = null;
			_tempGroup = null;
		}
	}
}
