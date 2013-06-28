//
//  PopUpLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-07-02.
//  Copyright 2012 Smashware. All rights reserved.
//

#import "PopUpLayer.h"
#import "MenuLayer.h"
#import "GameLayer.h"
#import "Profile.h"

@implementation PopUpLayer

-(id) init {
	if( (self=[super init])) {   
        buttons = [[NSMutableArray alloc] init];
        pages = [[NSMutableArray alloc] init];
                
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)dealloc {
    [buttons release];
    [pages release];
    [super dealloc];
}

- (void)setBackground {
    // SET BACKGROUND
    CCSprite *background = [CCSprite spriteWithFile: @"PopUpMenu.png"];
    [background setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:background z:-1];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //[background setScale:1.2];
    }
}

- (void)setBackgroundBig {
    // SET BACKGROUND
    CCSprite *background = [CCSprite spriteWithFile: @"PopUpMenuBig.png"];
    [background setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:background z:-1];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //[background setScale:1.2];
    }
}

- (void)actionForButton:(CCSprite*)button {
    if (button.tag == 1) {
        GameLayer *gameLayer = self.parent;
        [gameLayer disconnect];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer sceneWithAnimation:NO]]];
    }
    else if (button.tag == 2) {
        BaseLayer *gameLayer = self.parent;
        [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
        [gameLayer removeChild:self cleanup:YES];
        //[self.parent removeChild:self cleanup:YES];
    }
    else if (button.tag == 3) {
        BaseLayer *layer = self.parent;
        [layer yesButtonPressed];
        //[layer removeChild:self cleanup:YES];
    }
    else if (button.tag == 4) {
        BaseLayer *layer = self.parent;
        [layer removeChild:self cleanup:YES];
    }
    else if (button.tag == 5) {
        if (index < [pages count]-1) {
            if (index == 0)
                [backButton runAction:[CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255]];
            index++;
            [tutorialImage setTexture:[[CCTextureCache sharedTextureCache] addImage:[pages objectAtIndex:index]]];
        }
        else {
            GameLayer *layer = self.parent;
            [layer getTutorialMessage:name];
            [layer removeChild:self cleanup:YES];
        }
    }
    else if (button.tag == 6) {
        if (index > 0) {
            index--;
            [tutorialImage setTexture:[[CCTextureCache sharedTextureCache] addImage:[pages objectAtIndex:index]]];
            if (index == 0)
                [backButton runAction:[CCTintTo actionWithDuration:0.2 red:100 green:100 blue:100]];
        }
    }
    else if (button.tag == 7) {
        CCNode *layer = self.parent;
        [layer removeChild:self cleanup:YES];
        //NSString *GiftAppURL = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=492502890&mt=8"];
        NSString *GiftAppURL = [NSString stringWithFormat:@"http://itunes.apple.com/app/id492502890"];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GiftAppURL]];
    }
    else if (button.tag == 8) {
        CCNode *layer = self.parent;
        [layer removeChild:self cleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameLayer multiplayerScene]]];
    }
    else if (button.tag == 9) {
        CCNode *layer = self.parent;
        [layer removeChild:self cleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer scene]]];
        
        NSString *GiftAppURL = [NSString stringWithFormat:@"http://itunes.apple.com/app/id492502890"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:GiftAppURL]];
    }
    else if (button.tag == 10) {
        CCNode *layer = self.parent;
        [layer removeChild:self cleanup:YES];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer scene]]];
    }
}

- (void)showGameQuitMenu {
    [self setBackground];
    
    CCSprite *quitButton = [CCSprite spriteWithFile:@"QuitGame.png"];
    [quitButton setOpacity:0];
    [quitButton setPosition:[self makeScaledPointx:180 y:105]];
    quitButton.tag = 1;
    [buttons addObject:quitButton];
    [self addChild:quitButton];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:180 y:110]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [quitButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCSprite *resumeButton = [CCSprite spriteWithFile:@"ResumeButton.png"];
    [resumeButton setOpacity:0];
    [resumeButton setPosition:[self makeScaledPointx:310 y:105]];
    resumeButton.tag = 2;
    [buttons addObject:resumeButton];
    [self addChild:resumeButton];
    delay = [CCDelayTime actionWithDuration:0.2];
    moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:310 y:110]];
    fadeIn = [CCFadeIn actionWithDuration:0.2];
    moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [resumeButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:@"Quit the game?" dimensions:CGSizeMake([self makeScaledInt:800], [self makeScaledInt:40]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:32]];        
    [subTitle setPosition:[self makeScaledPointx:245 y:205]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    id fade = [CCFadeIn actionWithDuration:0.2];
    id move = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:245 y:210]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:spawn, nil]];
}

