//
//  Buff.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-03-10.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Buff : NSObject {
    int attackBonus;
    int defenseBonus;
    
    NSMutableArray *targetTypes;
    NSString *ability;
}

@property (nonatomic) int attackBonus;
@property (nonatomic) int defenseBonus;
@property (nonatomic,assign) NSString *ability;
@property (nonatomic,assign) NSMutableArray *targetTypes;


@end
