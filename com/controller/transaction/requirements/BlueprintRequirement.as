package com.controller.transaction.requirements
{
	import com.model.blueprint.BlueprintModel;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;

	public class BlueprintRequirement extends RequirementBase implements IRequirement
	{
		private var _blueprintModel:BlueprintModel;
		private var _prototypeModel:PrototypeModel;
		private var _requiredBlueprint:String;

		public function init( requiredBlueprint:String ):void
		{
			_requiredBlueprint = requiredBlueprint;
		}

		public function get isMet():Boolean
		{
			var blueprint:BlueprintVO = _blueprintModel.getBlueprintByName(_requiredBlueprint);
			var prototypeVO:IPrototype;
			if (!blueprint)
			{
				prototypeVO = _prototypeModel.getBlueprintPrototype(_requiredBlueprint);
				if (prototypeVO)
					return false;
			}
			if (_starbaseModel.currentBase.reqsDisabled)
				return true;
			return blueprint && blueprint.partsCompleted >= blueprint.totalParts;
		}

		public function toHtml():String
		{
			var blueprint:BlueprintVO = _blueprintModel.getBlueprintByName(_requiredBlueprint);
			if(blueprint == null)
				return "MISSING DATA";
			
			if (blueprint.partsCollected >= blueprint.totalParts)
				return "All PARTS COLLECTED";
			return "NEED " + (blueprint.totalParts - blueprint.partsCollected) + " of " + blueprint.totalParts + " PARTS";
		}

		public function get showIfMet():Boolean  { return true; }

		public override function get hasLink():Boolean  { return true; }

		[Inject]
		public function set blueprintModel( v:BlueprintModel ):void  { _blueprintModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_blueprintModel = null;
			_prototypeModel = null;
		}
	}
}
