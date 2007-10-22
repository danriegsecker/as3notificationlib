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
            this.queue = new Array();
            this.playing = false;
            this.paused = false;
        }
		
		public function addNotification(notification:AbstractNotification):void
		{
            this.queue.push(notification);
            if (this.queue.length == 1 && !this.playing)
            {
            	this.playing = true;
            	this.run();
            }
		}

		public function clear(): void
		{
			while (this.queue.length > 0)
			{
				var n: AbstractNotification = this.queue.shift() as AbstractNotification;
				n = null;
			}
		}

        public function get length():uint
        {
        	return this.queue.length;
        }

		public function pause():void
		{
			this.paused = true;
		}

		public function resume():void
		{
			this.paused = false;
			this.run();
		}
        
        private function run(): void
        {
        	if (this.paused || this.queue.length == 0) return;
            var n:AbstractNotification = this.queue[0] as AbstractNotification;
            n.addEventListener(Event.CLOSE,
            	function(e: Event): void
            	{
            		queue.shift();
            		if (queue.length > 0)
            		{
            			run();
            		}
            		else
            		{
            			playing = false;
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
