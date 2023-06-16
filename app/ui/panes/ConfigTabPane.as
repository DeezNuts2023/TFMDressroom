package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.AssetManager;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.ui.screens.LoaderDisplay;
	import app.ui.screens.LoadingSpinner;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormatAlign;
	import flash.display.MovieClip;
	import app.world.data.ItemData;
	
	public class ConfigTabPane extends TabPane
	{
		public var userOutfitsGrid		: Grid;
		public var usernameInput		: FancyInput;
		public var usernameErrorText	: TextBase;
		public var onUserLookClicked	: Function;
		public var _loadingUser			: Boolean;
		
		public function ConfigTabPane(pData:Object) {
			super();
			onUserLookClicked = pData.onUserLookClicked;
			_loadingUser = false;
			
			var i:int = 0, xx:Number = 0, yy:Number = 5, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			xx = 10; yy += 14; sizex = ConstantsApp.PANE_WIDTH - 20 - 15;
			addItem(new PasteShareCodeInput({ x:xx + sizex*0.5, y:yy, width:sizex, onChange:pData.onShareCodeEntered }));
			yy += 14;
			
			if(Fewf.assets.getData("config").username_lookup_url) {
				yy += 16;
				addItem( GameAssets.createHorizontalRule(5, yy, ConstantsApp.PANE_WIDTH - 15 - 10) );
				yy += 16;
				
				sizey = 20;
				xx = 10-2; yy += sizey*0.5;
				addItem(new TextBase({ text:"user_lookup_title", x:xx, y:yy-3, originX:0, size:14 }));
				yy += sizey*0.5 + 3;
				
				sizex = sizey = 18+10; spacingx = 10;
				xx = 10; yy += sizey*0.5;
				
				var fieldWidth = ConstantsApp.PANE_WIDTH*0.65 - spacingx*3 - sizex;
				usernameInput = addItem(new FancyInput({ placeholder:"user_lookup_placeholder", x:xx + fieldWidth*0.5, y:yy, width:fieldWidth, height:sizey-10 })) as FancyInput;
				usernameInput.field.addEventListener(KeyboardEvent.KEY_DOWN, function(pEvent){
					if(usernameInput.text != "" && pEvent.charCode == 13) {
						_onFetchUserLooks(null);
					}
				});
				
				var looksGoBtn = addItem(new SpriteButton({ x:xx+fieldWidth + spacingx + sizex*0.5, y:yy, width:sizex, height:sizey, obj:new $PlayButton(), obj_scale:0.5, origin:0.5 }));
				looksGoBtn.addEventListener(MouseEvent.CLICK, _onFetchUserLooks);
				
				yy += sizey*0.5 + 10;
				userOutfitsGrid = addItem( new Grid(ConstantsApp.PANE_WIDTH - spacingx*2 - 5, 6).setXY(xx-2,yy) ) as Grid;
				
				yy += 2;
				usernameErrorText = addChild(new TextBase({ text:"user_lookup_details", color:0xAAAAAA, x:xx-2, y:yy, originX:0, originY:0, align:TextFormatAlign.LEFT })) as TextBase;
			}
			
			UpdatePane();
		}
		
		private function _addTextField(pData) : TextField {
			var tTFWidth:Number = pData.width, tTFHeight:Number = pData.height, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = addItem(new RoundedRectangle({ x:pData.x, y:pData.y, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })) as RoundedRectangle;
			tTextBackground.draw(0xdcdfea, 7, 0x444444);
			
			var tTextField = tTextBackground.addChild(new TextField()) as TextField;
			tTextField.type = TextFieldType.INPUT;
			tTextField.multiline = false;
			tTextField.width = tTFWidth;
			tTextField.height = tTFHeight;
			tTextField.x = tTFPaddingX - tTextBackground.Width*0.5;
			tTextField.y = tTFPaddingY - tTextBackground.Height*0.5;
			
			return tTextField;
		}
		
		public function addLook(lookCode:String) {
			var grid:Grid = this.userOutfitsGrid;
			var character:Character = new Character(new <ItemData>[ GameAssets.defaultPose ], lookCode, true);
			var btn = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:character });
			btn.addEventListener(MouseEvent.CLICK, function(){
				onUserLookClicked(lookCode);
				btn.toggleOff();
			});
			grid.add(btn);
		}
		
		private function _onFetchUserLooks(pEvent) : void {
			if(usernameInput.text == "" || _loadingUser) { return; }
			userOutfitsGrid.reset();
			if(usernameErrorText) {
				removeChild(usernameErrorText);
				usernameErrorText = null;
			}
			var tLoaderDisplay = addChild( new LoadingSpinner({ x:5+ConstantsApp.PANE_WIDTH*0.5, y:userOutfitsGrid.y+50 }) );
			
			if(usernameInput.text.indexOf("#") == -1) {
				usernameInput.text += "#0000";
			}
			var username:String = usernameInput.text.replace("#", "%23");
			
			var url = Fewf.assets.getData("config").username_lookup_url.replace("$1", username);
			_loadingUser = true;
			Fewf.assets.load([
				[ url+"&cb="+String( new Date().getTime() ), { type:"json" } ],
			]);
			Fewf.assets.addEventListener(AssetManager.LOADING_FINISHED, function(e:Event){
				_loadingUser = false;
				Fewf.assets.removeEventListener(AssetManager.LOADING_FINISHED, arguments.callee);
				tLoaderDisplay.destroy();
				removeChild( tLoaderDisplay );
				tLoaderDisplay = null;
				
				var data = Fewf.assets.getData("fetchlooknickname");
				if(!data) {
					_setFetchUserError("##Unknown Error");
				} else if(data.error) {
					_setFetchUserError(data.error);
				} else {
					_parseUser(data);
				}
			});
		}
		
		private function _setFetchUserError(message:String) {
			usernameErrorText = addChild(new TextBase({ color:0xFF0000, x:5+ConstantsApp.PANE_WIDTH*0.5, y:userOutfitsGrid.y+25 })) as TextBase;
			usernameErrorText.setUntranslatedText(message);
		}
		
		private function _parseUser(pData:Object) {
			var looks:Array = pData.looks;
			
			for(var i:int = 0; i < looks.length; i++) {
				var look = looks[i];
				addLook(look);
			}
			
			UpdatePane();
		}
	}
}
