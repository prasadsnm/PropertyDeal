//
//  Resource.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Resource : NSObject {
    NSString *type;
    CCSprite *sprite;
    CCLabelTTF *label;
    int amount;
    BOOL graphicsCreated;
}

@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) CCSprite *sprite;
@property (nonatomic, assign) CCLabelTTF *label;
@property (nonatomic) int amount;
@property (nonatomic) BOOL graphicsCreated;


-(id)initWithType:(NSString*)inputType amount:(int)inputAmount;
-(void)createSpriteAndLabel:(int)labelSize;
-(void)createSpriteAndLabel:(int)labelSize withAmount:(int)inputAmount;
-(CCSprite*)getSpriteForType:(NSString*)type;

@end
