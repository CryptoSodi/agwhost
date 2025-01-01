package com.service.loading
{
	/**
	 * Supports:
	 *
	 *		http://localhost/path/file.php
	 * 		localhost/path/file.php?query=String&param=val
	 * 		file:///some/path/file.php
	 */
	public final class URL
	{

		////////////////////////////////////////////////////////////
		//   CONSTANTS 
		////////////////////////////////////////////////////////////

		public static const FILE_PROTOCOL:String = "file";

		public static const HTTP_PROTOCOL:String = "http";

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		public var prefix:String                 = '';

		private var _url:String                  = "";

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function URL( url:String )
		{
			_url = url;
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public function toString():String
		{
			return prefix + _url;
		}

		////////////////////////////////////////////////////////////
		//   GETTERS / SETTERS 
		////////////////////////////////////////////////////////////

		// rename: fullPath?
		public function get baseUrl():String
		{
			var end:int = _url.indexOf("?");

			if (end == -1)
			{
				end = _url.length;
			}

			return _url.substring(0, end);
		}

		public function get domain():String
		{
			//TODO: URL.domain
			return "";
		}

		public function get filename():String
		{
			var start:int = _url.lastIndexOf("/") + 1;
			var end:int   = _url.indexOf("?");

			if (end == -1)
			{
				end = _url.length;
			}

			return _url.substring(start, end);
		}

		public function get parameters():Object
		{
			var params:Object = new Object();
			var qs:String     = queryString;

			if (qs == "")
			{
				return params;
			}

			var pairs:Array   = qs.split("&");

			for each (var pair:String in pairs)
			{
				var keyVal:Array = pair.split("=");
				var key:String   = keyVal[0];
				var val:String   = keyVal[1];
				params[key] = val;
			}

			return params;
		}

		public function get path():String
		{
			var endOfProtocol:int = _url.lastIndexOf("//") + 2;
			var startOfPath:int   = _url.indexOf("/", endOfProtocol);
			var endOfPath:int     = _url.lastIndexOf("/") + 1;

			return _url.substring(startOfPath, endOfPath);
		}

		public function get port():int
		{
			var endOfProtocol:int = _url.lastIndexOf("//") + 2;
			var startOfPort:int   = _url.indexOf(":", endOfProtocol) + 1;

			if (startOfPort == 0)
			{
				return 80;
			}

			var endOfPort:int     = _url.indexOf("/", startOfPort);
			return int(_url.substring(startOfPort, endOfPort));
		}

		public function get protocol():String
		{
			var index:int = _url.indexOf("//");

			if (index == -1)
			{
				return HTTP_PROTOCOL;
			}

			return _url.substring(0, index - 1);
		}

		public function get queryString():String
		{
			var start:int = _url.indexOf("?") + 1;

			if (start == 0)
			{
				start = _url.length;
			}

			return _url.substring(start);
		}

		public function get server():String
		{
			var endOfProtocol:int = _url.lastIndexOf("//");

			if (endOfProtocol == -1)
			{
				endOfProtocol = 0;
			} else
			{
				endOfProtocol += "//".length;
			}

			var startOfPath:int   = _url.indexOf("/", endOfProtocol);
			var startOfPort:int   = _url.indexOf(":", endOfProtocol);

			if (startOfPath == -1)
			{
				startOfPath = _url.length;
			}

			if (startOfPort == -1)
			{
				startOfPort = _url.length;
			}

			var endOfServer:int   = Math.min(startOfPath, startOfPort);

			return _url.substring(endOfProtocol, endOfServer);
		}
	}
}
