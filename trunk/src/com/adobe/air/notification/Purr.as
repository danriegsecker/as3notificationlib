package com.adobe.air.notification
{
	import flash.display.DockIcon;
	import flash.display.InteractiveIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.display.SystemTrayIcon;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.system.Shell;
	
	public class Purr
	{
		private var topLeftQ:NotificationQueue;
		private var topRightQ:NotificationQueue;
		private var bottomLeftQ:NotificationQueue;
		private var bottomRightQ:NotificationQueue;
		private var paused:Boolean;

		public function Purr(idleThreshold:uint)
		{
			topLeftQ = new NotificationQueue();
			topRightQ = new NotificationQueue();
			bottomLeftQ = new NotificationQueue();
			bottomRightQ = new NotificationQueue();

			paused = false;

			Shell.shell.idleThreshold = idleThreshold * 60;
			Shell.shell.addEventListener(Event.USER_IDLE, function(e:Event):void {pause();});
			Shell.shell.addEventListener(Event.USER_PRESENT, function(e:Event):void {resume();});
		}

		public function alert(alertType:String, nativeWindow:NativeWindow):void
		{
			if (Shell.supportsDockIcon)
			{
				DockIcon(Shell.shell.icon).bounce(alertType);
			}
			else if (Shell.supportsSystemTrayIcon)
			{
				if (nativeWindow != null)
				{
					nativeWindow.notifyUser(alertType);
				}
			}
		}

		public function addNotification(n:Notification):void
		{
			switch (n.position)
            {
                case Notification.TOP_LEFT:
                    topLeftQ.addNotification(n);
                    break;
                case Notification.TOP_RIGHT:
                    topRightQ.addNotification(n);
                    break;
                case Notification.BOTTOM_LEFT:
                    bottomLeftQ.addNotification(n);
                    break;
                case Notification.BOTTOM_RIGHT:
                    bottomRightQ.addNotification(n);
                    break;
            }			
		}

		public function addNotificationByParams(title:String, message:String, position:String = null, duration:uint = 5, bitmap:Bitmap = null):Notification
		{
			var n:Notification = new Notification(title, message, position, duration, bitmap);
			addNotification(n);
            return n;
		}

		public function setMenu(menu:NativeMenu): void
		{
			if (Shell.supportsDockIcon)
			{
				DockIcon(Shell.shell.icon).menu = menu;
			}
			else if (Shell.supportsSystemTrayIcon)
			{
				SystemTrayIcon(Shell.shell.icon).menu = menu;
			}
		}

		public function getMenu():NativeMenu
		{
			if (Shell.supportsDockIcon)
			{
				return DockIcon(Shell.shell.icon).menu;
			}
			else if (Shell.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(Shell.shell.icon).menu;
			}
			return null;
		}

		public function setIcons(icons:Array, tooltip:String = null):void
		{
			if (Shell.shell.icon is InteractiveIcon)
			{
				InteractiveIcon(Shell.shell.icon).bitmaps = icons;
			}
			if (Shell.supportsSystemTrayIcon)
			{
				SystemTrayIcon(Shell.shell.icon).tooltip = tooltip;
			}
		}

		public function getIcons():Array
		{
			if (Shell.shell.icon is InteractiveIcon)
			{
				return InteractiveIcon(Shell.shell.icon).bitmaps;
			}
			return null;
		}

		public function getToolTip():String
		{
			if (Shell.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(Shell.shell.icon).tooltip;
			}
			return null;
		}

		public function pause():void
		{
			this.topLeftQ.pause();
			this.topRightQ.pause();
			this.bottomLeftQ.pause();
			this.bottomRightQ.pause();
			this.paused = true;
		}

		public function resume():void
		{
			this.topLeftQ.resume();
			this.topRightQ.resume();
			this.bottomLeftQ.resume();
			this.bottomRightQ.resume();
			this.paused = false;
		}

		public function isPaused():Boolean
		{
			return this.paused;
		}
	}
}