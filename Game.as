package
{
	import flash.display.MovieClip;
	
	public class Game extends MovieClip
	{
		public var boy_mc:Boy;
		public var p1:Purchase;
		
		public function Game()
		{
			//FarmGame.populateSyllabus();
			FarmGame.loadImages(FarmGame.syllabus);

			p1 = new Purchase();
			addChild(p1);
			
		// end of constructor definition
		}
		public function removeBoy():void
		{
			removeChild(boy_mc);
		}
		
		
		public function setupBoy(size:Number,left:Number,right:Number,up:Number,down:Number, target:Array):void
		{
			boy_mc = new Boy(size,left,right,up,down,target);
			boy_mc.setX(400);
			boy_mc.setY(240);
			addChild(boy_mc);
			
		//end of function setupBoy
		}
	// end of Game class definition
	}
	
// end of package
}