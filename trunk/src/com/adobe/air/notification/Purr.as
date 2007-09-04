package com.adobe.air.notification
{
	import flash.system.Shell;
	import flash.events.Event;
	import flash.display.DockIcon;
	import flash.display.SystemTrayIcon;
	import flash.display.NativeWindow;
	import flash.display.NativeMenu;
	
	public class Purr
	{
		private var topLeftQ:NotificationQueue;
		private var topRightQ:NotificationQueue;
		private var bottomLeftQ:NotificationQueue;
		private var bottomRightQ:NotificationQueue;

		public function Purr(idleThreshold:uint)
		{
			topLeftQ = new NotificationQueue();
			topRightQ = new NotificationQueue();
			bottomLeftQ = new NotificationQueue();
			bottomRightQ = new NotificationQueue();

			Shell.shell.idleThreshold = idleThreshold * 60;
			Shell.shell.addEventListener(Event.USER_IDLE, onIdle);
			Shell.shell.addEventListener(Event.USER_PRESENT, onPresent);
		}
		
		public function alert(alertType:String, nativeWindow:NativeWindow, tooltip:String = null):void
		{
			if (Shell.supportsDockIcon)
			{
				trace("here");
				DockIcon(Shell.shell.icon).bounce(alertType);
			}
			else
			{
				nativeWindow.notifyUser(alertType);
				
				if (tooltip != null)
				{
					SystemTrayIcon(Shell.shell.icon).tooltip = tooltip;
				}
			}
		}
		
		public function addNotification(n:Notification):void
		{
			switch (n.position)
            {
                case Notification.TOP_LEFT:
                    this.topLeftQ.addNotification(n);
                    break;
                case Notification.TOP_RIGHT:
                    this.topRightQ.addNotification(n);
                    break;
                case Notification.BOTTOM_LEFT:
                    this.bottomLeftQ.addNotification(n);
                    break;
                case Notification.BOTTOM_RIGHT:
                    this.bottomRightQ.addNotification(n);
                    break;
            }
		}

		public function setMenu(menu:NativeMenu):void
		{
			
		}

		public function setIcons(icons:Array):void
		{
			
		}
		
		//// Private Functions ////
		
		private function onIdle(e:Event):void
		{
			
		}

		private function onPresent(e:Event):void
		{
			
		}
		
	}
}
