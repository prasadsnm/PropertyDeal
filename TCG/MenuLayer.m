//
//  MenuLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-25.
//  Copyright 2012 Smashware. All rights reserved.
//

#import "MenuLayer.h"
#import "GameLayer.h"
#import "SimpleAudioEngine.h"
#import "GameOverLayer.h"
#import "StoreLayer.h"
#import "PopUpLayer.h"
#import "Profile.h"

#define FLOAT_DISTANCE 20
#define HEAD_MOVE_DISTANCE 80

CCLabelTTF *playLabel;
CCLabelTTF *optionsLabel;
CCSprite *storeLabel;
CCLabelTTF *singlePlayerLabel;
CCLabelTTF *multiplayerLabel;
CCLabelTTF *backLabel;
CCSprite *tournamentLabel;
CCSprite *practiceLabel;
CCSprite *leftSprite;
CCSprite *rightSprite;
CCSprite *musicButton;
CCSprite *audioButton;

NSString *menuState;
NSString *fontName;

@implementation MenuLayer

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    fontName = @"Badaboom.ttf";

	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
    [layer showMenuWithAnimation:YES];

	// add layer as a child to scene
	[scene addChild: layer];
        	
	// return the scene
	return scene;
}

+(CCScene *) sceneWithAnimation:(BOOL)animation {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
    fontName = @"Badaboom.ttf";
    
	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
    [layer showMenuWithAnimation:animation];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		// create and initialize our seeker sprite, and add it to this layer
        buttons = [[NSMutableArray alloc] init];
        
        // SET BACKGROUND
        CCSprite *background = [CCSprite spriteWithFile: @"PaperBackgroundDark.png"];
        [background setPosition:[self makeScaledPointx:240 y:160]];
        [self addChild:background z:-1];
                        
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)showMenuWithAnimation:(BOOL)animation {
    float duration = 0.7;
    
    CCSprite *ultimate = [CCSprite spriteWithFile:@"UltimateMain.png"];
    [ultimate setPosition:[self makeScaledPointx:244 y:280]];
    [self addChild:ultimate z:0];
    
    CCSprite *showdown = [CCSprite spriteWithFile:@"ShowdownMain.png"];
    [showdown setPosition:[self makeScaledPointx:244 y:225]];
    [self addChild:showdown z:0];
    
    leftSprite = [CCSprite spriteWithFile: @"robohead.png"];
    [leftSprite setPosition:[self makeScaledPointx:75-HEAD_MOVE_DISTANCE y:132]];
    [self addChild:leftSprite z:0];
    
    rightSprite = [CCSprite spriteWithFile: @"zombiehead.png"];
    [rightSprite setPosition:[self makeScaledPointx:405+HEAD_MOVE_DISTANCE y:132]];

    //rightSprite.scaleX = -1;
    [self addChild:rightSprite z:0];
    
    [leftSprite setOpacity:0];
    [rightSprite setOpacity:0];
    [leftSprite runAction:[CCMoveBy actionWithDuration:duration position:ccp(HEAD_MOVE_DISTANCE,0)]];//[self makeScaledPointx:HEAD_MOVE_DISTANCE y:0]]];
    [leftSprite runAction:[CCFadeIn actionWithDuration:duration]];
    [rightSprite runAction:[CCMoveBy actionWithDuration:duration position:ccp(-HEAD_MOVE_DISTANCE,0)]];//[self makeScaledPointx:-HEAD_MOVE_DISTANCE y:0]]];
    [rightSprite runAction:[CCFadeIn actionWithDuration:duration]];
    
    musicButton = [CCSprite spriteWithFile:@"MusicIcon.png"];
    [musicButton setPosition:[self makeScaledPointx:450 y:290]];
    [musicButton setOpacity:0];
    if (animation)
        [musicButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0],[CCFadeIn actionWithDuration:duration], nil]];
    else
        [musicButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.0],[CCFadeIn actionWithDuration:duration], nil]];

    [buttons addObject:musicButton];
    musicButton.tag = 100;
    [self addChild:musicButton];
    
    /*audioButton = [CCSprite spriteWithFile:@"AudioIcon.png"];
     [audioButton setPosition:[self makeScaledPointx:445 y:290]];
     [audioButton setOpacity:0];
     [audioButton runAction:[CCFadeIn actionWithDuration:duration]];
     [buttons addObject:audioButton];
     audioButton.tag = 101;
     [self addChild:audioButton];*/
    
    Profile *profile = [Profile sharedProfile];
    if ([profile.currentDeck count] == 0 && [profile.availableCards count] == 0 && [profile.decks count] == 0) {
        CCLabelTTF *welcome = [CCLabelTTF labelWithString:@"Welcome!" dimensions:CGSizeMake([self makeScaledInt:380], [self makeScaledInt:150]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:30]];
        [welcome setPosition:[self makeScaledPointx:240 y:100]];
        welcome.opacity = 0;
        welcome.color = ccc3(250, 250, 250);
        [self addChild:welcome z:0];
        id fade = [CCFadeIn actionWithDuration:duration];
        id move = [CCMoveTo actionWithDuration:duration position:[self makeScaledPointx:240 y:110]];
        id spawn = [CCSpawn actions:fade,move, nil];
        
        id delay;
        if (animation)
            delay = [CCDelayTime actionWithDuration:3.0];
        else
            delay = [CCDelayTime actionWithDuration:0.0];
        
        [welcome runAction:[CCSequence actions:delay,spawn, nil]];
        
        CCLabelTTF *subTitle = [CCLabelTTF labelWithString:@"Would you like to play the tutorial before choosing a deck?" dimensions:CGSizeMake([self makeScaledInt:200], [self makeScaledInt:150]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:25]];
        [subTitle setPosition:[self makeScaledPointx:235 y:65]];
        subTitle.opacity = 0;
        subTitle.color = ccc3(250, 250, 250);
        [self addChild:subTitle z:0];
        fade = [CCFadeIn actionWithDuration:duration];
        move = [CCMoveTo actionWithDuration:duration position:[self makeScaledPointx:235 y:75]];
        spawn = [CCSpawn actions:fade,move, nil];
        [subTitle runAction:[CCSequence actions:delay,spawn, nil]];
        
        CCSprite *noButton = [CCSprite spriteWithFile:@"NoButton.png"];
        [noButton setOpacity:0];
        [noButton setPosition:[self makeScaledPointx:180 y:20]];
        noButton.tag = 6;
        [buttons addObject:noButton];
        [self addChild:noButton];
        id moveUp = [CCMoveBy actionWithDuration:duration position:[self makeScaledPointx:0 y:10]];
        id fadeIn = [CCFadeIn actionWithDuration:duration];
        id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [noButton runAction:[CCSequence actions:delay,moveAndFade, nil]];
        
        CCSprite *okButton = [CCSprite spriteWithFile:@"YesButton.png"];
        [okButton setOpacity:0];
        [okButton setPosition:[self makeScaledPointx:290 y:20]];
        okButton.tag = 9;
        [buttons addObject:okButton];
        [self addChild:okButton];
        moveUp = [CCMoveBy actionWithDuration:duration position:[self makeScaledPointx:0 y:10]];
        fadeIn = [CCFadeIn actionWithDuration:duration];
        moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [okButton runAction:[CCSequence actions:delay,moveAndFade, nil]];
    }
    else {
        if (animation)
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3.0],[CCCallFuncND actionWithTarget:self selector:@selector(cocosSwitchToMenu:data:) data:@"Main"], nil]];
        else
            [self runAction:[CCSequence actions:[CCCallFuncND actionWithTarget:self selector:@selector(cocosSwitchToMenu:data:) data:@"Main"], nil]];
    }
    
    if (animation) {
        [showdown setOpacity:0];
        [showdown setScale:0.5];
        [showdown runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0],[CCSpawn actions:[CCScaleTo actionWithDuration:0.1 scale:1.0],[CCFadeIn actionWithDuration:0.1], nil],[CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"slam.wav"], nil]];
        [ultimate setOpacity:0];
        [ultimate setScale:0.5];
        [ultimate runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCSpawn actions:[CCScaleTo actionWithDuration:0.1 scale:1.0],[CCFadeIn actionWithDuration:0.1], nil],[CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"slam.wav"], nil]];
    }
    
    // PRELOAD SOUNDS
    SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
    [audioEngine preloadEffect:@"select.wav"];
    if (!profile.muted) {
        [audioEngine playBackgroundMusic:@"tunneled.mp3" loop:YES];
        [audioEngine setBackgroundMusicVolume:BACKGROUND_VOLUME];
    }
}

