package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import app.world.data.ItemData;
	
	public class OtherTabPane extends TabPane
	{
		public var character:Character;
		
		public var button_hand		: PushButton;
		public var button_back		: PushButton;
		public var button_backHand	: PushButton;
		
		public var shamanButtons	: Vector.<PushButton>;
		public var shamanColorPickerButton	: ScaleButton;
		public var shamanColorBlueButton	: ColorButton;
		public var shamanColorPinkButton	: ColorButton;
		
		public var characterHead	: Character;
		public var webpButton		: GameButton;
		public var outfitsButton	: SpriteButton;
		
		public function OtherTabPane(pCharacter:Character) {
			super();
			character = pCharacter;
			
			var i:int = 0, xx:Number = 15, yy:Number = 15, tButton:GameButton, sizex:Number, sizey:Number, spacingx:Number;
			
			sizex = 80; sizey = 50; spacingx = sizex + 10; xx = 5 - spacingx;
			
			shamanButtons = new Vector.<PushButton>();
			var icon = addItem(new $ShamFeather()); icon.x = (xx += spacingx) + sizex*0.5; icon.y = yy + sizey*0.5; icon.scaleX = icon.scaleY = 2;
			icon.addEventListener(MouseEvent.CLICK, _onNoShamanButtonClicked);
			xx -= 5;
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_normal_mode", text:"Normal" }), id:ShamanMode.NORMAL.toInt() })) as PushButton);
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_hard_mode", text:"Hard" }), id:ShamanMode.HARD.toInt() })) as PushButton);
			shamanButtons.push(tButton = addItem(new PushButton({ x:xx += spacingx, y:yy, width:sizex, height:sizey, obj:new TextBase({ text:"btn_divine_mode", text:"Divine" }), id:ShamanMode.DIVINE.toInt() })) as PushButton);
			if(character.shamanMode != ShamanMode.OFF) {
				shamanButtons[character.shamanMode.toInt()-2].toggleOn();
			}
			_registerClickHandler(shamanButtons, _onShamanButtonClicked);
			
			addItem( shamanColorPickerButton = new ScaleButton({ x:xx += spacingx + 30, y:yy + sizey*0.5 - 10, obj:new $ColorWheel() }) );
			
			sizex = 26; sizey = 18;
			
			addItem( shamanColorBlueButton = new ColorButton({ color:0x95D9D6, x:xx - (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }) );
			addItem( shamanColorPinkButton = new ColorButton({ color:0xFCA6F1, x:xx + (sizex*0.5+3), y:yy + sizey*0.5 + 35, width:sizex, height:sizey }) );
			yy += 50 + 10;
			addChild( GameAssets.createHorizontalRule(5, yy, ConstantsApp.PANE_WIDTH - 10) );
			
			yy += 15; xx = 15;
			var grid:Grid = this.addItem( new Grid(385, 5).setXY(xx,yy) ) as Grid;

			this.button_hand = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:new GameAssets.extraObjectWand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_hand);
			if(character.getItemData(ItemType.OBJECT)) { this.button_hand.toggleOn(); }
			
			this.button_back = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:new GameAssets.extraFromage.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_back);
			if(character.getItemData(ItemType.BACK)) { this.button_back.toggleOn(); }
			
			this.button_backHand = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:new GameAssets.extraBackHand.itemClass(), obj_scale:1.5, id:i++ });
			grid.add(this.button_backHand);
			if(character.getItemData(ItemType.PAW_BACK)) { this.button_backHand.toggleOn(); }
			
			characterHead = new Character(new <ItemData>[ GameAssets.defaultSkin, GameAssets.defaultPose ]);
			var saveHeadButton = addItem(new GameButton({ x:348, y:310, width:70, height:70 }));
			saveHeadButton.addChild(characterHead);
			saveHeadButton.addEventListener(MouseEvent.CLICK, _onSaveMouseHeadClicked);
			
			if(ConstantsApp.ANIMATION_DOWNLOAD_ENABLED) {
				webpButton = addItem(new GameButton({ x:348-70-5, y:310, width:70, height:70 })) as GameButton;
				var webpText:TextBase = new TextBase({ x:35, y:35, origin:0.5, size:16 });
				webpText.setUntranslatedText('.webp');
				webpButton.addChild(webpText);
				webpButton.addEventListener(MouseEvent.CLICK, _onSaveAsWebpClicked);
			}
			
			outfitsButton = addItem(new SpriteButton({ x:15, y:310, width:70, height:70, obj:new $Outfit(), obj_scale:0.85 })) as SpriteButton;
			
			UpdatePane();
		}
		
		
		public override function open() : void {
			super.open();
			
			_updateHead();
		}
		
		private function _colorSpriteBox(pData:Object) : Sprite {
			var tBox:Sprite = pData.box ? pData.box : new Sprite();
			var tSize:Number = pData.size ? pData.size : 20;
			tBox.graphics.beginFill(pData.color, 1);
			tBox.graphics.drawRect(0, 0, tSize, tSize);
			tBox.graphics.endFill();
			if(pData.x) tBox.x = pData.x;
			if(pData.y) tBox.y = pData.y;
			return tBox;
		}
		
		private function _updateHead() {
			for each(var tItemType in ItemType.LAYERING) {
				var data = character.getItemData(tItemType);
				if(data) characterHead.setItemData( data ); else characterHead.removeItem( tItemType );
			}
			characterHead.setItemData( character.getItemData(ItemType.POSE) );
			characterHead.scale = 1;
			
			var pose = characterHead.outfit.pose;
			var partsToKeep:Array = ["Tete_", "Oeil_", "OeilVide_", "Oeil2_", "Oeil3_", "Oeil4_", "OreilleD_", "OreilleG_"];
			var tChild:DisplayObject = null;
			for(var i:int = pose.numChildren-1; i >= 0; i--) {
				tChild = pose.getChildAt(i);
				
				if(tChild.name && !partsToKeep.some(function(partName){ return tChild.name.indexOf(partName) == 0 })) {
					pose.removeChildAt(i);
				}
			}
			
			var btnSize = 70, size = 60;
			var tBounds = characterHead.getBounds(characterHead);
			var tOffset = tBounds.topLeft;
			FewfDisplayUtils.fitWithinBounds(characterHead, size, size, size, size);
			characterHead.x = btnSize / 2 - (tBounds.width / 2 + tOffset.x) * characterHead.scaleX;
			characterHead.y = btnSize / 2 - (tBounds.height / 2 + tOffset.y) * characterHead.scaleY;
		
		}
		
		private function _registerClickHandler(pList:Vector.<PushButton>, pCallback:Function) : void {
			for(var i:int = 0; i < pList.length; i++) {
				pList[i].addEventListener(PushButton.STATE_CHANGED_BEFORE, pCallback);
			}
		}
		
		private function _onShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons, pEvent.target as PushButton);
			character.shamanMode = ShamanMode.fromInt(pEvent.target.id);
			if(pEvent.target.pushed) {
				character.shamanMode = ShamanMode.OFF;
			}
			character.updatePose();
			_updateHead();
		}
		
		private function _onNoShamanButtonClicked(pEvent:Event) {
			_untoggle(shamanButtons);
			character.shamanMode = ShamanMode.OFF;
			character.updatePose();
			_updateHead();
		}

		private function _untoggle(pList:Vector.<PushButton>, pButton:PushButton=null) : void {

			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pButton) {
					pList[i].toggleOff();
				}
			}
			_updateHead();
		}
		
		public function updateButtonsBasedOnCurrentData() : void {
			for(var i:int = 0; i < shamanButtons.length; i++) {
				shamanButtons[i].toggleOff();
			}
			if(character.shamanMode != ShamanMode.OFF) {
				shamanButtons[character.shamanMode.toInt()-2].toggleOn(false);
			}
			
			button_hand.toggle(!!character.getItemData(ItemType.OBJECT), false);
			button_back.toggle(!!character.getItemData(ItemType.BACK), false);
			button_backHand.toggle(!!character.getItemData(ItemType.PAW_BACK), false);
			_updateHead();
		}
		
		private function _onSaveMouseHeadClicked(pEvent:Event) {
			FewfDisplayUtils.saveAsPNG(characterHead, 'mouse_head', character.outfit.scaleX);
		}
		
		private function _onSaveAsWebpClicked(e:Event) {
			webpButton.disable();
			FewfDisplayUtils.saveAsAnimatedGif(character.copy().outfit.pose, "character", this.character.outfit.scaleX, "webp", function(){
				webpButton.enable();
			});
		}
	}
}
