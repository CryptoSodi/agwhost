/*
   Copyright (c) 2008, Adobe Systems Incorporated
   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are
   met:

 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

 * Neither the name of Adobe Systems Incorporated nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
   IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
   PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package org.adobe.utils
{
	import com.Application;
	import com.enum.TooltipEnum;
	import com.enum.TypeEnum;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.prototype.PrototypeVO;
	import com.service.language.Localization;
	import com.ui.core.component.tooltips.Tooltip;
	import com.util.statcalc.StatCalcUtil;

	import flash.utils.Dictionary;

	/**
	 * 	Class that contains static utility methods for manipulating Strings.
	 *
	 * 	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *	@tiptext
	 */
	public class StringUtil
	{
		private static var _locDictionary:Dictionary = new Dictionary();

		private static const _daysText:String        = 'CodeString.Shared.Time.Days'; // [[Number.Days]] d
		private static const _hoursText:String       = 'CodeString.Shared.Time.Hours'; // [[Number.Hours]] h
		private static const _minutesText:String     = 'CodeString.Shared.Time.Minutes'; // [[Number.Minutes]] m
		private static const _secondsText:String     = 'CodeString.Shared.Time.Seconds'; // [[Number.Seconds]] s

		/**
		 *	Formats a number to include a leading zero if it is a single digit
		 *	between -1 and 10.
		 *
		 * 	@param n The number that will be formatted
		 *
		 *	@return A string with single digits between -1 and 10 padded with a
		 *	leading zero.
		 */
		public static function addLeadingZero( num:uint ):String
		{
			if (num < 10)
			{
				return ("0" + num);
			}
			return String(num);
		}

		/**
		 * format a number with commas - ie. 10000 -> 10,000
		 * @param inNum (Object) String or Number
		 */
		public static function commaFormatNumber( inNum:Object ):String
		{
			var tmp:String        = String(inNum);
			var decimal:String    = '';
			var usePeriod:Boolean = (Application.LANGUAGE == 'de' || Application.LANGUAGE == 'it' || Application.LANGUAGE == 'pt')
			//step through backwards and insert commas
			var outString:String  = "";
			var neg:Boolean       = tmp.charAt(0) == "-";
			if (neg)
				tmp = tmp.slice(1);
			if (tmp.indexOf('.') != -1)
			{
				var split:Array = tmp.split('.');
				tmp = split[0];
				decimal = split[1];

				decimal = (usePeriod) ? ',' + decimal : '.' + decimal;
			}

			var l:Number          = tmp.length;
			var symbol:String     = (usePeriod) ? '.' : ',';
			for (var i:int = 0; i < l; i++)
			{
				if (i % 3 == 0 && i > 0)
					outString = symbol + outString;
				outString = tmp.substr(l - (i + 1), 1) + outString;
			}
			if (neg)
				outString = '-' + outString;

			if (decimal != '')
				outString += decimal;

			return outString;
		}

		public static function abbreviateNumber( inNum:Number ):String
		{
			var tmp:String = inNum.toFixed();
			if (tmp.length >= 4)
			{
				var len:int    = tmp.length;
				switch (len)
				{
					case 4:
						inNum *= 0.01;
						inNum = Number(inNum.toFixed(0));
						inNum *= 100;
						tmp = commaFormatNumber(inNum);
						break;
					case 5:
						tmp = tmp.slice(0, 2);
						tmp += ' K';
						break;
					case 6:
						tmp = tmp.slice(0, 3);
						tmp += ' K';
						break;
					case 7:
						tmp = tmp.slice(0, 1);
						tmp += ' M';
						break;
					case 8:
						tmp = tmp.slice(0, 2);
						tmp += ' M';
						break;
					case 9:
						tmp = tmp.slice(0, 3);
						tmp += ' M';
						break;
					default:
						tmp = commaFormatNumber(inNum);
				}
			}
			return tmp;
		}

		/**
		 * Encode HTML.
		 */
		public static function htmlEncode( s:String ):String
		{
			s = replace(s, "&", "&amp;");
			s = replace(s, "<", "&lt;");
			s = replace(s, ">", "&gt;");
			s = replace(s, "™", '&trade;');
			s = replace(s, "®", '&reg;');
			s = replace(s, "©", '&copy;');
			s = replace(s, "€", "&euro;");
			s = replace(s, "£", "&pound;");
			s = replace(s, "—", "&mdash;");
			s = replace(s, "–", "&ndash;");
			s = replace(s, "…", "&hellip;");
			s = replace(s, "†", "&dagger;");
			s = replace(s, "·", "&middot;");
			s = replace(s, "µ", "&micro;");
			s = replace(s, "«", "&laquo;");
			s = replace(s, "»", "&raquo;");
			s = replace(s, "•", "&bull;");
			s = replace(s, "°", "&deg;");
			s = replace(s, '"', "&quot;");
			s = replace(s, "'", "&apos;");
			return s;
		}

		/**
		 * Decode HTML.
		 */
		public static function htmlDecode( s:String ):String
		{
			s = replace(s, "&amp;", "&");
			s = replace(s, "&lt;", "<");
			s = replace(s, "&gt;", ">");
			s = replace(s, "&trade;", '™');
			s = replace(s, "&reg;", "®");
			s = replace(s, "&copy;", "©");
			s = replace(s, "&euro;", "€");
			s = replace(s, "&pound;", "£");
			s = replace(s, "&mdash;", "—");
			s = replace(s, "&ndash;", "–");
			s = replace(s, "&hellip;", '…');
			s = replace(s, "&dagger;", "†");
			s = replace(s, "&middot;", '·');
			s = replace(s, "&micro;", "µ");
			s = replace(s, "&laquo;", "«");
			s = replace(s, "&raquo;", "»");
			s = replace(s, "&bull;", "•");
			s = replace(s, "&deg;", "°");
			s = replace(s, "&ldquo", '"');
			s = replace(s, "&rsquo;", "'");
			s = replace(s, "&rdquo;", '"');
			s = replace(s, "&quot;", '"');
			return s;
		}

		/**
		 *	Does a case insensitive compare or two strings and returns true if
		 *	they are equal.
		 *
		 *	@param s1 The first string to compare.
		 *
		 *	@param s2 The second string to compare.
		 *
		 *	@returns A boolean value indicating whether the strings' values are
		 *	equal in a case sensitive compare.
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function stringsAreEqual( s1:String, s2:String,
												caseSensitive:Boolean ):Boolean
		{
			if (caseSensitive)
			{
				return (s1 == s2);
			} else
			{
				return (s1.toUpperCase() == s2.toUpperCase());
			}
		}

		/**
		 *	Removes whitespace from the front and the end of the specified
		 *	string.
		 *
		 *	@param input The String whose beginning and ending whitespace will
		 *	will be removed.
		 *
		 *	@returns A String with whitespace removed from the begining and end
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function trim( input:String ):String
		{
			return StringUtil.ltrim(StringUtil.rtrim(input));
		}

		/**
		 *	Removes whitespace from the front of the specified string.
		 *
		 *	@param input The String whose beginning whitespace will will be removed.
		 *
		 *	@returns A String with whitespace removed from the begining
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function ltrim( input:String ):String
		{
			var size:Number = input.length;
			for (var i:Number = 0; i < size; i++)
			{
				if (input.charCodeAt(i) > 32)
				{
					return input.substring(i);
				}
			}
			return "";
		}

		/**
		 *	Removes whitespace from the end of the specified string.
		 *
		 *	@param input The String whose ending whitespace will will be removed.
		 *
		 *	@returns A String with whitespace removed from the end
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function rtrim( input:String ):String
		{
			var size:Number = input.length;
			for (var i:Number = size; i > 0; i--)
			{
				if (input.charCodeAt(i - 1) > 32)
				{
					return input.substring(0, i);
				}
			}

			return "";
		}

		/**
		 *	Determines whether the specified string begins with the spcified prefix.
		 *
		 *	@param input The string that the prefix will be checked against.
		 *
		 *	@param prefix The prefix that will be tested against the string.
		 *
		 *	@returns True if the string starts with the prefix, false if it does not.
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function beginsWith( input:String, prefix:String ):Boolean
		{
			return (prefix == input.substring(0, prefix.length));
		}

		/**
		 *	Determines whether the specified string ends with the spcified suffix.
		 *
		 *	@param input The string that the suffic will be checked against.
		 *
		 *	@param prefix The suffic that will be tested against the string.
		 *
		 *	@returns True if the string ends with the suffix, false if it does not.
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function endsWith( input:String, suffix:String ):Boolean
		{
			return (suffix == input.substring(input.length - suffix.length));
		}

		/**
		 *	Removes all instances of the remove string in the input string.
		 *
		 *	@param input The string that will be checked for instances of remove
		 *	string
		 *
		 *	@param remove The string that will be removed from the input string.
		 *
		 *	@returns A String with the remove string removed.
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function remove( input:String, remove:String ):String
		{
			return StringUtil.replace(input, remove, "");
		}

		/**
		 *	Replaces all instances of the replace string in the input string
		 *	with the replaceWith string.
		 *
		 *	@param input The string that instances of replace string will be
		 *	replaces with removeWith string.
		 *
		 *	@param replace The string that will be replaced by instances of
		 *	the replaceWith string.
		 *
		 *	@param replaceWith The string that will replace instances of replace
		 *	string.
		 *
		 *	@returns A new String with the replace string replaced with the
		 *	replaceWith string.
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function replace( input:String, replace:String, replaceWith:String ):String
		{
			return input.split(replace).join(replaceWith);
		}


		/**
		 *	Specifies whether the specified string is either non-null, or contains
		 *  	characters (i.e. length is greater that 0)
		 *
		 *	@param s The string which is being checked for a value
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public static function stringHasValue( s:String ):Boolean
		{
			//todo: this needs a unit test
			return (s != null && s.length > 0);
		}

		public static function escapeHTML( s:String ):String
		{
			return s.split('<').join('&lt;').split('>').join('&gt;').split("&apos;").join("'");
		}

		public static function convertToRomanNumeral( num:int ):String
		{
			//TODO make this work for numbers larger than 10
			switch (num)
			{
				case 1:
					return 'I';
				case 2:
					return 'II';
				case 3:
					return 'III';
				case 4:
					return 'IV';
				case 5:
					return 'V';
				case 6:
					return 'VI';
				case 7:
					return 'VII';
				case 8:
					return 'VIII';
				case 9:
					return 'IX';
			}
			return 'X';
		}

		public static function getTooltip( type:String, proto:*, showName:Boolean = true, diffProto:* = null, abbreviated:Boolean = false ):String
		{
			var tooltip:String   = '';
			var assetVO:AssetVO;
			var loc:Localization = Localization.instance;
			assetVO = AssetModel.instance.getEntityData(proto.getUnsafeValue('uiAsset'));
			if (showName)
			{
				var rarity:String      = proto.getUnsafeValue('rarity');
				var rarityColor:String = getRarityColor(proto);

				if (!assetVO)
					assetVO = AssetModel.instance.getEntityData(proto.asset);
				if (assetVO)
					tooltip = '<font size="16" color="#' + rarityColor + '">' + loc.getString(assetVO.visibleName) + '</font><br/>\n';
			}

			// Add indentation
			tooltip += '<textformat blockindent="6" rightmargin="13">';

			var tipRows:Array    = getStatLabels(type, proto, -1, diffProto, abbreviated);
			for (var i:Number = 0; i < tipRows.length; i++)
				tooltip += tipRows[i] + '<br/>\n';

			// Close indentation
			tooltip += '</textformat>';

			return tooltip;
		}

		public static function getRarityColor( proto:* ):String
		{
			var rarity:String = proto.getUnsafeValue('rarity');
			if (rarity)
			{
				switch (rarity)
				{
					case 'Common':
						return "E7E7E7";
						break;
					case 'Uncommon':
						return "6ADB4C";
						break;
					case 'Rare':
						return "5285F7";
						break;
					case 'Epic':
						return "AB58FF";
						break;
					case 'Legendary':
						return "FA9D2F";
						break;
				}
			}
			return "F0F0F0";
		}

		public static function getStatLabels( type:String, proto:*, rows:Number = 6, diffProto:* = null, abbreviated:Boolean = false ):Array
		{
			var statList:Array = new Array();
			switch (uint(type))
			{
				case TypeEnum.SHIP_RESEARCH_TT:
					statList = (abbreviated) ? TooltipEnum.SHIP_RESEARCH_ABBR : TooltipEnum.SHIP_RESEARCH;
					break;
				case TypeEnum.SHIP_BUILT_TT:
					statList = TooltipEnum.SHIP_BUILT;
					break;
				case TypeEnum.PROJECTILE_TT:
				case TypeEnum.PROJECTILE_TURRET_TT:
					statList = (abbreviated) ? TooltipEnum.PROJECTILE_ABBR : TooltipEnum.PROJECTILE;
					break;
				case TypeEnum.BEAM_TT:
				case TypeEnum.BEAM_TURRET_TT:
					statList = (abbreviated) ? TooltipEnum.BEAM_ABBR : TooltipEnum.BEAM;
					break;
				case TypeEnum.AREA_TT:
					statList = (abbreviated) ? TooltipEnum.AREA_ABBR : TooltipEnum.AREA;
					break;
				case TypeEnum.DRONE_TT:
				case TypeEnum.DRONE_TURRET_TT:
					statList = (abbreviated) ? TooltipEnum.DRONE_ABBR : TooltipEnum.DRONE;
					break;
				case TypeEnum.DEFENSE_TT:
					statList = (abbreviated) ? TooltipEnum.DEFENSE_ABBR : TooltipEnum.DEFENSE;
					break;
				case TypeEnum.SHIELD_TT:
					statList = (abbreviated) ? TooltipEnum.SHIELD_ABBR : TooltipEnum.SHIELD;
					break;
				case TypeEnum.ARMOR_TT:
					statList = (abbreviated) ? TooltipEnum.ARMOR_ABBR : TooltipEnum.ARMOR;
					break;
				case TypeEnum.TECH_TT:
					statList = (abbreviated) ? TooltipEnum.TECH_ABBR : TooltipEnum.TECH;
					break;
				case TypeEnum.BUILDING_TT:
				case TypeEnum.BASE_SHIELD_TT:
				case TypeEnum.BASE_TURRET_TT:
					statList = (abbreviated) ? TooltipEnum.BUILDING_ABBR : TooltipEnum.BUILDING;
					break;
			}

			var tipRows:Array  = new Array();
			tipRows = composeBaseTooltip(statList, proto, diffProto);
			tipRows = tipRows.concat(composeStatModTooltip(proto, diffProto));

			// Add list of equipped module names for built ships
			if (uint(type) == TypeEnum.SHIP_BUILT_TT)
				tipRows = tipRows.concat(composeEquippedModuleTooltip(proto));

			// Add a list of unlocked research for buildings
			if (uint(type) == TypeEnum.BUILDING_TT)
				tipRows = tipRows.concat(composeResearchUnlockTooltip(proto));

			if (rows < 0)
				return tipRows;
			else
				return tipRows.slice(0, rows);

		}

		public static function composeBaseTooltip( statSet:Array, vo:*, difVo:* = false ):Array
		{
			var tipRows:Array = new Array();

			for (var i:int = 0; i < statSet.length; i++)
			{
				var value:String;
				var difValue:String;
				if (statSet[i] == 'dps')
				{
					value = calcModuleDpsTooltip(vo).toString();
					if (difVo)
						difValue = calcModuleDpsTooltip(difVo).toString();
				} else if (statSet[i] == 'shipDps')
				{
					value = calcTotalShipDpsTooltip(vo).toString();
					if (difVo)
						difValue = calcTotalShipDpsTooltip(difVo).toString();
				} else if (statSet[i] == 'shipRange')
				{
					value = calcWeaponRangeTooltip(vo.modules).toString();
					if (difVo)
						difValue = calcWeaponRangeTooltip(difVo.modules).toString();
				} else if (statSet[i] == 'itemClass')
				{
					value = getLocalizedResearch(vo.getUnsafeValue('itemClass'));
				} else if (statSet[i] == 'damageType')
				{
					var type:Number = vo.getValue(statSet[i]);
					if (type == 3)
						value = Localization.instance.getString('CodeString.DamageType.force');
					else if (type == 2)
						value = Localization.instance.getString('CodeString.DamageType.explosive');
					else if (type == 1)
						value = Localization.instance.getString('CodeString.DamageType.energy');
				} else if (statSet[i] == 'attackType')
				{
					var val:Number = Number(vo.getValue(statSet[i]));
					if (val == 1)
						value = Localization.instance.getString('CodeString.AttackType.Beam');
					else if (val == 2)
						value = Localization.instance.getString('CodeString.AttackType.Projectile');
					else if (val == 3)
						value = Localization.instance.getString('CodeString.AttackType.Guided');
				} else
				{
					value = vo.getUnsafeValue(statSet[i]);
					if (difVo)
						difValue = difVo.getUnsafeValue(statSet[i]);
				}

				// If we're diffing and there's no diff then skip it
				if (difVo && value == difValue)
					continue;

				var rowString:String = formatStatRow(statSet[i], value, 'flat', 'Base', difValue);
				if (rowString != '')
					tipRows.push(rowString);
			}

			return tipRows;
		}

		public static function composeStatModTooltip( proto:IPrototype, difProto:IPrototype = null ):Array
		{
			var tipRows:Array  = new Array();
			var statMods:Array = !(proto.getUnsafeValue('statMods') is Array) ? [] : proto.getUnsafeValue('statMods');

			// If there are any stat mods then line 'em up
			if (statMods)
			{
				for each (var modName:String in statMods)
				{
					var statMod:IPrototype     = PrototypeModel.instance.getStatModPrototypeByName(modName);
					var difValue:String        = '';

					// Get the dif value if needed
					if (difProto)
					{
						// Look for a matching mod on the dif item
						var difStatMods:Array = difProto.getUnsafeValue('statMods');
						for each (var difModName:String in difStatMods)
						{
							var difStatMod:IPrototype     = PrototypeModel.instance.getStatModPrototypeByName(difModName);
							var difFlatBonus:Number       = difStatMod.getValue('flatBonus');
							var difAdditivePercent:Number = difStatMod.getValue('additivePercent');
							var difMultiplier:Number      = difStatMod.getValue('multiplier');
							if (difStatMod.getValue('stat') == statMod.getValue('stat'))
							{
								if (difMultiplier != 1)
									difValue = difMultiplier.toString();
								else if (difAdditivePercent != 0)
									difValue = difAdditivePercent.toString();
								else
									difValue = difFlatBonus.toString();
								break;
							}
						}
					}

					var flatBonus:Number       = statMod.getValue('flatBonus');
					var additivePercent:Number = statMod.getValue('additivePercent');
					var multiplier:Number      = statMod.getValue('multiplier');

					// Format the value itself according to type
					var value:String           = '';
					var format:String          = '';
					if (multiplier != 1)
					{
						value = multiplier.toString();
						format = 'multiplier';
					} else if (additivePercent != 0)
					{
						value = additivePercent.toString();
						format = 'percent';
					} else
					{
						value = flatBonus.toString();
						format = 'flat';
					}

					// If we're diffing and there's no dif then skip
					if (difValue != '' && value == difValue)
						continue;

					var statName:String        = statMod.getValue('stat');
					var overrideName:String    = statMod.getUnsafeValue('displayStat');
					if (overrideName)
						statName = overrideName;

					// If the bonus has a radius figure it out
					var radius:String          = statMod.getUnsafeValue('radius');
					if (radius == null)
						radius = '0';

					var rowString:String       = formatStatRow(statName, value, format, statMod.getValue('type'), difValue, radius);
					if (rowString != '')
						tipRows.push(rowString);
				}
			}

			return tipRows;
		}

		public static function composeEquippedModuleTooltip( shipVO:ShipVO ):Array
		{
			var loc:Localization    = Localization.instance;
			// Create each section and add header
			var listName:String;
			var weaponTips:Array    = new Array();
			listName = Localization.instance.getString('CodeString.Tooltip.ModuleList.Weapons');
			weaponTips.push('<font color="#B3DDF2">' + listName + '</font>');
			var specialTips:Array   = new Array();
			listName = Localization.instance.getString('CodeString.Tooltip.ModuleList.Specials');
			specialTips.push('<font color="#B3DDF2">' + listName + '</font>');
			var defenseTips:Array   = new Array();
			listName = Localization.instance.getString('CodeString.Tooltip.ModuleList.Defense');
			defenseTips.push('<font color="#B3DDF2">' + listName + '</font>');
			var techTips:Array      = new Array();
			listName = Localization.instance.getString('CodeString.Tooltip.ModuleList.Tech');
			techTips.push('<font color="#B3DDF2">' + listName + '</font>');
			var structureTips:Array = new Array();
			listName = Localization.instance.getString('CodeString.Tooltip.ModuleList.Structure');
			structureTips.push('<font color="#B3DDF2">' + listName + '</font>');

			// Populate each section
			var moduleVO:IPrototype;
			var mods:Dictionary     = shipVO.modules;
			for (var key:String in mods)
			{
				moduleVO = mods[key];
				if (!moduleVO)
					continue;

				var color:String    = getRarityColor(moduleVO);
				var assetVO:AssetVO = AssetModel.instance.getEntityData(moduleVO.getUnsafeValue('uiAsset'));
				var name:String     = ' • <font color="#' + color + '">' + loc.getString(assetVO.visibleName) + '</font>';

				var type:String     = moduleVO.getValue('slotType');
				if (type == 'Weapon')
					weaponTips.push(name);
				else if (type == 'Arc' || type == 'DroneBay' || type == 'Spinal')
					specialTips.push(name);
				else if (type == 'Defense')
					defenseTips.push(name);
				else if (type == 'Tech')
					techTips.push(name);
				else if (type == 'Structure')
					structureTips.push(name);
			}

			// Compile master list from populated sections
			var tipRows:Array       = new Array();
			if (weaponTips.length > 1)
				tipRows = tipRows.concat(weaponTips);
			if (specialTips.length > 1)
				tipRows = tipRows.concat(specialTips);
			if (defenseTips.length > 1)
				tipRows = tipRows.concat(defenseTips);
			if (techTips.length > 1)
				tipRows = tipRows.concat(techTips);
			if (structureTips.length > 1)
				tipRows = tipRows.concat(structureTips);

			return tipRows;
		}

		public static function composeResearchUnlockTooltip( buildingProto:PrototypeVO, verbose:Boolean = true, countBlueprints:Boolean = false ):Array
		{
			// Create each section and add header
			var researchTips:Array    = new Array();
			researchTips.push('TEMP');

			// Identify the building that's asking
			var buildingName:String   = buildingProto.name;
			var playerFaction:String  = CurrentUser.faction;

			// Initialize a count of the findings
			var tokens:Dictionary     = new Dictionary();
			tokens['[[count]]'] = 0;

			var loc:Localization      = Localization.instance;

			// Populate each section
			var researches:Dictionary = PrototypeModel.instance.getResearchPrototypesDict();
			for (var key:String in researches)
			{
				if (researches[key] is IPrototype)
				{
					var research:IPrototype = researches[key];
					if (research.getUnsafeValue("requiredBuilding") == buildingName)
					{
						var factionReq:String = research.getUnsafeValue("requiredFaction");
						if (!factionReq || factionReq == playerFaction)
						{
							var rarity:String = research.getUnsafeValue("rarity");
							if (!countBlueprints && rarity != "Common")
								continue;

							// Update the count
							tokens['[[count]]']++;

							if (verbose)
							{
								var assetVO:AssetVO = AssetModel.instance.getEntityData(research.getUnsafeValue('uiAsset'));
								var name:String     = ' • <font color="#F0F0F0">' + loc.getString(assetVO.visibleName) + '</font>';
								researchTips.push(name);
							}
						}
					}
				}
			}

			// Write lable with the count of found items
			var listName:String       = loc.getStringWithTokens('CodeString.Tooltip.UnlockCount', tokens);
			researchTips[0] = '<font color="#B3DDF2">' + listName + '</font>';

			if (tokens['[[count]]'])
				return researchTips;
			else
				return new Array();
		}

		public static function formatStatRow( stat:String, value:String, format:String = 'flat', type:String = 'Base', difValue:String = null, radius:String = '0' ):String
		{
			// Do nothing for hidden stats
			if (type == 'Hidden')
				return '';

			// Get the stat prototype for this stat
			var statProto:IPrototype = PrototypeModel.instance.getStatPrototypeByName(stat);
			if (!statProto)
				return '[[Missing Stat Proto: ' + stat + ']] ' + value;

			// Special case for leading (TODO: Generalize this via stat prototype)
			var boolThreshold:Number = statProto.getUnsafeValue("boolThreshold");
			if (boolThreshold)
			{
				if (Number(value) < boolThreshold)
					value = "false";
				else
					value = "true";
			}

			// Do nothing if the stat has is not different from base value
			if (Number(value) == statProto.getUnsafeValue("stdBase"))
				return '';

			// Localize boolean values
			if (value == 'true')
				value = Localization.instance.getString('CodeString.BooleanValue.True');
			else if (value == 'false')
				value = Localization.instance.getString('CodeString.BooleanValue.False');

			// Generate the dif value if needed
			if (difValue && !isNaN(Number(value)))
				difValue = String(Number(value) - Number(difValue));

			// Set coloring for dif value
			if (difValue)
				var difColor:String  = ((Number(difValue) < 0 && statProto.getValue('negativeGood')) ||
					(Number(difValue) >= 0 && !statProto.getValue('negativeGood'))) ? '00FF00' : 'FF0000';

			// Format the values
			value = formatValue(value, statProto, format, type);
			if (difValue)
				difValue = formatValue(difValue, statProto, format, 'Dif');

			// Set coloring for row
			var bodyColor:String     = (type == 'Bonus') ? '00FF00' : 'B3DDF2';
			var valueColor:String    = (type == 'Bonus') ? 'A0FFA0' : 'F0F0F0';

			// Inject alternate diff value for radius bonuses
			var radString:String     = '';
			if (Number(radius) > 0)
			{
				var radTokens:Dictionary = new Dictionary();
				radTokens['[[RadColor]]'] = valueColor;
				radTokens['[[RadValue]]'] = radius;
				radString = Localization.instance.getStringWithTokens('CodeString.StatRadius', radTokens);
			}

			// Format and set the value tokens
			var tokens:Dictionary    = new Dictionary();
			tokens['[[Value]]'] = value;
			tokens['[[ValueColor]]'] = valueColor;
			if (difValue)
			{
				tokens['[[DifValue]]'] = difValue;
				tokens['[[DifColor]]'] = difColor;
			}

			// Compose the finalized row
			var locKey:String;
			if (difValue)
				locKey = statProto.getValue("difLocKey");
			else
				locKey = statProto.getValue("locKey");

			// Get the localized row string
			var rowString:String     = Localization.instance.getStringWithTokens(locKey, tokens);

			// Insert error notice if needed
			if (rowString == '')
				rowString = 'Missing Loc Data (' + locKey + ')';

			// Color the body of the row
			rowString = '<font color="#' + bodyColor + '">' + rowString + radString + '</font>';

			return rowString;
		}

		public static function formatValue( value:String, statProto:IPrototype, format:String, type:String ):String
		{
			// Format the value itself
			var valString:String;

			// Flip the value if needed
			if (!isNaN(Number(value)) && statProto.getUnsafeValue("flipValue"))
				value = String(Number(statProto.getValue("flipValue")) - Number(value));

			// Multiply the value if needed
			if (!isNaN(Number(value)))
				value = String(Number(value) * Number(statProto.getValue("displayScale")));

			// Fix precision or insert commas
			var precision:Number = statProto.getUnsafeValue("precision");
			if (precision > 0)
				valString = Number(value).toFixed(precision);
			else if (!isNaN(Number(value)) && Number(value) > 999)
				valString = commaFormatNumber(Math.round(Number(value)));
			else if (!isNaN(Number(value)))
				valString = String(Math.round(Number(value)));
			else
				valString = value;

			// Add relativity marks to value
			if ((type == 'Bonus' || type == 'Mod' || type == 'Dif') && !isNaN(Number(value)))
			{
				if (Number(value) < 0)
					valString = Localization.instance.getString('CodeString.Symbol.Subtract') + String(Math.abs(Number(valString)));
				else
					valString = Localization.instance.getString('CodeString.Symbol.Add') + valString;
			}

			return valString;
		}

		public static function calcTotalShipDpsTooltip( shipVO:ShipVO ):Number
		{
			var modules:Dictionary = shipVO.modules;
			var totalDPS:Number    = 0.0;
			for (var key:String in modules)
			{
				var module:IPrototype = modules[key];
				if (module)
				{
					var slotType:String = module.getValue('slotType');
					if (slotType == "Weapon" || slotType == "Spinal" || slotType == "Arc" || slotType == "Drone" || slotType == "BaseTurret")
						totalDPS += calcModuleDpsTooltip(module, key, shipVO);
				}
			}
			return totalDPS;
		}

		public static function calcModuleDpsTooltip( mod:IPrototype, slot:String = '', ship:ShipVO = null ):Number
		{
			var damage:Number      = 0;
			var volley:Number      = 0;
			var tickRate:Number    = 0;
			var duration:Number    = 0;
			var fireTime:Number    = 0;
			var burstSize:Number   = 0;
			var reloadTime:Number  = 0;
			var chargeTime:Number  = 0;
			var maxDrones:Number   = 0;
			var damageTime:Number  = 0;

			// Use stat calc if on a ship, or base attributes for loose modules
			if (ship)
			{
				damage = StatCalcUtil.entityStatCalc(ship, 'damage', 0.0, mod, slot);
				volley = StatCalcUtil.entityStatCalc(ship, 'volleySize', 0.0, mod, slot);
				tickRate = StatCalcUtil.entityStatCalc(ship, 'tickRate', 0.0, mod, slot);
				duration = StatCalcUtil.entityStatCalc(ship, 'duration', 0.0, mod, slot);
				fireTime = StatCalcUtil.entityStatCalc(ship, 'fireTime', 0.0, mod, slot);
				burstSize = StatCalcUtil.entityStatCalc(ship, 'burstSize', 0.0, mod, slot);
				reloadTime = StatCalcUtil.entityStatCalc(ship, 'reloadTime', 0.0, mod, slot);
				chargeTime = StatCalcUtil.entityStatCalc(ship, 'chargeTime', 0.0, mod, slot);
				maxDrones = StatCalcUtil.entityStatCalc(ship, 'maxDrones', 0.0, mod, slot);
				damageTime = StatCalcUtil.entityStatCalc(ship, 'damageTime', 0.0, mod, slot);
			} else
			{
				damage = mod.getUnsafeValue('damage');
				volley = mod.getUnsafeValue('volleySize');
				tickRate = mod.getUnsafeValue('tickRate');
				duration = mod.getUnsafeValue('duration');
				fireTime = mod.getUnsafeValue('fireTime');
				burstSize = mod.getUnsafeValue('burstSize');
				reloadTime = mod.getUnsafeValue('reloadTime');
				chargeTime = mod.getUnsafeValue('chargeTime');
				maxDrones = mod.getUnsafeValue('maxDrones');
				damageTime = mod.getUnsafeValue('damageTime');
			}

			// Do the appropriate calculation based on the attack type
			var type:int           = mod.getValue('attackMethod');
			var totalDamage:Number = 0;
			var totalPeriod:Number = 0;
			if (type == 1 || type == 2 || type == 3)
			{
				// Beams and Projectiles
				totalDamage = damage * Math.max(burstSize, 1) * Math.max(volley, 1);
				totalPeriod = (fireTime * burstSize) + reloadTime + chargeTime;
			} else if (type == 4)
			{
				// Areas
				totalDamage = damage * Math.max(burstSize, 1) * Math.max(volley, 1) * Math.max(duration / Math.max(tickRate, 1), 1);
				totalPeriod = (fireTime * burstSize) + reloadTime + chargeTime + duration;
			} else if (type == 5)
			{
				// Drones
				totalDamage = damage * Math.max(maxDrones, 1);
				totalPeriod = damageTime;
			}

			var DPS:Number         = totalDamage / totalPeriod;
			return DPS;
		}

		public static function calcWeaponRangeTooltip( mods:Dictionary ):Number
		{
			var range:Number = 0;
			var vo:IPrototype;

			for (var key:String in mods)
			{
				vo = mods[key];
				if (!vo || vo.getValue('slotType') == 'Defense' || vo.getValue('slotType') == 'Tech' || vo.getValue('slotType') == 'Structure')
					continue;

				var thisRange:Number = vo.getValue('maxRange');
				range = (thisRange > range) ? thisRange : range;
			}
			return range;
		}

		public static function getBuildTime( seconds:Number, maxElems:int = 4 ):String
		{
			var loc:Localization = Localization.instance;
			var s:int            = seconds % 60;
			var m:int            = Math.floor((seconds % 3600) / 60);
			var h:int            = Math.floor(seconds % (24 * 60 * 60)) / (60 * 60);
			var d:int            = Math.floor(seconds / (60 * 60 * 24));
			var elems:int;

			if (d != 0)
			{
				_locDictionary['[[Number.Days]]'] = loc.getStringWithTokens(_daysText, {'[[Number.Days]]':addLeadingZero(d)}) + ' ';
				++elems;
			} else
				_locDictionary['[[Number.Days]]'] = '';

			if (h != 0 && elems < maxElems)
			{
				_locDictionary['[[Number.Hours]]'] = loc.getStringWithTokens(_hoursText, {'[[Number.Hours]]':addLeadingZero(h)}) + ' ';
				++elems;
			} else
				_locDictionary['[[Number.Hours]]'] = '';

			if (m != 0 && elems < maxElems)
			{
				_locDictionary['[[Number.Minutes]]'] = loc.getStringWithTokens(_minutesText, {'[[Number.Minutes]]':addLeadingZero(m)}) + ' ';
				++elems;
			} else
				_locDictionary['[[Number.Minutes]]'] = '';

			if (elems < maxElems)
			{
				_locDictionary['[[Number.Seconds]]'] = loc.getStringWithTokens(_secondsText, {'[[Number.Seconds]]':addLeadingZero(s)}) + ' ';
				++elems;
			} else
				_locDictionary['[[Number.Seconds]]'] = '';

			return loc.localizeStringWithTokens('[[Number.Days]][[Number.Hours]][[Number.Minutes]][[Number.Seconds]]', _locDictionary);
		}

		public static function getLocalizedResearch( researchClass:String ):String
		{
			switch (researchClass)
			{
				case 'Fighter':
					return 'CodeString.Ship.Fighter';
					break;
				case 'HeavyFighter':
					return 'CodeString.Ship.HeavyFighter';
					break;
				case 'Corvette':
					return 'CodeString.Ship.Corvette';
					break;
				case 'Destroyer':
					return 'CodeString.Ship.Destroyer';
					break;
				case 'Battleship':
					return 'CodeString.Ship.Battleship';
					break;
				case 'Dreadnought':
					return 'CodeString.Ship.Dreadnought';
					break;
				case 'Transport':
					return 'CodeString.Ship.Transport';
					break;
				case 'ParticleBlaster':
					return 'CodeString.ModuleClass.ParticleBlaster';
					break;
				case 'StrikeCannon':
					return 'CodeString.ModuleClass.StrikeCannon';
					break;
				case 'Railgun':
					return 'CodeString.ModuleClass.Railgun';
					break;
				case 'GravitonPulseNode':
					return 'CodeString.ModuleClass.GravitonPulseNode';
					break;
				case 'PlasmaMissile':
					return 'CodeString.ModuleClass.PlasmaMissile';
					break;
				case 'AntimatterTorpedo':
					return 'CodeString.ModuleClass.AntimatterTorpedo';
					break;
				case 'GravitonBomb':
					return 'CodeString.ModuleClass.GravitonBomb';
					break;
				case 'MissileBattery':
					return 'CodeString.ModuleClass.MissileBattery';
					break;
				case 'BombardmentCannon':
					return 'CodeString.ModuleClass.BombardmentCannon';
					break;
				case 'MissilePod':
					return 'CodeString.ModuleClass.MissilePod';
					break;
				case 'SentinelMount':
					return 'CodeString.ModuleClass.SentinelMount';
					break;
				case 'PulseLaser':
					return 'CodeString.ModuleClass.PulseLaser';
					break;
				case 'DisintegrationRay':
					return 'CodeString.ModuleClass.DisintegrationRay';
					break;
				case 'GravitonBeam':
					return 'CodeString.ModuleClass.GravitonBeam';
					break;
				case 'PointDefenseCluster':
					return 'CodeString.ModuleClass.PointDefenseCluster';
					break;
				case 'PhotonBurster':
					return 'CodeString.ModuleClass.PhotonBurster';
					break;
				case 'DisintegratorArc':
					return 'CodeString.ModuleClass.DisintegratorArc';
					break;
				case 'KineticPulser':
					return 'CodeString.ModuleClass.KineticPulser';
					break;
				case 'FusionBeamer':
					return 'CodeString.ModuleClass.FusionBeamer';
					break;
				case 'DroneBay':
					return 'CodeString.ModuleClass.DroneBay';
					break;
				case 'AssaultSquadron':
					return 'CodeString.ModuleClass.AssaultSquadron';
					break;
				case 'BombardierWing':
					return 'CodeString.ModuleClass.BombardierWing';
					break;
				case 'DroneSquadron':
					return 'CodeString.ModuleClass.DroneSquadron';
					break;
				case 'AntiMissileSystem':
					return 'CodeString.ModuleClass.AntiMissileSystem';
					break;
				case 'DeflectorScreen':
					return 'CodeString.ModuleClass.DeflectorScreen';
					break;
				case 'DistortionWeb':
					return 'CodeString.ModuleClass.DistortionWeb';
					break;
				case 'ConcussiveShield':
					return 'CodeString.ModuleClass.ConcussiveShield';
					break;
				case 'EnergyShield':
					return 'CodeString.ModuleClass.EnergyShield';
					break;
				case 'KineticShield':
					return 'CodeString.ModuleClass.KineticShield';
					break;
				case 'PhaseShield':
					return 'CodeString.ModuleClass.PhaseShield';
					break;
				case 'DispersionArmor':
					return 'CodeString.ModuleClass.DispersionArmor';
					break;
				case 'PlastisteelArmor':
					return 'CodeString.ModuleClass.PlastisteelArmor';
					break;
				case 'DeflectorArmor':
					return 'CodeString.ModuleClass.DeflectorArmor';
					break;
				case 'NeutroniumArmor':
					return 'CodeString.ModuleClass.NeutroniumArmor';
					break;
				case 'CloakingDevice':
					return 'CodeString.ModuleClass.CloakingDevice';
					break;
				case 'ShieldExtender':
					return 'CodeString.ModuleClass.ShieldExtender';
					break;
				case 'MassLightening':
					return 'CodeString.ModuleClass.MassLightening';
					break;
				case 'ImprovedTracking':
					return 'CodeString.ModuleClass.ImprovedTracking';
					break;
				case 'WarpScrambler':
					return 'CodeString.ModuleClass.WarpScrambler';
					break;
				case 'TransgateBeacon':
					return 'CodeString.ModuleClass.TransgateBeacon';
					break;
				case 'ConcussiveShield':
					return 'CodeString.ModuleClass.ConcussiveShield';
					break;
				case 'EnergyShield':
					return 'CodeString.ModuleClass.EnergyShield';
					break;
				case 'KineticShield':
					return 'CodeString.ModuleClass.KineticShield';
					break;
				case 'PhaseShield':
					return 'CodeString.ModuleClass.PhaseShield';
					break;
				case 'MassAmplifier':
					return 'CodeString.ModuleClass.MassAmplifier';
					break;
				case 'LinearAccelerator':
					return 'CodeString.ModuleClass.LinearAccelerator';
					break;
				case 'NeutroniumCore':
					return 'CodeString.ModuleClass.NeutroniumCore';
					break;
				case 'ParticleLens':
					return 'CodeString.ModuleClass.ParticleLens';
					break;
				case 'BackscatterRefractor':
					return 'CodeString.ModuleClass.BackscatterRefractor';
					break;
				case 'CoolingCoils':
					return 'CodeString.ModuleClass.CoolingCoils';
					break;
				case 'GuidanceModule':
					return 'CodeString.ModuleClass.GuidanceModule';
					break;
				case 'ShapedCharge':
					return 'CodeString.ModuleClass.ShapedCharge';
					break;
				case 'ImpellerNodes':
					return 'CodeString.ModuleClass.ImpellerNodes';
					break;
				case 'ProfileSolver':
					return 'CodeString.ModuleClass.ProfileSolver';
					break;
				case 'AssessorModule':
					return 'CodeString.ModuleClass.AssessorModule';
					break;
				case 'PatternCodifier':
					return 'CodeString.ModuleClass.PatternCodifier';
					break;
				case 'IntegrityField':
					return 'CodeString.ModuleClass.IntegrityField';
					break;
				case 'ConcussiveBarrier':
					return 'CodeString.ModuleClass.ConcussiveBarrier';
					break;
				case 'EnergyBarrier':
					return 'CodeString.ModuleClass.EnergyBarrier';
					break;
				case 'KineticBarrier':
					return 'CodeString.ModuleClass.KineticBarrier';
					break;
				case 'PhaseBarrier':
					return 'CodeString.ModuleClass.PhaseBarrier';
					break;
			}
			return '';
		}
	}
}