- (void)switchToMenu:(NSString*)menu {
    // REMOVE OLD MENU ITEMS
    if ([menuState isEqualToString:@"Main"]) {
        [self removeChild:playLabel cleanup:YES];
        [buttons removeObject:playLabel];
        [self removeChild:optionsLabel cleanup:YES];
        [buttons removeObject:optionsLabel];
        [self removeChild:storeLabel cleanup:YES];
        [buttons removeObject:storeLabel];
        playLabel = nil;
        optionsLabel = nil;
        storeLabel = nil;
    }
    else if ([menuState isEqualToString:@"Play"]) {
        [self removeChild:singlePlayerLabel cleanup:YES];
        [self removeChild:multiplayerLabel cleanup:YES];
        if ([menu isEqualToString:@"Main"])
            [self removeChild:backLabel cleanup:YES];
    }
    else if ([menuState isEqualToString:@"Single Player"]) {
        [self removeChild:tournamentLabel cleanup:YES];
        [self removeChild:practiceLabel cleanup:YES];
    }
    
    // ADD NEW MENU ITEMS 
    if ([menu isEqualToString:@"Main"]) {
        playLabel = [CCSprite spriteWithFile:@"MenuPlay.png"];
        [playLabel setOpacity:0];
        [playLabel setPosition:[self makeScaledPointx:240 y:140-FLOAT_DISTANCE]];
        playLabel.tag = 1;
        [buttons addObject:playLabel];
        [self addChild:playLabel];
        id delay = [CCDelayTime actionWithDuration:0.4];
        id moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:140]];
        id fadeIn = [CCFadeIn actionWithDuration:0.4];
        id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [playLabel runAction:[CCSequence actions:moveAndFade, nil]];
        
        optionsLabel = [CCSprite spriteWithFile:@"MenuDecks.png"];
        [optionsLabel setOpacity:0];
        [optionsLabel setPosition:[self makeScaledPointx:240 y:95-FLOAT_DISTANCE]];
        optionsLabel.tag = 2;
        [buttons addObject:optionsLabel];
        [self addChild:optionsLabel];
        delay = [CCDelayTime actionWithDuration:0.4];
        moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:95]];
        fadeIn = [CCFadeIn actionWithDuration:0.4];
        moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [optionsLabel runAction:[CCSequence actions:moveAndFade, nil]];
        
        storeLabel = [CCSprite spriteWithFile:@"MenuStore.png"];
        [storeLabel setOpacity:0];
        [storeLabel setPosition:[self makeScaledPointx:240 y:50-FLOAT_DISTANCE]];
        storeLabel.tag = 3;
        [buttons addObject:storeLabel];
        [self addChild:storeLabel];
        delay = [CCDelayTime actionWithDuration:0.4];
        moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:50]];
        fadeIn = [CCFadeIn actionWithDuration:0.4];
        moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [storeLabel runAction:[CCSequence actions:moveAndFade, nil]];
    }
    else {
        if (![self.children containsObject:backLabel]) {
            backLabel = [CCSprite spriteWithFile:@"MenuBack.png"];
            [backLabel setOpacity:0];
            [backLabel setPosition:[self makeScaledPointx:240 y:30]];
            backLabel.tag = 0;
            [buttons addObject:backLabel];
            [self addChild:backLabel];
            id fadeIn = [CCFadeIn actionWithDuration:0.4];
            [backLabel runAction:fadeIn];
        }
    }
    
    if ([menu isEqualToString:@"Play"]) {
        singlePlayerLabel = [CCSprite spriteWithFile:@"MenuSinglePlayer.png"];
        [singlePlayerLabel setOpacity:0];
        [singlePlayerLabel setPosition:[self makeScaledPointx:240 y:140-FLOAT_DISTANCE]];
        singlePlayerLabel.tag = 4;
        [buttons addObject:singlePlayerLabel];
        [self addChild:singlePlayerLabel];
        id delay = [CCDelayTime actionWithDuration:0.4];
        id moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:140]];
        id fadeIn = [CCFadeIn actionWithDuration:0.4];
        id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [singlePlayerLabel runAction:[CCSequence actions:moveAndFade, nil]];
        
        multiplayerLabel = [CCSprite spriteWithFile:@"MenuMultiplayer.png"];
        [multiplayerLabel setOpacity:0];
        [multiplayerLabel setPosition:[self makeScaledPointx:240 y:95-FLOAT_DISTANCE]];
        multiplayerLabel.tag = 5;
        [buttons addObject:multiplayerLabel];
        [self addChild:multiplayerLabel];
        delay = [CCDelayTime actionWithDuration:0.4];
        moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:95]];
        fadeIn = [CCFadeIn actionWithDuration:0.4];
        moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [multiplayerLabel runAction:[CCSequence actions:moveAndFade, nil]];
    }
    
    if ([menu isEqualToString:@"Single Player"]) {
        tournamentLabel = [CCSprite spriteWithFile:@"MenuTournament.png"];
        [tournamentLabel setOpacity:0];
        [tournamentLabel setPosition:[self makeScaledPointx:240 y:140-FLOAT_DISTANCE]];
        tournamentLabel.tag = 7;
        [buttons addObject:tournamentLabel];
        [self addChild:tournamentLabel];
        id delay = [CCDelayTime actionWithDuration:0.4];
        id moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:140]];
        id fadeIn = [CCFadeIn actionWithDuration:0.4];
        id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [tournamentLabel runAction:[CCSequence actions:moveAndFade, nil]];
        
        practiceLabel = [CCSprite spriteWithFile:@"MenuSkirmish.png"];
        [practiceLabel setOpacity:0];
        [practiceLabel setPosition:[self makeScaledPointx:240 y:95-FLOAT_DISTANCE]];
        practiceLabel.tag = 8;
        [buttons addObject:practiceLabel];
        [self addChild:practiceLabel];
        delay = [CCDelayTime actionWithDuration:0.4];
        moveUp = [CCMoveTo actionWithDuration:0.4 position:[self makeScaledPointx:240 y:95]];
        fadeIn = [CCFadeIn actionWithDuration:0.4];
        moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
        [practiceLabel runAction:[CCSequence actions:moveAndFade, nil]];
    }
    
    
    menuState = menu;
}

