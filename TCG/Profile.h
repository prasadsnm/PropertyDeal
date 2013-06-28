//
//  Profile.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-30.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject {
    NSMutableArray *currentDeck;
    NSMutableArray *availableCards;
    NSMutableArray *decks;
    NSMutableArray *defeatedOpponents;
    NSMutableArray *opponentsOfTheDay;
    NSMutableArray *popUpsDisplayed;
    NSMutableArray *opponentList;
    int coins;
    int currentDeckIndex;
    BOOL muted;
    BOOL coinMultiplier;
}

@property (nonatomic,assign) NSMutableArray *currentDeck;
@property (nonatomic,assign) NSMutableArray *availableCards;
@property (nonatomic,retain) NSMutableArray *decks;
@property (nonatomic,assign) NSMutableArray *defeatedOpponents;
@property (nonatomic,assign) NSMutableArray *opponentsOfTheDay;
@property (nonatomic,assign) NSMutableArray *popUpsDisplayed;
@property (nonatomic,assign) NSMutableArray *opponentList;
@property (nonatomic) int gameVersion;
@property (nonatomic) int coins;
@property (nonatomic) int currentDeckIndex;
@property (nonatomic) BOOL muted;
@property (nonatomic) BOOL coinMultiplier;

+ (Profile*)sharedProfile;
- (void)saveProfile;
- (NSString*)getPopUpPath:(NSString*)popUp;

@end
