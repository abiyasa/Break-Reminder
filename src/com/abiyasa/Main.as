package com.abiyasa
{
	import flash.desktop.SystemTrayIcon;
	import flash.display.Loader;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import mx.core.BitmapAsset;
	
	/**
	 * Create a tray application and stays there
	 * 
	 * @author Abiyasa
	 */
	public class Main extends Sprite 
	{
		[Embed(source = "/../asset/alarm_24.png")]
		protected var ICON_ALARM1:Class;
		
		/** the main Timer */
		protected var _timer:Timer;
		
		
		public function Main():void 
		{
			NativeApplication.nativeApplication.autoExit = false;
			
			// create menu
			var iconMenu:NativeMenu = new NativeMenu();
			var exitCommand:NativeMenuItem = new NativeMenuItem("Exit");
			exitCommand.addEventListener(Event.SELECT, exitApplication, false, 0, true);
			var showPopupCommand:NativeMenuItem = new NativeMenuItem("Show Reminder");
			showPopupCommand.addEventListener(Event.SELECT, showPopup, false, 0, true);
			
			iconMenu.addItem(showPopupCommand);
			iconMenu.addItem(new NativeMenuItem("", true));
			iconMenu.addItem(exitCommand);			
			
			// create tray icon
			if (NativeApplication.supportsSystemTrayIcon)
			{
				var theIconBitmap:BitmapAsset = new ICON_ALARM1();
				NativeApplication.nativeApplication.icon.bitmaps = [ theIconBitmap.bitmapData ];
				var sysTray:SystemTrayIcon = NativeApplication.nativeApplication.icon as SystemTrayIcon;
				sysTray.tooltip = "Take A Break Reminder";
				sysTray.menu = iconMenu;
			}
			
			initTimer();
			//showPopup();
		}
		
		/**
		 * exit application
		 * 
		 * @param	event
		 */
		protected function exitApplication(event:Event):void
		{
			destroyTimer();
			
			NativeApplication.nativeApplication.icon.bitmaps = [];
			NativeApplication.nativeApplication.exit();
		}
		
		/**
		 * Init/reset the timer
		 * 
		 * @param	event
		 */
		protected function initTimer(event:Event = null):void
		{
			if (_timer != null)
			{
				destroyTimer();
			}
			
			// get remaining minutes to the next hour
			var currentDate:Date = new Date();
			var remainingMinutes:Number = 60 - currentDate.minutes;
			var remainingMinutesMilliSecs:Number = (remainingMinutes * 60 * 1000) + 30000;  // add 30s to prevent timer shows at minute 59th
			
			// adjust the timer tick based on current time!						
			_timer = new Timer(remainingMinutesMilliSecs, 1);			
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerEvent, false, 0, true);
			_timer.start();
		}
		
		/**
		 * Remove the timer
		 * @param	event
		 */
		protected function destroyTimer(event:Event = null):void
		{
			if (_timer != null)
			{
				_timer.stop();
				_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerEvent);
				
				_timer = null;
			}
			
		}
		
		/**
		 * The timer event
		 * @param	event
		 */
		protected function timerEvent(event:TimerEvent):void
		{
			showPopup();
			
			// prepare for the next timer
			initTimer();
		}
		
		/** timer popup */
		private var _timerPopup:ReminderPopup;
		
		
		/**
		 * Show something
		 */
		protected function showPopup(event:Event = null):void
		{
			// create popup
			if (_timerPopup == null)
			{
				_timerPopup = new ReminderPopup();				
				_timerPopup.addEventListener(Event.CLOSE, popupClosed, false, 0, true);				
			}
			
			// show/update it on main screen
			_timerPopup.showToScreen(Screen.mainScreen);
		}
		
		/**
		 * Close and destroy the popup
		 * @param	event
		 */
		protected function popupClosed(event:Event = null):void
		{			
			if (_timerPopup != null)
			{
				_timerPopup.removeEventListener(Event.CLOSE, popupClosed);
				_timerPopup = null;
			}
		}
	}
	
}