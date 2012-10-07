package {

	import Sprites;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	import fl.transitions.TweenEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;

	public class Boy extends Sprites {
		
		public var myTween:Tween;
		private var walkingSound:Sound;
		private var freeCounter_1:int;
		public var caughtTheThief:Boolean;
		private var xDifference:Number;
		private var yDifference:Number;
		private var xSign:Number;
		private var ySign:Number;
		public var thiefIndex:int;
		private var hitSound:Sound;
		private var hitSoundChannel:SoundChannel;
		public var enemyHit:Boolean;
		private var thiefTween:Tween;
		private var alternateMiscreantsArray:Array = new Array();
		private var indexForMiscreantsArray:int;
		public var animationFinished:Boolean;
		private var tweenMotionFinished:Boolean;
		private var centerX:Number;
		private var centerY:Number;
		
		
		//private var p1:Purchase;
		
		public function Boy(size:Number,left:Number,right:Number,up:Number,down:Number, target:Array) {
			super(size,left,right,up,down);
			this.initial_sprite_dir = "back";
			animals=target;
			hitSound = new Sound(new URLRequest("Audio/hit.mp3"));
			hitSoundChannel = new SoundChannel();
			
			animationFinished = true;
			
			enemyHit = false;
			tweenMotionFinished = false;
			//p1 = new Purchase();
			loadSounds();
			caughtTheThief = false;
			addListeners();
		}
		
		public function loadSounds():void {
			walkingSound = new Sound(new URLRequest("Audio/walking.mp3"));
		}
		
		public function addListeners():void {
			this.addEventListener(Event.ENTER_FRAME, enteredFrame);
		}
		
		public function enteredFrame(e:Event):void {
			//trace("I dont think if this function is getting executed");
			stage.addEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
			removeEventListener(Event.ENTER_FRAME, enteredFrame);
		}
		
		public function enemyHasEscaped(list:Array, index:int)
		{
			list[index].escaped = true;
		}
		
		public function moveBoy(e:KeyboardEvent):void 
		{
			
			FarmGame.boyIsMoving = true;
						
			
				if (e.keyCode == Keyboard.RIGHT) 
				{
					walkingSound.play();
					moveSprite("right",this.moveStepSize);
				}
				else if (e.keyCode == Keyboard.LEFT) 
				{
					walkingSound.play();
					moveSprite("left",this.moveStepSize);
				}
				else if (e.keyCode == Keyboard.UP) 
				{
					walkingSound.play();
					moveSprite("up",this.moveStepSize);
				}
				else if (e.keyCode == Keyboard.DOWN) 
				{
					walkingSound.play();
					moveSprite("down",this.moveStepSize);
				}
			
			
		}
		
		public function removeBoyKeyboardListener():void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
		}
		
		public function theHitSoundIsFinished(e:Event):void
		{
			if (alternateMiscreantsArray[indexForMiscreantsArray].caughtTheFruit == false)
					{
						//indexForMiscreantsArray = freeCounter_1;
						thiefTween = new Tween(alternateMiscreantsArray[indexForMiscreantsArray],"y",None.easeOut,alternateMiscreantsArray[indexForMiscreantsArray].y,580,2.5,true);
						tweenMotionFinished = false;
						//trace("start the tween");
						//thiefTween.start();
						thiefTween.addEventListener(TweenEvent.MOTION_FINISH, thiefTweenFinished);
						//miscreantsArray[freeCounter_1].escaped = true;
						
						//miscreantsArray[freeCounter_1].y = miscreantsArray[freeCounter_1].y + miscreantsArray[freeCounter_1].moveStepSize;
						//miscreantsArray[freeCounter_1].movingUp = false;
						//if (miscreantsArray[freeCounter_1].y>(constraint_down - 50))
						//{
							//miscreantsArray[freeCounter_1].escaped = true;
							
						//}
					}
					else
					{
						//trace("entering in the caughtThethief condition");
						caughtTheThief = true;
						//trace(caughtTheThief);
						animationFinished = true;
						thiefIndex = indexForMiscreantsArray;
						//stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
						
						//p1.startTheDialogues(miscreantsArray[freeCounter_1].x, miscreantsArray[freeCounter_1].y);
					}
			
			/*if (miscreantsArray[freeCounter_1].caughtTheFruit == false)
					{
						miscreantsArray[freeCounter_1].y = miscreantsArray[freeCounter_1].y + miscreantsArray[freeCounter_1].moveStepSize;
						miscreantsArray[freeCounter_1].movingUp = false;
						if (miscreantsArray[freeCounter_1].y>(constraint_down - 50))
						{
							miscreantsArray[freeCounter_1].escaped = true;
							
						}
					}
					else
					{
						caughtTheThief = true;
						thiefIndex = freeCounter_1;
						stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
						
						//p1.startTheDialogues(miscreantsArray[freeCounter_1].x, miscreantsArray[freeCounter_1].y);
					}*/
		}
		
		public function thiefTweenFinished(e:TweenEvent):void
		{
			alternateMiscreantsArray[indexForMiscreantsArray].escaped = true;
			enemyHit = false;
			animationFinished = true;
			tweenMotionFinished = true;
			
		}
		
		public function checkHitMiscreant(target_1:Sprites):Boolean
		{
			xSign = 0;
			ySign = 0;
			xDifference = this.getX() - target_1.getX();
			yDifference = this.getY()+this.height - (target_1.getY()+target_1.height);
			if (xDifference!=0)
				xSign = xDifference/Math.abs(xDifference);
			if (yDifference!=0)
				ySign = yDifference/Math.abs(yDifference);
			
			if(Math.abs(xDifference)<10 && Math.abs(yDifference)<10)
				return true;
			else
				return false;			
			
		}
		public function hitMiscreant(miscreantsArray:Array)
		{
			alternateMiscreantsArray = miscreantsArray;
			//trace(miscreantsArray.length);
			for (freeCounter_1=0; freeCounter_1<miscreantsArray.length; freeCounter_1 = freeCounter_1 + 1)
			{
				/*if (this.hitTestObject(miscreantsArray[freeCounter_1]) == false && tweenMotionFinished == true)
				{
					enemyHit = false;
				}*/
				//if (this.hitTestObject(miscreantsArray[freeCounter_1])==true && enemyHit == false)
				//if (checkHitMiscreant(miscreantsArray[freeCounter_1])==true && enemyHit == false)
				centerX = this.getX() + ((this.width)/2.0);
				centerY = this.getY() + ((this.height)/2.0);
				if ( ( centerX > miscreantsArray[freeCounter_1].getX() ) && enemyHit == false)
				{
					if ((centerX<(miscreantsArray[freeCounter_1].getX() + miscreantsArray[freeCounter_1].width)))
					{
						if ( ( centerY > miscreantsArray[freeCounter_1].getY() ) )
						{
							if ((centerY<(miscreantsArray[freeCounter_1].getY() + miscreantsArray[freeCounter_1].height)))
							{
								stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
								animationFinished = false;
								indexForMiscreantsArray = freeCounter_1;
					
								if (enemyHit == false)
								{
									miscreantsArray[freeCounter_1].blink(this);
									hitSoundChannel = hitSound.play(0,3);
									hitSoundChannel.addEventListener(Event.SOUND_COMPLETE,theHitSoundIsFinished);
									enemyHit = true;
									//return freeCounter_1;
						
								}
							}
						}
					}
					//FarmGame.boyIsMoving = false;
										
					//hitSoundChannel.addEventListener(Event.SOUND_COMPLETE, theHitSoundIsFinished);
					/*if (miscreantsArray[freeCounter_1].caughtTheFruit == false)
					{
						indexForMiscreantsArray = freeCounter_1;
						thiefTween = new Tween(miscreantsArray[freeCounter_1],"y",None.easeOut,miscreantsArray[freeCounter_1].y,480,2.5,true);
						trace("start the tween");
						thiefTween.start();
						thiefTween.addEventListener(TweenEvent.MOTION_FINISH, thiefTweenFinished);
						//miscreantsArray[freeCounter_1].escaped = true;
						
						//miscreantsArray[freeCounter_1].y = miscreantsArray[freeCounter_1].y + miscreantsArray[freeCounter_1].moveStepSize;
						//miscreantsArray[freeCounter_1].movingUp = false;
						//if (miscreantsArray[freeCounter_1].y>(constraint_down - 50))
						//{
							//miscreantsArray[freeCounter_1].escaped = true;
							
						//}
					}
					else
					{
						caughtTheThief = true;
						thiefIndex = freeCounter_1;
						stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
						
						//p1.startTheDialogues(miscreantsArray[freeCounter_1].x, miscreantsArray[freeCounter_1].y);
					}*/
				}
			// end of forLoop
			}
			//return -1;
		// end of function hitMiscreant
		}
		
		/*public function gotoNextFrame(e:Event):void{
			myTween.removeEventListener(TweenEvent.MOTION_FINISH, gotoNextFrame);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveBoy);
			Market.goNextFrame = true;
		}*/
		
		
	}
}