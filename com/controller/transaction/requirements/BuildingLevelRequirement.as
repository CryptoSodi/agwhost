package com.controller.transaction.requirements
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.BuildingVO;
	import com.service.language.Localization;

	public class BuildingLevelRequirement extends BuildingRequirementBase implements IRequirement
	{
		private var _prototypeModel:PrototypeModel;
		private var _requiredLevel:int;

		private const NOT_MET_STRING:String = "CodeString.BuildUpgrade.BuildingLevel"; //[[String.BuildingName]] Level [[Number.BuildingLevel]]

		public function init( requiredBuildingClass:String, requiredLevel:int ):void
		{
			_buildingClass = requiredBuildingClass;
			_requiredLevel = requiredLevel;
		}

		private function assessBuilding( item:BuildingVO, index:int, vector:Vector.<BuildingVO> ):Boolean
		{
			return (item.itemClass == _buildingClass) && (item.level >= _requiredLevel);
		}

		public function get isMet():Boolean
		{
			if (_starbaseModel.currentBase.reqsDisabled)
				return true;
			return _starbaseModel.getBuildingsByBaseID().some(assessBuilding);
		}

		public function toString():String
		{
			if (_requiredLevel == 0)
				_requiredLevel = 1;

			var buildingProto:IPrototype = _prototypeModel.getBuildingPrototypeByClassAndLevel(_buildingClass, _requiredLevel);
			var tokens:Object            = {'[[String.BuildingName]]':'<a href="event:' + buildingProto.name + '">' + locBuildingClass.toUpperCase() + '</a>', '[[Number.BuildingLevel]]':_requiredLevel};
			return Localization.instance.getStringWithTokens(NOT_MET_STRING, tokens);
		}

		public function toHtml():String
		{
			return toString();
		}

		public function get showIfMet():Boolean  { return true; }

		public override function get hasLink():Boolean  { return true; }

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_prototypeModel = null;
		}
	}
}
