package com.util
{
	import com.enum.TradeRouteQualityEnum;
	import com.model.prototype.PrototypeModel;
	import flash.utils.Dictionary;
	import com.util.statcalc.StatCalcUtil;

	public class TradeRouteUtil
	{
		public static function RollPointValue( reputation:Number ):Number
		{
			var constantPrototypes:Dictionary = PrototypeModel.instance.getConstantPrototypes();

			var weight_Common:Number          = constantPrototypes["contractRandWeight_Common"].getValue('value');
			var weight_Uncommon:Number        = constantPrototypes["contractRandWeight_Uncommon"].getValue('value');
			var weight_Rare:Number            = constantPrototypes["contractRandWeight_Rare"].getValue('value');
			var weight_Epic:Number            = constantPrototypes["contractRandWeight_Epic"].getValue('value');
			var weight_Legendary:Number       = constantPrototypes["contractRandWeight_Legendary"].getValue('value');

			var maxRarity:uint                = TradeRouteQualityEnum.COMMON;
			var maxWeight:Number              = weight_Common;
			if (reputation > constantPrototypes["contractRepReq_Uncommon"].getValue('value'))
			{
				maxRarity = TradeRouteQualityEnum.UNCOMMON;
				maxWeight += weight_Uncommon;
			}
			if (reputation > constantPrototypes["contractRepReq_Rare"].getValue('value'))
			{
				maxRarity = TradeRouteQualityEnum.RARE;
				maxWeight += weight_Rare;
			}
			if (reputation > constantPrototypes["contractRepReq_Epic"].getValue('value'))
			{
				maxRarity = TradeRouteQualityEnum.EPIC;
				maxWeight += weight_Epic;
			}
			if (reputation > constantPrototypes["contractRepReq_Legendary"].getValue('value'))
			{
				maxRarity = TradeRouteQualityEnum.LEGENDARY;
				maxWeight += weight_Legendary;
			}

			var rarityRoll:Number             = randomMinMax(0.0, maxWeight);
			var actualRarity:uint             = TradeRouteQualityEnum.COMMON;
			if (rarityRoll > weight_Common)
				actualRarity = TradeRouteQualityEnum.UNCOMMON;
			if (rarityRoll > weight_Common + weight_Uncommon)
				actualRarity = TradeRouteQualityEnum.RARE;
			if (rarityRoll > weight_Common + weight_Uncommon + weight_Rare)
				actualRarity = TradeRouteQualityEnum.EPIC;
			if (rarityRoll > weight_Common + weight_Uncommon + weight_Rare + weight_Epic)
				actualRarity = TradeRouteQualityEnum.LEGENDARY;

			var pointValueRolled:Number       = 100.0;
			var minValue:Number;
			var maxValue:Number;
			switch (actualRarity)
			{
				default:
				case TradeRouteQualityEnum.UNKNOWN:
					//might want to put some error message here.
					break;
				case TradeRouteQualityEnum.COMMON:
				{
					minValue = constantPrototypes["contractPointsMin_Common"].getValue('value');
					maxValue = constantPrototypes["contractPointsMax_Common"].getValue('value');
					pointValueRolled = randomMinMax(minValue, maxValue);
				}
					break;
				case TradeRouteQualityEnum.UNCOMMON:
				{
					minValue = constantPrototypes["contractPointsMin_Uncommon"].getValue('value');
					maxValue = constantPrototypes["contractPointsMax_Uncommon"].getValue('value');
					pointValueRolled = randomMinMax(minValue, maxValue);
				}
					break;
				case TradeRouteQualityEnum.RARE:
				{
					minValue = constantPrototypes["contractPointsMin_Rare"].getValue('value');
					maxValue = constantPrototypes["contractPointsMax_Rare"].getValue('value');
					pointValueRolled = randomMinMax(minValue, maxValue);
				}
					break;
				case TradeRouteQualityEnum.EPIC:
				{
					minValue = constantPrototypes["contractPointsMin_Epic"].getValue('value');
					maxValue = constantPrototypes["contractPointsMax_Epic"].getValue('value');
					pointValueRolled = randomMinMax(minValue, maxValue);
				}
					break;
				case TradeRouteQualityEnum.LEGENDARY:
				{
					minValue = constantPrototypes["contractPointsMin_Legendary"].getValue('value');
					maxValue = constantPrototypes["contractPointsMax_Legendary"].getValue('value');
					pointValueRolled = randomMinMax(minValue, maxValue);
				}
					break;
			}

			return pointValueRolled;
		}

		public static function CheckContractClamps( Productivity:Number, Payout:Number, Duration:Number, Frequency:Number, Security:Number ):Boolean
		{
			var constantPrototypes:Dictionary = PrototypeModel.instance.getConstantPrototypes();

			var min_Productivity:Number       = constantPrototypes["contractProductivityMin"].getValue('value');
			var max_Productivity:Number       = constantPrototypes["contractProductivityMax"].getValue('value');
			if (Productivity < min_Productivity || Productivity > max_Productivity)
				return false;

			var min_Payout:Number             = constantPrototypes["contractPayoutMin"].getValue('value');
			var max_Payout:Number             = constantPrototypes["contractPayoutMax"].getValue('value');
			if (Payout < min_Payout || Payout > max_Payout)
				return false;

			var min_Duration:Number           = constantPrototypes["contractDurationMin"].getValue('value');
			var max_Duration:Number           = constantPrototypes["contractDurationMax"].getValue('value');
			if (Duration < min_Duration || Duration > max_Duration)
				return false;

			var min_Frequency:Number          = constantPrototypes["contractFrequencyMin"].getValue('value');
			var max_Frequency:Number          = constantPrototypes["contractFrequencyMax"].getValue('value');
			if (Frequency < min_Frequency || Frequency > max_Frequency)
				return false;

			var min_Security:Number           = constantPrototypes["contractSecurityMin"].getValue('value');
			var max_Security:Number           = constantPrototypes["contractSecurityMax"].getValue('value');
			if (Security < min_Security || Security > max_Security)
				return false;

			return true;
		}

		// we expect the inputs to be properly clamped by CheckContractClamps
		public static function GetContractPointCost( Productivity:Number, Payout:Number, Duration:Number, Frequency:Number, Security:Number ):Number
		{
			var constantPrototypes:Dictionary  = PrototypeModel.instance.getConstantPrototypes();
			var pointCostRequested:Number      = 0.0;

			var base_Productivity:Number       = constantPrototypes["contractProductivityBase"].getValue('value');
			var delta_Productivity:Number      = Productivity - base_Productivity;
			var pointScale_Productivity:Number = constantPrototypes["contractProductivityPoints"].getValue('value');
			var increment_Productivity:Number  = constantPrototypes["contractProductivityIncrement"].getValue('value');
			var cost_Productivity:Number       = delta_Productivity * pointScale_Productivity / increment_Productivity;
			pointCostRequested += cost_Productivity;

			var base_Payout:Number             = constantPrototypes["contractPayoutBase"].getValue('value');
			var delta_Payout:Number            = Payout - base_Payout;
			var pointScale_Payout:Number       = constantPrototypes["contractPayoutPoints"].getValue('value');
			var increment_Payout:Number        = constantPrototypes["contractPayoutIncrement"].getValue('value');
			var cost_Payout:Number             = delta_Payout * pointScale_Payout / increment_Payout;
			pointCostRequested += cost_Payout;

			var base_Duration:Number           = constantPrototypes["contractDurationBase"].getValue('value');
			var delta_Duration:Number          = Duration - base_Duration;
			var pointScale_Duration:Number     = constantPrototypes["contractDurationPoints"].getValue('value');
			var increment_Duration:Number      = constantPrototypes["contractDurationIncrement"].getValue('value');
			var cost_Duration:Number           = delta_Duration * pointScale_Duration / increment_Duration;
			pointCostRequested += cost_Duration;

			var base_Frequency:Number          = constantPrototypes["contractFrequencyBase"].getValue('value');
			var delta_Frequency:Number         = Frequency - base_Frequency;
			var pointScale_Frequency:Number    = constantPrototypes["contractFrequencyPoints"].getValue('value');
			var increment_Frequency:Number     = constantPrototypes["contractFrequencyIncrement"].getValue('value');
			var cost_Frequency:Number          = delta_Frequency * pointScale_Frequency / increment_Frequency;
			pointCostRequested += cost_Frequency;

			var base_Security:Number           = constantPrototypes["contractSecurityBase"].getValue('value');
			var delta_Security:Number          = Security - base_Security;
			var pointScale_Security:Number     = constantPrototypes["contractSecurityPoints"].getValue('value');
			var increment_Security:Number      = constantPrototypes["contractSecurityIncrement"].getValue('value');
			var cost_Security:Number           = delta_Security * pointScale_Security / increment_Security;
			pointCostRequested += cost_Security;

			return pointCostRequested;
		}

		public static function get maxContracts():int  { return 3; }
		public static function get maxUnlockedContracts():int  { return StatCalcUtil.baseStatCalc("MaxContracts"); }

		private static function randomMinMax( min:Number, max:Number ):Number  { return min + (max - min) * Math.random(); }

	}
}
