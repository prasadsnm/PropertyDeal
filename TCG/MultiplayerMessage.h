//
//  Message.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-29.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Card.h"
#import "Player.h"

@interface MultiplayerMessage : NSObject <NSCoding> {
    Card *card;
    Card *targetCard;
    NSString *targetPlayer;
    NSMutableArray *cardArray;
    NSMutableArray *deckArray;
    NSString *code;
    NSString *cardName;
    int number;
}

@property (nonatomic,retain) Card *card;
@property (nonatomic,retain) Card *targetCard;
@property (nonatomic,retain) NSString *targetPlayer;
@property (nonatomic,retain) NSMutableArray *cardArray;
@property (nonatomic,retain) NSMutableArray *deckArray;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *cardName;
@property (nonatomic) int number;

@end
