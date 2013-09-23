//
//  CardFactory.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-12.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "CardFactory.h"

@implementation CardFactory

-(Card*)spawnCard:(NSString*)cardName {
    Card *card;
    // ACTIONS
    if ([cardName isEqualToString:@"IdentityTheft"]) {
        card = [[Card alloc] initWithName:cardName image:@"identitytheft.png" type:@"Action"];
        [card addPassiveAbility:@"StealProperties"];
        [card.abilityTargetTypes addObject:@"Property"];
    }
    // PROPERTIES
    else if ([cardName isEqualToString:@"RedProperty"]) {
        card = [[Card alloc] initWithName:cardName image:@"milosplace.png" type:@"Property"];
        card.subType = @"Red";
    }
    else if ([cardName isEqualToString:@"PurpleProperty"]) {
        card = [[Card alloc] initWithName:cardName image:@"forestridge.png" type:@"Property"];
        card.subType = @"Purple";
    }
    else if ([cardName isEqualToString:@"LightBlueProperty"]) {
        card = [[Card alloc] initWithName:cardName image:@"beachside.png" type:@"Property"];
        card.subType = @"LightBlue";
    }
    // MONEY
    else if ([cardName isEqualToString:@"Money100"]) {
        card = [[Card alloc] initWithName:cardName image:@"money100.png" type:@"Money"];
    }
    else if ([cardName isEqualToString:@"Money500"]) {
        card = [[Card alloc] initWithName:cardName image:@"money500.png" type:@"Money"];
    }

    [card autorelease];
    return card;
}
-(Deck*)spawnDeck {
    NSMutableArray *cardArray = [[NSMutableArray alloc] init];

    [cardArray addObject:@"RedProperty"];
    [cardArray addObject:@"RedProperty"];
    [cardArray addObject:@"RedProperty"];
    [cardArray addObject:@"RedProperty"];
    [cardArray addObject:@"RedProperty"];
    [cardArray addObject:@"PurpleProperty"];
    [cardArray addObject:@"PurpleProperty"];
    [cardArray addObject:@"PurpleProperty"];
    [cardArray addObject:@"PurpleProperty"];
    [cardArray addObject:@"PurpleProperty"];
    [cardArray addObject:@"LightBlueProperty"];
    [cardArray addObject:@"LightBlueProperty"];
    [cardArray addObject:@"LightBlueProperty"];
    [cardArray addObject:@"LightBlueProperty"];
    [cardArray addObject:@"LightBlueProperty"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money100"];
    [cardArray addObject:@"Money500"];
    [cardArray addObject:@"Money500"];
    [cardArray addObject:@"Money500"];
    [cardArray addObject:@"Money500"];
    [cardArray addObject:@"IdentityTheft"];
    [cardArray addObject:@"IdentityTheft"];
    [cardArray addObject:@"IdentityTheft"];
    [cardArray addObject:@"IdentityTheft"];
    [cardArray addObject:@"IdentityTheft"];
    [cardArray autorelease];
    
    Deck *deck = [[Deck alloc] init];
    for (NSString *name in cardArray) {
        [deck addCard:[self spawnCard:name]];
    }
    
    return deck;
}
-(BOOL)checkIfDeck:(NSArray*)deck hasCard:(NSString*)name {
    for (NSString *cardName in deck) {
        if ([cardName isEqualToString:name])
            return YES;
    }
    return NO;
}

@end
