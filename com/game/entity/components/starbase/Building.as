package com.game.entity.components.starbase
{
	import com.model.starbase.BuildingVO;

	public class Building
	{
		public var buildingVO:BuildingVO;
		public var faction:String;

		public function init( vo:BuildingVO ):void
		{
			buildingVO = vo;
			faction = '';
		}

		public function destroy():void
		{
			buildingVO = null;
		}
	}
}
