package com.controller.transaction.requirements
{
	import com.enum.StarbaseCategoryEnum;
	import com.enum.TypeEnum;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.prototype.PrototypeVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;

	import org.shared.ObjectPool;
	import org.swiftsuspenders.Injector;

	public class RequirementFactory implements IRequirementFactory
	{
		private var _injector:Injector;
		private var _prototypeModel:PrototypeModel;
		private var _starbaseModel:StarbaseModel;

		public function createRequirement( proto:IPrototype, klass:Class ):IRequirement
		{
			var result:IRequirement;
			if(proto == null)
				return result;
			
			var buildingClass:String;

			switch (klass)
			{
				case BuildingLevelRequirement:
					buildingClass = proto.getValue('requiredBuildingClass');
					if (buildingClass.length > 0)
					{
						var requiredBuildingLevel:int = proto.getValue('requiredBuildingLevel');
						result = ObjectPool.get(klass);
						BuildingLevelRequirement(result).init(buildingClass, requiredBuildingLevel);
					}
					break;

				case BuildingNotBusyRequirement:
					if (proto is PrototypeVO)
					{
						proto = _starbaseModel.getBuildingByClass(proto.getValue('requiredBuildingClass'));
					}

					result = ObjectPool.get(klass);
					BuildingNotBusyRequirement(result).init(BuildingVO(proto));
					break;

				case BuildingNotDamagedRequirement:
					if (proto is PrototypeVO)
					{
						proto = _starbaseModel.getBuildingByClass(proto.getValue('requiredBuildingClass'));
					}

					result = ObjectPool.get(klass);
					BuildingNotDamagedRequirement(result).init(BuildingVO(proto));
					break;

				case UnderMaxCountRequirement:
					buildingClass = proto.itemClass;
					if (buildingClass && buildingClass.length > 0)
					{
						//get the required building class
						var requiredBuilding:IPrototype  = _prototypeModel.getBuildingPrototype(proto.getValue('requiredBuilding'));
						var requiredBuildingClass:String = requiredBuilding ? requiredBuilding.itemClass : '';
						//if this is a starbase platform we need to set the requiredBuildingClass to the command center so the player knows what to upgrade
						if (proto.getUnsafeValue("category") == StarbaseCategoryEnum.STARBASE_STRUCTURE)
							requiredBuildingClass = TypeEnum.COMMAND_CENTER;
						var building:BuildingVO          = _starbaseModel.getBuildingByClass(requiredBuildingClass);
						if (building && building.level == 10)
							requiredBuildingClass = '';
						result = ObjectPool.get(klass);
						UnderMaxCountRequirement(result).init(proto, requiredBuildingClass);
					}
					break;

				case ResearchRequirement:
					var requiredResearch:String     = proto.getValue('requiredResearch');
					if (requiredResearch.length > 0)
					{
						result = ObjectPool.get(klass);
						ResearchRequirement(result).init(requiredResearch);
					}
					break;

				case BlueprintRequirement:
					var requiredBlueprint:String    = proto.getValue('requiredBlueprint');
					if (requiredBlueprint.length > 0)
					{
						result = ObjectPool.get(klass);
						BlueprintRequirement(result).init(requiredBlueprint);
					}
					break;

				case TechNotKnownRequirement:
					result = ObjectPool.get(klass);
					TechNotKnownRequirement(result).init(proto.name);
					break;

				case CategoryNotBuildingRequirement:
					var constructionCategory:String = proto.getUnsafeValue('constructionCategory');
					if (constructionCategory != null && constructionCategory.length > 0)
					{
						result = ObjectPool.get(klass);
						CategoryNotBuildingRequirement(result).init(constructionCategory);
					}
					break;
			}

			if (result)
			{
				_injector.injectInto(result);
			}

			return result;
		}

		[Inject]
		public function set injector( v:Injector ):void  { _injector = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
	}
}
