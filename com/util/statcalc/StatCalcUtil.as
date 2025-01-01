package com.util.statcalc
{
	import com.enum.StatModConditionalEnum;
	import com.enum.StatModScopeEnum;
	import com.enum.server.StarbaseBuildStateEnum;
	import com.model.fleet.EmptySlotVO;
	import com.model.fleet.ShipVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuffVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;

	import flash.utils.Dictionary;

	public class StatCalcUtil
	{
		private static var _prototypeModel:PrototypeModel;
		private static var _starbaseModel:StarbaseModel;

		public static const EMPTY_SLOT:IPrototype = new EmptySlotVO();

		public static function baseStatCalc( statName:String, baseValue:Number = 0.0, buildingId:String = null, baseID:String = null ):Number
		{
			var flatBonus:Number              = 0.0;
			var additivePercent:Number        = 0.0;
			var multiplier:Number             = 1.0;

			var building:BuildingVO;
			var buildings:Vector.<BuildingVO> = _starbaseModel.getBuildingsByBaseID(baseID);
			var len:int                       = buildings.length;
			var modProto:IPrototype;
			var statMods:Object
			var key:String;
			for (var idx:int = 0; idx < len; idx++)
			{
				building = buildings[idx];
				// this is a new building and it's not done being built yet!
				if (building.buildState == StarbaseBuildStateEnum.BUILDING)
					continue;
				//
				var isThisBuilding:Boolean = (building.id == buildingId);
				if (isThisBuilding)
				{
					if (building.prototype.getUnsafeValue(statName) != null)
						baseValue += building.prototype.getUnsafeValue(statName);
				}

				statMods = building.prototype.getValue("statMods");
				for (key in statMods)
				{
					modProto = _prototypeModel.getStatModPrototypeByName(statMods[key]);
					if (modProto == null)
						continue;
					if (modProto.getValue("stat") != statName)
						continue;

					if (isThisBuilding || modProto.getValue("scope") >= 3)
					{
						flatBonus += modProto.getValue("flatBonus");
						additivePercent += modProto.getValue("additivePercent");
						multiplier *= modProto.getValue("multiplier");
					}
				}
			}

			//calc buffs
			var buff:BuffVO;
			var buffs:Vector.<BuffVO>         = _starbaseModel.getBuffsByBaseID(baseID);
			len = buffs.length;
			for (var i:int = 0; i < len; i++)
			{
				buff = buffs[i];
				statMods = buff.prototypeVO.getValue("statMods");
				for (key in statMods)
				{
					modProto = _prototypeModel.getStatModPrototypeByName(statMods[key]);
					if (modProto == null)
						continue;
					if (modProto.getValue("stat") != statName)
						continue;

					if (modProto.getValue("scope") >= 3)
					{
						flatBonus += modProto.getValue("flatBonus");
						additivePercent += modProto.getValue("additivePercent");
						multiplier *= modProto.getValue("multiplier");
					}
				}
			}

			var flatValue:Number              = baseValue + flatBonus;
			var percentBonus:Number           = flatValue * (additivePercent / 100.0);
			var result:Number                 = (flatValue + percentBonus) * multiplier;
			return result;
		}

		public static function buildingStatCalc( statName:String, building:BuildingVO ):Number
		{
			var additivePercent:Number;
			var key:String;
			var modProto:IPrototype;
			var result:Number = 0;
			var statMods:Object

			statMods = building.prototype.getValue("statMods");
			for (key in statMods)
			{
				modProto = _prototypeModel.getStatModPrototypeByName(statMods[key]);
				if (modProto == null)
					continue;
				if (modProto.getValue("stat") != statName)
					continue;

				result += modProto.getValue("flatBonus");
				additivePercent = modProto.getValue("additivePercent");
				result = result + (result * (additivePercent / 100.0));
				result *= modProto.getValue("multiplier");
			}
			return result;
		}

		public static function entityStatCalc( parentEntity:IPrototype, statName:String, baseValue:Number = 0.0, requestingModule:IPrototype = null, requestingModuleSlot:String = '',
											   ignoreScope:Boolean = false ):Number
		{
			// bail out if the proto is gone
			if (!parentEntity || (!(parentEntity is ShipVO) && !(parentEntity is BuildingVO)))
				return baseValue;

			var defaultStat:Stat = new Stat();

			defaultStat.reset();
			defaultStat.stat = statName;
			defaultStat.baseValue = baseValue;

			if (requestingModuleSlot == '')
			{
				var protoBaseValue:Number = parentEntity.getUnsafeValue(statName);
				if (!isNaN(protoBaseValue) && protoBaseValue != 0.0)
					defaultStat.baseValue += protoBaseValue;
			}

			var modules:Dictionary;
			var refitModules:Dictionary;
			if (parentEntity is ShipVO)
			{
				modules = ShipVO(parentEntity).modules;
				refitModules = ShipVO(parentEntity).refitModules;
			} else
			{
				modules = BuildingVO(parentEntity).modules;
				refitModules = BuildingVO(parentEntity).refitModules;
			}


			var slots:Array      = !(parentEntity.getUnsafeValue('slots') is Array) ? [] : parentEntity.getUnsafeValue('slots');

			var len:uint         = slots.length;
			var slot:String;
			for (var i:uint = 0; i < len; ++i)
			{
				slot = slots[i];
				var mod:IPrototype      = modules[slot];
				var refitMod:IPrototype = refitModules[slot];
				mod = (refitMod != null) ? (refitMod != EMPTY_SLOT) ? refitMod : null : mod;
				if (mod)
				{
					var isThisModule:Boolean;
					if (requestingModuleSlot != '')
						isThisModule = (slot == requestingModuleSlot);

					modStatCalc(defaultStat, parentEntity, requestingModule, requestingModuleSlot, mod, isThisModule, ignoreScope);
				}
			}

			var statMods:Array   = !(parentEntity.getUnsafeValue('statMods') is Array) ? [] : parentEntity.getUnsafeValue('statMods');
			if (statMods)
			{
				for each (var modName:String in statMods)
				{
					var statMod:IPrototype = _prototypeModel.getStatModPrototypeByName(modName);
					if (!statMod)
						continue;
					if (statMod.getUnsafeValue('stat') != defaultStat.stat)
						continue;

					if (parentEntity is ShipVO && statMod.getUnsafeValue('affectsShips') == false)
						continue;
					if (parentEntity is BuildingVO && statMod.getUnsafeValue('affectsBuildings') == false)
						continue;
					if (!CheckConditional(parentEntity, requestingModule, requestingModuleSlot, ignoreScope, statMod.getUnsafeValue('conditionStat'), statMod.getUnsafeValue('conditionComp'), statMod.getUnsafeValue('conditionValue')))
						continue;

					defaultStat.flatBonus += statMod.getUnsafeValue('flatBonus');
					defaultStat.additivePercent += statMod.getUnsafeValue('additivePercent');
					defaultStat.multiplier *= statMod.getUnsafeValue('multiplier');
				}
			}

			return defaultStat.calculate();
		}

		private static function modStatCalc( stat:Stat, owningEntity:IPrototype, requestingModule:IPrototype, requestingModuleSlot:String, mod:IPrototype, forThisModule:Boolean, ignoreScope:Boolean, distance:Number =
											 -1.0 ):void
		{
			if (!mod)
				return;
			/*
			   Done on server not on client
			   if (!mod.getUnsafeValue('activated'))
			   return;
			 */

			// reflect onto this and get the base stat
			if (forThisModule || ignoreScope)
			{
				var val:Number = mod.getUnsafeValue(stat.stat);
				if (!isNaN(val) && val != 0.0)
					stat.baseValue += val;
			}

			var statMods:Array = !(mod.getUnsafeValue('statMods') is Array) ? [] : mod.getUnsafeValue('statMods');
			if (statMods)
			{
				for each (var modName:String in statMods)
				{
					var statMod:IPrototype = _prototypeModel.getStatModPrototypeByName(modName);

					if (!statMod)
						continue;
					if (statMod.getUnsafeValue('stat') != stat.stat)
						continue;

					var scope:Number       = statMod.getUnsafeValue('scope');

					if (distance != -1.0 && scope < StatModScopeEnum.Area)
						continue;

					if (!owningEntity)
						continue;

					if (owningEntity is ShipVO && statMod.getUnsafeValue('affectsShips') == false)
						continue;
					if (owningEntity is BuildingVO && statMod.getUnsafeValue('affectsBuildings') == false)
						continue;
					if (!CheckConditional(owningEntity, requestingModule, requestingModuleSlot, ignoreScope, statMod.getUnsafeValue('conditionStat'), statMod.getUnsafeValue('conditionComp'), statMod.getUnsafeValue('conditionValue')))
						continue;

					if (forThisModule || scope > StatModScopeEnum.Module)
					{
						if (distance != -1.0)
						{
							var radius:Number = statMod.getUnsafeValue('radius');

							if (radius < 0.0)
							{
								radius = entityStatCalc(owningEntity, "Radius", 0.0);
							}

							if (distance > radius)
							{
								continue;
							}
						}
					}

					stat.flatBonus += statMod.getUnsafeValue('flatBonus');
					stat.additivePercent += statMod.getUnsafeValue('additivePercent');
					stat.multiplier *= statMod.getUnsafeValue('multiplier');
				}
			}
		}

		private static function CheckConditional( parentEntity:IPrototype, requestingModule:IPrototype, requestingModuleSlot:String, ignoreScope:Boolean, conditionStat:String, conditionComp:String, value:Number ):Boolean
		{

			if (conditionStat == '')
			{
				return true;
			}
			var targetValue:Number = entityStatCalc(parentEntity, conditionStat, 0.0, requestingModule, requestingModuleSlot, ignoreScope);
			switch (conditionComp)
			{
				case StatModConditionalEnum.eq:
					return targetValue == value;
				case StatModConditionalEnum.ne:
					return targetValue != value;
				case StatModConditionalEnum.gt:
					return targetValue > value;
				case StatModConditionalEnum.lt:
					return targetValue < value;
				case StatModConditionalEnum.ge:
					return targetValue >= value;
				case StatModConditionalEnum.le:
					return targetValue <= value;
				default:
					return true;
			}
		}

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
	}
}
