package com.controller.transaction.requirements
{
	import com.model.starbase.BuildingVO;
	import com.service.language.Localization;

	public class BuildingRequirementBase extends RequirementBase
	{
		protected var _buildingClass:String;

		public function get locBuildingClass():String
		{
			return Localization.instance.getString('CodeString.Building.' + _buildingClass);
		}

		protected function matchBuildingHelper( item:BuildingVO, index:int, vector:Vector.<BuildingVO> ):Boolean
		{
			return item.itemClass == _buildingClass;
		}
	}
}
