package com.enum.server
{
	public class StarbaseTransactionStateEnum
	{	
		public static const PENDING:int = -1;
		
		public static const UNKNOWN:int = 0;

		public static const FAILED:int    = 1;

		public static const SAVING:int  = 2;
		
		public static const SAVED:int  = 3;
		
		public static const TIMER_RUNNING:int  = 4;
		
		public static const TIMER_DONE:int  = 5;
		
		public static const CANCELLED:int  = 6;
	}
}
