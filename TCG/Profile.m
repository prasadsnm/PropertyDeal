//
//  Profile.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-30.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "Profile.h"
#import "CardFactory.h"

static Profile *myprofile = nil;

@implementation Profile

@synthesize currentDeck;
@synthesize availableCards;
@synthesize decks;
@synthesize coins;
@synthesize defeatedOpponents;
@synthesize opponentsOfTheDay;
@synthesize popUpsDisplayed;
@synthesize muted;
@synthesize opponentList;
@synthesize currentDeckIndex;
@synthesize coinMultiplier;

+ (Profile*)sharedProfile {
    @synchronized(self) {
        if (myprofile == nil)
            myprofile = [[self alloc] init];
    }
    return myprofile;
}

- (id)init {
    [super init];
    
    currentDeckIndex = -1;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults valueForKey:@"decks"]) {
        decks = [defaults objectForKey:@"decks"];
    }
    else {
        decks = [[NSMutableArray alloc] init];
    }
    
    if ([defaults valueForKey:@"currentDeck"]) {
        currentDeck = [defaults objectForKey:@"currentDeck"];
    }
    else {
        NSLog(@"Creating new deck...");
        currentDeck = [[NSMutableArray alloc] init];
    }
    
    // FIX DECK SAVING ISSUES
    if ([decks count] == 1) {
        [decks replaceObjectAtIndex:0 withObject:currentDeck];
        currentDeckIndex = 0;
    }
    if ([defaults valueForKey:@"currentDeckIndex"])
        currentDeckIndex = [defaults integerForKey:@"currentDeckIndex"];

    
    if ([defaults valueForKey:@"availableCards"]) {
        availableCards = [defaults objectForKey:@"availableCards"];
    }
    else {
        availableCards = [[NSMutableArray alloc] init];
    }
    
    if ([defaults valueForKey:@"defeatedOpponents"])
        defeatedOpponents = [defaults objectForKey:@"defeatedOpponents"];
    else {
        defeatedOpponents = [[NSMutableArray alloc] init];
    }
    
    if ([defaults valueForKey:@"popUpsDisplayed"])
        popUpsDisplayed = [defaults objectForKey:@"popUpsDisplayed"];
    else {
        popUpsDisplayed = [[NSMutableArray alloc] init];
    }
    
    if ([defaults valueForKey:@"coins"])
        coins = [defaults integerForKey:@"coins"];
    else
        coins = 0;
    
    if ([defaults valueForKey:@"coinMultiplier"])
        coinMultiplier = [defaults boolForKey:@"coinMultiplier"];
    else
        coinMultiplier = NO;
        
    return self;
}

- (NSString*)getPopUpPath:(NSString*)popUp {
    for (NSString *name in popUpsDisplayed) {
        if ([name isEqualToString:popUp]) {
            return nil;
        }
    }
    
    if ([popUp isEqualToString:@"Ambush"]) {
        return @"Ambush.png";
    }
    if ([popUp isEqualToString:@"Ranged"]) {
        return @"Ranged.png";
    }
    if ([popUp isEqualToString:@"Pillage"]) {
        return @"Pillage.png";
    }
    if ([popUp isEqualToString:@"Overpower"]) {
        return @"Overpower.png";
    }
    if ([popUp isEqualToString:@"Steal Resources"]) {
        return @"StealResource.png";
    }
    if ([popUp isEqualToString:@"Distract"]) {
        return @"Distract.png";
    }
    if ([popUp isEqualToString:@"Multiple Defenders"]) {
        return @"MultipleDefenders.png";
    }
    
    return nil;
}

- (void)dealloc {
    [super dealloc];
    [decks release];
    [popUpsDisplayed release];
    [currentDeck release];
    [availableCards release];
}

- (void)saveProfile {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:currentDeck forKey:@"currentDeck"];
    [defaults setObject:availableCards forKey:@"availableCards"];
    [defaults setObject:defeatedOpponents forKey:@"defeatedOpponents"];
    [defaults setObject:popUpsDisplayed forKey:@"popUpsDisplayed"];
    [defaults setObject:decks forKey:@"decks"];
    [defaults setInteger:coins forKey:@"coins"];
    [defaults setInteger:currentDeckIndex forKey:@"currentDeckIndex"];
    [defaults setBool:coinMultiplier forKey:@"coinMultiplier"];
    [defaults synchronize];
}

@end
