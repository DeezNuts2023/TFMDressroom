package app.data
{
	public final class ItemType
	{
		public static const POSE				: ItemType = new ItemType("pose");
		public static const SKIN				: ItemType = new ItemType("fur", 22); // colors are 21
		public static const HEAD				: ItemType = new ItemType("head", 0);
		public static const HAIR				: ItemType = new ItemType("hair", 5);
		public static const EYES				: ItemType = new ItemType("eyes", 1);
		public static const EARS				: ItemType = new ItemType("ears", 2);
		public static const MOUTH				: ItemType = new ItemType("mouth", 3);
		public static const NECK				: ItemType = new ItemType("neck", 4);
		public static const TAIL				: ItemType = new ItemType("tail", 6);
		public static const CONTACTS			: ItemType = new ItemType("contacts", 7);
		public static const HAND				: ItemType = new ItemType("hands", 8);
		public static const TATTOO				: ItemType = new ItemType("tattoo", 11);
		public static const OBJECT				: ItemType = new ItemType("object", 9);
		public static const PAW_BACK			: ItemType = new ItemType("back-paw", 10);
		public static const BACK				: ItemType = new ItemType("back");
		
		public static const LAYERING : Vector.<ItemType> = new <ItemType>[
			SKIN, TATTOO, HEAD, MOUTH, HAIR, NECK, EARS, CONTACTS, EYES, TAIL, HAND, OBJECT, BACK, PAW_BACK ];
		
		public static const TYPES_WITH_SHOP_PANES : Vector.<ItemType> = new <ItemType>[
			HEAD, HAIR, EARS, EYES, MOUTH, NECK, TAIL, CONTACTS, HAND, TATTOO, SKIN, POSE ];
		
		public static const LOOK_CODE_ITEM_ORDER : Vector.<ItemType> = new <ItemType>[
			HEAD, EYES, EARS, MOUTH, NECK, HAIR, TAIL, CONTACTS, HAND, TATTOO]
		
		private var _value: String;
		private var _num: int;
		function ItemType(pValue:String, pNum:int=-1) { _value = pValue; _num = pNum }
		
		public function toString() : String { return _value.toString(); }
		
		public function toInt() : int { return _num; }
	}
}
