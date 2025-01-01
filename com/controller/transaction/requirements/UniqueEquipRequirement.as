package com.controller.transaction.requirements
{
	import com.model.prototype.IPrototype;

	import flash.utils.Dictionary;

	public class UniqueEquipRequirement extends RequirementBase implements IRequirement
	{
		private var _item:IPrototype;
		private var _modules:Dictionary;
		private var _refitModules:Dictionary;
		private var _slotID:String;

		private var _uniqueEquipped:String = 'CodeString.ComponentSelection.UniqueEquipped'; //Unique: 1

		public function init( item:IPrototype, modules:Dictionary, refitModules:Dictionary, slotId:String ):void
		{
			_item = item;
			_modules = modules;
			_refitModules = refitModules;
			_slotID = slotId;
		}

		public function UniqueEquipRequirement()
		{
			super();
		}

		public function get showIfMet():Boolean
		{
			return false;
		}

		public function get isMet():Boolean
		{
			var uniqueCat:String = _item.getValue("uniqueCategory");

			if (uniqueCat.length == 0)
				return true;

			if (_modules)
			{
				for (var key:String in _modules)
				{
					var module:IPrototype      = _modules[key];
					var refitModule:IPrototype = _refitModules[key];
					if (refitModule && refitModule.getValue("uniqueCategory") == uniqueCat && _slotID != key)
						return false;
					else if (module && module.getValue("uniqueCategory") == uniqueCat && _slotID != key && (!refitModule || refitModule.name == module.name))
						return false;
					else
					{
						if (refitModule == _item)
							return false;
						else if (module == _item && refitModule == null)
							return false;
					}

				}
			}

			return true;
		}

		public function toHtml():String
		{
			return _uniqueEquipped;
		}
	}
}
