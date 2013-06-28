//
//  GameOverLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-03-09.
//  Copyright 2012 Smashware. All rights reserved.
//


#import "MenuLayer.h"
#import "GameOverLayer.h"
#import "GameLayer.h"
#import "Profile.h"

@implementation GameOverLayer

@synthesize earnedCoins;
@synthesize victory;
@synthesize subText;
@synthesize mode;

CCLabelTTF *coinsLabel;

+(CCScene *) sceneWithVictory:(BOOL)victoryInput subText:(NSString*)subTextInput earnedCoins:(int)earnedCoinsInput fromMode:(NSString *)mode {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
    layer.earnedCoins = earnedCoinsInput;
    layer.victory = victoryInput;
    layer.subText = subTextInput;
    layer.mode = mode;
    [layer showGraphics];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id) init {
	if( (self=[super init])) {
        buttons = [[NSMutableArray alloc] init];
        
        // SET BACKGROUND
        CCSprite *background = [CCSprite spriteWithFile: @"PaperBackgroundWhite.png"];
        [background setPosition:[self makeScaledPointx:240 y:160]];
        [self addChild:background z:-1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //[background setScale:1.2];
        }
        
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)showGraphics {
    id initialDelay = [CCDelayTime actionWithDuration:0.5];
    float delayTime = 0.5;
    
    SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
    [audioEngine stopBackgroundMusic];
    
    CCSprite *title;
    if (victory) {
        [audioEngine playBackgroundMusic:@"victory.mp3" loop:NO];
        title = [CCSprite spriteWithFile: @"victorytext.png"];
    }
    else {
        [audioEngine playBackgroundMusic:@"defeat.wav" loop:NO];
        title = [CCSprite spriteWithFile: @"defeattext.png"];
    }
    [title setPosition:[self makeScaledPointx:235 y:270]];
    title.opacity = 0;
    [self addChild:title z:0];
    id fade = [CCFadeIn actionWithDuration:delayTime];
    id move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:248 y:270]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [title runAction:[CCSequence actions:initialDelay,spawn, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:subText dimensions:CGSizeMake([self makeScaledInt:800], [self makeScaledInt:40]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:30]];        
    [subTitle setPosition:[self makeScaledPointx:230 y:210]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    fade = [CCFadeIn actionWithDuration:delayTime];
    move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:243 y:210]];
    spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:initialDelay,spawn, nil]];
    
    if ([mode isEqualToString:@"Tutorial"]) {
        CCLabelTTF *welcome = [CCLabelTTF labelWithString:@"Congratulations on completing the tutorial, now you can pick a deck!" dimensions:CGSizeMake([self makeScaledInt:420], [self makeScaledInt:200]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:30]];
        [welcome setPosition:[self makeScaledPointx:240 y:35]];
        [welcome setColor:ccBLACK];
        welcome.opacity = 0;
        [self addChild:welcome z:0];
        id fade = [CCFadeIn actionWithDuration:1.0];
        id move = [CCMoveBy actionWithDuration:1.0 position:[self makeScaledPointx:0 y:10]];
        id spawn = [CCSpawn actions:fade,move, nil];
        
        id delay;
        delay = [CCDelayTime actionWithDuration:2.0];
        
        [welcome runAction:[CCSequence actions:delay,spawn, nil]];
        
        CCSprite *okButton = [CCSprite spriteWithFile: @"OkMenuButton.png"];
        [buttons addObject:okButton];
        [okButton setPosition:[self makeScaledPointx:240 y:35]];
        okButton.tag = 4;
        okButton.opacity = 0;
        [self addChild:okButton z:0];
        delay = [CCDelayTime actionWithDuration:2.0];
        fade = [CCFadeIn actionWithDuration:1.0];
        move = [CCMoveBy actionWithDuration:1.0 position:[self makeScaledPointx:0 y:10]];
        spawn = [CCSpawn actions:move,fade, nil];
        [okButton runAction:[CCSequence actions:delay,spawn, nil]];
    }
    else {
        CCSprite *coins = [CCSprite spriteWithFile: @"profilecoins.png"];
        [coins setPosition:[self makeScaledPointx:185 y:125]];
        coins.opacity = 0;
        [self addChild:coins z:0];
        fade = [CCFadeIn actionWithDuration:delayTime];
        move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:205 y:125]];
        spawn = [CCSpawn actions:move,fade, nil];
        id delay = [CCDelayTime actionWithDuration:delayTime];
        [coins runAction:[CCSequence actions:initialDelay,delay,spawn, nil]];
        
        coinsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [[Profile sharedProfile] coins]] dimensions:CGSizeMake([self makeScaledInt:100], [self makeScaledInt:50]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:42]];
        coinsLabel.color = ccc3(176, 121, 31);
        [coinsLabel setPosition:[self makeScaledPointx:240 y:125]];
        coinsLabel.opacity = 0;
        [self addChild:coinsLabel z:0];
        fade = [CCFadeIn actionWithDuration:delayTime];
        move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:273 y:125]];
        spawn = [CCSpawn actions:move,fade, nil];
        delay = [CCDelayTime actionWithDuration:delayTime];
        id grow = [CCScaleTo actionWithDuration:0.2 scale:1.4];
        id shrink = [CCScaleTo actionWithDuration:0.2 scale:1.0];
        id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"coins.wav"];
        id addCoins = [CCCallFunc actionWithTarget:self selector:@selector(addCoins)];
        
        float postCoinDelay;
        if (earnedCoins > 0) {
            postCoinDelay = delayTime*6;
            [coinsLabel runAction:[CCSequence actions:initialDelay,delay,spawn,delay,playSound,addCoins,grow,shrink, nil]];
            
            CCLabelTTF *newCoinsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d",earnedCoins] dimensions:CGSizeMake(70, 50) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:42]];
            newCoinsLabel.color = ccc3(176, 121, 31);
            [newCoinsLabel setPosition:[self makeScaledPointx:270 y:145]];
            newCoinsLabel.opacity = 0;
            [self addChild:newCoinsLabel z:0];
            fade = [CCFadeOut actionWithDuration:1.5];
            move = [CCMoveTo actionWithDuration:1.5 position:[self makeScaledPointx:273 y:175]];
            spawn = [CCSpawn actions:move,fade, nil];
            delay = [CCDelayTime actionWithDuration:delayTime*3];
            id setOpacity = [CCFadeIn actionWithDuration:0.05];
            [newCoinsLabel runAction:[CCSequence actions:initialDelay,delay,setOpacity,spawn,nil]];
        }
        else {
            float postCoinDelay = delayTime*3;
            [coinsLabel runAction:[CCSequence actions:initialDelay,delay,spawn, nil]];
        }
        
        CCSprite *playAgain;
        if ([mode isEqualToString:@"Tournament"]) {
            playAgain = [CCSprite spriteWithFile: @"ContinueButton.png"];
            playAgain.tag = 3;
        }
        else {
            playAgain = [CCSprite spriteWithFile: @"playagain.png"];
            playAgain.tag = 2;
        }
        [buttons addObject:playAgain];
        [playAgain setPosition:[self makeScaledPointx:360 y:20]];
        playAgain.opacity = 0;
        [self addChild:playAgain z:0];
        delay = [CCDelayTime actionWithDuration:postCoinDelay];
        fade = [CCFadeIn actionWithDuration:delayTime];
        move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:360 y:40]];
        spawn = [CCSpawn actions:move,fade, nil];
        [playAgain runAction:[CCSequence actions:initialDelay,delay,spawn, nil]];
        
        CCSprite *mainMenu = [CCSprite spriteWithFile: @"mainmenu.png"];
        [buttons addObject:mainMenu];
        [mainMenu setPosition:[self makeScaledPointx:120 y:20]];
        mainMenu.tag = 1;
        mainMenu.opacity = 0;
        [self addChild:mainMenu z:0];
        delay = [CCDelayTime actionWithDuration:postCoinDelay];
        fade = [CCFadeIn actionWithDuration:delayTime];
        move = [CCMoveTo actionWithDuration:delayTime position:[self makeScaledPointx:120 y:40]];
        spawn = [CCSpawn actions:move,fade, nil];
        [mainMenu runAction:[CCSequence actions:initialDelay,delay,spawn, nil]];
    }
}

- (void)actionForButton:(CCSprite*)button {
    if (button.tag == 1) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer sceneWithAnimation:YES]]];
    }
    else if (button.tag == 2) {
        if ([mode isEqualToString:@"Multiplayer"])
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer multiplayerScene]]];
        else
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer practiceScene]]];
    }
}

- (void)addCoins {
    Profile *profile = [Profile sharedProfile];
    profile.coins += earnedCoins;
    coinsLabel.string = [NSString stringWithFormat:@"%d",profile.coins];
    
    [profile saveProfile];
    /*NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:profile.coins forKey:@"coins"];
    [defaults synchronize];*/
}

- (void)dealloc {
    [buttons release];
    [super dealloc];
}

@end
