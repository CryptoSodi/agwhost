package {
	import DEBUGImpl;

	public var EXT_CONSOLE: Object = {
		log: function (...args) {
			if(CONFIG::EXTERNAL_CONSOLE){
			var stackTrace: String = new Error().getStackTrace();
			var stackTraceLines: Array = stackTrace.split("\n");
			var callerLine: String = stackTraceLines[2];
			var classNameMatchResult: Array = callerLine.match(/(?<=\[).+?(?=\])/);
			var info: String = "";
			try {
				var className: String  = classNameMatchResult[0];
				var i:int = className.lastIndexOf("\\") + 1;
				var l:int = className.length;
				info = className.substring(i, l);
			} catch (e) {
				info = "(Error Determining Stack Location} ";
			}

			if (info == "(Error Determining Stack Location} ") {
				var lineNumberMatchResult: Array = callerLine.match(/(?<=\:)\d+(?=\])/);
				var lineNumber: int = lineNumberMatchResult ? parseInt(lineNumberMatchResult[0]) : 0;
				info += lineNumber;
			}

			DEBUGImpl.send(args, info);
		}

		}

	};




}
