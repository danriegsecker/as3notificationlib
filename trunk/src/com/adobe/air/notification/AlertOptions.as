package com.adobe.air.notification
{
	import flash.display.NativeWindow;
	
	public class AlertOptions
	{
		private var _nativeWindow:NativeWindow;
		private var _alertType:String;
		private var _icons:Array;
		private var _toolTip:String;
		
		public function set nativeWindow(nativeWindow:NativeWindow):void
		{
			_nativeWindow = nativeWindow;
		}

		public function get nativeWindow():NativeWindow
		{
			return _nativeWindow;
		}

		public function set alertType(alertType:String):void
		{
			_alertType = alertType;
		}

		public function get alertType():String
		{
			return _alertType;
		}

		public function set icons(icons:Array):void
		{
			_icons = icons;
		}

		public function get icons():Array
		{
			return _icons;
		}

		public function set toolTip(toolTip:String):void
		{
			_toolTip = toolTip;
		}

		public function get toolTip():String
		{
			return _toolTip;
		}
	}
}
