package com.controller.command.account
{
	import com.freshplanet.ane.AirDeviceId;
	import com.hasoffers.nativeExtensions.MobileAppTracker;
	
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.robotlegs.extensions.presenter.impl.Command;
	
	/**
	 * Used in the mobile version of the game.
	 * Tracks app installs and updates with kabam.com 
	 */	
	public class MATCommand extends Command
	{
		private var _file:File;
		override public function execute():void
		{
			if (!AirDeviceId.getInstance().isOnDevice)
				return;
			
			MobileAppTracker.instance.init("885", "429151a2d9a0e1601b518a5cda19c750");
			
			//open the mat storage file
			_file = File.applicationStorageDirectory.resolvePath("mat.txt");
			if (!_file.exists)
				trackInstall();
			else
				trackUpdate();
		}
		
		private function trackInstall():void
		{
			//get the app version number and save it out into a file
			var fileStream:FileStream = new FileStream();
			fileStream.open(_file, FileMode.WRITE);
			fileStream.position = 0;
			fileStream.writeUTF(appVersionNumber);
			fileStream.close();
			
			MobileAppTracker.instance.trackInstall();
		}
		
		private function trackUpdate():void
		{
			//compare the version numbers. if they differ, track an update
			var fileStream:FileStream = new FileStream();
			fileStream.open(_file, FileMode.UPDATE);
			fileStream.position = 0;
			if (fileStream.readUTF() != appVersionNumber)
			{
				fileStream.position = 0;
				fileStream.writeUTF(appVersionNumber);
				MobileAppTracker.instance.trackUpdate();
			}
			fileStream.close();
		}
		
		private function get appVersionNumber():String
		{
			var appXML:XML =  NativeApplication.nativeApplication.applicationDescriptor;
			var ns:Namespace = appXML.namespace();
			return "v" + appXML.ns::versionNumber;
		}
	}
}