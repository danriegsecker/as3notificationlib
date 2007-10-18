package com.adobe.air.notification
{           
    import flash.display.Screen;
    import flash.events.Event;
    import flash.geom.Rectangle;
    
    public class NotificationQueue
    {

        private var queue:Array;
        private var playing:Boolean;
        private var paused:Boolean;

        public function NotificationQueue()
        {
            queue = new Array();
            playing = false;
            paused = false;
        }
		
		public function addNotification(notification:AbstractNotification):void
		{
            queue.push(notification);
            if (queue.length == 1 && !playing)
            {
            	playing = true;
            	run();
            }
		}

		public function clear(): void
		{
			while (queue.length > 0)
			{
				var n: AbstractNotification = queue.shift() as AbstractNotification;
				n = null;
			}
		}

        public function get length():uint
        {
        	return queue.length;
        }

		public function pause():void
		{
			this.paused = true;
		}

		public function resume():void
		{
			this.paused = false;
			run();
		}
        
        private function run():void
        {
        	if (paused || queue.length == 0) return;
            var n:AbstractNotification = queue[0] as AbstractNotification;
            n.addEventListener(Event.CLOSE,
            	function(e:Event):void
            	{
            		queue.shift();
            		if (queue.length > 0)
            		{
            			run();
            		}
            		else
            		{
            			playing = false;
            			return;
            		}
            	});
            var screen:Screen = Screen.mainScreen;
			switch (n.position)
            {
                case AbstractNotification.TOP_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.y + 3, n.width, n.height);
                    break;
                case AbstractNotification.TOP_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2), screen.visibleBounds.y + 3, n.width, n.height);
                    break;
                case AbstractNotification.BOTTOM_LEFT:
                    n.bounds = new Rectangle(screen.visibleBounds.x + 2, screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
                case AbstractNotification.BOTTOM_RIGHT:
                    n.bounds = new Rectangle(screen.visibleBounds.width - (n.width + 2) , screen.visibleBounds.height - (n.height + 2), n.width, n.height);
                    break;
            }
			n.alwaysInFront = true;
			n.visible = true;
        }
    }
}
