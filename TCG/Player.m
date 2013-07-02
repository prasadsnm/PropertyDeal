//
//  Player.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize ai;
@synthesize deck;
@synthesize resourcePool;
@synthesize hp;
@synthesize resourcePlayed;
@synthesize hand;
@synthesize board;
@synthesize sideBoard;
@synthesize graveyard;
@synthesize actionBoard;

-(id)init {
    if( (self=[super init])) {
        graveyard = [[NSMutableArray alloc] init];
        deck = [[Deck alloc] init];
        
        hand = [[NSMutableArray alloc] init];
        board = [[NSMutableArray alloc] init];
        
        resourcePool = [[ResourcePool alloc] init];
        hp = 20;
    }
    return self;
}

-(id)initWithAI {
    self=[self init];
    ai = [[ArtificialIntelligence alloc] init];
    ai.player = self;
    return self;
}

- (BOOL)canPlayCard:(Card*)card {    
    return YES;
}

-(void)payForCard:(Card*)card {

}

- (void)takeDamage:(int)damage {
    hp -= damage;
    if (hp < 0) {
        hp = 0;
    }
}

- (Card*)hasCardThatCanKillCard:(Card*)card {
    for (Card *loopCard in board) {
        if (loopCard.totalAttack >= card.totalDefense && loopCard.used == NO && !([card hasAbility:@"Ranged"] && card.totalAttack >= loopCard.totalDefense))
            return loopCard;
    }
    return nil;
}

- (Card*)hasCardThatCanKillCardWithoutDying:(Card*)card {
    for (Card *loopCard in board) {
        if ((loopCard.totalAttack >= card.totalDefense && loopCard.used == NO && loopCard.totalDefense > card.totalAttack) || ([loopCard hasAbility:@"Ranged"] && loopCard.totalAttack>=card.totalDefense && loopCard.used == NO)) {
            return loopCard;
        }
    }
    return nil;
}

- (BOOL)hasMoreAvailableFightersThan:(Player*)player {
    int unusedCards = 0;
    for (Card *card in board) {
        if (card.used == NO && card.justPlayed == NO)
            unusedCards++;
    }
    
    int otherPlayerUnusedCards = 0;
    for (Card *card in player.board) {
        if (card.used == NO && card.justPlayed == NO)
            otherPlayerUnusedCards++;
    }
    return (unusedCards >= otherPlayerUnusedCards);
    
}

- (BOOL)hasTotalResourceValue:(int)value {
    int total = 0;
    for (Resource *resource in resourcePool.resources) {
        total += resource.amount;
    }
    if (total >= value)
        return YES;
    return NO;
}

- (void)dealloc {
    if (ai != nil)
        [ai release];
    [graveyard release];
    [deck release];
    [resourcePool release];
    [super dealloc];
}
@end
