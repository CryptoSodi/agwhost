package com.game.entity.systems.interact.controls
{
	import com.game.entity.factory.IInteractFactory;

	import flash.utils.Dictionary;

	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class SelectorEntity
	{
		private static const LOOKUP:Dictionary = new Dictionary();

		public static function getSelectorEntity( id:String ):SelectorEntity
		{
			if (LOOKUP.hasOwnProperty(id))
				return LOOKUP[id];
			return null;
		}

		private var _count:int                 = 0;
		private var _entity:Entity;
		private var _id:String;
		private var _interactFactory:IInteractFactory;

		public function init( id:String, entity:Entity, factory:IInteractFactory ):void
		{
			_entity = entity;
			if (_entity == null)
				throw new Error("WTF! Man!");
			_id = id;
			_interactFactory = factory;
			LOOKUP[_id] = this;
		}

		public function increaseCount():void  { _count++; }
		public function decreaseCount():void
		{
			_count--;
			if (_count <= 0)
			{
				_interactFactory.destroyInteractEntity(_entity);
				_entity = null;
				ObjectPool.give(this);
			}
		}

		public function get id():String  { return _id; }

		public function destroy():void
		{
			delete LOOKUP[_id];
			_count = 0;
			_entity = null;
			_id = null;
			_interactFactory = null;
		}
	}
}
