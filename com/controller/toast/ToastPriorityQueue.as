package com.controller.toast
{
	import com.Application;
	import com.event.StateEvent;
	import com.util.priorityqueue.ArrayPriorityQueue;
	import com.util.priorityqueue.IPrioritizable;

	public class ToastPriorityQueue extends ArrayPriorityQueue
	{
		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function ToastPriorityQueue()
		{
			super();
		}

		override public function getNext():IPrioritizable
		{
			if (isEmpty)
			{
				return null;
			}

			var toast:Toast;
			for (var i:int = 0; i < _queue.length; i++)
			{
				toast = Toast(_queue[i]);
				if ((Application.STATE != StateEvent.GAME_BATTLE || toast.state == StateEvent.GAME_BATTLE) && (toast.state == null || toast.state == Application.STATE))
				{
					_queue.splice(i, 1);
					_map[toast] = null;
					delete _map[toast];
					return toast;
				}
			}

			return null;
		}
	}
}
