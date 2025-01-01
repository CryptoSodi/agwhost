package {
	import com.Application;
	import com.StartupConfig;
	import com.enum.TimeLogEnum;
	import com.service.ExternalInterfaceAPI;
	import com.util.TimeLog;
	import com.util.FileHelper;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;
	import flash.filesystem.File;
	
	import org.robotlegs.bundles.mvcs.MVCSBundle;
	import org.robotlegs.framework.api.IContext;
	import org.robotlegs.framework.impl.Context;

	[SWF(frameRate = CONFIG::FRAMERATE, backgroundColor = CONFIG::BG_COLOR)]
	public final
	class Imperium extends Sprite {
		protected var _ncontext: IContext;

		public static var NativeApplicationTypeDef: Object;
		public static var InvokeEventTypeDef: Object;
		public static var authToken: String;
		public static var language: String;
		public static var country: String;
		public static var entryTag: String;

		public function Imperium() {

			if (CONFIG::IS_DESKTOP) {

				NativeApplicationTypeDef = getDefinitionByName("flash.desktop.NativeApplication");
				InvokeEventTypeDef = getDefinitionByName("flash.events.InvokeEvent");
				NativeApplicationTypeDef.nativeApplication.addEventListener(InvokeEventTypeDef.INVOKE, onInvoke);
			} else {
				ExternalInterfaceAPI.logConsole("Imperium Starts");
				Application.ROOT = this;
				try {
					Security.allowDomain("*");
					Security.allowInsecureDomain("*");
				} catch (e) {
					//This is the desktop client
				}

				TimeLog.endTimeLog(TimeLogEnum.GAME_INITIALIZED);
				TimeLog.startTimeLog(TimeLogEnum.GAME_LOAD);
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}


		}

		private function onInvoke(e): void {
			if (CONFIG::USE_DEBUG_CONNECTON) {
				var debugConnectionConfig: Object = FileHelper.loadObject(File.applicationDirectory.resolvePath("debug-connection.json").nativePath);
				authToken = debugConnectionConfig.token;
				language = "en";
			} else {
				var args: Array = e.arguments;
				var obj: Object = new Object();

				try {
					for (var i: int = 0; i < args.length; i++) {
						var arg: String = args[i];
						if (arg.indexOf("--") == 0) {
							obj[arg] = args[i + 1];
						}
					}

					authToken = obj["--xsolla-login-token"];
					language = obj["--xsolla-locale"];


				} catch (e) {
					//something failed here, let the clients error handling system take care of it when the token fails.

				}
			}

			ExternalInterfaceAPI.logConsole("Imperium Starts");
			Application.ROOT = this;

			TimeLog.endTimeLog(TimeLogEnum.GAME_INITIALIZED);
			TimeLog.startTimeLog(TimeLogEnum.GAME_LOAD);
			if (this.stage == null) this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			else onAddedToStage(null);
		}

		private function onAddedToStage(e: Event): void {
			// Set it so that the stage resizes properly.
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = CONFIG::FRAMERATE;
			stage.showDefaultContextMenu = false;
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);

			_ncontext = new Context()
				.extend(MVCSBundle)
				.configure(StartupConfig, this);
		}

		private function onRightClick(e: MouseEvent): void {
			//do nothing, just listening to the event prevents
			//a right mouse click from opening the context menu
		}
	}
}