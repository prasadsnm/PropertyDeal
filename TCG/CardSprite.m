//
//  CardSprite.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-08.
//  Copyright 2012 Smashware. All rights reserved.
//

#import "CardSprite.h"


@implementation CardSprite

- (void)showStatsForCard:(Card*)card {
    [self removeAllChildrenWithCleanup:YES];
    cardSprite = [CCSprite spriteWithFile:card.imagePath];
    [self addChild:cardSprite z:999];
}

- (int)makeScaledInt:(int)input {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return input*2;
    return input;
}

- (int)getIconBufferForAmount:(int)amount {
    int iconBuffer = 0;
    if (amount < 10)
        iconBuffer = -3;
    if (amount/100 >= 1)
        iconBuffer = 3;
    if (amount/1000 >= 1)
        iconBuffer = 5;
    return iconBuffer;
}

- (void)runActionOnChildren:(id)action {
    for (CCSprite *child in self.children) {
        [child runAction:[action copy]];
    }
}

- (void)setOpacity:(float)opacity {
    for (CCSprite *child in self.children) {
        [child setOpacity:opacity];
    }
}

- (float)opacity {
    for (CCSprite *child in self.children) {
        return child.opacity;
    }
    return 0;
}

@end
