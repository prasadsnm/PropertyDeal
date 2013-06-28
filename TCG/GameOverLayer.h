//
//  GameOverLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-03-09.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BaseLayer.h"

@interface GameOverLayer : BaseLayer {
    BOOL victory;
    NSString *subText;
    NSString *mode;
    int earnedCoins;
}

@property (nonatomic) int earnedCoins;
@property (nonatomic) BOOL victory;
@property (nonatomic, retain) NSString *subText;
@property (nonatomic, retain) NSString *mode;

+(CCScene *) sceneWithVictory:(BOOL)victoryInput subText:(NSString*)subTextInput earnedCoins:(int)earnedCoinsInput fromMode:(NSString*)mode;
-(void)showGraphics;


@end
