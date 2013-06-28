//
//  Player.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourcePool.h"
#import "ArtificialIntelligence.h"
#import "Deck.h"
#import "Card.h"

@interface Player : NSObject {
    ArtificialIntelligence *ai;
    Deck *deck;
    NSMutableArray *hand;
    NSMutableArray *board;
    NSMutableArray *sideBoard;
    NSMutableArray *actionBoard;
    NSMutableArray *graveyard;
    ResourcePool *resourcePool;
    int hp;
    BOOL resourcePlayed;
}

- (id)initWithAI;
- (void)payForCard:(Card*)card;
- (void)takeDamage:(int)damage;
- (BOOL)canPlayCard:(Card*)card;
- (Card*)hasCardThatCanKillCard:(Card*)card;
- (Card*)hasCardThatCanKillCardWithoutDying:(Card*)card;
- (BOOL)hasMoreAvailableFightersThan:(Player*)player;
- (BOOL)hasTotalResourceValue:(int)value;

@property (nonatomic, assign) ArtificialIntelligence *ai;
@property (nonatomic, assign) Deck *deck;
@property (nonatomic, assign) NSMutableArray *hand;
@property (nonatomic, assign) NSMutableArray *board;
@property (nonatomic, assign) NSMutableArray *sideBoard;
@property (nonatomic, assign) NSMutableArray *actionBoard;
@property (nonatomic, assign) NSMutableArray *graveyard;
@property (nonatomic, assign) ResourcePool *resourcePool;
@property (nonatomic) int hp;
@property (nonatomic) BOOL resourcePlayed;

@end
