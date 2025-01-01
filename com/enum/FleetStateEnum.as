package com.enum
{
	public class FleetStateEnum
	{
		public static const DOCKED:int           = 0;

		public static const OUT:int              = 1;

		public static const DOCKING:int          = 2;

		public static const REPAIRING:int        = 4;

		public static const FORCED_RECALLING:int = 6; //needs to match number in SectorEntityStateEnum
		
		public static const SALVAGING:int        = 7;
		
		public static const DEFENDING:int        = 8;
	}
}
