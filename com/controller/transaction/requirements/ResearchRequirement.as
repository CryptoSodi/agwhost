package com.controller.transaction.requirements
{
	import com.controller.transaction.TransactionController;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.ResearchVO;
	import com.model.transaction.TransactionVO;
	import com.service.language.Localization;

	public class ResearchRequirement extends RequirementBase implements IRequirement
	{
		private var _assetModel:AssetModel;
		private var _prototypeModel:PrototypeModel;
		private var _transactionController:TransactionController;
		private var _requiredTech:String;

		private const NOT_MET_STRING:String = 'CodeString.ResearchInformation.ResearchRequired'; //Research [[String.RequiredTech]]

		public function init( requiredTech:String ):void
		{
			_requiredTech = requiredTech;
		}

		public function get isMet():Boolean
		{
			if (_requiredTech == 'NPC')
				return false;

			if (_starbaseModel.currentBase.reqsDisabled)
				return true;

			if (_requiredTech != '')
			{
				var requiredBuildingClass:String = _prototypeModel.getResearchPrototypeByName(_requiredTech).getValue('requiredBuildingClass');
				return _transactionController.isResearched(_requiredTech, requiredBuildingClass);
			} else
				return false;


		}

		public function toHtml():String
		{
			var loc:Localization = Localization.instance;
			var assetVO:AssetVO  = _assetModel.getEntityData(_prototypeModel.getResearchPrototypeByName(_requiredTech).uiAsset);
			var tokens:Object    = {'[[String.RequiredTech]]':'<a href="event:' + _requiredTech + '">' + loc.getString(assetVO.visibleName).toUpperCase() + '</a>'};
			return /*"<li>" + */ loc.getStringWithTokens(NOT_MET_STRING, tokens) /* + "</li>"*/;
		}

		public function get showIfMet():Boolean  { return true; }

		public override function get hasLink():Boolean  { return true; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }

		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }

		override public function destroy():void
		{
			super.destroy();
			_assetModel = null;
			_prototypeModel = null;
		}
	}
}
