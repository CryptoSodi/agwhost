package com.controller.transaction.requirements
{
	import com.controller.transaction.TransactionController;
	import com.service.language.Localization;

	public class CategoryNotBuildingRequirement extends RequirementBase implements IRequirement
	{
		private var _constructionCategory:String;
		private var _transactionController:TransactionController;

		private var BUILD_IN_PROGRESS:String = 'CodeString.BuildInformation.BuildInProgress'; //Current build must be finished

		public function init( constructionCategory:String ):void
		{
			_constructionCategory = constructionCategory;
		}

		public function get isMet():Boolean
		{
			return _transactionController.getStarbaseBuildingTransaction(_constructionCategory) == null;
		}

		public function get showIfMet():Boolean  { return false; }

		public function toString():String
		{
			return Localization.instance.getString(BUILD_IN_PROGRESS);
		}

		public function toHtml():String
		{
			return toString().toUpperCase();
		}

		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		override public function destroy():void
		{
			super.destroy();
			_transactionController = null;
		}
	}
}

