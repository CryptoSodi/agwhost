package com.service.loading
{

	import com.service.loading.loaditems.ILoadItem;
	import com.util.priorityqueue.ArrayPriorityQueue;
	import com.util.priorityqueue.IPriorityQueue;

	import flash.utils.Dictionary;

	internal final class LoadMap
	{
		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		private var _highPrioritiesInProgress:int = 0;
		private var _highPrioritiesInWaiting:int  = 0;
		private var _highPrioritiesTotal:int      = 0;
		private var _inProgressMap:Dictionary;
		private var _inWaitingMap:Dictionary;
		private var _loadsInProgress:int          = 0;
		private var _loadsWaiting:int             = 0;
		private var _queue:IPriorityQueue;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function LoadMap()
		{
			constructor();
		}

		private function constructor():void
		{
			_inProgressMap = new Dictionary(false);
			_inWaitingMap = new Dictionary(false);
			_queue = new ArrayPriorityQueue();
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public function add( loadItem:ILoadItem ):void
		{
			var url:String = loadItem.url;
			if (_inWaitingMap[url] != null || _inProgressMap[url] != null)
				return;
			if (loadItem.priority < LoadPriority.MEDIUM)
			{
				_highPrioritiesInWaiting++;
				_highPrioritiesTotal++;
			}
			_inWaitingMap[url] = loadItem;
			_queue.add(loadItem);
			_loadsWaiting++;
		}

		public function contains( loadItem:ILoadItem ):Boolean
		{
			if (_inProgressMap[loadItem.url] != null)
				return true;
			if (_inWaitingMap[loadItem.url] != null)
				return true;
			return false;
		}

		public function getNextLoadItem():ILoadItem
		{
			var next:ILoadItem = ILoadItem(_queue.getNext());
			if (next)
			{
				remove(next);
				if (_inProgressMap[next.url] == null)
				{
					_inProgressMap[next.url] = next;
					_loadsInProgress++;
					if (next.priority < LoadPriority.MEDIUM)
					{
						_highPrioritiesInProgress++;
						_highPrioritiesInWaiting--;
					}
				}
			}
			return next;
		}

		public function remove( loadItem:ILoadItem ):void
		{
			var url:String = loadItem.url;
			if (_inProgressMap[url] != null)
			{
				_loadsInProgress--;
				if (loadItem.priority < LoadPriority.MEDIUM)
				{
					_highPrioritiesInProgress--;
					_highPrioritiesTotal--;
				}
			}
			if (_inWaitingMap[url] != null)
			{
				_loadsWaiting--;
				_queue.remove(loadItem);
			}
			_inProgressMap[url] = null;
			delete _inProgressMap[url];
			_inWaitingMap[url] = null;
			delete _inWaitingMap[url];
		}

		////////////////////////////////////////////////////////////
		//   GETTERS / SETTERS 
		////////////////////////////////////////////////////////////

		public function get highPrioritiesInProgress():int  { return _highPrioritiesInProgress; }
		public function get highPrioritiesInWaiting():int  { return _highPrioritiesInWaiting; }
		public function get highPrioritiesTotal():int  { return _highPrioritiesTotal; }
		public function get loadsInProgress():int  { return _loadsInProgress; }
		public function get loadsWaiting():int  { return _loadsWaiting; }
	}
}

