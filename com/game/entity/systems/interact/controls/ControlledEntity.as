package com.game.entity.systems.interact.controls
{
	import org.ash.core.Entity;

	public class ControlledEntity
	{
		public var entity:Entity;
		public var range:Entity;
		public var selector:Entity;
		public var selectedEnemy:Entity;

		private var _destination:SelectorEntity;
		private var _selectorEnemy:SelectorEntity;

		public function get destination():SelectorEntity  { return _destination; }
		public function set destination( v:SelectorEntity ):void
		{
			if (_destination == v)
				return;
			if (_destination)
				_destination.decreaseCount();
			_destination = v;
			if (_destination != null)
				_destination.increaseCount();
		}

		public function get selectorEnemy():SelectorEntity  { return _selectorEnemy; }
		public function set selectorEnemy( v:SelectorEntity ):void
		{
			if (_selectorEnemy == v)
				return;
			if (_selectorEnemy)
				_selectorEnemy.decreaseCount();
			_selectorEnemy = v;
			if (_selectorEnemy != null)
				_selectorEnemy.increaseCount();
		}

		public function destroy():void
		{
			destination = null;
			entity = null;
			range = null;
			selector = null;
			selectedEnemy = null;
			selectorEnemy = null;
		}
	}
}
