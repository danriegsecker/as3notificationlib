package com.adobe.air.notification
{
	import flash.display.Bitmap;
	import flash.desktop.DockIcon;
	import flash.desktop.InteractiveIcon;
	import flash.display.NativeMenu;
	import flash.display.NativeWindow;
	import flash.desktop.SystemTrayIcon;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.desktop.NativeApplication;

	public class Purr
	{
		private var topLeftQ:NotificationQueue;
		private var topRightQ:NotificationQueue;
		private var bottomLeftQ:NotificationQueue;
		private var bottomRightQ:NotificationQueue;
		private var paused:Boolean;

		public function Purr(idleThreshold:uint)
		{
			this.topLeftQ = new NotificationQueue();
			this.topRightQ = new NotificationQueue();
			this.bottomLeftQ = new NotificationQueue();
			this.bottomRightQ = new NotificationQueue();

			this.paused = false;

			NativeApplication.nativeApplication.idleThreshold = idleThreshold * 60;
			NativeApplication.nativeApplication.addEventListener(Event.USER_IDLE, function(e: Event): void { pause(); });
			NativeApplication.nativeApplication.addEventListener(Event.USER_PRESENT, function(e: Event): void { resume(); });
		}

		public function alert(alertType:String, nativeWindow:NativeWindow):void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).bounce(alertType);
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				if (nativeWindow != null)
				{
					nativeWindow.notifyUser(alertType);
				}
			}
		}

		public function addNotification(n:AbstractNotification):void
		{
			switch (n.position)
            {
                case AbstractNotification.TOP_LEFT:
                    this.topLeftQ.addNotification(n);
                    break;
                case AbstractNotification.TOP_RIGHT:
                    this.topRightQ.addNotification(n);
                    break;
                case AbstractNotification.BOTTOM_LEFT:
                    this.bottomLeftQ.addNotification(n);
                    break;
                case AbstractNotification.BOTTOM_RIGHT:
                    this.bottomRightQ.addNotification(n);
                    break;
            }			
		}

		public function addTextNotificationByParams(title:String, message:String, position:String = null, duration:uint = 5, bitmap:Bitmap = null):Notification
		{
			var n:Notification = new Notification(title, message, position, duration, bitmap);
			this.addNotification(n);
            return n;
		}

		public function setMenu(menu:NativeMenu): void
		{
			if (NativeApplication.supportsDockIcon)
			{
				DockIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).menu = menu;
			}
		}

		public function getMenu():NativeMenu
		{
			if (NativeApplication.supportsDockIcon)
			{
				return DockIcon(NativeApplication.nativeApplication.icon).menu;
			}
			else if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).menu;
			}
			return null;
		}

		public function setIcons(icons:Array, tooltip:String = null):void
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps = icons;
			}
			if (NativeApplication.supportsSystemTrayIcon)
			{
				SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip = tooltip;
			}
		}

		public function getIcons():Array
		{
			if (NativeApplication.nativeApplication.icon is InteractiveIcon)
			{
				return InteractiveIcon(NativeApplication.nativeApplication.icon).bitmaps;
			}
			return null;
		}

		public function getToolTip():String
		{
			if (NativeApplication.supportsSystemTrayIcon)
			{
				return SystemTrayIcon(NativeApplication.nativeApplication.icon).tooltip;
			}
			return null;
		}

		public function clear(where: String = null): void
		{
			switch (where)
			{
                case AbstractNotification.TOP_LEFT || null:
					this.topLeftQ.clear();
                case AbstractNotification.TOP_RIGHT || null:
					this.topRightQ.clear();
                case AbstractNotification.BOTTOM_LEFT || null:
					this.bottomLeftQ.clear();
                case AbstractNotification.BOTTOM_RIGHT || null:
					this.bottomRightQ.clear();
			}
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

		public function set notificationSound(value: Sound): void
		{
			this.topLeftQ.sound = value;
			this.topRightQ.sound = value;
			this.bottomLeftQ.sound = value;
			this.bottomRightQ.sound = value;
		}

		public function get notificationSound(): Sound
		{
			return this.topLeftQ.sound;
		}

		public function isPaused():Boolean
		{
			return this.paused;
		}
	}
}