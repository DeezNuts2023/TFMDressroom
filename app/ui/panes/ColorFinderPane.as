package app.ui.panes
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import ext.ParentApp;
	
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	
	public class ColorFinderPane extends TabPane
	{
		public static const EVENT_SWATCH_CHANGED	: String = "event_swatch_changed";
		public static const EVENT_DEFAULT_CLICKED	: String = "event_default_clicked";
		public static const EVENT_COLOR_PICKED		: String = "event_color_picked";
		public static const EVENT_EXIT				: String = "event_exit";
		
		private var _tray : MovieClip;
		private var _stageBitmap : BitmapData;
		private var _itemCont : MovieClip;
		private var _itemDragDrop : MovieClip;
		private var _item : MovieClip;
		private var _text : TextField;
		private var _textColorBox : RoundedRectangle;
		private var _hoverText : TextField;
		private var _hoverColorBox : RoundedRectangle;
		private var _recentColorsDisplay : RecentColorsListDisplay;
		private var _scaleSlider : FancySlider;
		
		private var _dragging : Boolean = false;
		private var _ignoreNextColorClick : Boolean = false;
		private var _dragStartMouseX : Boolean;
		private var _dragStartMouseY : Boolean;
		
		private const _bitmapData:BitmapData = new BitmapData(1, 1);
		private const _matrix:Matrix = new Matrix();
		private const _clipRect:Rectangle = new Rectangle(0, 0, 1, 1);
		
		public function ColorFinderPane(pData:Object)
		{
			super();
			this.addInfoBar( new ShopInfoBar({ showBackButton:true }) );
			this.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, _onBackClicked);
			this.UpdatePane(false);
			
			_tray = addChild(new MovieClip()) as MovieClip;
			_tray.x = ConstantsApp.PANE_WIDTH * 0.5;
			_tray.y = 50 + (275 * 0.5);
			
			_stageBitmap = new BitmapData(Fewf.stage.stageWidth, Fewf.stage.stageHeight);
			
			_itemCont = new MovieClip();
			_itemCont.x = _tray.x;
			_itemCont.y = _tray.y - 35;
			_itemCont.addEventListener(MouseEvent.CLICK, _onItemClicked);
			_itemCont.addEventListener(MouseEvent.MOUSE_MOVE, _onItemHoveredOver);
			_itemCont.addEventListener(MouseEvent.MOUSE_OUT, _onItemMouseOut);
			addItem(_itemCont);
			_scrollPane.horizontalScrollPolicy = "off";
			_scrollPane.verticalScrollPolicy = "off";
			contentBack.graphics.clear();
			contentBack.graphics.beginFill(0, 0);
			contentBack.graphics.drawRect(0, 0, _scrollPane.width, _scrollPane.height);
			contentBack.graphics.endFill();
			
			_itemDragDrop = _itemCont.addChild(new MovieClip()) as MovieClip;
			_itemDragDrop.buttonMode = true;
			_itemDragDrop.addEventListener(MouseEvent.MOUSE_DOWN, function () {
				_dragging = true;
				_ignoreNextColorClick = false;
				_itemDragDrop.startDrag();
			});
			_itemDragDrop.addEventListener(MouseEvent.MOUSE_UP, function () { _dragging = false; _itemDragDrop.stopDrag(); });
			
			_item = _itemDragDrop.addChild(new MovieClip()) as MovieClip;
			
			var tSliderWidth = ConstantsApp.PANE_WIDTH * 0.4;
			_scaleSlider = new FancySlider(tSliderWidth)
				.setXY(-tSliderWidth*0.5, -110)
				.setSliderParams(1, 5, 1)
				.appendTo(_tray);
			_scaleSlider.addEventListener(FancySlider.CHANGE, _onSliderChange);
			
			this.contentBack.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			_itemCont.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			
			_recentColorsDisplay = new RecentColorsListDisplay({ x:ConstantsApp.PANE_WIDTH/2, y:316+60+17 });
			addChild(_recentColorsDisplay);
			
			var tTFWidth:Number = 65, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = new RoundedRectangle({ x:15, y:170, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })
				.appendTo(_tray).draw(0xFFFFFF, 7, 0x444444);
			
			_text = tTextBackground.addChild(new TextField()) as TextField;
			_text.type = TextFieldType.DYNAMIC;
			_text.multiline = false;
			_text.width = tTFWidth;
			_text.height = tTFHeight;
			_text.x = tTFPaddingX - tTextBackground.Width*0.5;
			_text.y = tTFPaddingY - tTextBackground.Height*0.5;
			_text.addEventListener(MouseEvent.CLICK, function(pEvent:Event){ _text.setSelection(0, _text.text.length); });
			
			var tSize = tTextBackground.Height;
			_textColorBox = _tray.addChild(new RoundedRectangle({
				x:tTextBackground.x - (tTextBackground.Width*0.5) - (tSize*0.5) - 5,
				y:tTextBackground.y, width: tSize, height: tSize, origin:0.5
			})) as RoundedRectangle;
			
			_hoverColorBox = _tray.addChild(new RoundedRectangle({
				width:35, height:35, originX:0, originY:1
			})) as RoundedRectangle;
			_hoverColorBox.visible = false;
			_setColorText(-1);
			_setHoverColor(-1);
			
			var fileRef : FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(){ fileRef.load(); });
			fileRef.addEventListener(Event.COMPLETE, _onFileSelect);
			
			var selectImageBtn = new ScaleButton({ x:ConstantsApp.PANE_WIDTH*0.5 - 30, y: -_tray.y + 60 + 20, obj:new $Folder(), obj_scale:1 });
			selectImageBtn.addEventListener(ButtonBase.CLICK, function(){
				fileRef.browse([new FileFilter("Images", "*.jpg;*.jpeg;*.gif;*.png")]);
			});
			_tray.addChild(selectImageBtn);
		}
		
		public override function open() : void {
			super.open();
			_recentColorsDisplay.render();
		}
		
		public function setItem(pObj:DisplayObject) : void {
			_setColorText(-1);
			_setHoverColor(-1);
			_itemDragDrop.removeChild(_item);
			_itemDragDrop.stopDrag(); _dragging = false; _ignoreNextColorClick = false;
			_item = _itemDragDrop.addChild(pObj) as MovieClip;
			_item.scaleX = _item.scaleY = 5;
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = 1;
			_scaleSlider.value = 1;
			_itemDragDrop.x = _itemDragDrop.y = 0;
			_item.mouseChildren = false;
			_item.mouseEnabled = false;
			
			var tPadding = 15, tBoundsWidth = ConstantsApp.PANE_WIDTH-(tPadding*2), tBoundsHeight = 250-(tPadding*2);
			FewfDisplayUtils.fitWithinBounds(_item, tBoundsWidth, tBoundsHeight, tBoundsWidth*0.7, tBoundsHeight*0.7);
			_centerImageOrigin(pObj);
			_stageBitmap.draw(Fewf.stage);
		}
		private function _centerImageOrigin(pImage:DisplayObject, pX:Number=0, pY:Number=0) : DisplayObject {
			var tBounds:Rectangle = pImage.getBounds(pImage);
			var tOffset:Point = tBounds.topLeft;
			pImage.x = pX - (tBounds.width / 2 + tOffset.x) * pImage.scaleX;
			pImage.y = pY - (tBounds.height / 2 + tOffset.y) * pImage.scaleY;
			return pImage;
		}
		
		public function setItemFromUrl(url:String) : void {
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				e.target.content.x = -e.target.content.width*0.5;
				e.target.content.y = -e.target.content.height*0.5;
				var mc = new MovieClip();
				mc.addChild(e.target.content);
				setItem(mc);
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
				setItem(new $No());
			});
		}
		
		private function _setColorText(pColor:int) : void {
			if(pColor != -1) {
				_text.text = FewfUtils.lpad(pColor.toString(16).toUpperCase(), 6, "0");
				_textColorBox.draw(pColor, 7, 0x444444);
				_recentColorsDisplay.addColor(pColor);
			} else {
				_text.text = "000000";
				_textColorBox.draw(0x000000, 7, 0x444444);
			}
		}
		
		private function _setHoverColor(pColor:int) : void {
			if(pColor != -1) {
				_hoverColorBox.draw(pColor, 7, 0x444444);
			} else {
				_hoverColorBox.draw(0x000000, 7, 0x444444);
			}
		}
		
		private function _getColorAtMouseLocation() : uint {
			return _getColorFromSpriteAtLocation(_itemDragDrop, _itemDragDrop.mouseX, _itemDragDrop.mouseY);
		}
		private function _getColorFromSpriteAtLocation(pDrawable:IBitmapDrawable, pX:Number, pY:Number) : uint {
			_matrix.setTo(1, 0, 0, 1, -pX, -pY)
			_bitmapData.draw(pDrawable, _matrix, null, null, _clipRect);
			return _bitmapData.getPixel(0, 0);
		}
		
		private function _onItemClicked(e:Event) : void {
			if(!_flagOpen) { return; }
			if(!_ignoreNextColorClick) {
				_setColorText(_getColorAtMouseLocation());
				_ignoreNextColorClick = false;
			}
		}
		
		private function _onItemHoveredOver(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = true;
			_setHoverColor(_getColorAtMouseLocation());
			_hoverColorBox.x = _tray.mouseX;
			_hoverColorBox.y = _tray.mouseY;
			
			if(_dragging) {
				_ignoreNextColorClick = true;
			}
		}
		
		private function _onItemMouseOut(e:Event) : void {
			if(!_flagOpen) { return; }
			_hoverColorBox.visible = false;
		}
		
		private function _onBackClicked(e:Event) : void {
			dispatchEvent(new Event(EVENT_EXIT));
		}
		
		private function _onSliderChange(e:Event) : void {
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = _scaleSlider.value;
			_centerImageOrigin(_item);
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			_scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
			_itemDragDrop.scaleX = _itemDragDrop.scaleY = _scaleSlider.value;
		}
		
		private function _onFileSelect(e:Event) : void {
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void{
				e.target.content.x = -e.target.content.width*0.5;
				e.target.content.y = -e.target.content.height*0.5;
				var mc = new MovieClip();
				mc.addChild(e.target.content);
				try {
					setItem(mc);
				} catch(e) {
					setItem(new $No());
				}
			});
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void{
				setItem(new $No());
			});
			loader.loadBytes(e.target.data);
		}
	}
}
