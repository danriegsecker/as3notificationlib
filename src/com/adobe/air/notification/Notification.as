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
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.text.TextFormatAlign;
    import flash.ui.ContextMenu;
    import flash.utils.Timer;

	[Event(name="notificationClickedEvent", type="com.adobeair.notification.NotificationClickedEvent")]

    public class Notification
        extends NativeWindow
    {
        public static const TOP_LEFT:String = "topLeft";
        public static const TOP_RIGHT:String = "topRight";
        public static const BOTTOM_LEFT:String = "bottomLeft";
        public static const BOTTOM_RIGHT:String = "bottomRight";
        
        private var _id:String;
        private var _duration:uint;
        private var _message:String;
        private var _position:String;
        private var _title:String;
        private var _height:String;
        private var _width:String;
		private var _iconURL:String;

		private var sprite:Sprite;
        private var messageLabel:TextField;
       	private var titleLabel:TextField;
       	private var closeTimer:Timer;
		
        public function Notification(title:String, message:String, position:String, duration:uint, icoURL:String = null)
        {   
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

            visible = false;

			createControls();

        	this.title = title;
        	this.message = message;
        	this.position = position;
            this.duration = duration;
        	this.iconURL = icoURL;
	    }

		protected function createControls():void
		{
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			this.bounds = new Rectangle(100, 100, 800, 600);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.sprite = new Sprite();
			this.sprite.alpha = 0;

            this.titleLabel = new TextField();
            this.titleLabel.autoSize = TextFieldAutoSize.LEFT;
            this.titleLabel.border = false;
            this.titleLabel.backgroundColor = 0xFFFFFF;

            var titleFormat:TextFormat = new TextFormat();
            titleFormat.font = "Verdana";
            titleFormat.bold = true;
            titleFormat.color = 0xFFFFFF;
            titleFormat.size = 12;
			titleFormat.align = TextFormatAlign.LEFT;

            this.titleLabel.defaultTextFormat = titleFormat;
            this.titleLabel.alpha = 0;
            this.titleLabel.multiline = false;
            this.titleLabel.selectable = false;
            this.titleLabel.wordWrap = false;

            this.titleLabel.contextMenu = cm;
            this.titleLabel.x = 2;
            this.titleLabel.y = 2;
            this.sprite.addChild(titleLabel);
            
            this.messageLabel = new TextField();

            this.messageLabel.autoSize = TextFieldAutoSize.LEFT;
            this.messageLabel.border = true;
            this.messageLabel.backgroundColor = 0xFFFFFF;

            var format:TextFormat = new TextFormat();
            format.font = "Verdana";
            format.color = 0x000000;
            format.size = 10;
			format.align = TextFormatAlign.LEFT;

            this.messageLabel.defaultTextFormat = format;
            this.messageLabel.alpha = 0;
            this.messageLabel.multiline = true;
            this.messageLabel.selectable = false;
            this.messageLabel.wordWrap = true;

            this.messageLabel.contextMenu = cm;
            this.messageLabel.x = 56;
            this.messageLabel.y = 19;

            this.sprite.addChild(messageLabel);

            this.width = 400;
            this.height = 100;

            this.sprite.graphics.beginFill(0xFFFFFF);
            this.sprite.graphics.lineStyle(1, 0xFFFFFF);
            this.sprite.graphics.drawRoundRect(2, 18, 396, 80, 10, 10);
            this.sprite.graphics.endFill();
            this.sprite.graphics.beginFill(0xFFFFFF);
            this.sprite.graphics.drawRoundRect(0, 0, 400, 100, 10, 10);
            this.sprite.graphics.endFill();

            var button:CustomSimpleButton = new CustomSimpleButton();
            sprite.addChild(button);
            button.x = width - button.width - 2;
			button.y = button.y + 2;
			button.addEventListener(MouseEvent.CLICK, function():void {close();});

			this.stage.addChild(sprite);

            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);

			if (this.iconURL != null)
			{
	            var request:URLRequest = new URLRequest(iconURL);
	            loader.load(request);
			}

			this.sprite.addEventListener(MouseEvent.CLICK, notificationClick);
        	this.messageLabel.addEventListener(MouseEvent.CLICK, notificationClick);
       		this.titleLabel.addEventListener(MouseEvent.CLICK, notificationClick);
		}

        private function completeHandler(event:Event):void 
        {
        	var loader:Loader = Loader(event.target.loader)
            var bitmapData:BitmapData = Bitmap(loader.content).bitmapData;
            loader.x = (52 / 2) - (bitmapData.width / 2);
            loader.y = (100 / 2) - (bitmapData.height / 2);
            loader.addEventListener(MouseEvent.CLICK, notificationClick);
            sprite.addChild(loader);
        }

        private function ioErrorHandler(event:IOErrorEvent):void 
        {
            trace("Unable to load image: " + iconURL);
        }

		private function superClose():void
		{
			super.close();
		}

		public override function close():void
		{
	        if (this.closeTimer != null)
	        {
	            this.closeTimer.stop();
	            this.closeTimer = null;
	        }

			var alphaTimer:Timer = new Timer(50);
			alphaTimer.addEventListener(TimerEvent.TIMER,
				function (e:TimerEvent):void
				{
					alphaTimer.stop();
					var nAlpha:Number = sprite.alpha;
					nAlpha = nAlpha - .1;
					if (nAlpha < 0)
					{
						nAlpha = 0;
					}
					sprite.alpha = nAlpha;
					messageLabel.alpha = sprite.alpha;
					if (sprite.alpha <= 0)
					{
						superClose();
					}
					else 
					{
						alphaTimer.start();
					}
				});
			alphaTimer.start();
		}

		override public function set visible(value:Boolean):void
		{
			super.visible = value;
			if (value == true)
			{
				var alphaTimer:Timer = new Timer(50);
				alphaTimer.addEventListener(TimerEvent.TIMER,
					function (e:TimerEvent):void
					{
						alphaTimer.stop();
						var nAlpha:Number = sprite.alpha;
						nAlpha = nAlpha + .1;
						if (nAlpha > .6)
						{
							nAlpha = .6;
						}
						sprite.alpha = nAlpha;
						messageLabel.alpha = sprite.alpha;
						if (Math.round(sprite.alpha) < .6)
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
				alphaTimer.start();
			}
		}

		public function set iconURL(url:String):void
		{
			this._iconURL = url;
		}
		
		public function get iconURL():String
		{
			return this._iconURL;
		}
        
        public function set position(position:String):void
        {
        	this._position = position;
        }
                    
        public function get position():String
        {
            return this._position;
        }

        public override function set title(title:String):void
        {
        	this._title = title;
        	this.titleLabel.text = title;
        }

        public override function get title():String
        {
            return this._title;
        }

        public function set message(message:String):void
        {
        	this._message = message;
            this.messageLabel.text = message;
        }

        public function get message():String
        {
            return this._message;
        }

        public function set duration(duration:uint):void
        {
           this._duration = duration;
        }

        public function get duration():uint
        {
            return this._duration;
        }

        public override function set width(width:Number):void
        {
			super.width = width;
			this.messageLabel.width = width - (messageLabel.x + 2);
			this.titleLabel.width = width - 8;
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.messageLabel.height = height - (messageLabel.y + 2);
        }
                
        public function get id():String
        {
        	return this._id;
        }

        public function set id(id:String):void
        {
        	this._id = id;
        }

		private function notificationClick(event:MouseEvent):void
		{
			this.dispatchEvent(new NotificationClickedEvent());
			this.close();
		}
    }
}

import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.SimpleButton;

class CustomSimpleButton extends SimpleButton 
{
    private var upColor:uint   = 0xFFCC00;
    private var overColor:uint = 0xCCFF00;
    private var downColor:uint = 0x00CCFF;
    private var size:uint      = 15;

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
    private var bgColor:uint;
    private var size:uint;

    public function ButtonDisplayState(bgColor:uint, size:uint)
    {
        this.bgColor = bgColor;
        this.size 	 = size;
        draw();
    }

    private function draw():void
    {
        graphics.beginFill(bgColor);
        graphics.drawRoundRect(0, 0, size, size, 1, 1);
        graphics.endFill();
    }
}