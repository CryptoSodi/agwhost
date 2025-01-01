package com.game.entity.components.battle
{
	import com.game.entity.components.shared.Animation;

	import org.osflash.signals.Signal;

	public class Shield
	{
		public var animation:Animation;

		private var _currentStrength:int;
		private var _enabled:Boolean;
		private var _enabledSignal:Signal;
		private var _isBuildingShield:Boolean;
		private var _strengthSignal:Signal;

		public function Shield()
		{
			_enabledSignal = new Signal(Boolean);
			_strengthSignal = new Signal(int);
		}

		public function init( enabled:Boolean, health:int, forBuilding:Boolean = false ):void
		{
			_enabled = enabled;
			_currentStrength = health;
			_isBuildingShield = forBuilding;
		}

		public function addStrengthListener( callback:Function ):void  { _strengthSignal.add(callback); }
		public function removeStrengthListener( callback:Function ):void  { _strengthSignal.remove(callback); }

		public function addEnableListener( callback:Function ):void  { _enabledSignal.add(callback); }
		public function removeEnableListener( callback:Function ):void  { _enabledSignal.remove(callback); }

		public function get enabled():Boolean  { return _enabled; }
		public function set enabled( value:Boolean ):void
		{
			if (value != _enabled)
			{
				_enabled = value;
				_enabledSignal.dispatch(_enabled);
			}
		}

		public function get currentStrength():int  { return _currentStrength; }
		public function set currentStrength( value:int ):void
		{
			if (_currentStrength != value)
			{
				_currentStrength = value;
				_strengthSignal.dispatch(_currentStrength);
			}
		}

		public function get isBuildingShield():Boolean  { return _isBuildingShield; }

		public function destroy():void
		{
			_enabledSignal.removeAll();
			_strengthSignal.removeAll();
			_isBuildingShield = false;
		}
	}
}
