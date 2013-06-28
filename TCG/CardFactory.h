//
//  CardFactory.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-12.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Deck.h"

@interface CardFactory : NSObject

-(Card*)spawnCard:(NSString*)cardName;
-(Deck*)spawnDeck;

@end
