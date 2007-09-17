package com.adobe.air.notification.events
{
	import flash.events.Event;
	public class NotificationClickedEvent extends Event
	{
		public var NotificationID: String;
		public function NotificationClickedEvent(NotificationID: String) 
		{
			super('Notification');
			this.NotificationID = NotificationID;			
		}
	}
}