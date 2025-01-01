package com.model.motd
{
	public class MotDVO
	{
		private var _key:String;
		private var _imageURL:String;
		private var _isRead:Boolean
		private var _title:String;
		private var _subtitle:String;
		private var _message:String;
		private var _dateSent:Number;
		
		public function MotDVO(key:String, imageURL:String, isRead:Boolean, title:String, subtitle:String, message:String, dateSent:Number)
		{
			_key		= key;
			_imageURL	= imageURL;
			_isRead		= isRead;
			_title		= title;
			_subtitle	= subtitle
			_message	= message
			_dateSent	= dateSent;
		}

		public function get key():String { return _key; }
		public function get imageURL():String {	return _imageURL; }
		public function get isRead():Boolean { return _isRead; }
		public function get title():String { return _title;	}
		public function get subtitle():String{ return _subtitle; }
		public function get message():String { return _message; }
		public function get dateSent():Number { return _dateSent; }

		public function set isRead(value:Boolean):void { _isRead = value; }

		

	}
}