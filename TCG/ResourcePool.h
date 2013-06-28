//
//  ResourcePool.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"
#import "Card.h"

@interface ResourcePool : NSObject {
    NSMutableArray *resources;
}

@property (nonatomic, assign) NSMutableArray *resources;

-(void)addResource:(Resource*)resource;
-(void)payResource:(Resource*)resource;
-(void)payResource:(Resource*)resource withBonus:(int)bonus;
-(Resource*)checkForResourceType:(NSString*)resourceType;

@end
