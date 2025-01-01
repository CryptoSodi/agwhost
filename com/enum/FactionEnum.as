package com.enum
{
	public class FactionEnum
	{
		public static const ALL:String         = "ALL";

		public static const IGA:String         = "IGA";

		public static const IMPERIUM:String    = "Imperium";

		public static const SOVEREIGNTY:String = "Sovereignty";

		public static const TYRANNAR:String    = "Tyrannar";
		
		public static function getFactionShort(faction:String)
		{
			if(faction == IGA)
				return "IGA";
			else if(faction == TYRANNAR)
				return "TYR";
			else if(faction == SOVEREIGNTY)
				return "SOV";
			else if(faction == IMPERIUM)
				return "IMP";
			else
				return "NON";
		}

	}
}
