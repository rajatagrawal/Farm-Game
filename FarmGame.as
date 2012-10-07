package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.media.Sound;
	
	public class FarmGame extends MovieClip
	{
		public static var mother_bubble:MovieClip = new Mother_bubble();
		public static var son_bubble:MovieClip = new Son_bubble();
		public static var syllabus:Array;
		public static var questionNumber:Number;
		public static var boyIsHit:Boolean;
		public static var boyIsMoving:Boolean;
		public static var fruitIsCaught:Boolean;
		public static var miscreantsSpeed:Number;
		
		// this variable will be used to store the images
		public static var imageLoader:Array;
		// this variable will be used to store the audio associated with the images
		private static var soundFiles:Array;
		public static var sock:SockConnection;
		
		public function FarmGame()
		{
			this.stage.addChild(mother_bubble);
			this.stage.addChild(son_bubble);
			miscreantsSpeed = 1.25;
   			mother_bubble.y=40; mother_bubble.x=160;
			son_bubble.y=90; son_bubble.x=600;
			mother_bubble.visible=false;
			son_bubble.visible=false;
			syllabus = new Array(5);
			questionNumber = 1;
			fruitIsCaught = false;
			boyIsHit = false;
			boyIsMoving = false;
			imageLoader = new Array();
			soundFiles = new Array();
			sock=new SockConnection("localhost",5000);  
			
		// end of constructor definition
		}
		
		public static function populateSyllabus():void {
			syllabus = SyllabusQueue.nextWords(5); //5 words extracted from the word queue each round
		}
		
		// this function loads the images which need to be taught 
		// to the child in the variable imageLoader
		// this function also loads the sounds corresponding to those images in the variable soundFiles
		// parameters 
		// 1. list : this is the array which stores the words which need to be taught
		public static function loadImages(list:Array)
		{
			// this variable is used to traverse the variable "list"
			var counter_1:Number = 0;
			while(imageLoader.length !=0)
				imageLoader.pop();
			
			while(soundFiles.length!=0)
			{
				soundFiles.pop();
			}
			while(counter_1<list.length)
			{
				// store the images in the imageLoader array						
				
				imageLoader.push(new ImageToMovie("Images/" + list[counter_1].image));
				soundFiles.push(new Sound());
				soundFiles[counter_1].load(new URLRequest("Audio/" + list[counter_1].audio));
				
				//this.addChild(imageLoader[counter_1]);
				//addChild(imageLoader[counter_1]);
				
				// hide the images
				//imageLoader[counter_1].visible = false;
				imageLoader[counter_1].showImage();
				// bring the images to the bottom left corner of the screen.
				//imageLoader[counter_1].setX(500);
				//imageLoader[counter_1].setY(140);
				
				//trace(imageLoader[counter_1].getHeight());
				//imageLoader[counter_1].setWidth(30);
				
				// shrink the size of the images by half				
				imageLoader[counter_1].scaleX = 0.3;
				imageLoader[counter_1].scaleY= 0.3;				
				
				counter_1 = counter_1 + 1;
			}
		}
	// end of class definition
	}
	
// end of package
}