package app.ui.buttons
{
	import com.fewfre.display.ButtonBase;
	import app.data.ConstantsApp;
	import app.ui.common.RoundedRectangle;
	
	public class GameButton extends ButtonBase
	{
		protected var _bg			: RoundedRectangle;
		
		public function get Width():Number { return _bg.Width; }
		public function get Height():Number { return _bg.Height; }
		
		public function GameButton(pData:Object)
		{
			_bg = addChild(new RoundedRectangle({ x:0, y:0, width:pData.width, height:pData.height, origin:pData.origin, originX:pData.originX, originY:pData.originY })) as RoundedRectangle;
			super(pData);
		}

		override protected function _renderUp() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_BLUE, 7, ConstantsApp.COLOR_BUTTON_OUTSET_TOP, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE);
		}
		
		override protected function _renderDown() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_DOWN);
		}
		
		override protected function _renderOver() : void {
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_OVER, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, ConstantsApp.COLOR_BUTTON_MOUSE_OVER);
		}
		
		override protected function _renderOut() : void {
			_renderUp();
		}
		
		override protected function _renderDisabled() : void {
			_bg.draw(0x555555, 7, ConstantsApp.COLOR_BUTTON_OUTSET_BOTTOM, ConstantsApp.COLOR_BUTTON_BLUE, 0x555555);
		}
	}
}
