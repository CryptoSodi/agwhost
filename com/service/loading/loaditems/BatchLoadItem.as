package com.service.loading.loaditems
{


	public final class BatchLoadItem extends LoadItem
	{

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		public var category:String;
		public var entityType:String;

		private var _items:Vector.<ILoadItem>;
		private var _itemsComplete:int;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function BatchLoadItem( urls:Array, type:int, priority:int = 0, absolute:Boolean = false )
		{
			_items = new Vector.<ILoadItem>;
			_itemsComplete = 0;
			super(urls.join(',') + "Batch", type, priority, absolute);
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public function addLoadItem( loadItem:ILoadItem ):void
		{
			_items.push(loadItem);
			addLoadListeners(loadItem);
		}

		//do nothing
		public override function load():void
		{

		}

		////////////////////////////////////////////////////////////
		//   PRIVATE METHODS 
		////////////////////////////////////////////////////////////

		private function addLoadListeners( loadItem:ILoadItem ):void
		{
			loadItem.addUpdateListener(onUpdate);
		}

		private function removeLoadListeners( loadItem:ILoadItem ):void
		{
			loadItem.removeUpdateListener(onUpdate);
		}

		private function onUpdate( state:String, loadItem:ILoadItem ):void
		{
			switch (state)
			{
				case LoadItem.COMPLETE:
					removeLoadListeners(loadItem);
					_itemsComplete++;
					if (_itemsComplete == _items.length)
						_updateSignal.dispatch(LoadItem.COMPLETE, this);
					break;
			}
		}

		////////////////////////////////////////////////////////////
		//   GETTERS / SETTERS 
		////////////////////////////////////////////////////////////

		public function get items():Vector.<ILoadItem>  { return _items; }

		public override function get progress():Number
		{
			return _itemsComplete / _items.length;
		}
	}
}