- (void)actionForButton:(CCSprite*)button {
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.wav" pitch:0.8 pan:1.0 gain:0.8];
    if (button.tag == 0) {
        if ([menuState isEqualToString:@"Play"])
            [self switchToMenu:@"Main"];
        else if ([menuState isEqualToString:@"Single Player"])
            [self switchToMenu:@"Play"];
    }
    else if (button.tag == 1) {
        Profile *profile = [Profile sharedProfile];
        if ([profile.currentDeck count] < 20)
            [self showPopUpWithText:@"Your deck must have at least 20 cards in it!"];
        else
            [self switchToMenu:@"Play"];
    }
    else if (button.tag == 2) {
    }
    else if (button.tag == 3) {
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:NO subText:@"Myrus primeus" earnedCoins:30 fromMode:@"Practice"]]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[StoreLayer scene]]];
    }
    else if (button.tag == 4) {
        [self switchToMenu:@"Single Player"];
    }
    else if (button.tag == 5) {
        NSError *e;
        NSString *newestVersion = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://www.smashwareapps.com/showdownversion.txt"] encoding:NSUTF8StringEncoding error:&e];
        if(e != nil) {
            NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSLog(@"Server shows latest version as %@",newestVersion);
            NSLog(@"Current Version is %@",currentVersion);
            if ([[[[newestVersion stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] intValue] >
                 [[[[currentVersion stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""] intValue]) {
                PopUpLayer *popUpMenuLayer = [PopUpLayer node];
                [popUpMenuLayer showNewPatchPopup];
                [self addChild:popUpMenuLayer z:1001];
            }
            else
                [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer multiplayerScene]]];
        }
        else {
            NSLog(@"Could not contact server to check version number");
            [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer multiplayerScene]]];
        }
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer multiplayerScene]]];
    }
    else if (button.tag == 8) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer practiceScene]]];
    }
    else if (button.tag == 9) {
        //[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:YES subText:@"You defeated your opponent!" earnedCoins:1 fromMode:@"Tutorial"]]];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer tutorialScene]]];
    }
    else if (button.tag == 100) {
        [Profile sharedProfile].muted = NO;
        if ([[SimpleAudioEngine sharedEngine] backgroundMusicVolume] == 0) {
            [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:BACKGROUND_VOLUME];
            [musicButton runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
        }
        else {
            [Profile sharedProfile].muted = YES;
            [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
            [musicButton runAction:[CCFadeTo actionWithDuration:0.2 opacity:50]];
        }
    }
}

- (void)cocosSwitchToMenu:(id)sender data:(NSString*)menu {
    [self switchToMenu:menu];
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

@end
