package com.adobe.air.notification
{           
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;
    import flash.display.Screen;
    
    public class NotificationQueue
    {   

        private var queue:Array;

        public function NotificationQueue()
        {
            this.queue = new Array();
        }

        public function addNotification(notification:Notification):void
        {
            this.queue.push(notification);
            if (this.queue.length == 1)
            {
                start();
            }
        }
        
        private function start():void
        {
            if (this.queue.length == 0) return;
            var n:Notification = this.queue.shift() as Notification;
            var bounds:Rectangle;
            var screen:Screen = Screen.mainScreen;
			switch (n.position)
            {
                case Notification.TOP_LEFT:
                    bounds = new Rectangle(screen.visibleBounds.x, screen.visibleBounds.y, n.width, n.height);
                    n.bounds = bounds;
                    break;
                case Notification.TOP_RIGHT:
                    bounds = new Rectangle(screen.visibleBounds.width - n.width, screen.visibleBounds.y, n.width, n.height);
                    n.bounds = bounds;
                    break;
                case Notification.BOTTOM_LEFT:
                    bounds = new Rectangle(screen.visibleBounds.x, screen.visibleBounds.height - n.height, n.width, n.height);
                    n.bounds = bounds;
                    break;
                case Notification.BOTTOM_RIGHT:
                    bounds = new Rectangle(screen.visibleBounds.width - n.width, screen.visibleBounds.height - n.height, n.width, n.height);
                    n.bounds = bounds;
                    break;
            }
			n.alwaysInFront = true;
            n.visible = true;
            var t:Timer = new Timer(n.duration);
            t.addEventListener(TimerEvent.TIMER,
                function (e:Event):void
                {
                    n.close();
                    t.stop();
                    if (queue.length > 0)
                    {
                        start();
                    }
                });
            t.start();
        }
    }
}
