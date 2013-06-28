//
//  Card.m
//  TCG
//
//  Created by Stephen Mashalidis on 11-12-14.
//  Copyright (c) 2011 Smashware. All rights reserved.
//

#import "Card.h"

@implementation Card

@synthesize costs;
@synthesize name;
@synthesize type;
@synthesize used;
@synthesize imagePath;
@synthesize attachedCards;
@synthesize sprite;
@synthesize host;
@synthesize passiveAbilities;
@synthesize activeAbilities;
@synthesize thumbSprite;
@synthesize owner;
@synthesize generatedResources;
@synthesize justPlayed;
@synthesize givenBuffs;
@synthesize subTypes;
@synthesize dying;
@synthesize attacking;
@synthesize abilityTargetTypes;
@synthesize playedSound;
@synthesize attackSound;
@synthesize aiTargetType;
@synthesize dieNextTurn;
@synthesize requiredCards;
@synthesize aiNotes;

-(id)initWithName:(NSString*)inputName image:(NSString*)inputPath type:(NSString*)inputType {
    if( (self=[super init])) {
        attachedCards = [[NSMutableArray alloc] init];
        passiveAbilities = [[NSMutableArray alloc] init];
        activeAbilities = [[NSMutableArray alloc] init];
        costs = [[NSMutableArray alloc] init];
        generatedResources = [[NSMutableArray alloc] init];
        givenBuffs = [[NSMutableArray alloc] init];
        subTypes = [[NSMutableArray alloc] init];
        abilityTargetTypes = [[NSMutableArray alloc] init];
        requiredCards = [[NSMutableArray alloc] init];
        aiNotes = [[NSMutableArray alloc] init];
        name = [inputName copy];
        imagePath = inputPath;
        type = inputType;
        used = NO;
        playedSound = nil;
    }
    return self;
}

-(BOOL)isEqualToCard:(Card*)card {
    BOOL equal = YES;
    
    if (![name isEqualToString:card.name]) {
        CCLOG(@"Name inequality");
        NSLog(@"Card Name: %@",name);
        NSLog(@"Card Name: %@",card.name);
        equal = NO;
    }
    if (card.used != used) {
        CCLOG(@"Used inequality");
        equal = NO;
    }
    if (card.justPlayed != justPlayed) {
        CCLOG(@"Just Played inequality");
        equal = NO;
    }
    
    if (card.attacking != attacking) {
        CCLOG(@"Attacking inequality");
        equal = NO;
    }
    
    NSMutableArray *cardsAccountedFor = [[NSMutableArray alloc] init];
    if ([attachedCards count] == [card.attachedCards count]) {
        for (Card *attachedCard in attachedCards) {
            Card *equivalentCard = nil;
            for (Card *comparisonCard in card.attachedCards) {
                if ([attachedCard.name isEqualToString:comparisonCard.name] && ![cardsAccountedFor containsObject:comparisonCard])
                    equivalentCard = comparisonCard;
            }
            
            if (equivalentCard == nil) {
                CCLOG(@"Attachment Inequality");
                equal = NO;
            }
            else {
                [cardsAccountedFor addObject:equivalentCard];
            }
        }
    }
    else
        equal = NO;
    [cardsAccountedFor release];
        
    return equal;
}

-(Resource*)getPrimaryResource {
    Resource *primaryResource;
    if ([type isEqualToString:@"Resource"]) {
        if ([generatedResources count] == 0) {
            NSLog(@"NO PRIMARY RESOURCE TYPE");
            return nil;
        }
        else {
            primaryResource = [generatedResources objectAtIndex:0];
        }
        
        for (Resource *resource in generatedResources) {
            if (resource.amount > primaryResource.amount) {
                primaryResource = resource;
            }
        }
    }
    else {
        if ([costs count] == 0) {
            NSLog(@"NO PRIMARY RESOURCE TYPE");
            return nil;
        }
        else {
            primaryResource = [costs objectAtIndex:0];
        }
        
        for (Resource *resource in costs) {
            if (resource.amount > primaryResource.amount) {
                primaryResource = resource;
            }
        }
    }
    
    return primaryResource;
}

-(void)addPassiveAbility:(NSString *)ability {
    [passiveAbilities addObject:ability];
}

-(void)addActiveAbility:(NSString *)ability {
    [activeAbilities addObject:ability];
}

