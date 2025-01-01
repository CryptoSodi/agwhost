package com.game.entity.components.battle
{
	import com.model.prototype.IPrototype;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import org.ash.core.Entity;

	public class Modules
	{
		private var _activatedModules:Array           = [];
		private var _activatedTimes:Array             = [];
		private var _modules:Array                    = [];
		private var _entityModules:Array              = [];
		private var _indiciesByAttachPoint:Dictionary = new Dictionary();
		private var _modulesByAttachPoint:Dictionary  = new Dictionary();

		public var moduleStates:Dictionary            = new Dictionary();

		public function addActivatedModule( id:int, activatedPrototypeVO:IPrototype ):void
		{
			_activatedModules[id] = activatedPrototypeVO;
		}

		public function activateModule( id:int ):void
		{
			if (_activatedModules[id] != null)
			{
				_activatedTimes[id] = getTimer();
			}
		}

		public function isActive( id:int ):Boolean
		{
			if (_activatedModules[id] != null)
			{
				if (_activatedTimes[id] == null || moduleCooldownTimeRemaining(id) == 0)
					return true;
			}
			return false;
		}

		public function moduleCooldownTimeRemaining( id:int ):Number
		{
			if (_activatedModules[id] != null)
			{
				if (_activatedTimes[id] != null)
				{
					var t:Number         = getTimer() - _activatedTimes[id];
					var remaining:Number = getModuleReloadTime(id) - t;
					if (remaining <= 0)
					{
						_activatedTimes[id] = null;
						remaining = 0;
					}
					return remaining;
				}
			}
			return 0;
		}

		public function getModuleReloadTime( id:int ):Number
		{
			if (_activatedModules[id] != null)
				return Number(_activatedModules[id].getValue('reloadTime')) * 1000;
			return 0;
		}

		public function addModule( id:int, prototypeVO:IPrototype ):void
		{
			_modules[id] = prototypeVO;
		}

		public function addModuleByAttachPoint( attachPoint:String, prototypeVO:IPrototype ):void  { _modulesByAttachPoint[attachPoint] = prototypeVO; }

		public function getModuleByAttachPoint( attachPoint:String ):IPrototype  { return _modulesByAttachPoint[attachPoint]; }

		public function addIndexByAttachPoint( attachPoint:String, moduleIndex:Number ):void  { _indiciesByAttachPoint[attachPoint] = moduleIndex; }

		public function getModuleIndexByAttachPoint( attachPoint:String ):Number  { return _indiciesByAttachPoint[attachPoint]; }

		public function getModule( id:int ):IPrototype
		{
			return _modules[id];
		}

		public function addEntityModule( id:int, defense:Entity ):void
		{
			if (defense != null)
				_entityModules[id] = defense;
		}

		public function getEntityModule( id:int ):Entity
		{
			return _entityModules[id];
		}

		public function get activatedModules():Array  { return _activatedModules; }

		public function get entityModules():Array  { return _entityModules; }

		public function destroy():void
		{
			_activatedModules.length = 0;
			_activatedTimes.length = 0;
			_modules.length = 0;
			_entityModules.length = 0;
			_indiciesByAttachPoint = new Dictionary();
			_modulesByAttachPoint = new Dictionary();
			moduleStates = new Dictionary();
		}
	}
}
