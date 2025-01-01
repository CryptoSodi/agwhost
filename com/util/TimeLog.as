package com.util
{
	import com.controller.ServerController;
	import com.enum.TimeLogEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.proxy.ProxyReportLoginDataRequest;

	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	public class TimeLog
	{
		private static var _enabled:Boolean     = true;
		private static var _log:String          = "";
		private static var _serverController:ServerController;
		private static var _startLog:Dictionary = new Dictionary();
		private static var _timeData:Object;

		public static function startTimeLog( id:String, message:String = null ):void
		{
			if (!_enabled)
				return;
			if (id == TimeLogEnum.FILE_LOAD)
				id += message;
			_startLog[id] = {message:message, time:getTimer()};
		}

		public static function endTimeLog( id:String, message:String = null ):void
		{
			if (!_enabled)
				return;
			var idr:String = id;
			if (idr == TimeLogEnum.FILE_LOAD)
				idr += message;
			_timeData = _startLog[idr];
			if (_timeData)
			{
				addLog("[" + id + "] " +
					   "START" + (_timeData.message != null ? "(" + _timeData.message + ")" : "") + ":" + _timeData.time +
					   " -- END" + (message != null && id != TimeLogEnum.FILE_LOAD ? "(" + message + ")" : "") + ":" + getTimer() +
					   " -- TOTAL:" + (getTimer() - _timeData.time));
			} else
			{
				addLog("[" + id + "] " +
					   "START:0" +
					   " -- END" + (message != null ? "(" + message + ")" : "") + ":" + getTimer() +
					   " -- TOTAL:" + getTimer());
			}
		}

		public static function addLog( message:String ):void
		{
			if (!_enabled)
				return;
			_log += message + ";";
			//trace(_log);
		}

		public static function set enabled( v:Boolean ):void
		{
			if (v)
				_enabled = true;
			else if (_enabled && _serverController)
			{
				//send the logs to the server
				var request:ProxyReportLoginDataRequest = ProxyReportLoginDataRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_REPORT_LOGIN_DATA));
				request.dataStr = _log;
				_serverController.send(request);

				_enabled = false;
				_log = null;
				_serverController = null;
				_startLog = null;
				_timeData = null;
			}
		}

		public static function set serverController( v:ServerController ):void  { _serverController = v; }
	}
}
