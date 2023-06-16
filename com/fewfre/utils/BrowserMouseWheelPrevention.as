package com.fewfre.utils
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	
	public class BrowserMouseWheelPrevention
	{
		static private var initialised:Boolean = false;
		static private var currentItem:InteractiveObject;
		static private var browserMouseEvent:MouseEvent;
		static private var lastEventTime:uint = 0;
		static private var nativeStage:Stage;
		
		static public var useRawValues:Boolean = false;
		static public var eventTimeout:Number = 50;
		
		public static function init(pStage:Stage):void {
			if(initialised) { return; }
			initialised = true;
			
			nativeStage = pStage;
			_registerListenerForMouseMove();
			_registerJS();
		}
		
		private static function _registerListenerForMouseMove() : void {
			nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent ):void {
				currentItem = InteractiveObject( e.target );
				browserMouseEvent = MouseEvent( e );
			});
		}
		
		private static function _registerJS() : void {
			if( ExternalInterface.available ) {
				var id:String = 'mws_' + Math.floor(Math.random()*1000000);
				ExternalInterface.addCallback(id, function():void{});
				ExternalInterface.call(JAVASCRIPT_CODE);
				ExternalInterface.call("mws.InitMouseWheelSupport", id);
				ExternalInterface.addCallback('externalMouseEvent', _handleExternalMouseEvent);
			}
		}
		
		private static function _handleExternalMouseEvent(rawDelta:Number, scaledDelta:*):void {
			var curTime:uint = getTimer();
			if (curTime >= eventTimeout + lastEventTime) {
				var delta:Number = int(useRawValues ? rawDelta : scaledDelta);
				
				nativeStage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false, nativeStage.mouseX, nativeStage.mouseY, null, false, false, false, false, delta));
				if(currentItem && browserMouseEvent) {
					currentItem.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_WHEEL, true, false,
						browserMouseEvent.localX, browserMouseEvent.localY, browserMouseEvent.relatedObject,
						browserMouseEvent.ctrlKey, browserMouseEvent.altKey, browserMouseEvent.shiftKey, browserMouseEvent.buttonDown,
						delta));
				}
				
				lastEventTime = curTime;
			}
		}
		
		private static const JAVASCRIPT_CODE : XML =
		<script><![CDATA[//]
			function() {
				window.mws = {};
				
				mws.InitMouseWheelSupport = function(id) {
					var swf = mws.findSwf(id);
					if(!swf) { return; }
					mws.id = id;
					
					swf.onmouseover = mws.addScrollListeners;
					swf.onmouseout = mws.removeScrollListeners;
				}
				
				mws.findSwf = function(id) {
					var data = document.querySelectorAll("object, embed");
					for(var i = 0; i < data.length; i++) {
						if(typeof data[i][id] != "undefined") {
							return data[i];
						}
					}
					return null;
				}
				
				mws.addScrollListeners = function() {
					window.addEventListener('DOMMouseScroll', mws.onScroll, false);
					window.addEventListener('wheel', mws.onScroll, false);
					window.onmousewheel = document.onmousewheel = mws.onScroll;
				}
				
				mws.removeScrollListeners = function() {
					window.removeEventListener('DOMMouseScroll', mws.onScroll, false);
					window.removeEventListener('wheel', mws.onScroll, false);
					window.onmousewheel = document.onmousewheel = null;
				}
				
				mws.onScroll = function(event) {
					if (!event) event = window.event;
					var swf = mws.findSwf(mws.id);
					
					var rawDelta = 0, divisor = 30, scaledDelta = 0;
					
					if(event.deltaY) {
						rawDelta = -event.deltaY;
					} else if(event.wheelDelta) {
						rawDelta = event.wheelDelta;
					}
					scaledDelta = Math.abs(rawDelta) >= divisor ? rawDelta/divisor : rawDelta;
					
					swf.externalMouseEvent(rawDelta, scaledDelta);
					
					if(event.preventDefault) {
						event.preventDefault();
					} else {
						return false;
					}
					return true;
				}
			}
		]]></script>;
	}
}
