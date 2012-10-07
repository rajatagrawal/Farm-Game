package{
	
	public class SyllabusItem {
		public var name:String;
		public var image:String;
		public var weight:int;
		public var audio:String;
		public var phonological_dist:String;
		public var semantic_dist:String;
		public var unrelated_dist:String;
		public var transliteration:String;

		public function SyllabusItem(name:String,audio:String,image:String,phonological_dist:String,semantic_dist:String,unrelated_dist:String,transliteration:String,weight:int) {
			this.name=name;
			this.audio=audio;
			this.image=image;
			this.phonological_dist = phonological_dist;
			this.semantic_dist = semantic_dist;
			this.unrelated_dist = unrelated_dist;
			this.weight=weight;
			this.transliteration = transliteration;
		}
	}
}