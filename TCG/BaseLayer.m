//
//  BaseLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-30.
//  Copyright 2012 Smashware. All rights reserved.
//

#import "BaseLayer.h"
#import "SimpleAudioEngine.h"
#import "PopUpLayer.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation BaseLayer

CGRect lastTouchedButtonBox;
CCSprite *lastTouchedButton;

@synthesize buttons;

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	BaseLayer *layer = [BaseLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

- (void)showPopUpWithText:(NSString*)text {
    PopUpLayer *popUpLayer = [PopUpLayer node];
    [popUpLayer showPopUpWithText:text];
    [self addChild:popUpLayer z:10000];
}

- (void)dealloc {
    //if (buttons)
        //[buttons release];
    [super dealloc];
}

// TOUCHES
- (void)touchStartedForButtonAtLocation:(CGPoint)location {
    if (buttons) {
        lastTouchedButton = nil;
        for (CCSprite *button in buttons) {
            if (CGRectContainsPoint(button.boundingBox, location) && button.opacity != 0) {
                lastTouchedButtonBox = button.boundingBox;
                lastTouchedButton = button;
                [button runAction:[CCScaleTo actionWithDuration:0.1 scale:0.9]];
            }
        }
    }
}
- (void)touchFinishedForButtonAtLocation:(CGPoint)location {
    CCSprite *selectedButton = nil;
    if (buttons) {
        for (CCSprite *button in buttons) {
            [button runAction:[CCScaleTo actionWithDuration:0.1 scale:1.0]];
        }
        if (CGRectContainsPoint(lastTouchedButtonBox, location)) {
            selectedButton = lastTouchedButton;
        }
        
        if (selectedButton)
            [self actionForButton:selectedButton];
    }
}
- (void)actionForButton:(CCSprite*)button {
    
}
- (void)yesButtonPressed {
    
}

// SCALING
- (CGPoint)makeScaledPointx:(int)x y:(int)y {
    return CGPointMake([self makeScaledx:x], [self makeScaledy:y]);
}
- (CGPoint)makeShiftedPointx:(int)x y:(int)y {
    if (IS_WIDESCREEN)
        return CGPointMake([self makeWidescreenInt:x], [self makeScaledy:y]);
    
    return CGPointMake(x,y);
}
- (CGPoint)makeShiftedPointx:(int)x y:(int)y withShift:(int)shift {
    if (IS_WIDESCREEN)
        return CGPointMake(x+shift, [self makeScaledy:y]);
    
    return CGPointMake(x,y);
}
- (int)makeScaledInt:(int)input {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return input*2;
    return input;
}
- (int)makeWidescreenInt:(int)input {
    return input + 88;
}
- (int)makeScaledx:(int)x {
    int result;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        result = x * 2;
        int buffer = 0;
        if (result > 480) {
            buffer = (result-480) * 0.1;
            result = result + buffer;
        }
        else if (result < 480) {
            buffer = (480-result) * 0.1;
            result = result - buffer;
        }
        result += 32;
        
        return result;
    }
    else if (IS_WIDESCREEN) {
        result = x;
        int buffer = 0;
        if (result > 240) {
            buffer = (result-240) * 0.183;
            result = result + buffer;
        }
        else if (result < 240) {
            buffer = (240-result) * 0.183;
            result = result - buffer;
        }
        result += 44;
        
        return result;
    }
    return x;
}
- (int)makeScaledy:(int)y {
    int result;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        result = y * 2;
        
        int buffer = 0;
        if (result > 320) {
            buffer = (result-320) * 0.215;
            result = result + buffer;
        }
        else if (result < 320) {
            buffer = (320-result) * 0.215;
            result = result - buffer;
        }
        
        result += 64;
        return result;
    }
    return y;
}
- (int)makeScaledDistance:(int)input {
    if (IS_WIDESCREEN)
        return input*1.18333;
        
    return input;
}

- (void)registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    [self touchStartedForButtonAtLocation:location];
    return YES;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [self convertTouchToNodeSpace: touch];
    [self touchFinishedForButtonAtLocation:location];
}
- (void)cocosPlaySoundWithName:(id)sender data:(NSString*)name {
    [[SimpleAudioEngine sharedEngine] playEffect:name];
}
- (void)cocosRemoveSprite:(id)sender {
    CCNode *node = sender;
    [self removeChild:node cleanup:YES];
}



@end
