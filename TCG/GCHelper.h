//
//  GCHelper.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-20.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@protocol GCHelperDelegate 
- (void)matchStarted;
- (void)matchEnded;
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data 
   fromPlayer:(NSString *)playerID;
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state;
- (void)inviteReceived;
- (void)noMatchesFound;
@end

@interface GCHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
    UIViewController *presentingViewController;
    GKMatch *match;
    NSMutableDictionary *playersDict;
    BOOL matchStarted;
    id <GCHelperDelegate> delegate;
    GKInvite *pendingInvite;
    NSArray *pendingPlayersToInvite;
    
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;
@property (retain) UIViewController *presentingViewController;
@property (retain) GKMatch *match;
@property (retain) NSMutableDictionary *playersDict;
@property (assign) id <GCHelperDelegate> delegate;
@property (retain) GKInvite *pendingInvite;
@property (retain) NSArray *pendingPlayersToInvite;

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers 
                 viewController:(UIViewController *)viewController 
                       delegate:(id<GCHelperDelegate>)theDelegate;
+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)reportMultiplayerWin;


@end