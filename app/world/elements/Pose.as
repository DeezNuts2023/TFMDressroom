package app.world.elements
{
	import com.fewfre.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.geom.*;
	
	public class Pose extends MovieClip
	{
		private var _poseData : ItemData;
		private var _pose : MovieClip;
		
		public function get pose():MovieClip { return _pose; }
		public function get poseCurrentFrame():Number { return _pose.currentFrame; }
		public function get poseTotalFrames():Number { return _pose.totalFrames; }
		
		public function Pose(pPoseData:ItemData) {
			super();
			_poseData = pPoseData;
			
			_pose = addChild( new pPoseData.itemClass() ) as MovieClip;
			stop();
		}
		
		override public function play() : void {
			super.play();
			_pose.play();
		}
		
		override public function stop() : void {
			super.stop();
			_pose.stop();
		}
		
		public function stopAtLastFrame() : void {
			_pose.gotoAndPlay(10000);
			stop();
		}
		
		public function poseNextFrame() : void {
			if(poseCurrentFrame == poseTotalFrames) {
				_pose.gotoAndPlay(0);
			} else {
				_pose.nextFrame();
			}
			stop();
		}
		
		public function apply(items:Vector.<ItemData>, shamanMode:ShamanMode, shamanColor:uint=0x95D9D6, removeBlanks:Boolean=false) : MovieClip {
			if(!items) items = new Vector.<ItemData>();
			
			var tSkinDataIndex = FewfUtils.getIndexFromVectorWithKeyVal(items, "type", ItemType.SKIN);
			var tSkinData:SkinData = tSkinDataIndex == -1 ? null : items.splice(tSkinDataIndex, 1)[0] as SkinData;//FewfUtils.getFromVectorWithKeyVal(items, "type", ItemType.SKIN);
			
			var tShopData:Vector.<ItemData> = _orderType(items);
			var part:MovieClip = null;
			var tPoseBone:MovieClip = null;
			var tBoneName:String;
			
			var tAccessories:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			
			var addToPoseData = { shamanMode:shamanMode };
			
			for(var i:int = 0; i < _pose.numChildren; i++) {
				tPoseBone = _pose.getChildAt(i) as MovieClip;
				if(!tPoseBone) continue;
				tBoneName = tPoseBone.name;
				
				if(tSkinData) {
					part = _addToPoseIfCan(tPoseBone, tSkinData, tBoneName, addToPoseData) as MovieClip;
					if(part) {
						_colorSkinPart(part, tSkinData.colors ? tSkinData.colors[0] : -1, shamanColor);
						tAccessories = tAccessories.concat(getMcItemSubAccessories(part));
					}
					
					if(tBoneName == "CuisseD_1" && shamanMode == ShamanMode.DIVINE && isPoseWingsAddable(_poseData.id)) {
						tPoseBone.addChild( _getWingsMC(shamanColor) );
					}
				}
				
				for(var j:int = 0; j < tShopData.length; j++) {
					part = _addToPoseIfCan(tPoseBone, tShopData[j], tBoneName, addToPoseData) as MovieClip;
					if(part) {
						_colorItemPart(part, tShopData[j], tBoneName, shamanColor);
						tAccessories = tAccessories.concat(getMcItemSubAccessories(part));
					}
				}
				part = null;
			}
			
			_handleAccessories(tAccessories);
				
			if(removeBlanks) {
				for(var i:int = _pose.numChildren-1; i >= 0; i--) {
					if(!!_pose.getChildAt(i) && (_pose.getChildAt(i) as MovieClip).numChildren == 0) {
						_pose.removeChildAt(i);
					}
				}
			}
			
			return this;
		}
		
		private function _addToPoseIfCan(pBone:MovieClip, pData:ItemData, pID:String, pOptions:Object=null) : DisplayObject {
			if(pData) {
				var tClass = pData.getPart(pID, pOptions);
				if(tClass) {
					var tMC = new tClass();
					if(pData.type == ItemType.HAIR || pData.type == ItemType.NECK) {
						return pBone.addChildAt(tMC, pBone.numChildren > 0 ? 1 : 0);
					}
					else if(pData.type == ItemType.TAIL) {
						if(pBone.numChildren) {
							pBone.removeChildAt(0);
						}
						return pBone.addChild(tMC);
					}
					return pBone.addChild(tMC);
				}
			}
			return null;
		}
		
		private function _handleAccessories(pAccessoires:Vector.<DisplayObject>) : void {
			var tAccMC:DisplayObject;
			for(var aI:int = 0; aI < pAccessoires.length; aI++) {
				tAccMC = pAccessoires[aI];
				var tName:String = tAccMC.name;
				var tNameMinusSlotPrefix:String = tName.substr(5);
				
				var tSlotIsBehind = tNameMinusSlotPrefix.substr(0,6) == "behind";
				if(tSlotIsBehind) {
					tNameMinusSlotPrefix = tNameMinusSlotPrefix.substr(7); 
				}
				
				var tSlotIsFirst = tNameMinusSlotPrefix.substr(0,5) == "first";
				if(tSlotIsFirst) {
					tNameMinusSlotPrefix = tNameMinusSlotPrefix.substr(6);
				}
				
				var tAccItemCat:int = int(tNameMinusSlotPrefix);
				var validBoneNamesForItemCat:Vector.<String> = GameAssets.accessorySlotBones[tAccItemCat];
				if(validBoneNamesForItemCat) {
					for(var bnaI:int = 0; bnaI < validBoneNamesForItemCat.length; bnaI++) {
						var tBoneMC:MovieClip = _pose.getChildByName(validBoneNamesForItemCat[bnaI]) as MovieClip;

						if(tBoneMC) {
							var tNewAccPos:Point = tBoneMC.globalToLocal(tAccMC.parent.localToGlobal(new Point(tAccMC.x,tAccMC.y)));
							tAccMC.x = tNewAccPos.x;
							tAccMC.y = tNewAccPos.y;
							if(tSlotIsBehind) {
								tBoneMC.addChildAt(tAccMC, 0);
							} else if(tSlotIsFirst) {
								tBoneMC.addChildAt(tAccMC, 1);
							} else {
								tBoneMC.addChild(tAccMC);
							}
						}
					}
				}
			}
		}
		
		private function _colorItemPart(part:MovieClip, pData:ItemData, pSlotName:String, pShamanColor:uint) : void {
			if(!part) { return; }
			if(part is MovieClip) {
				if(pData.colors != null) {
					GameAssets.colorItemUsingColorList(part, GameAssets.getColorsWithPossibleHoverEffect(pData));
				}
				else { GameAssets.colorDefault(part); }
			}
		}
		private function _colorSkinPart(part:MovieClip, pColor:int, pShamanColor:uint):MovieClip {
			const colors:Vector.<int> = new <int>[ pColor, pShamanColor ];
			for(var i:int = 0; i < part.numChildren; i++) {
				var child:MovieClip = part.getChildAt(i) as MovieClip;
				if(!child) continue;
				if(child.name.charAt(0) == "c"){
					var colorIndex:int = int(child.name.charAt(1));
					if(colorIndex < colors.length) {
						GameAssets.applyColorToObject(child, colors[colorIndex]);
					}
				}
			}
			return part;
		}
		
		private function getMcItemSubAccessories(part:MovieClip):Vector.<DisplayObject> {
			var tAccessoires:Vector.<DisplayObject> = new Vector.<DisplayObject>();
			var tChild:DisplayObject;
			for(var i:int = 0; i < part.numChildren; i++) {
				tChild = part.getChildAt(i);
				if(tChild.name.indexOf("slot_") == 0) {
					tAccessoires.push(tChild);
				}
			}
			return tAccessoires;
		}
		
		private function _orderType(pItems:Vector.<ItemData>) : Vector.<ItemData> {
			return pItems
			.filter(function(a){ return a != null })
			.sort(function(a, b){
				return ItemType.LAYERING.indexOf(a.type) > ItemType.LAYERING.indexOf(b.type) ? 1 : -1;
			});
		}
		private function isPoseWingsAddable(poseID:String) : Boolean {
			return poseID == "Statique" || poseID == "Course" || poseID == "Duck";
		}
		private function _getWingsMC(pShamanColor:uint) : MovieClip {
			var part = new $AileChamane();
			part.x = 10;
			part.y = -8;
			part.scaleX = 0.9;
			part.scaleY = 0.9;
			part.rotation = -10;
			_colorSkinPart(part, -1, pShamanColor);
			return part;
		}
	}
}
