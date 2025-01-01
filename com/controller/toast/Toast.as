package com.controller.toast
{
	import com.util.priorityqueue.IPrioritizable;

	import org.parade.core.IView;

	public class Toast implements IPrioritizable
	{
		private var _duration:Number;
		private var _limit:int;
		private var _priority:int;
		private var _sound:String;
		private var _state:String;
		private var _type:Object;
		private var _view:IView;

		public function init( type:Object, view:IView ):void
		{
			_duration = type.duration;
			_limit = type.limit;
			_priority = type.priority;
			_sound = type.sound;
			_state = type.state;
			_type = type;
			_view = view;
		}

		public function get duration():Number  { return _duration; }
		public function get limit():int  { return _limit; }
		public function get priority():int  { return _priority; }
		public function get sound():String  { return _sound; }
		public function get state():String  { return _state; }
		public function get type():Object  { return _type; }
		public function get view():IView  { return _view; }

		public function destroy():void
		{
			_type = null;
			_view = null;
		}
	}
}
