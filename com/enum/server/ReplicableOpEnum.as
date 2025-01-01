package com.enum.server
{
	public class ReplicableOpEnum
	{
		public static var EndDeltas:int = -128;
		public static var Copy:int = 127;
		public static var Modifychild:int = 100;
		public static var Insertdefault:int = 101; // operator[] on a map can cause this 
		public static var Set:int = 102;
		public static var Erase:int = 103;
		public static var Clear:int = 104;
		public static var Pushback:int = 105; // vector api
	}	
}