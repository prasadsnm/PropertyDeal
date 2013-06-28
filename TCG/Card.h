//
//  Card.h
//  TCG
//
//  Created by Stephen Mashalidis on 11-12-14.
//  Copyright (c) 2011 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Resource.h"

@class Player;

@interface Card : NSObject <NSCoding> {
    NSMutableArray *passiveAbilities;
    NSMutableArray *activeAbilities;
    NSMutableArray *attachedCards;
    NSMutableArray *generatedResources;
    NSMutableArray *costs;
    NSMutableArray *givenBuffs;
    NSMutableArray *subTypes;
    NSMutableArray *abilityTargetTypes;
    NSMutableArray *target;
    NSMutableArray *requiredCards;
    NSMutableArray *aiNotes;
    NSString *name;
    NSString *imagePath;
    NSString *type;
    NSString *playedSound;
    NSString *attackSound;
    NSString *aiTargetType;
    Player *owner;
    CCSprite *sprite;
    CCSprite *thumbSprite;
    Card *host;
    BOOL used;
    BOOL justPlayed;
    BOOL dying;
    BOOL attacking;
    BOOL dieNextTurn;
}

@property (nonatomic, assign) NSMutableArray *passiveAbilities;
@property (nonatomic, assign) NSMutableArray *activeAbilities;
@property (nonatomic, assign) NSMutableArray *attachedCards;
@property (nonatomic, assign) NSMutableArray *generatedResources;
@property (nonatomic, assign) NSMutableArray *costs;
@property (nonatomic, assign) NSMutableArray *givenBuffs;
@property (nonatomic, assign) NSMutableArray *subTypes;
@property (nonatomic, assign) NSMutableArray *abilityTargetTypes;
@property (nonatomic, assign) NSMutableArray *requiredCards;
@property (nonatomic, assign) NSMutableArray *aiNotes;
@property (nonatomic, assign) NSString *name;
@property (nonatomic, assign) NSString *imagePath;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, assign) NSString *playedSound;
@property (nonatomic, assign) NSString *attackSound;
@property (nonatomic, assign) NSString *aiTargetType;
@property (nonatomic, assign) Player *owner;
@property (nonatomic, assign) Card *host;
@property (nonatomic, retain) CCSprite *sprite;
@property (nonatomic, retain) CCSprite *thumbSprite;
@property (nonatomic) BOOL used;
@property (nonatomic) BOOL justPlayed;
@property (nonatomic) BOOL dying;
@property (nonatomic) BOOL attacking;
@property (nonatomic) BOOL dieNextTurn;

-(id) initWithName:(NSString*)inputName image:(NSString*)inputPath type:(NSString*)inputType;
-(int)totalAttack;
-(int)totalDefense;
-(int)totalValue;
-(void)addCost:(Resource*)resource;
-(void)addGeneratedResource:(Resource*)resource;
-(void)addActiveAbility:(NSString*)ability;
-(void)addPassiveAbility:(NSString*)ability;
-(BOOL)hasAbility:(NSString*)ability;
-(BOOL)hasSubType:(NSString*)subtype;
-(BOOL)hasAiNote:(NSString*)note;
-(BOOL)hasAttachmentWithName:(NSString*)name;
-(BOOL)canBeTargetOfAbilityFromCard:(Card*)card;
-(BOOL)canUserAbilityOnType:(NSString*)targetType;
-(BOOL)hasActiveAbility;
-(BOOL)hasTargetType:(NSString*)targetType;
-(BOOL)isEqualToCard:(Card*)card;
-(BOOL)hasEnhancementWithAbility:(NSString*)ability;
-(BOOL)sortValueHigherThan:(Card*)card;
-(Resource*)getPrimaryResource;
-(NSString*)getThumbPath;

@end
