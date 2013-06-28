//
//  ArtificialIntelligence.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-24.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"

@class Player;

@interface ArtificialIntelligence : NSObject {
    Player *player;
    Player *opponent;
}

@property (nonatomic,retain) Player *player;
@property (nonatomic,retain) Player *opponent;

- (Card*)chooseDefenderFromBoard:(NSArray*)board againstCard:(Card*)attackingCard;
- (Card*)chooseAttackerFromBoard:(NSArray*)board againstBoard:(NSArray*)opponentBoard;
- (id)chooseTargetForCard:(Card*)card;
- (Card*)pickCardFromHand:(NSArray*)hand;
- (Card*)pickResourceFromHand:(NSArray*)hand;

@end
