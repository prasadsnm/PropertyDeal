//
//  Message.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-29.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "MultiplayerMessage.h"

@implementation MultiplayerMessage

@synthesize card;
@synthesize targetCard;
@synthesize targetPlayer;
@synthesize code;
@synthesize number;
@synthesize cardName;
@synthesize cardArray;
@synthesize deckArray;

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        card = [[aDecoder decodeObjectForKey:@"card"] retain];
        targetCard = [[aDecoder decodeObjectForKey:@"targetCard"] retain];
        targetPlayer = [[aDecoder decodeObjectForKey:@"targetPlayer"] retain];
        code = [[aDecoder decodeObjectForKey:@"code"] retain];
        cardArray = [[aDecoder decodeObjectForKey:@"cardArray"] retain];
        deckArray = [[aDecoder decodeObjectForKey:@"deckArray"] retain];
        cardName = [[aDecoder decodeObjectForKey:@"cardName"] retain];
        number = [aDecoder decodeIntForKey:@"number"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {    
    [aCoder encodeObject:card forKey:@"card"];
    [aCoder encodeObject:targetCard forKey:@"targetCard"];
    [aCoder encodeObject:targetPlayer forKey:@"targetPlayer"];
    [aCoder encodeObject:code forKey:@"code"];
    [aCoder encodeObject:cardName forKey:@"cardName"];
    [aCoder encodeObject:cardArray forKey:@"cardArray"];
    [aCoder encodeObject:deckArray forKey:@"deckArray"];
    [aCoder encodeInt:number forKey:@"number"];
    
}

@end
