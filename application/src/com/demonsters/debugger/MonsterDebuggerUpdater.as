package com.demonsters.debugger
{
	import air.update.ApplicationUpdaterUI;
	import air.update.events.StatusFileUpdateErrorEvent;
	import air.update.events.StatusUpdateErrorEvent;
	import air.update.events.UpdateEvent;
	import flash.desktop.NativeApplication;
	import flash.events.ErrorEvent;
	import flash.events.Event;


	public class MonsterDebuggerUpdater
	{

		// Updater
		private static var _updater:ApplicationUpdaterUI;
		

		/**
		 * Check for an update
		 */
		public static function check():void
		{
			// The code below is a hack to work around a bug in the framework so that CMD-Q still works on Mac OSX
			// This is a temporary fix until the framework is updated (3.02)
			// See http://www.adobe.com/cfusion/webforums/forum/messageview.cfm?forumid=72&catid=670&threadid=1373568
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, function(event:Event):void {
				var windows:Array = NativeApplication.nativeApplication.openedWindows;
				for (var i:int = 0; i < windows.length; i++) {
					windows[i].close();
				}
			});
			
			_updater = new ApplicationUpdaterUI();
			_updater.updateURL = MonsterDebuggerConstants.PATH_UPDATE;
			_updater.isCheckForUpdateVisible = false;
			_updater.isDownloadUpdateVisible = true;
			_updater.isDownloadProgressVisible = true;
			_updater.isInstallUpdateVisible = true;
			
			_updater.addEventListener(UpdateEvent.INITIALIZED, onUpdate, false, 0, false);
			_updater.addEventListener(ErrorEvent.ERROR, onError, false, 0, false);
			_updater.addEventListener(StatusFileUpdateErrorEvent.FILE_UPDATE_ERROR, onError, false, 0, false);
			_updater.addEventListener(StatusUpdateErrorEvent.UPDATE_ERROR, onError, false, 0, false);
			_updater.addEventListener(ErrorEvent.ERROR, onError, false, 0, false);			
			_updater.initialize();
		}


		/**
		 * Error handlers
		 */
		private static function onError(event:Event):void {
			//
		}
		
		
		/**
		 * An update is found
		 */
		private static function onUpdate(event:UpdateEvent):void {
			_updater.checkNow();
		}
		
	}
}