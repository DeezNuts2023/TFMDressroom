package com.fewfre.utils
{
	public class FewfUtils
	{
		public static function getFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : * {
			return pArray[getIndexFromArrayWithKeyVal(pArray, pKey, pVal)];
		}
		
		public static function getIndexFromArrayWithKeyVal(pArray:Array, pKey:String, pVal:*) : int {
			for(var i:int = 0; i < pArray.length; i++) {
				if(pArray[i] && pArray[i][pKey] == pVal) {
					return i;
				}
			}
			return -1;
		}
		
		public static function getFromVectorWithKeyVal(pVector:Object, pKey:String, pVal:*) : * {
			var i:int = getIndexFromVectorWithKeyVal(pVector, pKey, pVal);
			return i > -1 ? pVector[i] : null;
		}
		
		public static function getIndexFromVectorWithKeyVal(pVector:Object, pKey:String, pVal:*) : int {
			for(var i:int = 0; i < pVector.length; i++) {
				if(pVector[i] && pVector[i][pKey] == pVal) { return i; }
			}
			return -1;
		}
		
		public static function stringSubstitute(pVal:String, ...pValues) : String {
			if(pValues[0] is Array) { pValues = pValues[0]; }
			for(var i:* in pValues) {
				pVal = pVal.replace("{"+i+"}", pValues[i]);
			}
			return pVal;
		}
		
		public static function lpad(str:String, width:int, pad:String="0") : String {
			var ret:String = ""+str;
			while( ret.length < width )
				ret = pad + ret;
			return ret;
		}
	}
}
