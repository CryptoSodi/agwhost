package com.model.mail
{
	public class MailVO
	{
		private var _key:String;
		private var _sender:String;
		private var _senderKey:String;
		private var _senderAlliance:String;
		private var _subject:String;
		private var _body:String;
		private var _sendersRace:String;
		private var _isRead:Boolean;
		private var _showHtml:Boolean;
		private var _timeSent:Number;

		public function MailVO( key:String, sender:String, subject:String, isRead:Boolean, timeSent:Number )
		{
			_key = key;
			_sender = sender;
			_subject = subject;
			_isRead = isRead;
			_timeSent = timeSent;

		}

		public function updateMailData( sender:String, subject:String, isRead:Boolean, timeSent:Number ):void
		{
			_sender = sender;
			_subject = subject;
			_isRead = isRead;
			_timeSent = timeSent;
		}

		public function addDetail( senderKey:String, senderAlliance:String, body:String, senderRace:String, html:Boolean ):void
		{
			_senderKey = senderKey;
			_senderAlliance = senderAlliance;
			_body = body;
			_sendersRace = senderRace;
			_showHtml = html;
		}

		public function get key():String  { return _key; }
		public function get senderKey():String  { return _senderKey; }
		public function get allianceKey():String  { return _senderAlliance; }
		public function get sender():String  { return _sender; }
		public function get subject():String  { return _subject; }
		public function get body():String  { return _body; }
		public function get sendersRace():String  { return _sendersRace; }
		public function get isRead():Boolean  { return _isRead; }
		public function set isRead( v:Boolean ):void  { _isRead = v; }
		public function get showHtml():Boolean  { return _showHtml; }
		public function get timeSent():Number  { return _timeSent; }
	}
}
