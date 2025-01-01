package com.controller.transaction.requirements
{
	import com.controller.transaction.TransactionController;
	import com.model.prototype.PrototypeModel;
	import com.service.language.Localization;

	/**
	 * Just to make this as confusing as possible: The requirement is that you have not yet researched the tech.
	 * If you already know it, you fail to meet the requirement.
	 *
	 * @author tkeating
	 */
	public class TechNotKnownRequirement extends RequirementBase implements IRequirement
	{
		private var _unknownTech:String;
		private var _prototypeModel:PrototypeModel;
		private var _transactionController:TransactionController;

		private const NOT_MET_STRING:String = 'CodeString.ResearchInformation.AlreadyResearched'; //Already researched

		public function init( unknownTech:String ):void
		{
			_unknownTech = unknownTech;
		}

		public function get isMet():Boolean
		{
			if(_unknownTech != '')
			{
				var requiredBuildingClass:String = _prototypeModel.getResearchPrototypeByName(_unknownTech).getValue('requiredBuildingClass');
				return !_transactionController.isResearched(_unknownTech, requiredBuildingClass);
			}else
				return false;
		}

		public function get showIfMet():Boolean  { return false; }

		public function toString():String
		{
			return null;
		}

		public function toHtml():String
		{
			return Localization.instance.getString(NOT_MET_STRING);
		}

		override public function destroy():void
		{
			_prototypeModel = null;
			super.destroy();
		}
		
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		
		[Inject]
		public function set transactionController( v:TransactionController ):void { _transactionController = v; }
	}
}
