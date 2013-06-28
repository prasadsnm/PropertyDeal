//
//  ArtificialIntelligence.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-24.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "ArtificialIntelligence.h"
#import "ResourcePool.h"
#import "Player.h"

@implementation ArtificialIntelligence

@synthesize player;
@synthesize opponent;

- (Card*)pickResourceFromHand:(NSArray*)hand {
    for (Card *card in hand) {
        if ([card.type isEqualToString:@"Resource"])
            if ([player canPlayCard:card])
                return card;
    }
    return nil;
}

- (Card*)pickCardFromHand:(NSArray*)hand {
    for (Card *card in hand) {
        if (![card.type isEqualToString:@"Resource"]) {
            if ([player canPlayCard:card]) {
                if ([card.type isEqualToString:@"Fighter"] || [self chooseTargetForCard:card] != nil || [card hasTargetType:@"Global"])
                    return card;
            }
        }
    }
    return nil;
}

- (id)chooseTargetForCard:(Card*)card {
    id target = nil;
    
    return target;
}

- (Card*)chooseAttackerFromBoard:(NSArray*)board againstBoard:(NSArray*)opponentBoard {
    for (Card *card in board) {
        if (card.used == NO && card.justPlayed == NO && ![card hasAbility:@"Defender"]) {
            if ((!([card.generatedResources count] > 0 && [opponent hasCardThatCanKillCard:card] != nil) || [card.owner hasTotalResourceValue:100])
                && !([opponent hasCardThatCanKillCardWithoutDying:card] != nil && [opponent hasMoreAvailableFightersThan:player])) {
                Card *cardThatCanKillCard = [opponent hasCardThatCanKillCard:card];
                // IF CARD CAN BE KILLED BY LESS VALUABLE CARD DON'T ATTACK
                if (!(cardThatCanKillCard.totalValue <= card.totalValue/2) || cardThatCanKillCard == nil) {
                    if ([self checkIfOpponentCanWinWithAttack:opponentBoard] == NO)
                        return card;
                }
            }
        }
    }
    return nil;
}

-(BOOL)checkIfOpponentCanWinWithAttack:(NSArray*)opponentBoard {
    // CHECK IF WE HAVE MORE GUYS
    int opponentCards;
    for (Card* card in opponentBoard) {
        opponentCards++;
    }
    int ourCards;
    for (Card* card in player.board) {
        if (card.used == NO)
            ourCards++;
    }
    if (ourCards > opponentCards)
        return NO;
    
    
    int totalDamage = 0;
    for (Card* loopCard in opponentBoard) {
        totalDamage += loopCard.totalAttack;
        if (totalDamage >= player.hp)
            return YES;
    }
    return NO;
}

- (Card*)chooseDefenderFromBoard:(NSArray*)board againstCard:(Card*)attackingCard {
    Card *defender = nil;
    
    return defender;
}

@end
