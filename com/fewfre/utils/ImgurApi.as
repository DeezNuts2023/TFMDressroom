package com.fewfre.utils
{
	import com.adobe.images.PNGEncoder;
	import com.fewfre.utils.Fewf;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import flash.external.ExternalInterface;

	public class ImgurApi
	{
		public static const EVENT_DONE			: String = "ImgurApi:done";
		private static const _CLIENT_ID			: String = "c62a11c2af9173b";
		private static var _flagInited			: Boolean = false;
		
		public static function uploadImage(pObj:DisplayObject) : void {
			if( !ExternalInterface.available ) { return; }
			if(!_flagInited) { _init(); }
			
			var uri:String = _convertDisplayObjectToURI(pObj);
			_sendDataToApi(uri);
		}
		
		private static function _init() : void {
			_flagInited = true;
			if( ExternalInterface.available ) {
				var id:String = 'as3imgurapi_' + Math.floor(Math.random()*1000000);
				ExternalInterface.addCallback(id, function():void{});
				ExternalInterface.call(JAVASCRIPT_CODE);
				ExternalInterface.call("as3imgurapi.init", id);
				ExternalInterface.addCallback('imgurApiSuccess', _onAjaxSuccess);
			}
		}
		
		private static function _convertDisplayObjectToURI(pObj:DisplayObject) : String {
			var tRect:Rectangle = pObj.getBounds(pObj);
			var bmd:BitmapData = new BitmapData(tRect.width, tRect.height, true, 0xFFFFFF);
			var tMatrix:flash.geom.Matrix = new flash.geom.Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			bmd.draw(pObj, tMatrix);
			var ba:ByteArray = PNGEncoder.encode(bmd);
			var uri:String = encodeByteArray(ba);
			return uri;
		}
		
		private static function _sendDataToApi(pImage:String) : void {
			ExternalInterface.call("as3imgurapi.ajax", {
				"url": "https://api.imgur.com/3/image",
				"method": "POST",
				"headers": {
					"authorization": "Client-ID "+_CLIENT_ID
				},
				"data": {
					"image": pImage
				}
			});
		}
		
		private static function _onAjaxSuccess(pData:Object) : void {
			navigateToURL(new URLRequest(pData.data.link), "_blank");
			Fewf.dispatcher.dispatchEvent(new Event(EVENT_DONE));
		}
		
		private static const JAVASCRIPT_CODE : XML =
		<script><![CDATA[//]
			function() {
				window.as3imgurapi = {
					id: null,
					swf: null,
					
					init: function(pID){
						as3imgurapi.id = pID;
						var data = document.querySelectorAll("object, embed");
						for(var i = 0; i < data.length; i++) {
							if(typeof data[i][as3imgurapi.id] != "undefined") {
								as3imgurapi.swf = data[i];
								break;
							}
						}
					},
					
					ajax: function(pSettings){
						var fd = new FormData();
						as3imgurapi._objForEach(pSettings.data||{}, function(pVal, pKey){
							fd.append(pKey, pVal);
						});
						var xhr = new XMLHttpRequest();
						xhr.open(pSettings.method, pSettings.url, true);
						as3imgurapi._objForEach(pSettings.headers||{}, function(pVal, pKey){
							xhr.setRequestHeader(pKey, pVal);
						});
						xhr.onreadystatechange = function(){
							if (xhr.readyState === 4) {
								if (xhr.status === 200) {
									as3imgurapi._doSuccess(JSON.parse(xhr.responseText), xhr);
								} else {
									as3imgurapi._doFail(JSON.parse(xhr.responseText), xhr);
								}
							}
						};
						xhr.send(fd);
					},
					
					_doSuccess: function(pData, pXhr){
						as3imgurapi.swf.imgurApiSuccess(pData);
					},
					

					_objForEach: function(pObj, pCallback) {
						for (var key in pObj) {
							if (pObj.hasOwnProperty(key)) {
								pCallback(pObj[key], key, pObj);
							}
						}
					},
				};

			}
		]]></script>;

		private static const ENCODE_CHARS : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		public static function encodeByteArray(bytes:ByteArray):String{
			var encodeChars:Array = ENCODE_CHARS.split("");
			var out:Array = [];
			var i:int = 0;
			var j:int = 0;
			var r:int = bytes.length % 3;
			var len:int = bytes.length - r;
			var c:int;
			while (i < len) {
				c = bytes[i++] << 16 | bytes[i++] << 8 | bytes[i++];
				out[j++] = encodeChars[c >> 18] + encodeChars[c >> 12 & 0x3f] + encodeChars[c >> 6 & 0x3f] + encodeChars[c & 0x3f];
			}
			if (r == 1) {
				c = bytes[i++];
				out[j++] = encodeChars[c >> 2] + encodeChars[(c & 0x03) << 4] + "==";
			}
			else if (r == 2) {
				c = bytes[i++] << 8 | bytes[i++];
				out[j++] = encodeChars[c >> 10] + encodeChars[c >> 4 & 0x3f] + encodeChars[(c & 0x0f) << 2] + "=";
			}
			return out.join('');
		}
	}
}
