package com.fewfre.utils
{
	import com.fewfre.display.TextBase;
	import com.adobe.images.*;
	import com.adobe.images.PNGEncoder;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.net.FileReference;
	import flash.utils.getDefinitionByName;
	import flash.utils.ByteArray;
	import ext.ParentAppSystem;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.utils.setTimeout;
	
	public class FewfDisplayUtils
	{
		public static function fitWithinBounds(pObj:DisplayObject, pMaxWidth:Number, pMaxHeight:Number, pMinWidth:Number=0, pMinHeight:Number=0) : DisplayObject {
			var tRect:Rectangle = pObj.getBounds(pObj);
			var tWidth:Number = tRect.width * pObj.scaleX;
			var tHeight:Number = tRect.height * pObj.scaleY;
			var tMultiX:Number = 1;
			var tMultiY:Number = 1;
			if(tWidth > pMaxWidth) {
				tMultiX = pMaxWidth / tWidth;
			}
			else if(tWidth < pMinWidth) {
				tMultiX = pMinWidth / tWidth;
			}
			
			if(tHeight > pMaxHeight) {
				tMultiY = pMaxHeight / tHeight;
			}
			else if(tHeight < pMinHeight) {
				tMultiY = pMinHeight / tHeight;
			}
			
			var tMulti:Number = 1;
			if(tMultiX > 0 && tMultiY > 0) {
				tMulti = Math.min(tMultiX, tMultiY);
			}
			else if(tMultiX < 0 && tMultiY < 0) {
				tMulti = Math.max(tMultiX, tMultiY);
			}
			else {
				tMulti = Math.min(tMultiX, tMultiY);
			}
			
			pObj.scaleX *= tMulti;
			pObj.scaleY *= tMulti;
			return pObj;
		}
		
		public static function handleErrorMessage(e:Error) : void {
			Fewf.dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "["+e.name+":"+e.errorID+"] "+e.message));
		}
		
		public static function bitmapDataDrawBestQuality(pBitmap:BitmapData, source:IBitmapDrawable, matric:Matrix) : BitmapData {
			var defaultQuality = Fewf.stage.quality;
			Fewf.stage.quality = StageQuality.BEST;
			pBitmap.draw(source, matric, null, null, null, true);
			Fewf.stage.quality = defaultQuality;
			return pBitmap;
		}

		public static function copyToClipboard(pObj:DisplayObject, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:Rectangle = pObj.getBounds(pObj);
			var tBitmap:BitmapData = new BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:Matrix = new Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);
			tBitmap.draw(pObj, tMatrix);
			
			Clipboard.generalClipboard.setData(ClipboardFormats.BITMAP_FORMAT, tBitmap);
		}
		public static function copyToClipboardAnimatedGif(mc:MovieClip, scale:Number=1, pFinished:Function=null) {
			handleErrorMessage(new Error("Sorry, animated GIFs cannot be saved to the clipboard - please download image or disable animation to copy as a still image."));
			pFinished();
		}
		
		private static function _deviceUsesCameraRoll() : Boolean {
			try {
				var CameraRoll = ParentAppSystem.getCameraRollClass();
				return !!CameraRoll && CameraRoll.supportsAddBitmapData;
			} catch(e) {}
			return false;
		}
		
		public static function saveImageDataToDevice(data:*, pName:String, pExt:String) : void {
			try {
				var CameraRoll = ParentAppSystem.getCameraRollClass();
				if(!!CameraRoll && CameraRoll.supportsAddBitmapData) {
					if(data is Bitmap) {
						( new CameraRoll() ).addBitmapData(data);
					} else {
						handleErrorMessage(new Error("Sorry, this image type cannot be saved to mobile camera roll."));
					}
				} else {
					if(pExt == "png") {
						var bytes = PNGEncoder.encode(data);
						( new FileReference() ).save( bytes, pName+"."+pExt );
					} else {
						( new FileReference() ).save( data, pName+"."+pExt );
					}
				}
			}
			catch(e) {
				handleErrorMessage(e);
			}
		}
		public static function saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number=1) : void {
			if(!pObj){ return; }

			var tRect:Rectangle = pObj.getBounds(pObj);
			var tBitmap:BitmapData = new BitmapData(tRect.width*pScale, tRect.height*pScale, true, 0xFFFFFF);

			var tMatrix:Matrix = new Matrix(1, 0, 0, 1, -tRect.left, -tRect.top);
			tMatrix.scale(pScale, pScale);

			bitmapDataDrawBestQuality(tBitmap, pObj, tMatrix);
			
			saveImageDataToDevice(tBitmap, pName, 'png');
		}
		
		public static function convertMovieClipToSpriteSheet(mc:MovieClip, scale:Number=1, bg:int=-1) : SpritesheetData {
			var tOrigScale = mc.scaleX;
			mc.scaleX = mc.scaleY = scale;
			
			var totalFrames:int = mc.totalFrames;
			var lifetimeBounds:Rectangle = new Rectangle(), tempRect:Rectangle;
			mc.gotoAndStop(1);
			for(var i:int = 0; i < totalFrames; i++) {
				tempRect = mc.getBounds(mc);
				lifetimeBounds.top = Math.min(lifetimeBounds.top, tempRect.top);
				lifetimeBounds.left = Math.min(lifetimeBounds.left, tempRect.left);
				lifetimeBounds.bottom = Math.max(lifetimeBounds.bottom, tempRect.bottom);
				lifetimeBounds.right = Math.max(lifetimeBounds.right, tempRect.right);
				mc.nextFrame();
			}
			var rect:Rectangle = lifetimeBounds;
			
			var tWidth = Math.ceil(rect.width*scale), tHeight = Math.ceil(rect.height*scale);
			
			
			var maxSpriteWidth:Number = 1024*4;
			
			var columns:uint = totalFrames*tWidth > maxSpriteWidth ? Math.floor(maxSpriteWidth / tWidth) : totalFrames,
				rows:uint = Math.ceil(totalFrames/columns);
			var tBitmap:BitmapData = new BitmapData(tWidth*columns, tHeight*rows, bg == -1, bg >= 0 ? bg : 0xFFFFFF);
			
			var tFrameBitmap:BitmapData, tFrameMatrix:Matrix;
			mc.gotoAndStop(1);
			for(var i:int = 0; i < totalFrames; i++) {
				tFrameBitmap = new BitmapData(tWidth, tHeight, true, 0xFFFFFF);
				tFrameMatrix = new Matrix(1, 0, 0, 1, -rect.x, -rect.y);
				tFrameMatrix.scale(scale, scale);
				bitmapDataDrawBestQuality(tFrameBitmap, mc, tFrameMatrix);
				
				var tMatrix:Matrix = new Matrix(1, 0, 0, 1, (i%columns)*tWidth, Math.floor(i/columns)*tHeight);
				tMatrix.scale(1, 1);
				bitmapDataDrawBestQuality(tBitmap, tFrameBitmap, tMatrix);
			
				mc.nextFrame();
			}
			tFrameBitmap = null; tFrameMatrix = null;
			
			mc.scaleX = mc.scaleY = tOrigScale;

			return new SpritesheetData(tBitmap, tWidth, tHeight, totalFrames);
		}
		
		public static function saveAsSpriteSheet(mc:MovieClip, pName:String, scale:Number=1) {
			var sheetData = convertMovieClipToSpriteSheet(mc, scale);
			saveImageDataToDevice(sheetData.bitmapData, pName, 'png');
		}
		
		public static function saveAsAnimatedGif(mc:MovieClip, pName:String, scale:Number=1, pFormat:String=null, pFinished:Function=null) {
			if(_deviceUsesCameraRoll()) {
				handleErrorMessage(new Error("Sorry, animated GIFs cannot be saved to mobile camera roll - please use desktop app or disable animation to copy as a still image"));
				pFinished && pFinished();
				return;
			}
			_fetchGif(mc, scale, pFormat, function(data:*, error:Error){
				if(error) { handleErrorMessage(error); pFinished && pFinished(); return; }
				
				saveImageDataToDevice(data, pName, pFormat ? pFormat : 'gif');
				pFinished && pFinished();
			});
		}
		private static function _fetchGif(mc:MovieClip, scale:Number, pFormat:String, pCallback:Function) {
			var sheetData:SpritesheetData = convertMovieClipToSpriteSheet(mc, scale, -1);//pFormat && pFormat != "gif" ? -1 : 0x6A7495); // give it a bg color since gifs don't support partial opacity
			var tPNG:ByteArray = PNGEncoder.encode(sheetData.bitmapData);
			
			var url = Fewf.assets.getData("config").spritesheet2gif_url;
			if(!url) {
				handleErrorMessage(new Error("GIF generation api not found.", 1));
				return;
			}
			
			var request:URLRequest = new URLRequest(url);
			request.method = URLRequestMethod.POST;
			request.requestHeaders.push(new URLRequestHeader("enctype", "multipart/form-data"));
			
			var requestVars:URLVariables = new URLVariables();
			requestVars.sheet_base64 = ImgurApi.encodeByteArray(tPNG);
			requestVars.width = sheetData.frameWidth;
			requestVars.height = sheetData.frameHeight;
			requestVars.framescount = sheetData.framesCount;
			requestVars.delay = (1 / Fewf.stage.frameRate) * 100;
			if(pFormat) requestVars.format = pFormat;
			
			request.data = requestVars;
			
 
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlLoader.addEventListener(Event.COMPLETE, function tOnComplete(e:Event):void{
				urlLoader.removeEventListener(Event.COMPLETE, tOnComplete);
				pCallback(e.target.data, null);
			});
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e:SecurityErrorEvent){ pCallback(null, new SecurityError(e.text, e.errorID)); }, false, 0, true);
			var status:int = 500;
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent):void{
				trace('status', e, e.target);
				status = e.status;
			}, false, 0, true);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent){
				pCallback(null, new Error("[HTTP Error] "+(e.target.data || "Error connecting to GIF api - make sure internet is connected"), status));
			}, false, 0, true);

			try {
				urlLoader.load(request);
			} catch (e:Error) { pCallback(null, e); }
		}
	}
}

class SpritesheetData {
	public var bitmapData: *;
	public var frameWidth: Number;
	public var frameHeight: Number;
	public var framesCount: uint;
	public function SpritesheetData(bitmapData: *, frameWidth: Number, frameHeight: Number, framesCount: uint) {
		this.bitmapData = bitmapData; this.frameWidth = frameWidth; this.frameHeight = frameHeight; this.framesCount = framesCount;
	}
}