-(BOOL)hasAbility:(NSString *)ability {
    for (NSString *loopAbility in passiveAbilities) {
        if ([ability isEqualToString:loopAbility])
            return YES;
    }
    for (NSString *loopAbility in activeAbilities) {
        if ([ability isEqualToString:loopAbility])
            return YES;
    }
    return NO;
}

-(BOOL)hasActiveAbility {
    if ([activeAbilities count] > 0)
        return YES;
    return NO;
}

-(BOOL)hasTargetType:(NSString*)targetType {
    for (NSString *loopTargetType in abilityTargetTypes) {
        if ([targetType isEqualToString:loopTargetType]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)hasSubType:(NSString*)subtype {
    for (NSString *loopType in subTypes) {
        if ([loopType isEqualToString:subtype]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)hasAiNote:(NSString*)note {
    for (NSString *loopType in aiNotes) {
        if ([loopType isEqualToString:note]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)hasAttachmentWithName:(NSString*)name {
    for (Card *loopCard in attachedCards) {
        if ([loopCard.name isEqualToString:name]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)canBeTargetOfAbilityFromCard:(Card*)card {
    // IF A CARD IS RESTRICTED TO CERTAIN TYPES (IE ROBOTS)
    for (NSString *ability in card.abilityTargetTypes) {
        if (!([ability rangeOfString:@"Only"].location == NSNotFound)) {
            NSString *restrictionType = [ability stringByReplacingCharactersInRange:[ability rangeOfString:@"Only"] withString:@""];
            if (![self hasSubType:restrictionType]) {
                NSLog(@"Only Restriction: type is %@", restrictionType);
                return NO;
            }
        }
    }
    for (NSString *ability in card.abilityTargetTypes) {
        if ([ability isEqualToString:@"Fighters"]) {
            if (![self.type isEqualToString:@"Fighter"]) {
                NSLog(@"Fighter Restriction");
                return YES;
            }
        }
        else if ([ability isEqualToString:@"FriendlyFighters"]) {
            if (!([self.type isEqualToString:@"Fighter"] && self.owner == card.owner)) {
                NSLog(@"Friendly Fighter Restriction");
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL)canUseAbilityOnType:(NSString*)targetType {
    for (NSString *loopTargetType in abilityTargetTypes) {
        if ([loopTargetType isEqualToString:targetType]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)hasEnhancementWithAbility:(NSString*)ability {
    for (Card *attachedCard in attachedCards) {
        if ([attachedCard hasAbility:ability] && attachedCard.used == NO) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)sortValueHigherThan:(Card*)card {
    Resource *localResource = [costs objectAtIndex:0];
    Resource *otherResource = [card.costs objectAtIndex:0];
    
    return NO;
}

-(NSString*)getThumbPath {
    NSString *thumbPath;
    thumbPath = [imagePath stringByReplacingOccurrencesOfString:@".png" withString:@""];
    thumbPath = [thumbPath stringByAppendingString:@"Thumb.png"];
    return thumbPath;
}

-(int)totalValue {
    int value = 0;
    for (Resource *resource in costs) {
        value += resource.amount;
    }
    return value;
}

-(void)addCost:(Resource*)resource {
    [costs addObject:resource];
    [resource release];
}

-(void)addGeneratedResource:(Resource*)resource {
    [generatedResources addObject:resource];
    [resource release];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        name = [[aDecoder decodeObjectForKey:@"name"] retain];
        attachedCards = [[aDecoder decodeObjectForKey:@"attachedCard"] retain];
        used = [aDecoder decodeBoolForKey:@"used"];
        attacking = [aDecoder decodeBoolForKey:@"attacking"];
        justPlayed = [aDecoder decodeBoolForKey:@"justPlayed"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {    
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:attachedCards forKey:@"attachedCard"];
    [aCoder encodeBool:used forKey:@"used"];
    [aCoder encodeBool:attacking forKey:@"attacking"];
    [aCoder encodeBool:justPlayed forKey:@"justPlayed"];
}

-(void)dealloc {
    [attachedCards release];
    [costs release];
    [passiveAbilities release];
    [activeAbilities release];
    [generatedResources release];
    [givenBuffs release];
    [subTypes release];
    [abilityTargetTypes release];
    [requiredCards release];
    [aiNotes release];
    [thumbSprite release];
    [sprite release];
    [super dealloc];
}

@end
