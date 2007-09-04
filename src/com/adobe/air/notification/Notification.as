package com.adobe.air.notification
{           
    import mx.containers.Panel;
    import mx.controls.Label;
    import flash.display.NativeWindow;
    import flash.display.NativeWindowInitOptions;
    import flash.display.NativeWindowType;
    import flash.display.NativeWindowSystemChrome;
    import flash.system.Shell;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.text.TextField;
    
    public class Notification
        extends NativeWindow
    {
        public static const TOP_LEFT:String = "topLeft";
        public static const TOP_RIGHT:String = "topRight";
        public static const BOTTOM_LEFT:String = "bottomLeft";
        public static const BOTTOM_RIGHT:String = "bottomRight";
        
        private var _duration:uint;
        private var _message:String;
        private var _position:String;
        private var _title:String;
        private var _height:String;
        private var _width:String;
        
        private var panel:Panel;
        private var messageLabel:Label;
            
        public function Notification()
        {   
			// Configure the window
            var initOpts:NativeWindowInitOptions = new NativeWindowInitOptions();
            initOpts.appearsInWindowMenu = false;
            initOpts.hasMenu = false;
            initOpts.maximizable = false;
            initOpts.minimizable = false;
            initOpts.resizable = false;
            initOpts.systemChrome = NativeWindowSystemChrome.STANDARD;
            initOpts.transparent = false;
            initOpts.type = NativeWindowType.NORMAL;
            super(initOpts);

            this.visible = false;
            this._duration = 9000;
            if (Shell.supportsDockIcon)
            {
            	this._position = Notification.TOP_RIGHT;
            }
            else
            {
            	this._position = Notification.BOTTOM_RIGHT;            	
            }
            this.panel = new Panel();
            this.messageLabel = new Label();
            this.panel.addChild(messageLabel);
            this.width = 400;
            this.height = 300;
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
            this.stage.addChild(panel);
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
            this.panel.title = title;
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
			this.panel.width = width;
        }

        public override function set height(height:Number):void
        {
			super.height = height;
			this.panel.height = height;
        }

    }
}
