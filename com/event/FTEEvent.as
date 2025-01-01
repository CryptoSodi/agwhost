package com.event
{
	import com.controller.fte.FTEStepVO;

	import flash.events.Event;

	public class FTEEvent extends Event
	{
		public static const FTE_COMPLETE:String = "FTEComplete";
		public static const FTE_STEP:String     = "FTEStep";

		public var step:FTEStepVO;

		public function FTEEvent( type:String, step:FTEStepVO )
		{
			super(type, false, false);
			this.step = step;
		}
	}
}
