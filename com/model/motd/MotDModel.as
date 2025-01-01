package com.model.motd
{
	import com.model.Model;
	import com.service.server.incoming.data.MotdData;

	import org.osflash.signals.Signal;

	public class MotDModel extends Model
	{
		private var _messageCount:uint;
		private var _motd:Vector.<MotDVO>;

		public var newMessage:Signal;

		[PostConstruct]
		public function init():void
		{
			_motd = new Vector.<MotDVO>;
			newMessage = new Signal(Vector.<MotDVO>);

		}

		public function addMessages( v:Vector.<MotdData> ):void
		{
			var messageVO:MotDVO;
			for (var i:int; i < v.length; i++)
			{
				messageVO = new MotDVO(v[i].key, v[i].imageURL, v[i].isRead, v[i].title, v[i].subtitle, v[i].text, v[i].startTime);
				_motd.push(messageVO);
			}

			//			_motd.sort(orderItems);

			if (_motd && _motd.length > 0)
				newMessage.dispatch(_motd); //[0]);
		}

		private function orderItems( itemOne:MotDVO, itemTwo:MotDVO ):Number
		{

			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var dateSentOne:Number = itemOne.dateSent;
			var dateSent:Number    = itemTwo.dateSent;

			if (dateSentOne > dateSent)
				return -1;
			else if (dateSentOne < dateSent)
				return 1;

			return 0;
		}

		public function get hasMessage():Boolean  { return _motd && _motd.length > 0; }

		public function get motd():Vector.<MotDVO>  { return _motd; }
	}
}
