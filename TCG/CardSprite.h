//
//  CardSprite.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-08.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Card.h"

@interface CardSprite : CCNode {
    CCLabelTTF *cardStatsLabel;
    CCLabelTTF *cardCostLabel;
    CCSprite *cardResourceIcon;
    CCSprite *cardSprite;
}

- (void)showStatsForCard:(Card*)card;
- (void)runActionOnChildren:(id)action;
- (float)opacity;
- (void)setOpacity:(float)opacity;
- (int)makeScaledInt:(int)input;
- (int)getIconBufferForAmount:(int)amount;

@end
