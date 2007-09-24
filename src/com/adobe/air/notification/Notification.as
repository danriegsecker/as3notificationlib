package com.adobe.air.notification
{           
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowSystemChrome;
    import flash.display.NativeWindowType;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.filters.DropShadowFilter;
    import flash.geom.Rectangle;
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
       	private var _bitmap: Bitmap;

		private var sprite:Sprite;
        private var messageLabel:TextField;
       	private var titleLabel:TextField;
       	private var closeTimer:Timer;
       	private var alphaTimer:Timer;

        public function Notification(title:String, message:String, position:String, duration:uint, bitmap: Bitmap = null)
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

			if (bitmap != null)
			{
    	    	this.bitmap = new Bitmap(bitmap.bitmapData);
   			}

			createControls();

        	this.title = title;
        	this.message = message;
        	this.position = position;
            this.duration = duration;
	    }
		
		private const Left_Pos: int = 56;

		protected function createControls():void
		{
			var leftPos: int = (this.bitmap != null) ? 56 : 2;
			var cm:ContextMenu = new ContextMenu();
			cm.hideBuiltInItems();
			
			this.bounds = new Rectangle(100, 100, 800, 600);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.sprite = new Sprite();
			this.sprite.alpha = 0;

			// title
            this.titleLabel = new TextField();
            this.titleLabel.autoSize = TextFieldAutoSize.LEFT;
            var titleFormat:TextFormat = titleLabel.defaultTextFormat;
            titleFormat.font = "Verdana";
            titleFormat.bold = true;
            titleFormat.color = 0xFFFFFF;
            titleFormat.size = 10;
			titleFormat.align = TextFormatAlign.LEFT;
            this.titleLabel.defaultTextFormat = titleFormat;
            this.titleLabel.multiline = false;
            this.titleLabel.selectable = false;
            this.titleLabel.wordWrap = false;
            this.titleLabel.contextMenu = cm;
            this.titleLabel.x = leftPos;
            this.titleLabel.y = 2;
            var titleSprite:Sprite = new Sprite();
            titleSprite.addChild(titleLabel);
            titleSprite.filters = [new DropShadowFilter(5, 45, 0x000000, .9)];
            this.sprite.addChild(titleSprite);

			// message            
            this.messageLabel = new TextField();
            this.messageLabel.autoSize = TextFieldAutoSize.LEFT;
            var messageFormat:TextFormat = messageLabel.defaultTextFormat;
            messageFormat.font = "Verdana";
            messageFormat.color = 0xFFFFFF;
            messageFormat.size = 10;
			messageFormat.align = TextFormatAlign.LEFT;
            this.messageLabel.defaultTextFormat = messageFormat;
            this.messageLabel.multiline = true;
            this.messageLabel.selectable = false;
            this.messageLabel.wordWrap = true;
            this.messageLabel.contextMenu = cm;
            this.messageLabel.x = leftPos;
            this.messageLabel.y = 19;
            var messageSprite:Sprite = new Sprite();
            messageSprite.addChild(messageLabel);
            messageSprite.filters = [new DropShadowFilter(5, 45, 0x000000, .9)];
            this.sprite.addChild(messageSprite);

            this.width = 400;
            this.height = 100;

            this.sprite.graphics.beginFill(0x333333);
            this.sprite.graphics.drawRoundRect(0, 0, 400, 100, 10, 10);
            this.sprite.graphics.endFill();

			this.stage.addChild(sprite);

			this.sprite.addEventListener(MouseEvent.CLICK, notificationClick);
        	this.messageLabel.addEventListener(MouseEvent.CLICK, notificationClick);
       		this.titleLabel.addEventListener(MouseEvent.CLICK, notificationClick);

			if (this.bitmap != null)
			{
	            var bitmapData:BitmapData = this.bitmap.bitmapData;
	            this.bitmap.x = (52 / 2) - (bitmapData.width / 2);
	            this.bitmap.y = (100 / 2) - (bitmapData.height / 2);
	            this.bitmap.addEventListener(MouseEvent.CLICK, notificationClick);
	            bitmap.filters = [new DropShadowFilter(5, 45, 0x000000, .9)];
	            this.sprite.addChild(bitmap);
			}
		}

		private function superClose():void
		{
			super.close();
		}

		override public function close():void
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

			alphaTimer = new Timer(25);
			alphaTimer.addEventListener(TimerEvent.TIMER,
				function (e:TimerEvent):void
				{
					alphaTimer.stop();
					var nAlpha:Number = sprite.alpha;
					nAlpha = nAlpha - .01;
					sprite.alpha = nAlpha;
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
				alphaTimer = new Timer(10);
				alphaTimer.addEventListener(TimerEvent.TIMER,
					function (e:TimerEvent):void
					{
						alphaTimer.stop();
						var nAlpha:Number = sprite.alpha;
						nAlpha = nAlpha + .01;
						sprite.alpha = nAlpha;
						if (sprite.alpha < .9)
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

		public function set bitmap(bitmap:Bitmap):void
		{
			this._bitmap = bitmap;
		}
		
		public function get bitmap():Bitmap
		{
			return this._bitmap;
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
			this.messageLabel.width = width - (this.messageLabel.x + 2);
			this.titleLabel.width = width - 8;
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.messageLabel.height = height - (this.messageLabel.y + 2);
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