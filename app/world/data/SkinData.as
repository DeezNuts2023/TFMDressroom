package app.world.data
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.getDefinitionByName;

	public class SkinData extends ItemData
	{
		private var _assetID : String;
		public var isSkinColor : Boolean;
		
		public function SkinData(pData:Object) {
			super(ItemType.SKIN, pData.id, {});
			_assetID = pData.assetID != null ? pData.assetID : id;
			isSkinColor = !!pData.isSkinColor;
			if(pData.color) {
				defaultColors = new <uint>[ pData.color ];
				setColorsToDefault();
			}
			
			classMap = {};

			// Face
			classMap.Tete_1			= Fewf.assets.getLoadedClass( "_Tete_1_"+_assetID+"_1" );
			// Eyes
			classMap.Oeil_1			= Fewf.assets.getLoadedClass( "_Oeil_1_"+_assetID+"_1" );
			// Body
			classMap.Corps_1		= Fewf.assets.getLoadedClass( "_Corps_1_"+_assetID+"_1" );
			// Wings
			classMap.Ailes_1		= Fewf.assets.getLoadedClass( "_Ailes_1_"+_assetID+"_1" );
			// Tail
			classMap.Queue_1		= Fewf.assets.getLoadedClass( "_Queue_1_"+_assetID+"_1" );
			// Tail Ornament
			classMap.Boule_1		= Fewf.assets.getLoadedClass( "_Boule_1_"+_assetID+"_1" );

			// Back Paws
			classMap.PiedG_1		= Fewf.assets.getLoadedClass( "_PiedG_1_"+_assetID+"_1" );
			classMap.PiedD_1		= Fewf.assets.getLoadedClass( "_PiedD_1_"+_assetID+"_1" );
			classMap.PiedD2_1		= Fewf.assets.getLoadedClass( "_PiedD2_1_"+_assetID+"_1" );
			// Front Paws
			classMap.PatteG_1		= Fewf.assets.getLoadedClass( "_PatteG_1_"+_assetID+"_1" );
			classMap.PatteD_1		= Fewf.assets.getLoadedClass( "_PatteD_1_"+_assetID+"_1" );
			// Ears
			classMap.OreilleG_1		= Fewf.assets.getLoadedClass( "_OreilleG_1_"+_assetID+"_1" );
			classMap.OreilleD_1		= Fewf.assets.getLoadedClass( "_OreilleD_1_"+_assetID+"_1" );
			// Legs
			classMap.CuisseG_1		= Fewf.assets.getLoadedClass( "_CuisseG_1_"+_assetID+"_1" );
			classMap.CuisseD_1		= Fewf.assets.getLoadedClass( "_CuisseD_1_"+_assetID+"_1" );
		}

		protected override function _initDefaultColors() : void {

		}
		
		public override function copy() : ItemData {
			return new SkinData({ assetID:_assetID, id:id, type:type, color:defaultColors ? defaultColors[0] : null, itemClass:itemClass, classMap:classMap });
		}
		
		public override function getPart(pID:String, pOptions:Object=null) : Class {
			var shamanMode:ShamanMode = ShamanMode.OFF;
			if(pOptions != null) {
				if(pOptions.shamanMode) { shamanMode = pOptions.shamanMode; }
			}
			if(shamanMode == ShamanMode.DIVINE) {
				shamanMode = ShamanMode.HARD;
			}
			var mcName = "_"+pID+"_"+_assetID+"_"+shamanMode.toInt();
			var tClass = _assetID == 1 ? getDefaultSkinPart(mcName) : Fewf.assets.getLoadedClass(mcName);
			trace("_"+pID+"_"+_assetID+"_"+shamanMode+" - "+tClass);
			return tClass == null && shamanMode.toInt() > ShamanMode.NORMAL.toInt() ? getPart(pID, { shamanMode:ShamanMode.fromInt(shamanMode.toInt()-1) }) : tClass;
		}
		
		private function getDefaultSkinPart(pName:String) : Class {
			try {
				return getDefinitionByName(pName) as Class;
			}
			catch(err:Error) {
				return null;
			}
		}
	}
}
