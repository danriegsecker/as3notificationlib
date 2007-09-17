package com.adobe.air.notification
{
	import flash.display.DockIcon;
	import flash.display.InteractiveIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.display.SystemTrayIcon;
	import flash.events.Event;
	import flash.system.Shell;
	
	public class Purr
	{
		private var topLeftQ: NotificationQueue;
		private var topRightQ: NotificationQueue;
		private var bottomLeftQ: NotificationQueue;
		private var bottomRightQ: NotificationQueue;

		public function Purr(idleThreshold: uint)
		{
			topLeftQ = new NotificationQueue();
			topRightQ = new NotificationQueue();
			bottomLeftQ = new NotificationQueue();
			bottomRightQ = new NotificationQueue();

			Shell.shell.idleThreshold = idleThreshold * 60;
			Shell.shell.addEventListener(Event.USER_IDLE, onIdle);
			Shell.shell.addEventListener(Event.USER_PRESENT, onPresent);
		}

		public function alert(alertType: String, nativeWindow: NativeWindow): void
		{
			if (Shell.supportsDockIcon)
			{
				DockIcon(Shell.shell.icon).bounce(alertType);
			}
			else if (Shell.supportsSystemTrayIcon)
			{
				if (nativeWindow != null)
					nativeWindow.notifyUser(alertType);
			}
		}

		public function addNotification(title: String, message: String, position: String = null, duration: uint = 5, icoURL: String = null): Notification
		{
            var result: Notification = null;
        	if (position == null)
        		position = Notification.BOTTOM_RIGHT;
			var queue: NotificationQueue = null;
			switch (position)
            {
                case Notification.TOP_LEFT:
                    queue = topLeftQ;
                    break;
                case Notification.TOP_RIGHT:
                    queue = topRightQ;
                    break;
                case Notification.BOTTOM_LEFT:
                    queue = bottomLeftQ;
                    break;
                case Notification.BOTTOM_RIGHT:
                    queue = bottomRightQ;
                    break;
            }
			if (queue != null)
			{
				result = new Notification(queue, title, message, position, duration, icoURL);
				queue.addNotification(result);
   			}
            return result;
		}
		
		public function start(): void
		{
			topLeftQ.startNotifying();
			topRightQ.startNotifying();
			bottomLeftQ.startNotifying();
			bottomRightQ.startNotifying();
		}

		public function setMenu(menu: NativeMenu): void
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

/*
		public function getMenu(): NativeMenu
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
*/

		public function setIcons(icons: Array, tooltip: String = null): void
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

/*
		public function getIcons(): Array
		{
			if (Shell.shell.icon is InteractiveIcon)
			{
				return InteractiveIcon(Shell.shell.icon).bitmaps;
			}
			return null;
		}

		public function getToolTip(): String
		{
			if (Shell.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(Shell.shell.icon).tooltip;
			}
			return null;
		}
*/

		//// Private Functions ////
		private function onIdle(e: Event): void
		{
			topLeftQ.canStart = false;
			topRightQ.canStart = false;
			bottomLeftQ.canStart = false;
			bottomRightQ.canStart = false;
		}

		private function onPresent(e: Event): void
		{
			topLeftQ.canStart = true;
			topRightQ.canStart = true;
			bottomLeftQ.canStart = true;
			bottomRightQ.canStart = true;
		}

	}
}