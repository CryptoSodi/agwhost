package com.controller.transaction.requirements
{
	import com.model.starbase.BuildingVO;
	import com.service.language.Localization;

	public class BuildingNotDamagedRequirement extends BuildingRequirementBase implements IRequirement
	{
		private var _building:BuildingVO;

		private const NOT_MET_STRING:String = 'CodeString.ResearchInformation.BuildingDamaged'; //Repair the building
		private const NOT_BUILT_STRING:String = 'CodeString.ResearchInformation.BuildingNotBuilt'; //Build the building

		public function init( building:BuildingVO ):void
		{
			_building = building;
		}

		public function get isMet():Boolean
		{
			var isMet:Boolean;
			if(_building)
				isMet = _building.currentHealth == 1;
			return isMet;
		}

		public function get showIfMet():Boolean  { return false; }

		public function toString():String
		{
			if(_building)
				return Localization.instance.getString(NOT_MET_STRING);
			else
				return Localization.instance.getString(NOT_BUILT_STRING);
		}

		public function toHtml():String
		{
			return toString().toUpperCase();
		}

		override public function destroy():void
		{
			super.destroy();
			_building = null;
		}
	}
}
