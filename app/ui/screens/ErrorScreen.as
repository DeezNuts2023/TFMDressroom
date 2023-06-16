package app.ui.screens
{
	import app.data.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.world.data.*;
	import com.adobe.images.*;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;
	import flash.display.*;
	import flash.events.*;
	
	public class ErrorScreen extends MovieClip
	{
		private var _tray			: RoundedRectangle;
		private var _text			: TextBase;
		private var _string			: String;
		
		public function ErrorScreen() {
			this.x = Fewf.stage.stageWidth * 0.5;
			this.y = Fewf.stage.stageHeight * 0.5;
			
			var tClickTray = addChild(new Sprite());
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			var tWidth:Number = 500, tHeight:Number = 200;
			_tray = new RoundedRectangle({ width:tWidth, height:tHeight, origin:0.5 }).appendTo(this).draw(0xFFDDDD, 25, 0xFF0000);

			_text = new TextBase({ color:0x330000, originX:0, originY:0.5, x:-(_tray.Width - 20) / 2 });
			_text.field.width = _tray.Width - 20;
			_text.field.wordWrap = true;
			addChild(_text);
			
			var tCloseIcon = new MovieClip();
			var tSize:Number = 10;
			tCloseIcon.graphics.beginFill(0x000000, 0);
			tCloseIcon.graphics.drawRect(-tSize*2, -tSize*2, tSize*4, tSize*4);
			tCloseIcon.graphics.endFill();
			tCloseIcon.graphics.lineStyle(8, 0xFFFFFF, 1, true);
			tCloseIcon.graphics.moveTo(-tSize, -tSize);
			tCloseIcon.graphics.lineTo(tSize, tSize);
			tCloseIcon.graphics.moveTo(tSize, -tSize);
			tCloseIcon.graphics.lineTo(-tSize, tSize);
			
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:tCloseIcon })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
		}
		
		public function open(errorText:String) : void {
			if(_string) {
				errorText = _string+"\n\n"+errorText;
			}
			_text.setUntranslatedText(_string = errorText);
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			_close();
		}
		
		private function _close() : void {
			_text.setUntranslatedText(_string = "");
			dispatchEvent(new Event(Event.CLOSE));
		}
	}
}
