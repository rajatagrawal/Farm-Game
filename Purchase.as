package{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import fl.transitions.Tween;
	import fl.transitions.TransitionManager;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	public class Purchase extends MovieClip
 	{
		private var boy_mc:Boy;
		//private var myMovingBoy:MovingBoy;
		private var raju_leftFrame:ImageToMovie;
		private var rajuTween:Tween;
		private var shopkeeperTween:Tween;
		private var shopkeeperTween2:Tween;
		private var shopkeeperTween3:Tween;
		private var shopkeeperTween4:Tween;
		private var shopkeeper_bubble:MovieClip;
		private var correct:MovieClip;
		private var wrong:MovieClip;
		private var dialogue_shopkeeper:Sound;
		private var dialogue_shopkeeper2:Sound;
		private var soundChannel_shopkeeper:SoundChannel;
		private var wordSound:Sound;
		private var wordSoundChannel:SoundChannel;
		private var wordSound_telegu:Sound;
		private var wordSoundChannel_telegu:SoundChannel;
		private var moveSelector:Boolean;
		private var bottomBar:ImageToMovie;
		private var buttonTextLeft:TextField;
		private var buttonTextRight:TextField;
		private var buttonTextLeft_telegu:TextField;
		private var buttonTextRight_telegu:TextField;
		private var textStyling:TextFormat;
		private var textStyling_telegu_5:TextFormat;
		private var repeat:MovieClip;
		private var nextWord:MovieClip;
		public var image:Loader;
		public var answers:Array;
		public var URLImage:URLRequest;
		public var sequence:Array;
		public var current_selection:int;
		public var answer_selector:MovieClip;
		public var answer_selector_1:MovieClip;
		public var gameFinished:Boolean;
		public var guessingTheGame:Boolean;
		public var levelComplete:Boolean;
		private var tryAgainBubbleX:Number;
		private var tryAgainBubbleY:Number;
		private var tree_1_MovieClip:MovieClip;
		private var tree_2_MovieClip:MovieClip;
		private var tree_3_MovieClip:MovieClip;
		private var tree_4_MovieClip:MovieClip;
		private var miscreantsVisibilityArray_1:Array;
		private var externalFruitsArray:Array;
		private var visibilityCounter_1:int;
		private var raju_visibility_1:MovieClip;
		private var answersArrayCounter_1:int;
		
		private var mainTextContainer:fontContainer;
		private var textBoxStyling:TextFormat;
		private var teleguTextField:TextField;
		private var dialogueTextField_mother_1:TextField;
		private var dialogueTextField_raju:TextField;
		private var dialogueStyling:TextFormat;
		
		private var microphoneImageLoader:Loader;
		private var microphoneText:TextField;
		private var speakNow:Sound;
		private var speakNow_soundChannel:SoundChannel;
		private var compareString:String;
		private var congratsVoiceOver:Sound;
		private var congratsSoundChannel:SoundChannel;
		private var noOfTries:int;
		private var time:Date;
		private var l2Word:TextField;
		private var l2WordTextFormat:TextFormat;
		private var blinkTween:Tween;
		private var noOfL2Blinks:int;
		private var movieClipL2Word:MovieClip;
		private var speakingInstruction:TextField;
		private var speakingInstructionStyling:TextFormat;
		
		private var phonologicalPrompt:Sound;
		private var phonologicalPromptChannel:SoundChannel;
		
		private var firstLetterSound:Sound;
		private var firstLetterSoundChannel:SoundChannel;


		public function Purchase() {
			
			noOfL2Blinks = 6;
			//FarmGame.populateSyllabus();
			microphoneText = new TextField();
			compareString = new String();
			
			addChild(microphoneText);
			speakNow = new Sound(new URLRequest("Audio/speakNow_telegu.mp3"));
			speakNow_soundChannel = new SoundChannel();
			congratsVoiceOver = new Sound(new URLRequest("Audio/congrats.mp3"));
			congratsSoundChannel = new SoundChannel();
			
			l2Word = new TextField();
			l2WordTextFormat = new TextFormat();
			setupL2TextField();
			setupInstructionTextField();
			
			noOfTries = 0;
			levelComplete = false;
			answers = new Array(4);
			sequence = new Array(4);
			gameFinished = false;
			shopkeeper_bubble = new Mother_bubble();
			soundChannel_shopkeeper = new SoundChannel();
			wordSoundChannel = new SoundChannel();
			wordSoundChannel_telegu = new SoundChannel();
			tree_1_MovieClip = new MovieClip();
			tree_2_MovieClip = new MovieClip();
			tree_3_MovieClip = new MovieClip();
			tree_4_MovieClip = new MovieClip();
			raju_visibility_1 = new MovieClip();
			externalFruitsArray = new Array();
			miscreantsVisibilityArray_1 = new Array();
			
			guessingTheGame = false;
			//boy_mc = new Boy(10,0,800,100,355,null);
			//setupRajuAnimation();
			setupShopkeeper();
			//startRajuAnimation();
			//this.addEventListener(Event.ADDED_TO_STAGE, enteredFrame);
			moveSelector = false;
			correct = new Correct();
			wrong = new Wrong();
			setUpButtons();
			setupTeleguTextBox();
			setupDialogueTextFields();
			myDialogueSetupFunction();
			setupMicrophoneImage();
			setupPhonologicalHint();
		}
		private function setupPhonologicalHint()
		{
			phonologicalPrompt = new Sound(new URLRequest("Audio/firstLetterSounds/this_word_begins_with.mp3"));
			phonologicalPromptChannel = new SoundChannel();
			
			firstLetterSound = new Sound();
			firstLetterSoundChannel = new SoundChannel();
		}
		
		private function setupL2TextField():void
		{
			movieClipL2Word = new MovieClip();
			movieClipL2Word.addChild(l2Word);
			addChild(movieClipL2Word);
			
			movieClipL2Word.x = 150;
			movieClipL2Word.y = 90;
			//addChild(l2Word);
			l2Word.visible = false;
			//l2Word.x = 150;
			//l2Word.y = 90;
			l2Word.autoSize = TextFieldAutoSize.LEFT;
			l2WordTextFormat.size = 36;
			l2WordTextFormat.bold = true;
			
		}
		private function setupInstructionTextField()
		{
			speakingInstructionStyling = new TextFormat();
			speakingInstruction = new TextField();
			speakingInstruction.text = "ఈ పదము దీనితో మొదలవుతు౦ది";
			speakingInstruction.autoSize = TextFieldAutoSize.CENTER;
			speakingInstruction.x = 150;
			speakingInstruction.y = 50;
			
			speakingInstructionStyling.bold = true;
			speakingInstructionStyling.size = 28;
			
			speakingInstructionStyling.font = "Gautami";
			speakingInstruction.setTextFormat(speakingInstructionStyling);
			
			addChild(speakingInstruction);
			speakingInstruction.visible = false;
			trace(speakingInstructionStyling.font);
		}
		private function putTextInL2(myString:String):void
		{
			var tempString:String;
			var stringLengthCounter:int;
			tempString = myString.toUpperCase();
			l2Word.text = tempString.charAt(0);
			
			for(stringLengthCounter=0; stringLengthCounter<tempString.length -1 ; stringLengthCounter = stringLengthCounter + 1)
			{
				l2Word.appendText(" _");
			}
			l2Word.visible = true;
			l2Word.setTextFormat(l2WordTextFormat);
		}
		
		private function setupDialogueTextFields():void
		{
			dialogueStyling = new TextFormat();
			dialogueTextField_mother_1 = new TextField();
			dialogueTextField_raju = new TextField();
			shopkeeper_bubble.addChild(dialogueTextField_mother_1);
			FarmGame.son_bubble.addChild(dialogueTextField_raju);
			dialogueTextField_mother_1.visible = true;
			dialogueTextField_mother_1.wordWrap = true;
			dialogueTextField_raju.wordWrap = true;
			//dialogueTextField_mother.multiline = true;
			//dialogueTextField_raju.multiline = true;
			
			dialogueTextField_mother_1.autoSize = TextFieldAutoSize.LEFT;
			dialogueTextField_raju.autoSize = TextFieldAutoSize.LEFT;
			dialogueTextField_mother_1.width = 200;
			dialogueTextField_raju.width = 200;
			
			dialogueTextField_mother_1.x = -10;
			dialogueTextField_mother_1.y = -10;
			
			dialogueTextField_raju.y = -30;
			dialogueStyling.font = "Gautami";
			dialogueStyling.size = 26;
			dialogueStyling.bold = true;
			//dialogueTextField_mother_1.text = "abcd";
			dialogueTextField_mother_1.setTextFormat(dialogueStyling);
			dialogueTextField_raju.setTextFormat(dialogueStyling);
			
		}
		private function setupMicrophoneImage():void
		{
			microphoneImageLoader = new Loader();
			microphoneImageLoader.load(new URLRequest("Images/rajuMike.png"));
			addChild(microphoneImageLoader);
			microphoneImageLoader.visible = false;
						
		}
		private function myDialogueSetupFunction():void
		{
			var textField_20:TextField = new TextField();
			var textFormat_99:TextFormat = new TextFormat();
			textFormat_99.size = 40;
			//addChild(textField_20);
			
			//addChild(textField_20);
			//textField_20.x = 100;
			//textField_20.y = 100;
			textField_20.text = " jkl;";
			textField_20.setTextFormat(textFormat_99);
			
			
		}
		private function setupTeleguTextBox():void
		{
			mainTextContainer = new fontContainer();
			// uncomment the below line to see the telegu text;
			//addChild(mainTextContainer);
			mainTextContainer.visible = false;
			mainTextContainer.alpha = 0;
			mainTextContainer.x = 100;
			mainTextContainer.y = 5;
			
			
			
			textBoxStyling = new TextFormat();
			textBoxStyling.color = 0x000000;
			textBoxStyling.size = 40;
			//textBoxStyling.font = "BRH Telugu";
			textBoxStyling.font = "Gautami";
			
			teleguTextField = new TextField();
			teleguTextField.autoSize = TextFieldAutoSize.LEFT;
			mainTextContainer.addChild(teleguTextField);
			//setupDialogueTextFields();
		}
		
		

		private function setupShopkeeper():void
		{
			dialogue_shopkeeper = new Sound(new URLRequest("Audio/dialogue6.mp3"));
			dialogue_shopkeeper2 = new Sound(new URLRequest("Audio/dialogue7.mp3"));
			
			shopkeeperTween = new Tween(shopkeeper_bubble,"alpha",Regular.easeIn,0,1,0.5,true);			
			shopkeeperTween.stop();
			
			shopkeeperTween2 = new Tween(shopkeeper_bubble,"alpha",Regular.easeIn,0,1,0.5,true);
			shopkeeperTween2.stop();
			
			shopkeeperTween3 = new Tween(shopkeeper_bubble,"alpha",Regular.easeIn,1,0,0.5,true);
			shopkeeperTween3.stop();
			
			shopkeeperTween4 = new Tween(shopkeeper_bubble,"alpha",Regular.easeIn,1,0,0.5,true);
			shopkeeperTween4.stop();
			
			addChild(shopkeeper_bubble);
			shopkeeper_bubble.visible = false;
			
			answer_selector = new AnswerSelection();
			addChild(answer_selector);
			answer_selector.visible = false;
			
			answer_selector_1 = new AnswerSelection();
			addChild(answer_selector_1);
			answer_selector_1.visible = false;
			
			answer_selector_1.x = 150;
			answer_selector_1.y = 150;
		}
		
		
		//private function startTheDialogues( e:Event):void {
		public function startTheDialogues(bubbleX:Number, bubbleY:Number, movieClip_1:MovieClip,movieClip_2:MovieClip,movieClip_3:MovieClip,movieClip_4:MovieClip,fruitsArray_1:Array,miscreantsVisibilityArray:Array,boy_visibilityClip_1:MovieClip):void {
			
			//rajuTween.removeEventListener(TweenEvent.MOTION_FINISH, startTheDialogues);
			//boy_mc.x = 470;
			//boy_mc.visible = true;
			//myMovingBoy.visible = false;
			//removeChild(myMovingBoy);
			tree_1_MovieClip = movieClip_1;
			tree_2_MovieClip = movieClip_2;
			tree_3_MovieClip = movieClip_3;
			tree_4_MovieClip = movieClip_4;
			raju_visibility_1 = boy_visibilityClip_1;
			externalFruitsArray = fruitsArray_1;
			miscreantsVisibilityArray_1 = miscreantsVisibilityArray;
			this.addEventListener(Event.ENTER_FRAME, enteredFrame);
			guessingTheGame = true;
			shopkeeper_bubble.visible = true;
			shopkeeper_bubble.x = bubbleX;
			shopkeeper_bubble.y = bubbleY;
			tryAgainBubbleX = bubbleX;
			tryAgainBubbleY = bubbleY;
			//shopkeeper_bubble.mother_speech.text = "What do you want, Raju?";
			shopkeeper_bubble.mother_speech.text = "";
			dialogueTextField_mother_1.text = "నీకు ఏ౦ కావాలి రాజు?";
			//dialogueTextField_mother_1.text = "hi how are you doing?";
			dialogueTextField_mother_1.setTextFormat(dialogueStyling);
			shopkeeperTween.start();
			shopkeeperTween.addEventListener(TweenEvent.MOTION_FINISH,shopkeeperDialogue1Finished);
			
			
			
		}
		private function shopkeeperDialogue1Finished(e:Event):void
		{
			shopkeeperTween.removeEventListener(TweenEvent.MOTION_FINISH,shopkeeperDialogue1Finished);
			soundChannel_shopkeeper = dialogue_shopkeeper.play();
			soundChannel_shopkeeper.addEventListener(Event.SOUND_COMPLETE, startTheGuessGame);
			
			
			
		}
		
		private function startTheGuessGame(e:Event):void {
			soundChannel_shopkeeper.removeEventListener(Event.SOUND_COMPLETE, startTheGuessGame);
			shopkeeperTween3.start();
			shopkeeperTween3.addEventListener(TweenEvent.MOTION_FINISH, shopkeeperDialogue1Finished_fadeOut);
			
			
		}
		private function shopkeeperDialogue1Finished_fadeOut(e:Event):void
		{
			shopkeeperTween3.removeEventListener(TweenEvent.MOTION_FINISH, shopkeeperDialogue1Finished_fadeOut);
			//boy_mc.gotoAndStop("front");
			dialogueTextField_mother_1.text = "";
			
			microphoneImageLoader.x = 90;
			microphoneImageLoader.y = 350;
			tree_1_MovieClip.alpha = 0.3;
			tree_2_MovieClip.alpha = 0.3;
			tree_3_MovieClip.alpha = 0.3;
			tree_4_MovieClip.alpha = 0.3;
			raju_visibility_1.alpha = 0.3
			for(visibilityCounter_1=0; visibilityCounter_1<miscreantsVisibilityArray_1.length;visibilityCounter_1 = visibilityCounter_1 + 1)
			miscreantsVisibilityArray_1[visibilityCounter_1].alpha = 0.3;
			
			externalFruitsArray[0].visible = false;
			externalFruitsArray[1].visible = false;
			externalFruitsArray[2].visible = false;
			externalFruitsArray[3].visible = false;
						
			loadImagesAndSound(FarmGame.questionNumber);
			//loadImagesAndSound(3);
			mainTextContainer.visible = true;
			answer_selector.visible = false;			
			answer_selector_1.visible = true;
			current_selection = 0;
			moveAnswerSelector();
			arrangeImagesRandomly();
			//playSound(null);
			speakingInstruction.visible = true;
			trace("coming before starting blinking text");
			startWordBlinking(null);
			
			//startPhonologicalHint();
		}
		public function startPhonologicalHint()
		{
			bar_invisible();
			microphoneImageLoader.visible = false;
			phonologicalPromptChannel = phonologicalPrompt.play();
			phonologicalPromptChannel.addEventListener(Event.SOUND_COMPLETE,speakPhonologicalHint);
		}
		public function speakPhonologicalHint(e:Event)
		{
			firstLetterSoundChannel = firstLetterSound.play();
			firstLetterSoundChannel.addEventListener(Event.SOUND_COMPLETE,playSound);
		}
		
		public function loadImagesAndSound(myIndex:int):void {
			/*if(Market.questionNumber>1)
			{
				removeChild(correct);
				removeChild(wrong);
			}*/
			wordSound = new Sound();
			wordSound_telegu = new Sound();
			wordSound.load(new URLRequest("Audio/" + FarmGame.syllabus[myIndex-1].audio));
			wordSound_telegu.load(new URLRequest("Audio/" + FarmGame.syllabus[myIndex-1].audio.substr(0,(FarmGame.syllabus[myIndex-1].audio.length)-4 ) + "_telegu.mp3"));
			teleguTextField.text = FarmGame.syllabus[myIndex-1].transliteration;
			teleguTextField.setTextFormat(textBoxStyling);
			loadImage("Images/" + FarmGame.syllabus[myIndex-1].image, 1);
						
			putTextInL2(FarmGame.syllabus[myIndex-1].name);
			firstLetterSound = new Sound();
			firstLetterSound.load(new URLRequest("Audio/firstLetterSounds/" + FarmGame.syllabus[myIndex-1].name +"_firstletter.mp3"));			
			addChild(correct);
			addChild(wrong);
			correct.visible = false;
			wrong.visible = false;
		}
		
		private function hidePreviousImages():void
		{
			var my_i:int;
			
			removeChild(answers[1].movie)
			
			removeChild(correct);
			removeChild(wrong);
			answer_selector.visible = false;
			answer_selector_1.visible = false;
			microphoneImageLoader.visible = false;
			speakingInstruction.visible = false;
			l2Word.visible = false;
			
			bar_invisible();
			
		}
		public function loadImage(filename:String, i:Number):void {
			//trace(filename);
			URLImage = new URLRequest(filename);
			image = new Loader();
			image.load(URLImage);
			answers[i] = new Object();
			answers[i].imageName = filename.substring(7);
			
			answers[i].movie = new MovieClip();
			addChild(answers[i].movie);
			answers[i].movie.addChild(image);
			
		}
		public function startWordBlinking(e:Event)
		{
			noOfL2Blinks = 6; 
			blinkL2Word(null);
		}
		public function blinkL2Word(e:TweenEvent)
		{
			if (blinkTween != null)
				blinkTween.removeEventListener(TweenEvent.MOTION_FINISH,blinkL2Word);
			
			noOfL2Blinks = noOfL2Blinks - 1;
			if (noOfL2Blinks >=0)
			{
				trace("coming in blinkTween function");
				blinkTween = new Tween(movieClipL2Word,"alpha",Regular.easeIn,1,0,0.5,true);
				blinkTween.start();
				//l2Word.alpha = 0;
				l2Word.visible = false;
				blinkTween.addEventListener(TweenEvent.MOTION_FINISH,makeBlinkReappear);
			}
			else
				//playSound(null);
				startPhonologicalHint();
				
		}
		public function makeBlinkReappear(e:TweenEvent)
		{
			blinkTween.removeEventListener(TweenEvent.MOTION_FINISH,makeBlinkReappear);
			blinkTween = new Tween(movieClipL2Word,"alpha",Regular.easeIn,0,1,0.5,true);
			blinkTween.start();
			//blinkTween.alpha = 1;
			l2Word.visible = true;
			blinkTween.addEventListener(TweenEvent.MOTION_FINISH,blinkL2Word);
		}
		
		public function playSound(event:Event):void {
			
			if (wrong.visible == true)
			{
				shopkeeperTween4.start();
				shopkeeperTween4.addEventListener(TweenEvent.MOTION_FINISH, shopkeeperDialogue2Finished_fadeOut);
			}
			else
			{
				microphoneImageLoader.visible = false;
				bar_invisible();
				speakNow_soundChannel = speakNow.play();
				speakNow_soundChannel.addEventListener(Event.SOUND_COMPLETE,soundIsComplete);
			}
		}
		private function playTeleguSoundNow(e:Event):void
		{
			wordSoundChannel_telegu = wordSound_telegu.play();
			wordSoundChannel_telegu.addEventListener(Event.SOUND_COMPLETE, soundIsComplete);
		}
		private function shopkeeperDialogue2Finished_fadeOut(e:Event):void
		{
			shopkeeperTween4.removeEventListener(TweenEvent.MOTION_FINISH, shopkeeperDialogue2Finished_fadeOut);
			
			answers[1].movie.alpha = 1;
			wrong.alpha = 1;
			answer_selector_1.alpha = 1;
			
				
			for(visibilityCounter_1=0; visibilityCounter_1<miscreantsVisibilityArray_1.length;visibilityCounter_1 = visibilityCounter_1 + 1)
				miscreantsVisibilityArray_1[visibilityCounter_1].alpha = 0.3;				
			
			dialogueTextField_mother_1.text = "";
			tree_1_MovieClip.alpha = 0.3;
			tree_2_MovieClip.alpha = 0.3;
			tree_3_MovieClip.alpha = 0.3;
			tree_4_MovieClip.alpha = 0.3;	
			raju_visibility_1.alpha = 0.3;
			correct.visible = false;
			wrong.visible = false;
			mainTextContainer.visible = true;
			arrangeImagesRandomly();
			current_selection = 0;
			
			if (noOfTries >=3)
			{
				noOfTries = 0;
				wordSoundChannel = wordSound.play();
				wordSoundChannel.addEventListener(Event.SOUND_COMPLETE,wordReiterated_1);
				return;
			}
			
			else
			{
				moveAnswerSelector();
			
				speakNow_soundChannel = speakNow.play();
				speakNow_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundIsComplete);					
			}			
			
		}
		private function wordReiterated_1(e:Event):void
		{
			moveAnswerSelector();
			
			speakNow_soundChannel = speakNow.play();
			speakNow_soundChannel.addEventListener(Event.SOUND_COMPLETE, soundIsComplete);					
		}
		public function soundIsComplete(e:Event):void {
			bar_visible_repeatWord();
			moveSelector = true;
			
			microphoneImageLoader.visible = true;
			
			
			// the recognizer code is added here.
			FarmGame.sock.addEventListener(SockConnection.DATA_CHANGED, checkAnswer);
		}
		
		public function arrangeImagesRandomly():void {
			answers[1].movie.x = 150;
			answers[1].movie.y = 150;			
		}
		
		public function enteredFrame(e:Event):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN,moveSelection);
			
			removeEventListener(Event.ENTER_FRAME, enteredFrame);
		}
		
		public function moveSelection(e:KeyboardEvent):void 
		{
			
			if(repeat.visible == true)
			{
				if (e.keyCode == 81) // keycode for q
				//if (e.keyCode == Keyboard.SPACE)
				{
					FarmGame.sock.removeEventListener(SockConnection.DATA_CHANGED, checkAnswer);
					moveSelector = false;
					playSound(null);
				}
			}
			
			if (nextWord.visible == true)
			{
				if (e.keyCode == 80) // keycode for p
				//if (e.keyCode == Keyboard.ENTER)
				{
					guessingTheGame = false;
					levelComplete = true;
					
					for(visibilityCounter_1=0; visibilityCounter_1<miscreantsVisibilityArray_1.length;visibilityCounter_1 = visibilityCounter_1 + 1)
					miscreantsVisibilityArray_1[visibilityCounter_1].alpha = 1;
					raju_visibility_1.alpha = 1;
					loadTheNextQuestion();
					
				}
			}
			if(moveSelector == true)
			{
				if (e.keyCode == Keyboard.RIGHT && current_selection%2==0) {
					current_selection++;
				} else if (e.keyCode == Keyboard.LEFT && current_selection%2==1) {
					current_selection--;
				} else if (e.keyCode == Keyboard.UP && current_selection>1) {
					current_selection=current_selection-2;
				} else if (e.keyCode == Keyboard.DOWN && current_selection<2) {
					current_selection=current_selection+2;
				} 
				moveAnswerSelector();
			}
		}
		
		public function checkAnswer(event:Event):void 
		{
			moveSelector = false;
			bar_invisible();
			FarmGame.sock.removeEventListener(SockConnection.DATA_CHANGED, checkAnswer);
			
			compareString = FarmGame.sock._data[0];
			compareString = compareString.toLowerCase();
			var comparingStrings:Array = compareString.split('\ ');
			
			var compareStringCounter:int = 0;
			//trace(comparingStrings);
			for (compareStringCounter = 0; compareStringCounter < comparingStrings.length; compareStringCounter = compareStringCounter + 1)
			{
				comparingStrings[compareStringCounter] = comparingStrings[compareStringCounter] + ".png";
			}
			
			compareString = compareString + ".png";
			
			time = new Date();
			echoLog(time.getDate()+ "/" + (time.getMonth() + 1)+ "/" + time.getFullYear()+ ", "+time.getHours()+"/"+time.getMinutes()+"/"+time.getSeconds()+"/"+time.getMilliseconds()+ ", Recall, " +answers[1].imageName + ", " + compareString + ", ");
			
			
			for (compareStringCounter = 0; compareStringCounter < comparingStrings.length; compareStringCounter = compareStringCounter + 1)
			{
				//if(imageFilenames[imageNumber_1] == comparingStrings[compareStringCounter])
				if(comparingStrings[compareStringCounter].search(answers[1].imageName) != -1)
				{
					congratulations();
					//break;
					return;
				}
				
			}
			tryAgain();
			//Market.sock.sendData("pause\n");
			
		}
		
		public function echoLog(str:String)
		{
			FarmGame.sock.sendData("echo \'"+str+"\' >> log.txt");
		}
		private function congratulations(): void {
			
			moveSelector = false;
			correct.visible = true;
			correct.x = answers[1].movie.x + 37.5;
			correct.y = answers[1].movie.y + 37.5;
			microphoneImageLoader.visible = false;
			congratsSoundChannel = congratsVoiceOver.play();
			congratsSoundChannel.addEventListener(Event.SOUND_COMPLETE, congratsVoiceoverFinished);
			
			SyllabusQueue.updateWordWeight(FarmGame.syllabus[FarmGame.questionNumber-1].name,1);
			//nextWord.addEventListener(MouseEvent.CLICK, loadTheNextQuestion);
		}
		
		private function congratsVoiceoverFinished(e:Event):void
		{
			bar_visible_nextWord();
		}
		/*public function updateSyllabusList_1():void
		{
			if (FarmGame.questionNumber<=5)
				SyllabusQueue.updateWordWeight(FarmGame.syllabus[FarmGame.questionNumber-1].name,1);
			
			if (FarmGame.questionNumber>5)
			{
				FarmGame.questionNumber = 1;
				SyllabusQueue.updateSyllabusQueue();
			}			
			
		}*/
		private function loadTheNextQuestion():void
		{
			//nextWord.removeEventListener(MouseEvent.CLICK, loadTheNextQuestion);
			
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,moveSelection);
			FarmGame.questionNumber++;
			//levelComplete = false;
			
			noOfTries = 0;
			
			if(FarmGame.questionNumber>5) {
				
				FarmGame.questionNumber = 1;
				mainTextContainer.visible = false;
				//removeChild(myMovingBoy);
				gotoNextRound();
				return;
			}
			hidePreviousImages();
			mainTextContainer.visible = false;
			
		}
		
		private function tryAgain(): void {
			noOfTries = noOfTries + 1;
			wrong.visible = true;
			wrong.x = answers[1].movie.x + 37.5;
			wrong.y = answers[1].movie.y + 37.5;
			microphoneImageLoader.visible = false;
			
			if (noOfTries >2)
			{
				moveSelector = false;
				microphoneImageLoader.visible = false;
				bar_visible_nextWord();
				
				
			}
			else
			{
				shopkeeperDialogue("Audio/dialogue7.mp3","Try Again!");
				dialogueTextField_mother_1.text = "మళ్ళీ చేసి చూడు";
				dialogueTextField_mother_1.setTextFormat(dialogueStyling);
			}
		}
		
		private function shopkeeperDialogue(audio:String, text:String):void {
			
			shopkeeper_bubble.visible = true;
			shopkeeperTween2.start();
			
			
			answers[1].movie.alpha = 0.3;
			wrong.alpha = 0.3;
			answer_selector_1.alpha = 0.3;
			//mainTextContainer.visible = false;
				
			for(visibilityCounter_1=0; visibilityCounter_1<miscreantsVisibilityArray_1.length;visibilityCounter_1 = visibilityCounter_1 + 1)
				miscreantsVisibilityArray_1[visibilityCounter_1].alpha = 1;
			
			tree_1_MovieClip.alpha = 1;
			tree_2_MovieClip.alpha = 1;
			tree_3_MovieClip.alpha = 1;
			tree_4_MovieClip.alpha = 1;
			raju_visibility_1.alpha = 1;
			shopkeeperTween2.addEventListener(TweenEvent.MOTION_FINISH,shopkeeperDialogue2Finished);
			shopkeeper_bubble.x = tryAgainBubbleX;
			shopkeeper_bubble.y = tryAgainBubbleY;
			shopkeeper_bubble.mother_speech.text = "";
		}
		private function shopkeeperDialogue2Finished(e:Event):void
		{
			shopkeeperTween2.removeEventListener(TweenEvent.MOTION_FINISH,shopkeeperDialogue2Finished);
			soundChannel_shopkeeper = dialogue_shopkeeper2.play();
			soundChannel_shopkeeper.addEventListener(Event.SOUND_COMPLETE, playSound);
		}
		
		private function gotoNextRound():void {
			SyllabusQueue.updateSyllabusQueue();
			
			
			
			//Now transfer control back to the narrative screen
			gameFinished = true;
			hidePreviousImages();
			//removeChild(boy_mc);						
		}
		
		public function moveAnswerSelector():void {
			if(current_selection%2==0)
				answer_selector.x = 50;
			else
				answer_selector.x = 250;
					
			if(current_selection<2)
				answer_selector.y = 50;
			else
				answer_selector.y = 250;
		}
		
		public function setUpButtons()
		{
			repeat = new MovieClip();
			nextWord = new MovieClip();
			bottomBar = new ImageToMovie("Images/horizontalBar.jpg");
			bottomBar.setX(0);
			bottomBar.setY(453);
			bottomBar.scaleX = 1.61;
			
			buttonTextLeft = new TextField();
			buttonTextRight = new TextField();
			buttonTextLeft_telegu = new TextField();
			buttonTextRight_telegu = new TextField();
			buttonTextLeft_telegu.text = " మళ్ళీ చెయ్యి";
			buttonTextRight_telegu.text = " ము౦దుకు";
			buttonTextLeft_telegu.x = 0;
			buttonTextLeft_telegu.y = -4;
			buttonTextRight_telegu.x = 0;
			buttonTextRight_telegu.y = -4;
			buttonTextRight_telegu.width = 350;
			buttonTextLeft_telegu.width = 350;
			
			softKeys("Repeat", "Next");
			buttonTextRight.autoSize = TextFieldAutoSize.LEFT;
			buttonTextLeft.autoSize = TextFieldAutoSize.LEFT;
			textStyling = new TextFormat();
			textStyling.size = 24;
			textStyling.color = 0xFFFFFF;
			
			textStyling_telegu_5 = new TextFormat();
			textStyling_telegu_5.size = 24;
			textStyling_telegu_5.color = 0xFFFFFF;
			//textStyling_telegu_5.font = "BRH Telugu";
			textStyling_telegu_5.font = "Gautami";
			
			buttonTextLeft.setTextFormat(textStyling);
			buttonTextRight.setTextFormat(textStyling);
			buttonTextRight_telegu.setTextFormat(textStyling_telegu_5);
			buttonTextLeft_telegu.setTextFormat(textStyling_telegu_5);
			
			buttonTextLeft_telegu.x = buttonTextLeft.width + 10;
			buttonTextRight_telegu.x = buttonTextRight.width + 10;
			
			bar_invisible();
			addChild(bottomBar);
			addChild(repeat);
			addChild(nextWord);
			
			repeat.addChild(buttonTextLeft);
			repeat.addChild(buttonTextLeft_telegu);
			repeat.x = 20;
			repeat.y = 450;
			nextWord.addChild(buttonTextRight);
			nextWord.addChild(buttonTextRight_telegu);
			nextWord.x = 600;
			nextWord.y = 450;
		}
		
		public function softKeys(textLeftKey:String, textRightKey:String) {
			buttonTextLeft.text = textLeftKey;
			buttonTextRight.text = textRightKey;
		}
		
		
		
		public function bar_invisible():void {
			bottomBar.hideImage();
			repeat.visible = false;
			nextWord.visible = false;
		}
		
		public function bar_visible_nextWord():void {
			bottomBar.showImage();
			repeat.visible = false;
			nextWord.visible = true;
		}
		public function bar_visible_repeatWord():void
		{
			bottomBar.showImage();
			repeat.visible = true;
			nextWord.visible = false;
		}
	}
}