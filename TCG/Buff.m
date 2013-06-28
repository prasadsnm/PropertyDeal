//
//  Buff.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-03-10.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "Buff.h"

@implementation Buff

@synthesize attackBonus;
@synthesize defenseBonus;
@synthesize targetTypes;
@synthesize ability;

- (id)init {
    if( (self=[super init])) {
        targetTypes = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
