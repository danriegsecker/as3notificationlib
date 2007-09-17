package com.adobe.air.notification
{           
    import flash.display.Screen;
    import flash.geom.Rectangle;
    
    public class NotificationQueue
    {

        private var _queue: Array;

        public function NotificationQueue()
        {
            _queue = new Array();
        }

		public function get queue(): Array
		{
			return _queue;
		}
		
		public function addNotification(notification: Notification): void
		{
            queue.push(notification);
		}
		
		public function startNotifying(): void
		{
            if (canStart)
                start();
		}

        public function get length(): uint
        {
        	return queue.length;
        }
        
        private var _canStart: Boolean = true;
        
        public function get canStart(): Boolean
        {
        	return _canStart;
        }

		public function set canStart(value: Boolean): void
		{
			if (_canStart != value)
			{
				_canStart = value;
				if (_canStart)
					start();				
			}
		}        
        
        private function start():void
        {
        	if (!canStart) return;
            if (length == 0) return;
        	canStart = false;

            var n: Notification = queue.shift() as Notification; 
            var screen: Screen = Screen.mainScreen;
			switch (n.position)
            {
                case Notification.TOP_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.y + 2, n.width, n.height);
                    break;
                case Notification.TOP_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2), screen.visibleBounds.y + 2, n.width, n.height);
                    break;
                case Notification.BOTTOM_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
                case Notification.BOTTOM_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2) , screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
            }
			n.alwaysInFront = true;
			n.visible = true;
        }
    }
}
