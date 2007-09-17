package com.adobe.air.notification
{           
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowSystemChrome;
    import flash.display.NativeWindowType;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.EventDispatcher
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.Shell;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.ContextMenu;
    import flash.utils.Timer;
    import com.adobe.air.notification.events.NotificationClickedEvent;
    
    public class Notification
        extends NativeWindow
    {
        public static const TOP_LEFT:String = "topLeft";
        public static const TOP_RIGHT:String = "topRight";
        public static const BOTTOM_LEFT:String = "bottomLeft";
        public static const BOTTOM_RIGHT:String = "bottomRight";
        
        private var _id: String;
        private var _duration:uint;
        private var _message:String;
        private var _position:String;
        private var _title:String;
        private var _height:String;
        private var _width:String;
		private var _iconURL: String;

		private var sprite:Sprite;
        private var messageLabel: TextField;
       	private var titleLabel: TextField;
		
		private var queue: NotificationQueue;
		
        public function Notification(queue: NotificationQueue, title: String, message: String, position: String, duration: uint, icoURL: String = null)
        {   
			// Configure the window
            var initOpts:NativeWindowInitOptions = new NativeWindowInitOptions();
            initOpts.appearsInWindowMenu = false;
            initOpts.hasMenu = false;
            initOpts.maximizable = false;
            initOpts.minimizable = false;
            initOpts.resizable = false;
            initOpts.transparent = true;
            initOpts.systemChrome = NativeWindowSystemChrome.NONE;
            initOpts.type = NativeWindowType.LIGHTWEIGHT;
            super(initOpts);
            this.queue = queue; 

            visible = false;
            _duration = duration;
            if (Shell.supportsDockIcon)
            {
            	_position = Notification.TOP_RIGHT;
            }
            else if (Shell.supportsSystemTrayIcon)
            {
            	_position = Notification.BOTTOM_RIGHT;
            }

        	this.iconURL = icoURL;

			createControls();

        	this.title = title;
        	this.message = message;
        	this.position = position;
	    }

		protected function createControls(): void
		{
			// spreite.graphics.beginBitmapFill(bitmap:BitmapData, matrix:Matrix = null, repeat:Boolean = true, smooth:Boolean = false)	

			// default context menu used for all text fields 
			var cm: ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			bounds = new Rectangle(100, 100, 800, 600);
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			sprite = new Sprite();
			sprite.alpha = 0;

            titleLabel = new TextField();
            titleLabel.autoSize = TextFieldAutoSize.LEFT;
            titleLabel.border = false;
            titleLabel.backgroundColor = 0xFFFFFF;

            var titleFormat: TextFormat = new TextFormat();
            titleFormat.font = "Verdana";
            titleFormat.bold = true;
            titleFormat.color = 0xFFFFFF;
            titleFormat.size = 12;
			titleFormat.align = TextFormatAlign.LEFT;

            titleLabel.defaultTextFormat = titleFormat;
            titleLabel.alpha = 0;
            titleLabel.multiline = false;
            titleLabel.selectable = false;
            titleLabel.wordWrap = false;

            titleLabel.contextMenu = cm;
            titleLabel.x = 2;
            titleLabel.y = 2;
            sprite.addChild(titleLabel);
            
            messageLabel = new TextField();

            messageLabel.autoSize = TextFieldAutoSize.LEFT;
            messageLabel.border = true;
            messageLabel.backgroundColor = 0xFFFFFF;

            var format: TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0x000000;
            format.size = 10;
			format.align = TextFormatAlign.LEFT;

            messageLabel.defaultTextFormat = format;
            messageLabel.alpha = 0;
            messageLabel.multiline = true;
            messageLabel.selectable = false;
            messageLabel.wordWrap = true;

            messageLabel.contextMenu = cm;
            messageLabel.x = 56;
            messageLabel.y = 19;

            sprite.addChild(messageLabel);

            width = 400;
            height = 100;

            sprite.graphics.beginFill(0xFFFFFF);
            sprite.graphics.lineStyle(1, 0xFFFFFF);
            sprite.graphics.drawRoundRect(2, 18, 396, 80, 10, 10);
            sprite.graphics.endFill();
            sprite.graphics.beginFill(0xFFFFFF);
            sprite.graphics.drawRoundRect(0, 0, 400, 100, 10, 10);
            sprite.graphics.endFill();

            var button: CustomSimpleButton = new CustomSimpleButton();
            sprite.addChild(button);
            button.x = width - button.width - 2;
			button.y = button.y + 2;
			button.addEventListener(MouseEvent.CLICK, closeNotification);

			stage.addChild(sprite);

            var loader: Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			if (iconURL != null)
			{
	            var request: URLRequest = new URLRequest(iconURL);
	            loader.load(request);
			}

			sprite.addEventListener(MouseEvent.DOUBLE_CLICK, notificationDoubleClick);
        	messageLabel.addEventListener(MouseEvent.DOUBLE_CLICK, notificationDoubleClick);
       		titleLabel.addEventListener(MouseEvent.DOUBLE_CLICK, notificationDoubleClick);
		}

        private function completeHandler(event: Event): void 
        {
        	var loader:Loader = Loader(event.target.loader)
            var bitmapData:BitmapData = Bitmap(loader.content).bitmapData;
            loader.x = (52 / 2) - (bitmapData.width / 2);
            loader.y = (100 / 2) - (bitmapData.height / 2);
            loader.addEventListener(MouseEvent.DOUBLE_CLICK, notificationDoubleClick);
            sprite.addChild(loader);
        }

        private function ioErrorHandler(event: IOErrorEvent): void 
        {
            trace("Unable to load image: " + iconURL);
        }

        private function _close(): void
        {
			close();
			queue.canStart = true;
        }

        private var t: Timer;
		private function closeNotification(e: MouseEvent): void
		{
	        if (t != null)
	        {
	            t.stop();
				if (t.hasEventListener(TimerEvent.TIMER))
		            t.removeEventListener(TimerEvent.TIMER, _timerEvent);
	            t = null;
	        }
            if (e != null)
            {
				_close();
            }
            else 
            {
				var alphaTimer: Timer = new Timer(50);
				alphaTimer.addEventListener(TimerEvent.TIMER,
					function (e: TimerEvent): void
					{
						alphaTimer.stop();
						var nAlpha: Number = sprite.alpha;
						nAlpha = nAlpha - .1;
						if (nAlpha < 0)
							nAlpha = 0;
						sprite.alpha = nAlpha;
						messageLabel.alpha = sprite.alpha;
						if (Math.round(sprite.alpha) == 0)
						{
							_close();
						}
						else 
						{
							alphaTimer.start();
						}
					});
				alphaTimer.start();
            }
		}

		override public function set visible(value: Boolean):void
		{
			super.visible = value;
			if (value == true)
			{
				var alphaTimer: Timer = new Timer(50);
				alphaTimer.addEventListener(TimerEvent.TIMER,
					function (e: TimerEvent): void
					{
						alphaTimer.stop();
						var nAlpha: Number = sprite.alpha;
						nAlpha = nAlpha + .1;
						if (nAlpha > .6)
							nAlpha = .6;
						sprite.alpha = nAlpha;
						messageLabel.alpha = sprite.alpha;
						if (Math.round(sprite.alpha) < .6)
						{
							alphaTimer.start();
						}
						else 
						{
							t = new Timer(duration * 1000);
				            t.addEventListener(TimerEvent.TIMER, _timerEvent); 
				            t.start();
						}
					});
				alphaTimer.start();
			}
		}
		
    	private function _timerEvent(e: TimerEvent): void
    	{
            closeNotification(null);
    	}

		public function set iconURL(url: String): void
		{
			_iconURL = url;
		}
		
		public function get iconURL(): String
		{
			return _iconURL;
		}
        
        public function set position(position: String):void
        {
        	_position = position;
        }
                    
        public function get position():String
        {
            return _position;
        }

        public override function set title(title: String): void
        {
        	_title = title;
        	titleLabel.text = title;
        }

        public override function get title(): String
        {
            return _title;
        }

        public function set message(message:String):void
        {
        	_message = message;
            messageLabel.text = message;
        }

        public function get message(): String
        {
            return _message;
        }

        public function set duration(duration: uint): void
        {
            _duration = duration;
        }

        public function get duration():uint
        {
            return _duration;
        }

        public override function set width(width: Number):void
        {
			super.width = width;
			messageLabel.width = width - (messageLabel.x + 2);
			titleLabel.width = width - 8;
        }

        public override function set height(height: Number):void
        {
			super.height = height;
			messageLabel.height = height - (messageLabel.y + 2);
        }
                
        public function get id(): String
        {
        	return _id;
        }

        public function set id(NewID: String): void
        {
        	_id = NewID;
        }

		private function notificationDoubleClick(event: MouseEvent): void
		{
			(event.target as EventDispatcher).dispatchEvent(new NotificationClickedEvent(this.id));
		}
    }
}

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;

class CustomSimpleButton extends SimpleButton 
{
    private var upColor: uint   = 0xFFCC00;
    private var overColor: uint = 0xCCFF00;
    private var downColor: uint = 0x00CCFF;
    private var size: uint      = 15;

    public function CustomSimpleButton() 
    {
        downState      = new ButtonDisplayState(downColor, size);
        overState      = new ButtonDisplayState(overColor, size);
        upState        = new ButtonDisplayState(upColor, size);
        hitTestState   = new ButtonDisplayState(upColor, size * 2);
        hitTestState.x = -(size / 4);
        hitTestState.y = hitTestState.x;
        useHandCursor  = true;
    }
}

class ButtonDisplayState extends Shape 
{
    private var bgColor: uint;
    private var size: uint;

    public function ButtonDisplayState(bgColor:uint, size:uint)
    {
        this.bgColor = bgColor;
        this.size 	 = size;
        draw();
    }

    private function draw(): void
    {
        graphics.beginFill(bgColor);
        graphics.drawRoundRect(0, 0, size, size, 1, 1);
        graphics.endFill();
    }
}