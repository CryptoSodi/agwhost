package com.game.entity.components.battle
{
	import com.game.entity.components.shared.Animation;
	import com.model.battle.BattleEntityVO;

	import org.osflash.signals.Signal;

	public class Health
	{
		public var animation:Animation;

		private var _battleEntityVO:BattleEntityVO;
		private var _conversion:Number;
		private var _currentHealth:int = 0;
		private var _damageThreshold:Number;
		private var _maxHealth:int;
		private var _percent:Number;
		private var _signal:Signal;
		private var _temp:Number;

		public function Health()
		{
			_signal = new Signal(Number, Number);
		}

		public function init( current:int, max:int, beVO:BattleEntityVO, damageThreshold:Number = -1 ):void
		{
			if (max <= 0)
				max = 1;
			_conversion = 1 / max;
			_currentHealth = current;
			_damageThreshold = damageThreshold;
			_percent = _currentHealth * _conversion;
			_maxHealth = max;

			if (beVO)
			{
				_battleEntityVO = beVO;
				_battleEntityVO.healthPercent = _percent;
			}
		}

		public function addListener( callback:Function ):void  { _signal.add(callback); }
		public function removeListener( callback:Function ):void  { _signal.remove(callback); }

		public function get maxHealth():int  { return _maxHealth; }
		public function set maxHealth( value:int ):void
		{
			_conversion = 1 / value;
			_maxHealth = value;
			_temp = percent;
			_percent = _currentHealth * _conversion;
			_signal.dispatch(_percent, _temp - percent);
		}

		public function get currentHealth():int  { return _currentHealth; }
		public function set currentHealth( value:int ):void
		{
			_temp = _currentHealth;
			_currentHealth = value;
			_percent = _currentHealth * _conversion;
			if (_battleEntityVO)
				_battleEntityVO.healthPercent = _percent;
			_signal.dispatch(_percent, _temp - _currentHealth);
		}

		public function get damageThreshold():Number  { return _damageThreshold; }
		public function set damageThreshold( v:Number ):void  { _damageThreshold = v; }

		public function get percent():Number  { return _percent; }

		public function destroy():void
		{
			animation = null;
			if (_battleEntityVO)
				_battleEntityVO.healthPercent = 0;
			_battleEntityVO = null;
			_damageThreshold = -1;
			_signal.removeAll();
		}
	}
}
