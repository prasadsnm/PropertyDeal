//
//  GameLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 11-12-11.
//  Copyright 2011 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCTouchDispatcher.h"
#import "cocos2d.h"
#import "Card.h"
#import "Player.h"
#import "GCHelper.h"
#import "BaseLayer.h"

@interface GameLayer : BaseLayer <GCHelperDelegate> {
    BOOL opponentIsHuman;
}

@property (nonatomic) BOOL opponentIsHuman;

// STANDARD FUNCTIONS
- (void)setGamePhase:(int)phase;
- (void)setUpPractice;
- (void)setUpTournament;
- (void)selectCardAtLocation:(CGPoint)location;
- (Card*)getBoardCardAtLocation:(CGPoint)location;
- (BOOL)selectButtonsAtLocation:(CGPoint)location;
- (void)hideBigCard;
- (void)updateResourcePanel;
- (void)endPhase;
- (void)beginPlayerTurn;
- (void)startGame;
- (void)dealFirstHand:(Player*)player;
- (void)procCardAttackPlayerAbilities:(Card*)card onPlayer:(Player*)player;
- (void)procCardAttackAbilitiesBetween:(Card*)playerCard OpponentCard:(Card*)opponentCard;
- (void)procCardPlayedAbilities:(Card*)card;
- (void)procCardDeathAbilities:(Card*)card;
- (void)procCardUpkeepAbilities:(Card*)card;
- (void)procCardUpkeepAbilitiesForPlayer:(Player*)player;
- (void)procBuffsOfOtherCardsOnCard:(Card*)card;
- (void)procUpdateOnCardStats:(Card*)card;
- (BOOL)drawCardForPlayer:(Player*)player;
- (void)floatText:(int)amount forResource:(Resource*)resource forPlayer:(Player*)player;
- (void)floatTextOverCard:(Card*)card withText:(NSString*)text;
- (void)takeDamageFromCard:(Card*)card forPlayer:(Player*)player;
- (void)destroyCard:(Card*)card;
- (void)cleanUpDestroyedCard:(Card*)card;
- (void)resolveBattleBetweenCard:(Card*)playerCard andCard:(Card*)opponentCard;
- (void)setCardToProperBrightness:(Card*)card withDelay:(BOOL)delay;
- (void)setAllCardsToProperBrightness;
- (void)attackWithCard:(Card *)card forPlayer:(Player*)player;
- (void)defendWithCard:(Card *)card forPlayer:(Player*)player;
- (void)showBigCard:(Card *)card;
- (void)animateAllCardsToProperLocation;
- (void)animateCardToProperLocation:(Card *)card forPlayer:(Player*)player;
- (void)animateBoardsToProperLocation:(Player*)player;
- (void)doUpkeepPhase:(Player*)player;
- (void)dealHandForPlayer:(Player*)player;
- (void)redealHandForPlayer:(Player*)player;
- (void)addCardToHand:(Card*)card forPlayer:(Player*)player;
- (void)playCard:(Card *)card forPlayer:(Player*)player onTarget:(id)target;
- (void)addCardToBoard:(Card *)card forPlayer:(Player*)player onTarget:(id)target;
- (void)moveCardToFrontOfHand:(Card *)card;
- (BOOL)cardIsInPlay:(Card *)card;
- (void)showEnhancementsForCard:(Card*)card;
- (void)hideEnhancementsForCard:(Card*)card;
- (void)playSoundForCard:(Card*)card forAction:(NSString*)action;
- (void)playSoundForResource:(Resource*)resource;
- (BOOL)checkIfGameIsFinished;
- (void)enterTargetMode;
- (void)exitTargetMode;
- (void)showButton:(NSString*)buttonName;
- (void)hideButton:(NSString*)buttonName;
- (void)showButtonsForBigCard;
- (void)useAbilityFromCard:(Card*)sourceCard onCard:(Card*)targetCard;
- (void)procAbility:(NSString*)ability onCard:(Card*)targetCard;
- (void)useCardWithAnimation:(Card*)card withEffect:(NSString*)effect;
- (void)stopAttackingCard:(Card*)card;
- (Card*)createCardWithSprites:(NSString*)cardName;
- (void)flashCard:(Card*)card withColor:(ccColor3B)color;
- (void)removeMenu;
- (void)disconnect;
- (void)setUpTutorial;
- (void)getTutorialMessage:(NSString*)message;

// DATA MODIFICATION FUNCTIONS
- (void)giveDamage:(int)damage toPlayer:(Player*)player;
- (void)addResource:(Resource*)resource toPlayer:(Player*)player;
- (void)removeResource:(Resource*)resource toPlayer:(Player*)player;

// UI FUNCTIONS
- (void)showOpponentsTurn;
- (void)hideOpponentsTurn;
- (void)showEndPhase;
- (void)hideEndPhase;

// HELPER FUNCTIONS
- (void)cocosRemoveSprite:(id)sender;
- (void)cocosMoveAllCardToProperLocation:(id)sender;
- (void)cocosDestroyCard:(id)sender data:(Card*)card;
- (void)cocosSetCardToProperBrightness:(id)sender data:(Card*)card;
- (void)cocosDealHandForPlayer:(id)sender data:(Player*)player;
- (void)cocosPlaySoundForCard:(id)sender data:(Card*)card;
- (void)cocosFloatTextOverCard:(id)sender data:(NSArray*)cardAndText;

// TECHNICAL FUNCTIONS
- (int)getIconBufferForAmount:(int)amount;

// MULTIPLAYER FUNCTIONS
- (void)sendData:(NSData *)data;
- (void)tryToDetermineHost;
- (void)sendReadyToPlay;
- (void)sendDeckAndHand;
- (void)sendEndPhase;
- (void)sendPhaseChange:(int)phase;
- (void)sendAttackWithCard:(Card*)card;
- (void)sendDefendWithCard:(Card*)card;
- (void)sendUseAbilityWithCard:(Card*)card onTarget:(Card*)targetCard;

+(CCScene *) scene;
+(CCScene *) tutorialScene;
+(CCScene *) practiceScene;
+(CCScene *) multiplayerScene;


@end
