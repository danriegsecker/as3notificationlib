package com.adobe.air.notification
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.system.Shell;
	import flash.utils.Timer;

	[Event(name=NotificationClickedEvent.NOTIFICATION_CLICKED_EVENT, type="com.adobe.air.notification.NotificationClickedEvent")]

	public class AbstractNotification 
		extends NativeWindow
	{
        public static const TOP_LEFT:String = "topLeft";
        public static const TOP_RIGHT:String = "topRight";
        public static const BOTTOM_LEFT:String = "bottomLeft";
        public static const BOTTOM_RIGHT:String = "bottomRight";

        private var _duration:uint;
        private var _id:String;
        private var _position:String;

       	private var closeTimer:Timer;
       	private var alphaTimer:Timer;
		private var sprite:Sprite;

		public function AbstractNotification(position:String = null, duration:uint = 5)
		{
			super(this.getWinOptions());

			this.createControls();

            this.visible = false;

        	if (position == null)
        	{
	            if (Shell.supportsDockIcon)
	            {
	            	position = AbstractNotification.TOP_RIGHT;
	            }
	            else if (Shell.supportsSystemTrayIcon)
	            {
	            	position = AbstractNotification.BOTTOM_RIGHT;
	            }
        	}
        	this.position = position;
            this.duration = duration;
		}
		
		protected function getWinOptions(): NativeWindowInitOptions
		{
            var result: NativeWindowInitOptions = new NativeWindowInitOptions();
            result.appearsInWindowMenu = false;
            result.hasMenu = false;
            result.maximizable = false;
            result.minimizable = false;
            result.resizable = false;
            result.transparent = true;
            result.systemChrome = NativeWindowSystemChrome.NONE;
            result.type = NativeWindowType.LIGHTWEIGHT;
            return result;
		}
		
		protected function getSprite(): Sprite
		{
			if (this.sprite == null)
			{
				this.sprite = new Sprite();
				this.sprite.alpha = 0;
				this.stage.addChild(this.sprite);
				this.addClickEvent(this.sprite);
			}
			return this.sprite;
		}

		protected function createControls():void
		{
			this.bounds = new Rectangle(100, 100, 800, 600);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
		}

		protected function beforeClose(): void
		{
			// do custom process.
			// see videoNotificaton class for more specific usecase.		
		}

		private function superClose():void
		{
			this.beforeClose();
			super.close();
		}

		override public function close(): void
		{
	        if (this.closeTimer != null)
	        {
	            this.closeTimer.stop();
	            this.closeTimer = null;
	        }

			if (this.alphaTimer != null)
			{
				this.alphaTimer.stop();
				this.alphaTimer = null;
			}

			this.alphaTimer = new Timer(25);
			this.alphaTimer.addEventListener(TimerEvent.TIMER,
				function (e:TimerEvent):void
				{
					alphaTimer.stop();
					var nAlpha:Number = getSprite().alpha;
					nAlpha = nAlpha - .01;
					getSprite().alpha = nAlpha;
					if (getSprite().alpha <= 0)
					{
						superClose();
					}
					else 
					{
						alphaTimer.start();
					}
				});
			this.alphaTimer.start();
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value == true)
			{
				this.alphaTimer = new Timer(10);
				this.alphaTimer.addEventListener(TimerEvent.TIMER,
					function (e:TimerEvent):void
					{
						alphaTimer.stop();
						var nAlpha:Number = getSprite().alpha;
						nAlpha = nAlpha + .01;
						getSprite().alpha = nAlpha;
						if (getSprite().alpha < .9)
						{
							alphaTimer.start();
						}
						else
						{
							closeTimer = new Timer(duration * 1000);
				            closeTimer.addEventListener(TimerEvent.TIMER,
				            	function(e:TimerEvent):void
				            	{
						            close();
				            	}); 
				            closeTimer.start();
						}
					});
				this.alphaTimer.start();
			}
		}

        public function set position(position:String):void
        {
        	this._position = position;
        }
                    
        public function get position():String
        {
            return this._position;
        }

        public function get id():String
        {
        	return this._id;
        }

        public function set id(id:String):void
        {
        	this._id = id;
        }

        public function set duration(duration:uint):void
        {
           this._duration = duration;
        }

        public function get duration():uint
        {
            return this._duration;
        }

		private function drawBackGround(): void
		{
			this.getSprite().graphics.clear();
            this.getSprite().graphics.beginFill(0x333333);
            this.getSprite().graphics.drawRoundRect(0, 0, this.width, this.height, 10, 10);
            this.getSprite().graphics.endFill();
		}

        public override function set width(width:Number):void
        {
			super.width = width;
			this.drawBackGround()
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.drawBackGround()
        }

		private function notificationClick(event:MouseEvent):void
		{
			this.dispatchEvent(new NotificationClickedEvent());
			this.close();
		}
		
		public function addClickEvent(target: EventDispatcher): void
		{
			target.addEventListener(MouseEvent.CLICK, this.notificationClick);
		}
	}
}