- (void)showYesNoPopUpWithText:(NSString*)text {
    [self setBackground];

    CCSprite *quitButton = [CCSprite spriteWithFile:@"YesButton.png"];
    [quitButton setOpacity:0];
    [quitButton setPosition:[self makeScaledPointx:305 y:105]];
    quitButton.tag = 3;
    [buttons addObject:quitButton];
    [self addChild:quitButton];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:305 y:110]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [quitButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCSprite *resumeButton = [CCSprite spriteWithFile:@"NoButton.png"];
    [resumeButton setOpacity:0];
    [resumeButton setPosition:[self makeScaledPointx:175 y:105]];
    resumeButton.tag = 4;
    [buttons addObject:resumeButton];
    [self addChild:resumeButton];
    delay = [CCDelayTime actionWithDuration:0.2];
    moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:175 y:110]];
    fadeIn = [CCFadeIn actionWithDuration:0.2];
    moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [resumeButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:text dimensions:CGSizeMake([self makeScaledInt:240], [self makeScaledInt:100]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:28]];
    [subTitle setPosition:[self makeScaledPointx:240 y:180]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    id fade = [CCFadeIn actionWithDuration:0.2];
    id move = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:185]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:spawn, nil]];
}

- (void)showPopUpWithText:(NSString*)text {
    [self setBackground];

    CCSprite *okButton = [CCSprite spriteWithFile:@"OkMenuButton.png"];
    [okButton setOpacity:0];
    [okButton setPosition:[self makeScaledPointx:240 y:105]];
    okButton.tag = 2;
    [buttons addObject:okButton];
    [self addChild:okButton];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:110]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [okButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:text dimensions:CGSizeMake([self makeScaledInt:240], [self makeScaledInt:100]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:28]];        
    [subTitle setPosition:[self makeScaledPointx:240 y:180]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    id fade = [CCFadeIn actionWithDuration:0.2];
    id move = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:185]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:spawn, nil]];
}

- (BOOL)showAbilityPopUp:(NSString *)abilityPath {
    [self setBackgroundBig];
    
    tutorialImage = [CCSprite spriteWithFile:abilityPath];
    [tutorialImage setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:tutorialImage];
    
    CCSprite *okButton = [CCSprite spriteWithFile:@"OkMenuButton.png"];
    [okButton setOpacity:0];
    [okButton setPosition:[self makeScaledPointx:240 y:75]];
    okButton.tag = 4;
    [buttons addObject:okButton];
    [self addChild:okButton];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions: fadeIn, nil];
    [okButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    return YES;
}

- (void)showTutorialPopUp:(NSString*)popUp {
    [self setBackgroundBig];
    
    [pages removeAllObjects];
    name = [popUp copy];
    if ([popUp isEqualToString:@"Intro"]) {
        [pages addObject:@"IntroTutorial1.png"];
    }
    else if ([popUp isEqualToString:@"Deck"]) {
        [pages addObject:@"DeckTutorial1.png"];
        [pages addObject:@"DeckTutorial2.png"];
        [pages addObject:@"DeckTutorial3.png"];
    }
    else if ([popUp isEqualToString:@"First Round"]) {
        [pages addObject:@"FirstRound1.png"];
        [pages addObject:@"FirstRound2.png"];
        [pages addObject:@"Resources1.png"];
        [pages addObject:@"Resources2.png"];
        [pages addObject:@"Resources3.png"];
    }
    else if ([popUp isEqualToString:@"Fighters"]) {
        [pages addObject:@"Fighters1.png"];
        [pages addObject:@"Fighters2.png"];
        [pages addObject:@"Fighters3.png"];
        [pages addObject:@"Fighters4.png"];
    }
    else if ([popUp isEqualToString:@"End Phase"]) {
        [pages addObject:@"EndPhase1.png"];
        [pages addObject:@"EndPhase2.png"];
    }
    else if ([popUp isEqualToString:@"Attacking"]) {
        [pages addObject:@"NewTurn1.png"];
        [pages addObject:@"Attacking1.png"];
        [pages addObject:@"Attacking2.png"];
        [pages addObject:@"Attacking3.png"];
        [pages addObject:@"Attacking4.png"];
        [pages addObject:@"Attacking5.png"];
    }
    else if ([popUp isEqualToString:@"Health"]) {
        [pages addObject:@"Attacking6.png"];
        [pages addObject:@"Health1.png"];
        [pages addObject:@"Health2.png"];
    }
    else if ([popUp isEqualToString:@"End Turn"]) {
        [pages addObject:@"EndTurn1.png"];
        [pages addObject:@"EndTurn2.png"];
    }
    else if ([popUp isEqualToString:@"Defending"]) {
        [pages addObject:@"Defending1.png"];
        [pages addObject:@"Defending2.png"];
        [pages addObject:@"Defending3.png"];
        [pages addObject:@"Defending4.png"];
    }
    else if ([popUp isEqualToString:@"Enhancements"]) {
        [pages addObject:@"Enhancements1.png"];
        [pages addObject:@"Enhancements2.png"];
        [pages addObject:@"Enhancements3.png"];
    }
    else if ([popUp isEqualToString:@"Tutorial Finished"]) {
        [pages addObject:@"Tutorial1.png"];
    }

    tutorialImage = [CCSprite spriteWithFile:[pages objectAtIndex:0]];
    [tutorialImage setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:tutorialImage];
    
    nextButton = [CCSprite spriteWithFile:@"NextButton.png"];
    [nextButton setOpacity:0];
    [nextButton setPosition:[self makeScaledPointx:310 y:70]];
    nextButton.tag = 5;
    [buttons addObject:nextButton];
    [self addChild:nextButton];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:310 y:75]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [nextButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    backButton = [CCSprite spriteWithFile:@"BackButton.png"];
    [backButton setOpacity:0];
    [backButton setColor:ccc3(100, 100, 100)];
    [backButton setPosition:[self makeScaledPointx:170 y:70]];
    backButton.tag = 6;
    [buttons addObject:backButton];
    [self addChild:backButton];
    delay = [CCDelayTime actionWithDuration:0.2];
    moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:170 y:75]];
    fadeIn = [CCFadeIn actionWithDuration:0.2];
    moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [backButton runAction:[CCSequence actions:moveAndFade, nil]];
}

