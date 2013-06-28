//
//  Resource.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-01-07.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "Resource.h"

@implementation Resource

@synthesize type;
@synthesize amount;
@synthesize sprite;
@synthesize label;
@synthesize graphicsCreated;

-(id)initWithType:(NSString*)inputType amount:(int)inputAmount {
    if( (self=[super init])) {
        type = inputType;
        amount = inputAmount;
        graphicsCreated = NO;
    }
    return self;    
}

-(void)createSpriteAndLabel:(int)labelSize {
    sprite = [self getSpriteForType:type];
    
    label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", amount] fontName:@"Hobo.ttf" fontSize:labelSize];
    [label retain];
    
    graphicsCreated = YES;
}

-(void)createSpriteAndLabel:(int)labelSize withAmount:(int)inputAmount {
    sprite = [self getSpriteForType:type];
    
    label = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", inputAmount] fontName:@"Hobo.ttf" fontSize:labelSize];
    [label retain];
    
    graphicsCreated = YES;
}

-(CCSprite*)getSpriteForType:(NSString *)inputType {
    CCSprite *returnSprite;
    if ([inputType isEqualToString:@"Metal"])
        returnSprite = [CCSprite spriteWithFile:@"Gear.png"];
    else if ([inputType isEqualToString:@"Meat"])
        returnSprite = [CCSprite spriteWithFile:@"Meat.png"];
    else if ([inputType isEqualToString:@"Money"])
        returnSprite = [CCSprite spriteWithFile:@"Gold.png"];
    else if ([inputType isEqualToString:@"Magic"])
        returnSprite = [CCSprite spriteWithFile:@"Mana.png"];
    else
        returnSprite = [CCSprite spriteWithFile:@"Heart.png"];
    
    [returnSprite retain];
    return returnSprite;
}

@end
