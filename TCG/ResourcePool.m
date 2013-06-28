//
//  ResourcePool.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "ResourcePool.h"

@implementation ResourcePool

@synthesize resources;

-(id)init {
    if( (self=[super init])) {
        resources = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addResource:(Resource*)resource {
    Resource *existingResource = [self checkForResourceType:resource.type];
    if (existingResource != nil) {
        existingResource.amount += resource.amount;
        if (existingResource.amount < 0)
            existingResource.amount = 0;
    }
    else {
        existingResource = [[Resource alloc] initWithType:resource.type amount:resource.amount];
        if (existingResource.amount < 0)
            existingResource.amount = 0;
        [resources addObject:existingResource];
        [existingResource release];
    }
}

-(void)payResource:(Resource*)resource {
    [self payResource:resource withBonus:0];
}

-(void)payResource:(Resource*)resource withBonus:(int)bonus {
    Resource *existingResource = [self checkForResourceType:resource.type];
    if (existingResource != nil) {
        existingResource.amount -= resource.amount+bonus;
        if (existingResource.amount < 0)
            existingResource.amount = 0;
    }
}

-(Resource*)checkForResourceType:(NSString*)resourceType {
    for (Resource *resource in resources) {
        if ([resource.type isEqualToString:resourceType]) {
            return resource;
        }
    }
    return nil;
}

-(void)dealloc {
    [resources dealloc];
    [super dealloc];
}

@end