- (void)showDisconnectPopUp {
    [self setBackground];

    CCSprite *okButton = [CCSprite spriteWithFile:@"QuitGame.png"];
    [okButton setOpacity:0];
    [okButton setPosition:[self makeScaledPointx:240 y:105]];
    okButton.tag = 1;
    [buttons addObject:okButton];
    [self addChild:okButton];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:110]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [okButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:@"Your opponent has disconnected" dimensions:CGSizeMake([self makeScaledInt:240], [self makeScaledInt:100]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:28]];        
    [subTitle setPosition:[self makeScaledPointx:240 y:180]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    id fade = [CCFadeIn actionWithDuration:0.2];
    id move = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:185]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:spawn, nil]];
}

- (void)showVersionPopUp {
    [self setBackground];

    CCSprite *okButton = [CCSprite spriteWithFile:@"QuitGame.png"];
    [okButton setOpacity:0];
    [okButton setPosition:[self makeScaledPointx:240 y:105]];
    okButton.tag = 1;
    [buttons addObject:okButton];
    [self addChild:okButton];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:110]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [okButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    CCLabelTTF *subTitle = [CCLabelTTF labelWithString:@"Game versions are different - make sure both are updated and try again." dimensions:CGSizeMake([self makeScaledInt:240], [self makeScaledInt:150]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:25]];
    [subTitle setPosition:[self makeScaledPointx:240 y:160]];
    subTitle.opacity = 0;
    subTitle.color = ccBLACK;
    [self addChild:subTitle z:0];
    id fade = [CCFadeIn actionWithDuration:0.2];
    id move = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:240 y:165]];
    id spawn = [CCSpawn actions:fade,move, nil];
    [subTitle runAction:[CCSequence actions:spawn, nil]];
}

- (void)showNewPatchPopup {
    [self setBackgroundBig];

    tutorialImage = [CCSprite spriteWithFile:@"NewPatch.png"];
    [tutorialImage setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:tutorialImage];
    
    nextButton = [CCSprite spriteWithFile:@"YesButton.png"];
    [nextButton setOpacity:0];
    [nextButton setPosition:[self makeScaledPointx:310 y:75]];
    nextButton.tag = 7;
    [buttons addObject:nextButton];
    [self addChild:nextButton];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:310 y:80]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [nextButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    backButton = [CCSprite spriteWithFile:@"NoButton.png"];
    [backButton setOpacity:0];
    [backButton setPosition:[self makeScaledPointx:170 y:75]];
    backButton.tag = 8;
    [buttons addObject:backButton];
    [self addChild:backButton];
    delay = [CCDelayTime actionWithDuration:0.2];
    moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:170 y:80]];
    fadeIn = [CCFadeIn actionWithDuration:0.2];
    moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [backButton runAction:[CCSequence actions:moveAndFade, nil]];
}

- (void)showNoMatchPopup {
    [self setBackgroundBig];
    
    tutorialImage = [CCSprite spriteWithFile:@"GameCenterNoMatch.png"];
    [tutorialImage setPosition:[self makeScaledPointx:240 y:160]];
    [self addChild:tutorialImage];
    
    nextButton = [CCSprite spriteWithFile:@"YesButton.png"];
    [nextButton setOpacity:0];
    [nextButton setPosition:[self makeScaledPointx:310 y:75]];
    nextButton.tag = 9;
    [buttons addObject:nextButton];
    [self addChild:nextButton];
    id delay = [CCDelayTime actionWithDuration:0.2];
    id moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:310 y:80]];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [nextButton runAction:[CCSequence actions:moveAndFade, nil]];
    
    backButton = [CCSprite spriteWithFile:@"NoButton.png"];
    [backButton setOpacity:0];
    [backButton setPosition:[self makeScaledPointx:170 y:75]];
    backButton.tag = 10;
    [buttons addObject:backButton];
    [self addChild:backButton];
    delay = [CCDelayTime actionWithDuration:0.2];
    moveUp = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:170 y:80]];
    fadeIn = [CCFadeIn actionWithDuration:0.2];
    moveAndFade = [CCSpawn actions:moveUp, fadeIn, nil];
    [backButton runAction:[CCSequence actions:moveAndFade, nil]];
}

@end
