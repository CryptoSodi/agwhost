package com.controller.transaction.requirements
{
	import com.model.asset.AssetModel;
	import com.model.prototype.IPrototype;

	import org.shared.ObjectPool;

	public class RequirementVO
	{
		public var purchaseVO:PurchaseVO              = new PurchaseVO();
		public var requirements:Vector.<IRequirement> = new Vector.<IRequirement>();
		public var requiredFor:Vector.<IPrototype>    = new Vector.<IPrototype>();

		private var _assetModel:AssetModel;

		private const REQUIREMENTS_TEXT:String        = 'CodeString.Shared.Requirements';
		private const REQUIRED_FOR_TEXT:String        = 'CodeString.Shared.RequiredFor';

		public function RequirementVO( assetModel:AssetModel )
		{
			_assetModel = assetModel;
		}

		public function addRequirement( requirement:IRequirement ):void
		{
			if (requirement)
			{
				requirements.push(requirement);
			}
		}

		public function reset():void
		{
			purchaseVO.reset();
			//give the requirements to the objectpool
			for (var i:int = 0; i < requirements.length; i++)
			{
				ObjectPool.give(requirements[i]);
			}
			requirements.length = 0;
			if (requiredFor)
				requiredFor.length = 0;
		}

		public function requirementsToHtml( req:IRequirement ):String
		{
			var str:String = "";
			//			if (!allMet)
			//			{
			if (!req.isMet || req.showIfMet)
			{
				str += req.toHtml() + "<br>";
			}
			//			}

			return str;
		}

		private function isMetHelper( item:IRequirement, index:int, vector:Vector.<IRequirement> ):Boolean
		{
			return item.isMet;
		}

		public function get allMet():Boolean
		{
			return requirements.length == 0 || requirements.every(isMetHelper);
		}

		private function hasLinkHelper( item:IRequirement, index:int, vector:Vector.<IRequirement> ):Boolean
		{
			return item.hasLink;
		}

		public function get hasLinks():Boolean
		{
			return (requirements.length > 0 && requirements.some(hasLinkHelper)) ||
				(requiredFor.length > 0);
		}

		public function getRequirementOfType( klass:Class ):IRequirement
		{
			for each (var req:IRequirement in requirements)
			{
				if (req is klass)
				{
					return req;
				}
			}

			return null;
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
	}
}
