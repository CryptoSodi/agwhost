package {

	import flash.net.Socket;
	import flash.utils.Endian;
	import flash.utils.ByteArray;
	import flash.events.Event;
	import flash.net.ObjectEncoding;

	public class DEBUGImpl {

		private static var _socket: Socket = _initialize();

		private static function _initialize(): Socket {
			try{
			_socket = new Socket();
			_socket.endian = Endian.LITTLE_ENDIAN;
			_socket.connect("127.0.0.1", 17357);
			return _socket;
				} catch(e){
					throw(e);
				}
				return null;
		}

		public static function send(args:Array, info:String): void {
			
			var msg: Object = new Object();
			msg.type = "trace";
			msg.data = args;
			msg.info = info;
			

			var bytes: ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeObject(msg);
			bytes.position = 0;

			_socket.writeUnsignedInt(bytes.length);
			_socket.writeBytes(bytes);
			_socket.flush();
		}

	}

}