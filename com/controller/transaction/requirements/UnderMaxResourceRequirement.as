package com.controller.transaction.requirements
{
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;

	public class UnderMaxResourceRequirement extends BuildingRequirementBase implements IRequirement
	{
		private var _purchaceVO:PurchaseVO;
	
		private const NOT_MET_STRING:String         = 'CodeString.ResearchInformation.UnderMaxResource'; //Cost Exceeds Max Resource Count
		
		public function init( purchaceVO:PurchaseVO ):void
		{
			_purchaceVO = purchaceVO;
		}
		
		public function get showIfMet():Boolean { return false; }
		
		public function get isMet():Boolean
		{
			return !_purchaceVO.costExceedsMaxResources;
		}
		
		public function toHtml():String
		{
			return Localization.instance.getString(NOT_MET_STRING);
		}
	}
}

