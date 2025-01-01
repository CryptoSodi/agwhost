package com.model.player
{
	import com.enum.CurrencyEnum;

	import org.osflash.signals.Signal;

	public class PlayerWallet
	{
		public var onPremiumChange:Signal = new Signal(Boolean);

		private var _premium:uint         = 0;
		private var _prevPremium:uint     = 0;

		public function deposit( amount:uint, type:String ):void
		{
			switch (type)
			{
				case CurrencyEnum.PREMIUM:
					_prevPremium = amount;
					_premium += amount;
					onPremiumChange.dispatch(true);
					break;
			}
		}

		public function withdraw( amount:uint, type:String ):Boolean
		{
			switch (type)
			{
				case CurrencyEnum.PREMIUM:
					if (_premium < amount)
						return false;
					_prevPremium = amount;
					_premium -= amount;
					onPremiumChange.dispatch(false);
					break;
			}
			return true;
		}

		public function getPrevAddedAmount( type:String ):uint
		{
			switch (type)
			{
				case CurrencyEnum.PREMIUM:
					return _prevPremium;
			}
			return 0;
		}

		public function getAmount( type:String ):uint
		{
			switch (type)
			{
				case CurrencyEnum.PREMIUM:
					return _premium;
			}
			return 0;
		}

		public function get premium():uint  { return _premium; }

		public function set overridePremium( v:uint ):void  { if (_premium != v) _premium = v; onPremiumChange.dispatch(false); }
	}
}
