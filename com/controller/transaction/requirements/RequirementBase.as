package com.controller.transaction.requirements
{
	import com.model.starbase.StarbaseModel;

	public class RequirementBase
	{
		protected var _starbaseModel:StarbaseModel;

		public function get hasLink():Boolean  { return false; }

		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }

		public function destroy():void
		{
			_starbaseModel = null;
		}
	}
}
