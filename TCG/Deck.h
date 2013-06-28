//
//  Deck.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-24.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@interface Deck : NSObject {
    NSMutableArray *cards;
}

@property (nonatomic,retain) NSMutableArray *cards;

- (Card*)drawCard;
- (BOOL)hasResourceInDraw;
- (void)addCard:(Card*)card;
- (void)shuffle;
- (int)getSize;

@end
