package
{
	public class Miscreant extends Sprites
	{
		import flash.events.Event;
		import flash.net.URLRequest;
		import flash.media.Sound;
		import flash.media.SoundChannel;
		public var distance:Number;
		private var xDifference_1:Number;
		private var yDifference_1:Number;
		private var xSign:Number;
		private var ySign:Number;
		private var hitSound:Sound;
		public var movingRight:Boolean;
		public var movingUp:Boolean;
		public var caughtTheFruit:Boolean;
		public var escaped:Boolean;
		public var changedDirection:Boolean;
		private var chooseDirectionNumber:int;
		private var chooseDirectionNumber_1:int;
		private var chooseDirectionNumber_2:int;
		private var chooseDirectionNumber_3:int;
		private var chooseDirectionNumber_4:int;
		private var hitSoundChannel:SoundChannel;
		private var targetX:Number;
		private var targetY:Number;
		private var thiefX:Number;
		private var thiefY:Number;
		
		public function Miscreant(size:Number,separation:Number,left:Number,right:Number,up:Number,down:Number,startingY:Number = -1)
		{
			distance = separation;
			initial_sprite_dir = "front";
			hitSound = new Sound(new URLRequest("Audio/hit.mp3"));
			hitSoundChannel = new SoundChannel();
			
			//movingUp = false;
			//movingRight = true;
			decideMovingDirections();
			changedDirection = false;
			super(size,left,right,up,down);
			//initial_y = 480;
			decideInitialPositions();
			//initial_x = Math.ceil(Math.random() * 800);
			//setX(initial_x);
			//setY(initial_y);
			this.x = initial_x;
			if (startingY != -1)
				this.y = startingY;
			else
			{	initial_y = 480;
				decideInitialYPositions();
				this.y = initial_y;
			}
			caughtTheFruit = false;
			escaped = false;
			
		}
		public function decideInitialYPositions():void
		{
			chooseDirectionNumber_3 = Math.floor(Math.random() * 2);
			chooseDirectionNumber_4 = Math.floor(Math.random() * 2);
			initial_y = initial_y + (chooseDirectionNumber_3 * Math.floor(Math.random()*150));
			initial_y = initial_y + (chooseDirectionNumber_4 * Math.floor(Math.random()*150));
			//trace(initial_y);
		}
		public function decideInitialPositions():void
		{
			chooseDirectionNumber = Math.floor(Math.random() * 2);
			chooseDirectionNumber_1 = Math.floor(Math.random() * 2);
			chooseDirectionNumber_2 = Math.floor(Math.random() * 2);
			//trace(chooseDirectionNumber,chooseDirectionNumber_1,chooseDirectionNumber_2);
			initial_x = (chooseDirectionNumber * 200 ) + Math.ceil(Math.random() * 200) + (chooseDirectionNumber_1 * 200 ) + (chooseDirectionNumber_2 * 200 );
			
			
		}
		public function decideMovingDirections():void
		{
			chooseDirectionNumber = Math.ceil(Math.random() * 2);
			if (chooseDirectionNumber == 1)
				movingRight = true;
			else 
				movingRight = false;
				
			/*chooseDirectionNumber = Math.ceil(Math.random() * 2);
			if (chooseDirectionNumber == 1)
				movingUp = true;
			else 
				movingUp = false;*/
		}
		public function hitTrees(syllabusCopies:Array):void
		{
			var syllabusCounter:int;
			syllabusCounter = 0;
			for (syllabusCounter=0; syllabusCounter<syllabusCopies.length;syllabusCounter = syllabusCounter + 1)
			{
				if  (this.hitTestObject(syllabusCopies[syllabusCounter]) && caughtTheFruit == false && FarmGame.fruitIsCaught == false) 
				{
					caughtTheFruit = true;
					FarmGame.fruitIsCaught = true;
					this.addChild(syllabusCopies[syllabusCounter]);
					
					// set the coordinates for the syllabus item to zero
					syllabusCopies[syllabusCounter].x = 0;
					syllabusCopies[syllabusCounter].y = 0;
					this.constraint_up = 350;
					
				}
			}
		}
		public function moveMiscreant(syllabusCopies:Array)
		//public function moveMiscreant()
		{
			hitTrees(syllabusCopies);
			if (caughtTheFruit == true)
			{
				if (this.y>=constraint_down)
				{					
					escaped = true;
					//return;
				}
			}
			 
			
			if (movingRight == true)
			{
				if (this.x + moveStepSize < constraint_right)
					this.x = this.x + moveStepSize;
				
				//if (this.x >=constraint_right)
				else
				{
					movingRight = false;
				}
				
			}
			
			else if (movingRight == false)
			{
				if (this.x - moveStepSize > constraint_left)
					this.x = this.x - moveStepSize;
				
				//if (this.x <=constraint_left)
				else
				{
					movingRight = true;
				}
			}
			
			if (movingUp == true)
			{
				if (this.y - moveStepSize > constraint_up)
					this.y = this.y - moveStepSize;
				
				//if (this.y <= constraint_up)
				else
				{
					movingUp = false;
				}
			}
			
			else if (movingUp == false)
			{
				if (this.y + moveStepSize < constraint_down)
					this.y = this.y + moveStepSize;
				
				//if (this.y >= constraint_down)
				else
				{
					movingUp = true;
				}
			}
			
		}
		
		public function moveAwayFromTarget(target:Sprites):void
		{
			targetX = target.getX() + (target.width)/2.0;
			targetY = target.getY() + (target.height)/2.0;
			thiefX = this.getX() + (this.width)/2.0;
			thiefY = this.getY() + (this.height)/2.0;
			xDifference_1 = thiefX-targetX;
			yDifference_1 = thiefY-targetY;
			if (Math.abs(xDifference_1)<this.distance)
			{
				if (Math.abs(yDifference_1)<this.distance)
				{
					if (xDifference_1>0)
					{
						if (yDifference_1<0)
						{
							// FIRST QUADRANT
							if (Math.abs(xDifference_1)<Math.abs(yDifference_1))
							{
								if (this.movingRight == false)
									this.movingRight = true;
							}
							else
							{
								if (this.movingUp == false)
								this.movingUp = true;
							}
						}
						else
						{
							// FOURTH QUADRANT
							if (Math.abs(xDifference_1)<Math.abs(yDifference_1))
							{
								if (this.movingRight == false)
									this.movingRight = true;
							}
							else
							{
								if (this.movingUp == true)
									this.movingUp = false;
							}
						}
					}
			
					else if (xDifference_1<0)
					{
						if (yDifference_1<0)
						{
							// SECOND QUADRANT
							if (Math.abs(xDifference_1)<Math.abs(yDifference_1))
							{
								if (this.movingRight == true)
									this.movingRight = false;
							}
							else
							{
								if (this.movingUp == false)
									this.movingUp = true;
							}
						}
						else
						{
							// THIRD QUADRANT
							if (Math.abs(xDifference_1)<Math.abs(yDifference_1))
							{
								if (this.movingRight == true)
									this.movingRight = false;
							}
							else
							{
								if (this.movingUp == true)
									this.movingUp = false;
							}
						}
					}			
				// end of inner if 
				}
			// end of outer if
			}		
		// end of function moveAwayFromTarget
		}
		
		/*public function checkHitTarget():Boolean
		{
			if(Math.abs(xDifference)<3 && Math.abs(yDifference)<3)
				return true;
			else
				return false;
		}*/
	}
}