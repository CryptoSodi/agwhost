package com.model.mail
{
	import com.model.Model;
	import com.service.server.incoming.data.MailInboxData;

	import org.osflash.signals.Signal;
	
	import flash.utils.Dictionary;

	public class MailModel extends Model
	{
		private var _unreadCount:uint;
		private var _mailCount:uint;
		private var _mail:Vector.<MailVO>;
		private var _mailInvites:Dictionary;

		public var countUpdated:Signal;
		public var mailHeadersUpdated:Signal;
		public var mailDetailUpdated:Signal;

		[PostConstruct]
		public function init():void
		{
			_mail = new Vector.<MailVO>;
			_mailInvites = new Dictionary();
			countUpdated = new Signal(uint, uint, Boolean);
			mailHeadersUpdated = new Signal(Vector.<MailVO>);
			mailDetailUpdated = new Signal(MailVO);
		}

		public function updateCount( unread:uint, count:uint, serverUpdate:Boolean ):void
		{
			unreadCount = unread;
			mailCount = count;
			countUpdated.dispatch(unread, count, serverUpdate);
		}

		public function addMailHeaders( v:Vector.<MailInboxData> ):void
		{
			var oldMail:Vector.<MailVO> = _mail.concat();
			_mail = new Vector.<MailVO>;
			_mailInvites = new Dictionary();

			var len:uint                = v.length;
			var currentMail:MailVO;
			var currentMailData:MailInboxData;
			for (var i:uint = 0; i < len; ++i)
			{
				currentMailData = v[i];
				currentMail = getMailByKey(currentMailData.key, oldMail);

				if (currentMail)
					currentMail.updateMailData(currentMailData.sender, currentMailData.subject, currentMailData.isRead, currentMailData.timeSent);
				else if (currentMailData.key != '') //Tell Steve about this bug!
					currentMail = new MailVO(currentMailData.key, currentMailData.sender, currentMailData.subject, currentMailData.isRead, currentMailData.timeSent);

				if (currentMail)
				{
					_mail.push(currentMail);
					
					// Look for the alliance invitations in the mail subject
					// Match strings between Join and alliance
					var joinAllianceRegExp:RegExp = /Join.*?alliance/g;
					var mailSubjectJoinAllanceParts:Array = currentMail.subject.match(joinAllianceRegExp);
					
					var currentSubjectJoinAlliancePart:String;
					for (var j:uint = 0; j < mailSubjectJoinAllanceParts.length; ++j)
					{
						currentSubjectJoinAlliancePart = mailSubjectJoinAllanceParts[j];
						if(currentSubjectJoinAlliancePart.length > 0)
						{
							// Prepare extracted alliance key to match database key
							var allianceKey:String = currentSubjectJoinAlliancePart.replace("Join ", "");
							allianceKey = allianceKey.replace(" alliance", "");
							allianceKey = "alliance." + allianceKey;
							allianceKey = allianceKey.toLowerCase();
							allianceKey = allianceKey.replace(" ", "_");
							if (!(allianceKey in _mailInvites))
							{
								_mailInvites[allianceKey] = allianceKey;
							}
						}
					}
				}
			}
			oldMail.length = 0;
			mailHeadersUpdated.dispatch(_mail);
		}

		public function addMailDetail( key:String, sender:String, senderAlliance:String, body:String, senderRace:String, html:Boolean ):void
		{
			var mail:MailVO = getMailByKey(key, _mail);
			if (mail)
			{
				mail.addDetail(sender, senderAlliance, body, senderRace, html);
				mailDetailUpdated.dispatch(mail);
			}
		}

		public function getMailByKey( key:String, mailHolder:Vector.<MailVO> ):MailVO
		{
			var mail:MailVO;
			if (mailHolder)
			{
				var len:uint = mailHolder.length;
				var currentMail:MailVO;
				for (var i:uint = 0; i < len; ++i)
				{
					currentMail = mailHolder[i];
					if (currentMail.key == key)
					{
						mail = currentMail;
						break;
					}
				}

			}

			return mail;
		}

		private function deleteMailByKey( key:String ):void
		{
			if (_mail)
			{
				var len:uint = _mail.length;
				var currentMail:MailVO;
				for (var i:uint = 0; i < len; ++i)
				{
					currentMail = _mail[i];
					if (currentMail.key == key)
					{
						_mail.splice(i, 1);
						if (!currentMail.isRead)
						{
							if (_unreadCount != 0)
								_unreadCount -= 1;

							updateCount(_unreadCount, _mailCount, false);
						}
						currentMail = null;
						break;
					}
				}

			}
		}

		public function deleteMail( key:String ):void
		{
			deleteMailByKey(key);
		}

		public function mailRead( key:String ):void
		{
			var mail:MailVO = getMailByKey(key, _mail);
			if (mail && !mail.isRead)
			{
				mail.isRead = true;
				if (_unreadCount != 0)
					_unreadCount -= 1;

				updateCount(_unreadCount, _mailCount, false);
			}
		}

		public function set unreadCount( v:uint ):void  { _unreadCount = v; }

		public function get unreadCount():uint  { return _unreadCount; }

		public function set mailCount( v:uint ):void  { _mailCount = v; }

		public function get mailCount():uint  { return _mailCount; }

		public function get mail():Vector.<MailVO>  { return _mail; }
		
		public function getMailInvites():Dictionary  { return _mailInvites; }		
	}
}
