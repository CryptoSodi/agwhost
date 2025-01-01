package com.game.entity.components.shared
{
	import org.ash.core.Entity;

	public class VCList
	{
		private var _addCallback:Function;
		private var _entity:Entity;
		private var _components:Vector.<Entity> = new Vector.<Entity>;
		private var _names:Array;
		private var _removeCallback:Function;
		private var _updateCallback:Function;

		public function init( ... componentNames ):void
		{
			_names = (componentNames) ? componentNames : [];
		}

		public function addComponentType( type:String ):void
		{
			var index:int = _names.indexOf(type);
			if (index == -1)
			{
				_names.push(type);
				_addCallback && _addCallback(_entity, type);
			} else
				_updateCallback && _updateCallback(_entity, type);
		}

		public function hasComponentType( type:String ):Boolean  { return _names.indexOf(type) > -1 ? true : false; }

		public function removeComponentType( type:String ):void
		{
			if (!_names)
				return;
			var index:int = _names.indexOf(type);
			if (index > -1)
			{
				_names.splice(index, 1);
				_removeCallback && _removeCallback(_entity, type);
			}
		}

		public function addComponent( component:Entity ):void
		{
			_components.push(component);
		}

		public function getComponent( type:String ):Entity
		{
			for (var i:int = 0; i < _components.length; i++)
			{
				if (Detail(_components[i].get(Detail)).type == type)
					return _components[i];
			}
			return null;
		}

		public function removeComponent( component:Entity ):void
		{
			var index:int = _components.indexOf(component);
			if (index > -1)
				_components.splice(index, 1);
		}

		public function addCallbacks( add:Function, update:Function, remove:Function, entity:Entity ):void
		{
			_addCallback = add;
			_entity = entity;
			_removeCallback = remove;
			_updateCallback = update;
		}

		public function removeCallbacks():void
		{
			_addCallback = _removeCallback = _updateCallback = null;
			_entity = null;
		}

		public function get components():Vector.<Entity>  { return _components; }
		public function get names():Array  { return _names; }

		public function destroy():void
		{
			_components.length = 0;
			_names = null;
			removeCallbacks();
		}
	}
}
