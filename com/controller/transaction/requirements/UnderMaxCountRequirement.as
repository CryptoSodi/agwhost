package com.controller.transaction.requirements
{
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;

	public class UnderMaxCountRequirement extends BuildingRequirementBase implements IRequirement
	{
		private const NOT_MET_UPGRADE_STRING:String = 'CodeString.BuildInformation.UpgradeRequired';
		private const NOT_MET_STRING:String         = 'CodeString.BuildInformation.BuildRequired';

		private var _prototype:IPrototype;
		private var _requiredBuilding:String;

		public function init( prototype:IPrototype, requiredBuilding:String ):void
		{
			_prototype = prototype;
			_requiredBuilding = requiredBuilding;
		}

		public function get isMet():Boolean
		{
			var cnt:int = count;
			switch (_prototype.getValue("category"))
			{
				case StarbaseCategoryEnum.STARBASE_STRUCTURE:
					cnt += (_prototype.getValue("sizeX") / 5) * (_prototype.getValue("sizeY") / 5);
					break;
				default:
					cnt += 1;
					break;
			}
			return cnt <= maxCount;
		}

		public function toString():String
		{
			if (_requiredBuilding == '' || _requiredBuilding == null)
			{
				return "Maximum count reached"; //TODO localize
			}

			var tokens:Object = {'[[String.BuildingName]]':'<a href="event:' + _requiredBuilding + '">' + Localization.instance.getString('CodeString.Building.' + _requiredBuilding).toUpperCase() +
						'</a>'};
			if (maxCount == 0)
				return Localization.instance.getStringWithTokens(NOT_MET_STRING, tokens); //need to build;
			return Localization.instance.getStringWithTokens(NOT_MET_UPGRADE_STRING, tokens); //need to upgrade;
		}

		public function get showIfMet():Boolean  { return false; }

		public override function get hasLink():Boolean  { return true; }

		public function toHtml():String
		{
			return /*"<li>" + */ toString() /* + "</li>"*/;
		}

		public function get count():int  { return _starbaseModel.currentBase.getBuildingCount(_prototype.itemClass); }
		public function get maxCount():int  { return _starbaseModel.currentBase.getBuildingMaxCount(_prototype.itemClass); }

		override public function destroy():void
		{
			super.destroy();
			_prototype = null;
		}
	}
}
