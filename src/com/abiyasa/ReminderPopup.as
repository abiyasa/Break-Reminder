package com.abiyasa 
{
	import flash.display.Bitmap;
	import flash.display.Graphics;
	import flash.display.NativeWindow;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowType;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowInitOptions;	
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.display.Screen;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextFormat;
	import mx.core.BitmapAsset;
	
	import flash.text.TextField;

	
	/**
	 * The reminder popup
	 * 
	 * @author Abiyasa
	 */
	public class ReminderPopup extends NativeWindow 
	{
		[Embed(source = "/../asset/battery.png")]
		protected var ICON_BREAK:Class;
		
		public static const POPUP_WIDTH:int = 200;
		public static const POPUP_HEIGHT:int = 150;
		
		public function ReminderPopup() 
		{
			var popupOption:NativeWindowInitOptions = new NativeWindowInitOptions();
			popupOption.type = NativeWindowType.LIGHTWEIGHT;
			popupOption.systemChrome = NativeWindowSystemChrome.NONE;
			popupOption.transparent = true;
				
			super(popupOption);
			
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.quality = StageQuality.BEST;
			this.alwaysInFront = true;
			this.width = POPUP_WIDTH;
			this.height = POPUP_HEIGHT;			
			
			this.visible = false;
			this.stage.addEventListener(MouseEvent.CLICK, closePopup, false, 0, true);
			
			draw();			
			updateMessage();
		}
		
		/**
		 * Draw everything!
		 */
		protected function draw():void
		{
			drawBg();
			drawText();
		}
		
		/**
		 * SHows this popup to the screen or just update
		 */
		public function showToScreen(targetScreen:Screen):void
		{
			updatePosition(targetScreen);
			updateMessage();
			
			// show fade-in animation
			startFadeIn();
		}
		
		/**
		 * Prepare before closing
		 * @param	event
		 */
		public function closePopup(event:Event = null):void
		{
			//this.visible = false;
			this.close();
			this.stage.removeEventListener(MouseEvent.CLICK, closePopup);			
		}
		
		/**
		 * SHows and update the position
		 * @param	targetScreen
		 */
		protected function updatePosition(targetScreen:Screen):void
		{
			this.visible = true;
			this.x = targetScreen.visibleBounds.right - POPUP_WIDTH - 10;
			this.y = targetScreen.visibleBounds.bottom - POPUP_HEIGHT;
		}
		
		/** Containing all stuff */
		protected var _container:Sprite;
		
		/**
		 * Draw the bg rect for container
		 */
		protected function drawBg():void
		{			
			if (_container == null)
			{
				// currently show simple rect
				_container = new Sprite();
				
				// create bg rect
				var bgRect:Sprite = new Sprite();
				var g:Graphics = bgRect.graphics;
				
				g.beginFill(0x009ee1, 0.7);
				g.drawRect(2, 2, POPUP_WIDTH - 4, POPUP_HEIGHT - 4);
				g.endFill();
				
				// add icon
				var theAsset:BitmapAsset = new ICON_BREAK();
				var theBitmap:Bitmap = new Bitmap(theAsset.bitmapData);				
				bgRect.addChild(theBitmap);
				theBitmap.x = POPUP_WIDTH - theBitmap.width - 25;
				theBitmap.y = POPUP_HEIGHT - theBitmap.height - 25;
				
				// filters?
				//bgRect.filters = [new DropShadowFilter(4, 45, 0, 0.5) ];
				
				_container.addChildAt(bgRect, 0);
			}
			
			this.stage.addChildAt(_container, 0);
		}
		
		protected var _labelTextLine1:TextLine;
		protected var _labelTextLine2:TextLine;
		
		protected var _labelTextBlock:TextBlock;
		
		protected var _labelFormat:ElementFormat;
		
		/**
		 * Draw the text with the message and time
		 */
		protected function drawText():void
		{
			if (_labelTextBlock == null)
			{
				if (_container == null)
				{
					drawBg();
				}
				
				// define font
				var fontDescription:FontDescription = new FontDescription();
				fontDescription.fontLookup = FontLookup.DEVICE;
				fontDescription.fontName = "Segoe WP Light";
				
				// define format
				_labelFormat = new ElementFormat();
				_labelFormat.fontDescription = fontDescription;
				_labelFormat.fontSize = 28;
				_labelFormat.color = 0xFFFFFF;
				
				var labelText:TextElement = new TextElement("Test\nTest", _labelFormat);
				_labelTextBlock = new TextBlock(labelText);
				_labelTextLine1 = _labelTextBlock.createTextLine(null, POPUP_WIDTH);
				_container.addChild(_labelTextLine1); 
				_labelTextLine2 = _labelTextBlock.createTextLine(_labelTextLine1, POPUP_WIDTH);
				_container.addChild(_labelTextLine2); 
				
				layoutTextLines();
			}
		}
		
		protected function layoutTextLines():void
		{
			_labelTextLine1.x = 10;
			_labelTextLine1.y = 35;			
			_labelTextLine2.x = 10;
			_labelTextLine2.y = 60;
		}
		
		/**
		 * Update the message!
		 */
		protected function updateMessage():void
		{			
			var breakMessage:String = "Take a Break!";
			
			// show current time
			var nowDate:Date = new Date();
			var minuteString:String = nowDate.minutes.toString();
			if (minuteString.length < 2)
			{
				minuteString = "0" + minuteString;
			}
			breakMessage += "\n" + nowDate.hours + ":" + minuteString;
			
			// show message
			var labelText:TextElement = new TextElement(breakMessage, _labelFormat);			
			_labelTextBlock.content = labelText;
			_labelTextBlock.recreateTextLine(_labelTextLine1, null, POPUP_WIDTH);
			_labelTextBlock.recreateTextLine(_labelTextLine2, _labelTextLine1, POPUP_WIDTH);
			
			layoutTextLines();			
		}
		
		/**
		 * Starts the fade in animation
		 */
		protected function startFadeIn():void
		{
			this.stage.addEventListener(Event.ENTER_FRAME, fadeIn, false, 0, true);
			_container.alpha = 0;
		}
		
		/**
		 * DO the fade in animation
		 * @param	event
		 */
		protected function fadeIn(event:Event = null):void
		{
			var distance:Number = 1.0 - _container.alpha;
			if (distance > 0.05)
			{
				// ease in
				_container.alpha += (distance * 0.3);
			}
			else  // stop fade in
			{
				stopFadeIn();
			}
		}
		
		protected function stopFadeIn():void
		{
			_container.alpha = 1;
			this.stage.removeEventListener(Event.ENTER_FRAME, fadeIn);
		}
	}

}