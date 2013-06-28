//
//  Deck.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-24.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "Deck.h"

@implementation Deck

@synthesize cards;

- (id)init {
    if( (self=[super init])) {
        cards = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addCard:(Card *)card {
    [cards addObject:card];
}

- (Card*)drawCard {
    if ([cards count] > 0) {
        Card *card = [cards objectAtIndex:0];
        [card retain];
        [cards removeObjectAtIndex:0];
        return [card autorelease];
    }
    return nil;
}

- (void)shuffle {
    NSUInteger firstObject = 0;
    
    for (int i = 0; i<[cards count];i++) {
        NSUInteger randomIndex = arc4random() % [cards count];
        [cards exchangeObjectAtIndex:firstObject withObjectAtIndex:randomIndex];
        firstObject +=1;
		
    }
}

- (BOOL)hasResourceInDraw {
    for (int i = 0; i < 7; i++) {
        Card *card = [cards objectAtIndex:i];
        if ([card.type isEqualToString:@"Resource"])
            return YES;
    }
    return NO;
}

- (int)getSize {
    return [cards count];
}

- (void)dealloc {
    [cards release];
    [super dealloc];
}

@end
