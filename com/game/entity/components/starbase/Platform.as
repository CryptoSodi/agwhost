package com.game.entity.components.starbase
{
	import com.model.starbase.BuildingVO;

	public class Platform
	{
		public var buildingVO:BuildingVO;

		public function init( vo:BuildingVO ):void
		{
			buildingVO = vo;
		}

		public function destroy():void
		{
			buildingVO = null;
		}
	}
}
