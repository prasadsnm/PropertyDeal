//
//  BaseLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-30.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#define BACKGROUND_VOLUME 0.5f

@interface BaseLayer : CCLayer {
    NSMutableArray *buttons;
}

@property (nonatomic,retain) NSMutableArray *buttons;

+(CCScene *) scene;

- (void)showPopUpWithText:(NSString*)text;
- (void)touchStartedForButtonAtLocation:(CGPoint)location;
- (void)touchFinishedForButtonAtLocation:(CGPoint)location;
- (void)cocosPlaySoundWithName:(id)sender data:(NSString*)name;
- (void)cocosRemoveSprite:(id)sender;
- (void)yesButtonPressed;

// Device Scaling
- (CGPoint)makeScaledPointx:(int)x y:(int)y;
- (CGPoint)makeShiftedPointx:(int)x y:(int)y;
- (CGPoint)makeShiftedPointx:(int)x y:(int)y withShift:(int)shift;
- (int)makeScaledDistance:(int)input;
- (int)makeScaledInt:(int)input;
- (int)makeScaledx:(int)x;
- (int)makeScaledy:(int)y;
- (int)makeWidescreenInt:(int)input;

@end
