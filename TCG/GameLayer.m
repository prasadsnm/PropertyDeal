//
//  GameLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 11-12-11.
//  Copyright 2011 Smashware. All rights reserved.
//

#import "GameLayer.h"
#import "Card.h"
#import "Resource.h"
#import "Player.h"
#import "CardFactory.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "MultiplayerMessage.h"
#import "SimpleAudioEngine.h"
#import "Profile.h"
#import "GameOverLayer.h"
#import "CardSprite.h"
#import "PopUpLayer.h"
#import <GameKit/GameKit.h>

#define CARD_SPACING 25
#define CARD_STARTX 190
#define CARD_PLAYERY 100
#define NAMETAG_X 240
#define NAMETAG_SIDE_Y 160
#define BIG_CARDX 420
#define BIG_CARDY 90
#define HEARTX 300
#define ICON_SPACING 15
#define RESOURCE_SPACING 40
#define RESOURCE_Y 9
#define BOARD_CENTER_X 240
#define BOARD_Y 124
#define BOARD_SPACING 40;
#define BOARD_SCALE 0.40
#define ENDPHASE_X 425
#define ENDPHASE_Y 295
#define MID_TAB_X 180
#define OPPONENT_TURN_GRAPHIC_X 20
#define WAITING_FOR_OPPONENT_GRAPHIC_X 40
#define SIDEBOARD_X 375
#define SIDEBOARD_Y 70
#define CARD_USED_DISTANCE 10
#define SIDE_BUTTON_X 464
#define SIDE_BUTTON_MOVE_X 43
#define TOP_BUTTON_Y 230
#define TOP_BUTTON_BUFFER 95
#define BOTTOM_BUTTON_Y 160
#define DEAL_SPEED 0.25
#define FADE_DURATION 2.0
#define FLOAT_TEXT_DELAY 0.3
#define ENHANCEMENT_SPACING 7
#define ENHANCEMENT_BUFFER 8
#define OPPONENT_TURN_DELAY 1.2
#define MAX_Z 10000

#define PREGAME 0
#define PLAYER_TURN 1
#define PLAYER_DEFEND 2
#define OPPONENT_TURN 3
#define OPPONENT_DEFEND 4
#define GAME_FINISHED 5

#define MULTIPLAYER_WAITING_RANDOM 0
#define MULTIPLAYER_RECEIVED_RANDOM 1

Deck *deck;
Player *localPlayer;
Player *opponentPlayer;
Player *leftPlayer;
Player *rightPlayer;
Card *pickedCard;
Card *opponentActiveCard;
Card *playerActiveCard;
CardSprite *bigCard;
CCSprite *attackButton;
CCSprite *defendButton;
CCSprite *abilityButton;
CCSprite *targetButton;
CCSprite *cancelButton;
CCSprite *endTurnButton;
CCSprite *playButton;
CCSprite *redealButton;
CCSprite *opponentTurnGraphic;
CCSprite *waitingForOpponentGraphic;
CCSprite *selectATargetGraphic;
CCSprite *playerResourceBar;
CCSprite *opponentResourceBar;
CCSprite *playerHPSprite;
CCSprite *opponentHPSprite;
CCSprite *menuButton;
CCSprite *showTableButton;
CCLabelTTF *playerHPLabel;
CCLabelTTF *opponentHPLabel;
CardFactory *factory;
GameOverLayer *gameOverLayer;
PopUpLayer *popUpMenuLayer;
NSMutableArray *playerHand;
NSMutableArray *opponentHand;
NSMutableArray *playerBoard;
NSMutableArray *opponentBoard;
NSMutableArray *playerSideBoard;
NSMutableArray *opponentSideBoard;
NSMutableArray *playerActionBoard;
NSMutableArray *opponentActionBoard;
NSMutableArray *cardDiscs;
NSMutableArray *moneyPiles;
NSString *gameState;
BOOL rotated;
BOOL dragging;
BOOL targetMode;
BOOL opponentHandRevealed;
BOOL tutorial;
BOOL defensePopUp;
BOOL tutorialFinished;
BOOL zoomedOnHand;
int turn;
int redealCount;
int zOrder;
int gamePhase;

// MULTIPLAYER VARIABLES
int ourRoll;
int theirRoll;
BOOL host;
BOOL readyToPlay;
BOOL opponentReadyToPlay;

@implementation GameLayer

@synthesize opponentIsHuman;

+(CCScene *)scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
+(CCScene *)practiceScene {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object
	GameLayer *layer = [GameLayer node];
    
    [layer setUpPractice];
    [layer dealFirstHand:nil];
    layer.opponentIsHuman = NO;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
+(CCScene *)tutorialScene {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object
	GameLayer *layer = [GameLayer node];
    
    [layer setUpTutorial];
    
    //[layer setUpPractice];
    //[layer dealFirstHand:nil];
    layer.opponentIsHuman = NO;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}
+(CCScene *)multiplayerScene {
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object
	GameLayer *layer = [GameLayer node];
    layer.opponentIsHuman = YES;
	AppDelegate * delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;                
    [[GCHelper sharedInstance] findMatchWithMinPlayers:2 maxPlayers:2 viewController:delegate.viewController delegate:layer];

	// add layer as a child to scene
	[scene addChild: layer];
    
    // DISABLE SLEEP
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	
	// return the scene
	return scene;
}

-(id)init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        localPlayer = [[Player alloc] init];
        opponentPlayer = [[Player alloc] initWithAI];
        leftPlayer = [[Player alloc] initWithAI];
        rightPlayer = [[Player alloc] initWithAI];
        opponentPlayer.ai.opponent = localPlayer;
        playerHand = [[NSMutableArray alloc] init];
        opponentHand = [[NSMutableArray alloc] init];
        playerBoard = [[NSMutableArray alloc] init];
        opponentBoard = [[NSMutableArray alloc] init];
        playerSideBoard = [[NSMutableArray alloc] init];
        opponentSideBoard = [[NSMutableArray alloc] init];
        playerActionBoard = [[NSMutableArray alloc] init];
        opponentActionBoard = [[NSMutableArray alloc] init];
        localPlayer.hand = playerHand;
        localPlayer.board = playerBoard;
        localPlayer.sideBoard = playerSideBoard;
        localPlayer.actionBoard = playerActionBoard;
        opponentPlayer.hand = opponentHand;
        opponentPlayer.board = opponentBoard;
        opponentPlayer.sideBoard = opponentSideBoard;
        opponentPlayer.actionBoard = opponentActionBoard;
        zOrder = 1;
        redealCount = 0;
        ourRoll = 0;
        theirRoll = 0;
        turn = 0;
        tutorial = NO;
        readyToPlay = NO;
        opponentReadyToPlay = NO;
        
        // SET GAME PHASE
        gamePhase = PREGAME;
        
        // PRELOAD SOUNDS
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        if (audioEngine != nil) {
            if (![Profile sharedProfile].muted)
                [audioEngine setBackgroundMusicVolume:0.4f];
            [audioEngine preloadEffect:@"card.wav"];
            [audioEngine preloadEffect:@"crash.wav"];
            [audioEngine preloadEffect:@"squash.wav"];
            [audioEngine preloadEffect:@"death.wav"];
            [audioEngine preloadEffect:@"coins.wav"];
            [audioEngine preloadEffect:@"empower.wav"];
        }
        
        // SET BACKGROUND
        factory = [[CardFactory alloc] init];
        
        Profile *profile = [Profile sharedProfile];
        
        // SET END PHASE BUTTON AND OPPONENT TURN INDICATOR
        endTurnButton = [CCSprite spriteWithFile: @"endturn.png"];
        //[endTurnButton setPosition:[self makeScaledPointx:ENDPHASE_X y:ENDPHASE_Y]];
        [endTurnButton setPosition:[self makeScaledPointx:ENDPHASE_X + 500 y:ENDPHASE_Y]];
        [self addChild:endTurnButton z:MAX_Z];
        
        showTableButton = [CCSprite spriteWithFile: @"showtable.png"];
        [showTableButton setPosition:[self makeScaledPointx:ENDPHASE_X-40 y:ENDPHASE_Y]];
        showTableButton.visible = NO;
        [self addChild:showTableButton z:MAX_Z];
        
        /*opponentTurnGraphic = [CCSprite spriteWithFile: @"OpponentsTurn.png"];
        [opponentTurnGraphic setPosition:[self makeScaledPointx:ENDPHASE_X + OPPONENT_TURN_GRAPHIC_X y:ENDPHASE_Y+20]];
        [self addChild:opponentTurnGraphic z:MAX_Z];*/
        
        /*waitingForOpponentGraphic = [CCSprite spriteWithFile: @"WaitingForOpponent.png"];
        [waitingForOpponentGraphic setPosition:[self makeScaledPointx:ENDPHASE_X + WAITING_FOR_OPPONENT_GRAPHIC_X y:ENDPHASE_Y+20]];
        [self addChild:waitingForOpponentGraphic z:MAX_Z];*/
        
        /*playButton = [CCSprite spriteWithFile: @"Play.png"];
        [playButton setPosition:[self makeScaledPointx:ENDPHASE_X y:ENDPHASE_Y+20]];
        [self addChild:playButton z:MAX_Z];
        
        redealButton = [CCSprite spriteWithFile: @"Redeal.png"];
        [redealButton setPosition:[self makeScaledPointx:ENDPHASE_X+TOP_BUTTON_BUFFER y:ENDPHASE_Y+20]];
        [self addChild:redealButton z:MAX_Z];
        
        /*menuButton = [CCSprite spriteWithFile: @"MenuButton.png"];
        [menuButton setPosition:[self makeScaledPointx:470 y:ENDPHASE_Y]];
        [self addChild:menuButton z:MAX_Z];*/
        
        CCSprite *nametag = [CCSprite spriteWithFile: @"name.png"];
        [nametag setPosition:[self makeScaledPointx:NAMETAG_X y:37]];
        [self addChild:nametag z:0];
        
        nametag = [CCSprite spriteWithFile: @"name.png"];
        [nametag setPosition:[self makeScaledPointx:480-NAMETAG_X y:320-37]];
        [self addChild:nametag z:0];
        
        nametag = [CCSprite spriteWithFile: @"name.png"];
        [nametag setPosition:[self makeScaledPointx:25 y:NAMETAG_SIDE_Y+5]];
        [self addChild:nametag z:0];
        
        nametag = [CCSprite spriteWithFile: @"name.png"];
        [nametag setPosition:[self makeScaledPointx:480-25 y:320-NAMETAG_SIDE_Y-5]];
        [self addChild:nametag z:0];
        
        cardDiscs = [[NSMutableArray alloc] init];
        moneyPiles = [[NSMutableArray alloc] init];
        
        CCSprite *disc = [CCSprite spriteWithFile: @"disc.png"];
        [disc setPosition:[self makeScaledPointx:NAMETAG_X-60 y:150]];
        disc.scale = 0.5;
        [self addChild:disc z:0];
        [cardDiscs addObject:disc];
        
        CCSprite *moneyPile = [CCSprite spriteWithFile: @"moneystack.png"];
        [moneyPile setPosition:[self makeScaledPointx:NAMETAG_X+60 y:150]];
        moneyPile.scale = 0.5;
        [self addChild:moneyPile z:0];
        [moneyPiles addObject:moneyPile];
        
        disc = [CCSprite spriteWithFile: @"disc.png"];
        [disc setPosition:[self makeScaledPointx:480-NAMETAG_X+20 y:320-120]];
        disc.scale = 0.5;
        [self addChild:disc z:0];
        [cardDiscs addObject:disc];
        
        moneyPile = [CCSprite spriteWithFile: @"moneystack.png"];
        [moneyPile setPosition:[self makeScaledPointx:480-NAMETAG_X-20 y:320-120]];
        moneyPile.scale = 0.5;
        [self addChild:moneyPile z:0];
        [moneyPiles addObject:moneyPile];
        
        disc = [CCSprite spriteWithFile: @"disc.png"];
        [disc setPosition:[self makeScaledPointx:100 y:NAMETAG_SIDE_Y+20]];
        disc.scale = 0.5;
        [self addChild:disc z:0];
        [cardDiscs addObject:disc];
        
        moneyPile = [CCSprite spriteWithFile: @"moneystack.png"];
        [moneyPile setPosition:[self makeScaledPointx:100 y:NAMETAG_SIDE_Y-20]];
        moneyPile.scale = 0.5;
        moneyPile.rotation = 90;
        [self addChild:moneyPile z:0];
        [moneyPiles addObject:moneyPile];
        
        disc = [CCSprite spriteWithFile: @"disc.png"];
        [disc setPosition:[self makeScaledPointx:480-100 y:320-NAMETAG_SIDE_Y-20]];
        disc.scale = 0.5;
        [self addChild:disc z:0];
        [cardDiscs addObject:disc];
        
        moneyPile = [CCSprite spriteWithFile: @"moneystack.png"];
        [moneyPile setPosition:[self makeScaledPointx:480-100 y:NAMETAG_SIDE_Y+20]];
        moneyPile.scale = 0.5;
        moneyPile.rotation = 90;
        [self addChild:moneyPile z:0];
        [moneyPiles addObject:moneyPile];

        self.isTouchEnabled = YES;
	}
	return self;
}
-(void)dealloc {
	// cocos2d will automatically release all the children (Label)
    [localPlayer release];
    [opponentPlayer release];
    [playerBoard release];
    [opponentBoard release];
    [playerSideBoard release];
    [opponentSideBoard release];
    [playerHand release];
    [opponentHand release];
    [playerActionBoard release];
    [opponentActionBoard release];
    [cardDiscs release];
    [moneyPiles release];
	
	[super dealloc];
}

// TOUCH FUNCTIONS
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    // CHECK IF PLAYER IS SELECTING A BUTTON
    if (![self selectButtonsAtLocation:location] && gamePhase != GAME_FINISHED)
        // CHECK IF PLAYER IS SELECTING A CARD
        [self selectCardAtLocation:location];

    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    
    // IF CARD BELONGS TO PLAYER'S HAND, MOVE IT AND SHOW INFO
    /*
    if (pickedCard != nil && ![self cardIsInPlay:pickedCard] && pickedCard.owner == localPlayer) {
        [pickedCard.thumbSprite setPosition:location];
        
        if (!dragging) {
            [self moveCardToFrontOfHand:pickedCard];
            if (bigCard != nil) {
                [bigCard runActionOnChildren:[CCFadeTo actionWithDuration:0.2 opacity:0]];
            }
            dragging = YES;
        }
        else if ([pickedCard.type isEqualToString:@"Enhancement"] || [pickedCard.type isEqualToString:@"Action"]) {
            if ([pickedCard hasTargetType:@"Fighters"]) {
                Card *foundCard = nil;
                for (Card *card in playerBoard) {
                    [self setCardToProperBrightness:card withDelay:NO];
                    if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
                        foundCard = card;
                    }
                }
                for (Card *card in opponentBoard) {
                    [self setCardToProperBrightness:card withDelay:NO];
                    if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
                        foundCard = card;
                    }
                }
                if (foundCard != nil) {
                    [bigCard showStatsForCard:foundCard];
                    [bigCard setOpacity:255];
                    
                    ccColor3B color = foundCard.thumbSprite.color;
                    if (foundCard.used)
                        [foundCard.thumbSprite setColor:ccc3(color.r-20, color.g-20, color.b-20)];
                    else
                        [foundCard.thumbSprite setColor:ccc3(color.r-40, color.g-40, color.b-40)];  
                 }   
                else {
                    [bigCard setOpacity:0];
                }    
            }
            if ([pickedCard hasTargetType:@"Players"]) {
                [playerResourceBar setColor:ccc3(255, 255, 255)];
                [opponentResourceBar setColor:ccc3(255, 255, 255)];
                int heightTouchBuffer = 30;
                //CGRect opponentBox = CGRectMake(opponentResourceBar.boundingBox.origin.x, opponentResourceBar.boundingBox.origin.y-heightTouchBuffer, opponentResourceBar.boundingBox.size.width, opponentResourceBar.boundingBox.size.height+heightTouchBuffer);
                CGRect playerBox = CGRectMake(playerResourceBar.boundingBox.origin.x, playerResourceBar.boundingBox.origin.y, playerResourceBar.boundingBox.size.width, playerResourceBar.boundingBox.size.height+heightTouchBuffer);
                if (location.y > 250) {
                    [opponentResourceBar setColor:ccc3(150, 150, 150)];
                }
                else if (CGRectContainsPoint(playerBox, location)) {
                    [playerResourceBar setColor:ccc3(150, 150, 150)];
                }
            }
        }
    }
     */
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint location = [self convertTouchToNodeSpace: touch];
    BOOL dragBack = NO;
    if (pickedCard != nil) {
        if (![self cardIsInPlay:pickedCard] && pickedCard.owner == localPlayer) {
            if ((location.y > 80 || location.x > 320) && dragging == YES && (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND)) {
                if ([localPlayer canPlayCard:pickedCard]) {
                    // PUT CARD ON BOARD
                    if ([pickedCard.type isEqualToString:@"Enhancement"] || [pickedCard.type isEqualToString:@"Action"]) {
                        if ([pickedCard hasTargetType:@"Global"]) {
                            [self playCard:pickedCard forPlayer:pickedCard.owner onTarget:nil];
                        }
                        if ([pickedCard hasTargetType:@"Fighters"]) {
                            Card *target = [self getBoardCardAtLocation:location];
                            if (target != nil) {
                                if ([target canBeTargetOfAbilityFromCard:pickedCard])
                                    [self playCard:pickedCard forPlayer:localPlayer onTarget:target];
                                else
                                    dragBack = YES;
                            }
                        }
                        else {
                            dragBack = YES;
                        }
                        if ([pickedCard hasTargetType:@"Players"]) {
                            int heightTouchBuffer = 30;
                            //CGRect opponentBox = CGRectMake(opponentResourceBar.boundingBox.origin.x, opponentResourceBar.boundingBox.origin.y-heightTouchBuffer, opponentResourceBar.boundingBox.size.width, opponentResourceBar.boundingBox.size.height+heightTouchBuffer);
                            CGRect playerBox = CGRectMake(playerResourceBar.boundingBox.origin.x, playerResourceBar.boundingBox.origin.y, playerResourceBar.boundingBox.size.width, playerResourceBar.boundingBox.size.height+heightTouchBuffer);
                            if (location.y > 250) {
                                [self playCard:pickedCard forPlayer:localPlayer onTarget:opponentPlayer];
                                NSLog(@"Play card on opponent");
                            }
                            else if (CGRectContainsPoint(playerBox, location)) {
                                [self playCard:pickedCard forPlayer:localPlayer onTarget:localPlayer];
                            }
                            
                        }
                    }
                    
                    else if (gamePhase == PLAYER_TURN)
                        [self playCard:pickedCard forPlayer:localPlayer onTarget:nil];
                    else
                        dragBack = YES;
                }
                else {
                    dragBack = YES;
                }
            }
            else {
                dragBack = YES;
            }
            //[self setAllCardsToProperBrightness];
        }
    }
    /*
    if (dragBack) {
        // DRAG CARD BACK
        [self animateCardToProperLocation:pickedCard forPlayer:localPlayer];
        if (bigCard != nil) {
            [bigCard showStatsForCard:pickedCard];
            [bigCard runActionOnChildren:[CCFadeTo actionWithDuration:0.2 opacity:255]];
        }
    }*/
    
    [playerResourceBar setColor:ccc3(255, 255, 255)];
    [opponentResourceBar setColor:ccc3(255, 255, 255)];
    
    dragging = NO;
}

// TURN FLOW FUNCTIONS
- (void)setUpPractice {    
    // OPPONENT CARDS
    NSArray *cardNames;
    //[self loadBackgroundWithName:@"Castle"];
    CCSprite *background;
    background = [CCSprite spriteWithFile: @"backgroundwide.png"];
    [background setPosition:[self makeScaledPointx:240 y:160]];
    [background setOpacity:0];
    [background runAction:[CCFadeIn actionWithDuration:0.5]];
    [self addChild:background z:-1];
    
    /*for (NSString *cardName in cardNames) {
        [opponentPlayer.deck addCard:[factory spawnCard:cardName]];
    }
    [opponentPlayer.deck shuffle];

    [self opponentDrawHand];*/
}
- (void)setUpTutorial {
    tutorial = YES;
    
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Intro"], nil]];
}
- (void)dealFirstHand:(Player *)player {
    id delay = [CCDelayTime actionWithDuration:1.0];
    id dealHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:localPlayer];
    id dealOpponentHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:opponentPlayer];
    id dealLeftPlayerHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:leftPlayer];
    id dealRightPlayerHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:rightPlayer];
    if (player == nil) {
        id dealAllHands = [CCSpawn actions:dealHand, dealOpponentHand, dealLeftPlayerHand, dealRightPlayerHand, nil];
        [self runAction:[CCSequence actions:delay, dealAllHands, nil]];
        //id showBlackBar = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowBlackBarWithText:data:) data:@"Ready!"];
        //[self runAction:[CCSequence actions:[delay copy],showBlackBar, nil]];
        [self runAction:[CCSequence actions:[delay copy], nil]];

    }
    else if (player == localPlayer) {
        [self runAction:[CCSequence actions:delay, dealHand, nil]];
        //id showBlackBar = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowBlackBarWithText:data:) data:@"Ready!"];
        //[self runAction:[CCSequence actions:[delay copy],showBlackBar, nil]];
        [self runAction:[CCSequence actions:[delay copy], nil]];
    }
    else if (player == opponentPlayer) {
        [self runAction:[CCSequence actions:delay, dealOpponentHand, nil]];
    }
}
- (void)startGame {
    deck = [factory spawnDeck];
    [deck shuffle];
    [self hideWaitingForOpponent];
    //[self showBlackBarWithText:@"Begin!"];
    if (gamePhase == PREGAME) {
        gamePhase = PLAYER_TURN;
    }
    
    if (gamePhase == PLAYER_TURN) {
        //[self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCCallFunc actionWithTarget:self selector:@selector(showEndPhase)], nil]];
    }
    else {
        //[self showOpponentsTurn];
    }
    
    if (tutorial)
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2.0],[CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"First Round"], nil]];
}
- (void)endPhase {
    [self drawCardForPlayer:localPlayer];
    [self drawCardForPlayer:localPlayer];
    /*
    [self stopFlashingEndTurn];
    switch (gamePhase) {
        case PLAYER_TURN:
            [self setGamePhase:OPPONENT_TURN];
            [self hideBigCard];
            [self opponentTurn];
            if (opponentIsHuman)
                [self sendEndPhase];
            break;
            
        case PLAYER_DEFEND:
            if (opponentIsHuman)
                [self sendDefendWithCard:nil];
            if (opponentActiveCard.used == NO)
                [self takeDamageFromCard:opponentActiveCard forPlayer:localPlayer];
            [self opponentFinishedAttack];
            break;
        
        case OPPONENT_TURN:
            [self setGamePhase:PLAYER_TURN];
            [self beginPlayerTurn];
            break;
            
        default:
            break;
    }
    */
}
- (void)doUpkeepPhase:(Player *)player {
    NSArray *sideBoard;
    NSArray *board;
    
    player.resourcePlayed = NO;
    
    if (player == localPlayer) {
        if (opponentIsHuman)
            [self showBlackBarWithText:@"Your Turn!"];
        sideBoard = playerSideBoard;
        board = playerBoard;
        for (Card *card in opponentBoard) {
            card.justPlayed = NO;
            [self setCardToProperBrightness:card withDelay:YES];
        }
        turn++;
        if (tutorial && gamePhase == PLAYER_TURN && [player.board count] > 0 && turn == 1) {
            id delay = [CCDelayTime actionWithDuration:2.0];
            id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Attacking"];
            [playButton runAction:[CCSequence actions:delay, showPopUp, nil]];
        }
    }
    else if (player == opponentPlayer) {
        sideBoard = opponentSideBoard;
        board = opponentBoard;
        for (Card *card in playerBoard) {
            card.justPlayed = NO;
            [self setCardToProperBrightness:card withDelay:YES];
        }
        if (opponentHandRevealed)
            [self hideOpponentHand];
    }
    
    ResourcePool *pool = [[ResourcePool alloc] init];
    for (Card *card in sideBoard) {
        card.justPlayed = NO;
        for (Resource *generatedResource in card.generatedResources) {
            [pool addResource:generatedResource];
        }
    }
    for (Card *card in board) {
        for (Resource *generatedResource in card.generatedResources) {
            [pool addResource:generatedResource];
        }
        NSMutableArray *cardsToDestroy = [[NSMutableArray alloc] init];
        for (Card *enhancementCard in card.attachedCards) {
            if (enhancementCard.dieNextTurn) {
                [cardsToDestroy addObject:enhancementCard];
            }
            else {
                enhancementCard.used = NO;
                [self setCardToProperBrightness:enhancementCard withDelay:YES];
            }
        }
        for (Card *cardToDestroy in cardsToDestroy) {
            [self destroyCard:cardToDestroy];
        }
        [cardsToDestroy release];
        card.used = NO;
        card.justPlayed = NO;
        [self setCardToProperBrightness:card withDelay:YES];
    }
    
    [self procCardUpkeepAbilitiesForPlayer:player];
    int count = [board count];
    for (int i = 0; i < count; i++) {
        Card *card = [board objectAtIndex:i];
        [self procCardUpkeepAbilities:card];
        
    }

    // ADD ALL OF RESOURCE TYPE AT ONCE
    for (Resource *resource in pool.resources) {
        [self addResource:resource toPlayer:player];
    }
    [pool release];
    
    // DRAW A CARD
    if (![self drawCardForPlayer:player]) {
        if (player == localPlayer)
            [self finishGameWithCondition:@"Defeat:OutOfCards"];
        else
            [self finishGameWithCondition:@"Victory:OutOfCards"];
    }
}
- (void)beginPlayerTurn {
    // GIVE PLAYER RESOURCES AT BEGINNING OF TURN
    [self doUpkeepPhase:localPlayer];
    
    if (tutorial && defensePopUp && !tutorialFinished) {
        id delay = [CCDelayTime actionWithDuration:2.0];
        id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Enhancements"];
        [self runAction:[CCSequence actions:delay, showPopUp, nil]];
    }
    
    // REFRESH BUTTONS ON SELECTED CARD
    if (pickedCard != nil) {
        [self hideBigCard];
        [self showBigCard:pickedCard];
    }    
}
- (void)setGamePhase:(int)phase {
    if (gamePhase == GAME_FINISHED)
        return;
    
    gamePhase = phase;
    if (phase == PLAYER_TURN || phase == PLAYER_DEFEND) {
        [self showEndPhase];
        [self hideOpponentsTurn];
        playerActiveCard = nil;
    }
    else if (phase == OPPONENT_TURN || phase == OPPONENT_DEFEND) {
        [self hideEndPhase];
        [self showOpponentsTurn];
    }
    
    if (phase == PLAYER_TURN || phase == OPPONENT_TURN) {
        for (Card *card in opponentBoard) {
            card.attacking = NO;
        }
        for (Card *card in playerBoard) {
            card.attacking = NO;
        }
    }
}
- (BOOL)checkIfGameIsFinished {
    id delay = [CCDelayTime actionWithDuration:1.0];
    id smallDelay = [CCDelayTime actionWithDuration:0.25];
    if (localPlayer.hp <= 0) {
        [self freezeGameState];
        id finishGame = [CCCallFuncND actionWithTarget:self selector:@selector(cocosFinishGameWithCondition:data:) data:@"Defeat"];
        id destroyCards = [self destroyAllCardsForPlayer:localPlayer];
        id destroyResources = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDestroyResourcesForPlayer:data:) data:localPlayer];
        [self runAction:[CCSequence actions:destroyCards,smallDelay,destroyResources,delay,finishGame, nil]];
        return YES;
    }
    else if (opponentPlayer.hp <= 0) {
        [self freezeGameState];
        id finishGame = [CCCallFuncND actionWithTarget:self selector:@selector(cocosFinishGameWithCondition:data:) data:@"Victory"];
        id destroyCards = [self destroyAllCardsForPlayer:opponentPlayer];
        id destroyResources = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDestroyResourcesForPlayer:data:) data:opponentPlayer];
        [self runAction:[CCSequence actions:destroyCards,smallDelay,destroyResources,delay,finishGame, nil]];
        return YES;
    }
    return NO;
}
- (void)freezeGameState {
    [self hideEndPhase];
    [self hideOpponentsTurn];
    [self setGamePhase:GAME_FINISHED];
    [self hideBigCard];
}
- (void)finishGameWithCondition:(NSString*)condition {
    int earnedCoins;
    NSString *mode = @"Practice";
    
    earnedCoins = 2;
    
    if (opponentIsHuman) {
        mode = @"Multiplayer";
        earnedCoins = 5;
        if ([condition isEqualToString:@"Victory"] || [condition isEqualToString:@"Victory:OutOfCards"])
            [[GCHelper sharedInstance] reportMultiplayerWin];
    }
    
    if ([condition isEqualToString:@"Defeat"] || [condition isEqualToString:@"Defeat:OutOfCards"]) {
        if ([mode isEqualToString:@"Multiplayer"])
            earnedCoins = 2;
        else
            earnedCoins = 0;
    }
    
    if (tutorial)
        mode = @"Tutorial";
    
    if ([Profile sharedProfile].coinMultiplier == YES) {
        earnedCoins = earnedCoins * 2;
    }
    
    if ([condition isEqualToString:@"Victory"]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:YES subText:@"You defeated your opponent!" earnedCoins:earnedCoins fromMode:mode]]];
    }
    else if ([condition isEqualToString:@"Defeat"]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:NO subText:@"You were beaten by your opponent!" earnedCoins:earnedCoins fromMode:mode]]];
    }
    else if ([condition isEqualToString:@"Victory:OutOfCards"]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:YES subText:@"Your opponent ran out of cards!" earnedCoins:earnedCoins fromMode:mode]]];
    }
    else if ([condition isEqualToString:@"Defeat:OutOfCards"]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameOverLayer sceneWithVictory:NO subText:@"You ran out of cards!" earnedCoins:earnedCoins fromMode:mode]]];
    }
}
- (void)enterTargetMode {
    targetMode = YES;
    playerActiveCard = pickedCard;
    
    if (attackButton != nil)
        [self hideButton:@"AttackButton"];
    if (defendButton != nil)
        [self hideButton:@"DefendButton"];
    if (abilityButton != nil)
        [self hideButton:@"AbilityButton"];
    
    [self hideEndPhase];
    [self showButton:@"Cancel"];
    [self showButton:@"SelectATarget"];
    [self hideBigCard];
    //[self showBlackBarWithText:@"Select a Target!"];
}
- (void)exitTargetMode {
    targetMode = NO;
    playerActiveCard = nil;
    
    if (targetButton != nil)
        [self hideButton:@"TargetButton"];
    if (cancelButton != nil)
        [self hideButton:@"CancelButton"];
    
    if (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND)
        [self showEndPhase];
        
    [self hideButton:@"Cancel"];
    [self hideButton:@"SelectATarget"];
}
- (void)getTutorialMessage:(NSString*)message {
    if ([message isEqualToString:@"Intro"]) {
        [self dealFirstHand:nil];
        [self opponentDrawHand];
    }
    else if ([message isEqualToString:@"End Phase"]) {
        [self flashEndTurn];
    }
    else if ([message isEqualToString:@"Health"]) {
        id delay = [CCDelayTime actionWithDuration:2.0];
        id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"End Turn"];
        [self runAction:[CCSequence actions:delay, showPopUp, nil]];
    }
    else if ([message isEqualToString:@"Defending"]) {
        defensePopUp = YES;
    }
    else if ([message isEqualToString:@"Tutorial Finished"]) {
        tutorialFinished = YES;
    }
}

// OPPONENT AI FUNCTIONS
- (void)opponentDefendAttackingCard:(Card *)card {
    if (!opponentIsHuman) {
        Card *defendingCard = [opponentPlayer.ai chooseDefenderFromBoard:opponentBoard againstCard:card];
        if (defendingCard != nil) {
            [self resolveBattleBetweenCard:card andCard:defendingCard];
        }
        else {
            [self takeDamageFromCard:card forPlayer:opponentPlayer];
        }
    }
    [self setGamePhase:PLAYER_TURN];
}
- (void)opponentTurn {
    [self doUpkeepPhase:opponentPlayer];
    
    if (!opponentIsHuman) {
        id delay = [CCDelayTime actionWithDuration:OPPONENT_TURN_DELAY];
        id playResource = [CCCallFunc actionWithTarget:self selector:@selector(opponentPlayResource)];
        id playCard = [CCCallFunc actionWithTarget:self selector:@selector(opponentPlayCard)];
        
        [self runAction:[CCSequence actions:delay,playResource,delay,playCard,nil]];
    }
}
- (void)opponentCheckFinished {
    if (gamePhase != PLAYER_DEFEND) {
        if (![self opponentAttack])
            [self endPhase];
    }
}
- (void)opponentPlayResource {
    Card *opponentCard;
    opponentCard = [opponentPlayer.ai pickResourceFromHand:opponentHand];
    if (opponentCard != nil)
        [self playCard:opponentCard forPlayer:opponentPlayer onTarget:nil];
}
- (void)opponentPlayCard {
    Card *opponentCard;
    opponentCard = [opponentPlayer.ai pickCardFromHand:opponentHand];
    if (opponentCard != nil) {
        id target = [opponentPlayer.ai chooseTargetForCard:opponentCard];
        [self playCard:opponentCard forPlayer:opponentPlayer onTarget:target];
        id delay = [CCDelayTime actionWithDuration:OPPONENT_TURN_DELAY/2];
        id playCard = [CCCallFunc actionWithTarget:self selector:@selector(opponentPlayCard)];
        [self runAction:[CCSequence actions:delay,playCard,nil]];
    }
    else {
        id delay = [CCDelayTime actionWithDuration:OPPONENT_TURN_DELAY];
        id attack = [CCCallFunc actionWithTarget:self selector:@selector(opponentAttack)];
        id checkEnd = [CCCallFunc actionWithTarget:self selector:@selector(opponentCheckFinished)];
        [self runAction:[CCSequence actions:delay,attack,checkEnd,nil]];
    }
}
- (BOOL)opponentAttack {
    Card *attackingCard = [opponentPlayer.ai chooseAttackerFromBoard:opponentBoard againstBoard:playerBoard];
    
    if (attackingCard != nil) {
        [self attackWithCard:attackingCard forPlayer:opponentPlayer];
        
        if (tutorial && !defensePopUp) {
            id delay = [CCDelayTime actionWithDuration:1.5];
            id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Defending"];
            [self runAction:[CCSequence actions:delay, showPopUp, nil]];
        }
    }
    else
        return NO;
    
    return YES;
}
- (void)opponentFinishedAttack {
    opponentActiveCard = nil;
    [self setGamePhase:OPPONENT_TURN];
    if (!opponentIsHuman) {
        id delay = [CCDelayTime actionWithDuration:OPPONENT_TURN_DELAY];
        id checkEnd = [CCCallFunc actionWithTarget:self selector:@selector(opponentCheckFinished)];
        [self runAction:[CCSequence actions:delay, checkEnd, nil]];
    }
}
- (void)opponentDrawHand {
    // GET FIRST 7 CARDS
    while (![opponentPlayer.deck hasResourceInDraw]) {
        [opponentPlayer.deck shuffle];
    }
    
    for (int i = 0; i < 5; i++) {
        [self addCardToHand:[opponentPlayer.deck drawCard] forPlayer:opponentPlayer];
    }
}

// CARD ACTION FUNCTIONS
- (void)addCardToHand:(Card*)card forPlayer:(Player*)player {
    card.owner = player;
    [player.hand addObject:card];
    [self procUpdateOnCardStats:card];
}
- (void)playCard:(Card *)card forPlayer:(Player*)player onTarget:(id)target {
    Card *targetCard = nil;
    Player *targetPlayer = nil;
    if ([target isKindOfClass:[Card class]])
        targetCard = target;
    else if (target != nil)
        targetPlayer = target;
    
    if (player == localPlayer) {
        pickedCard = nil;
        [self setCardToProperBrightness:card withDelay:YES];
        [self hideBigCard];
    }
    
    if ([card.type isEqualToString:@"Money"] || [card.type isEqualToString:@"Property"]) {
        // SHOW ABILITY TUTORIAL POP UPS
        Profile *profile = [Profile sharedProfile];
        for (NSString *ability in card.passiveAbilities) {
            NSString *abilityPath = [profile getPopUpPath:ability];
            
            if (abilityPath != nil) {
                [profile.popUpsDisplayed addObject:ability];
                [profile saveProfile];
                [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowAbilityPopUpWithName:data:) data:abilityPath],nil]];
            }
        }
        for (NSString *ability in card.activeAbilities) {
            NSString *abilityPath = [profile getPopUpPath:ability];
            
            if (abilityPath != nil) {
                [profile.popUpsDisplayed addObject:ability];
                [profile saveProfile];
                [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5], [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowAbilityPopUpWithName:data:) data:abilityPath],nil]];
            }
        }
        
        [self addCardToBoard:card forPlayer:player onTarget:nil];
        if (opponentIsHuman && player == localPlayer) {
            MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
            message.code = @"Play Card";
            message.cardName = card.name;
            message.targetCard = nil;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
            [self sendData:data];
            [message release];        
        }
    }
    else if ([card.type isEqualToString:@"Enhancement"]) {
        if (opponentIsHuman && player == localPlayer) {
            MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
            message.code = @"Play Card";
            message.cardName = card.name;
            message.targetCard = targetCard;
            if (targetCard.owner == localPlayer)
                message.targetPlayer = @"Friendly";
            else if (targetCard.owner == opponentPlayer)
                message.targetPlayer = @"Enemy";
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
            [self sendData:data];
            [message release];        
        }
        [self addCardToBoard:card forPlayer:player onTarget:target];
    }
    else if ([card.type isEqualToString:@"Action"]) {
        if (opponentIsHuman && player == localPlayer) {
            MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
            message.code = @"Play Card";
            message.cardName = card.name;
            message.targetCard = targetCard;
            NSString *targetPlayerMessage = @"";
            if (targetPlayer == localPlayer)
                targetPlayerMessage = @"LocalPlayer";
            else if (targetPlayer == opponentPlayer)
                targetPlayerMessage = @"OpponentPlayer";
            else if (targetCard.owner == localPlayer)
                targetPlayerMessage = @"Friendly";
            else if (targetCard.owner == opponentPlayer)
                targetPlayerMessage = @"Enemy";
            message.targetPlayer = targetPlayerMessage;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
            [self sendData:data];
            [message release];
        }
        NSLog(@"Action Card");
        if (targetPlayer) {
            NSLog(@"Player on player");
            [self addCardToBoard:card forPlayer:player onTarget:targetPlayer];
        }
        else if (target != nil) {
            NSLog(@"Played on target");
            [self addCardToBoard:card forPlayer:player onTarget:targetCard];
        }
        else {
            NSLog(@"Played Globally");
            [self addCardToBoard:card forPlayer:player onTarget:nil];
        }
    }

    [self animateAllCardsToProperLocation];
}
- (void)addCardToBoard:(Card *)card forPlayer:(Player *)player onTarget:(id)target {
    [self addCardToBoard:card forPlayer:player onTarget:target chargeForCard:YES];
}
- (void)addCardToBoard:(Card *)card forPlayer:(Player *)player onTarget:(id)target chargeForCard:(BOOL)costFlag {
    Card *targetCard = nil;
    Player *targetPlayer = nil;
    if ([target isKindOfClass:[Card class]])
        targetCard = target;
    else
        targetPlayer = target;
    
    if (costFlag) {
        [player payForCard:card];
    }
    
    [self procBuffsOfOtherCardsOnCard:card];
    [card.thumbSprite runAction:[CCScaleTo actionWithDuration:0.2 scale:BOARD_SCALE]];
    if (card.type == @"Resource") {
        player.resourcePlayed = YES;
        
        if (tutorial && gamePhase == PLAYER_TURN && [player.sideBoard count] == 0) {
            id delay = [CCDelayTime actionWithDuration:2.0];
            id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Fighters"];
            [playButton runAction:[CCSequence actions:delay, showPopUp, nil]];
        }
    }
    else {
        if (![card.type isEqualToString:@"Enhancement"]) {
            if (![card hasAbility:@"Ambush"]) {
                if (costFlag)
                    card.justPlayed = YES;
                
                // SET TO PROPER BRIGHTNESS IF COMING FROM THE PLAYER'S HAND
                if ([player.hand containsObject:card]) {
                    [self setCardToProperBrightness:card withDelay:YES];
                }
            }
        }
        if ([player.hand containsObject:card])
            [self playSoundForCard:card forAction:@"Played"];
    }
    
    if (player == localPlayer) {
        if ([card.type isEqualToString:@"Property"] ||[card.type isEqualToString:@"Money"]) {
            if ([card.type isEqualToString:@"Property"]) {
                BOOL shouldStack = NO;
                for (Card *boardCard in player.board) {
                    if ([boardCard.type isEqualToString:@"Property"] && [boardCard.subType isEqualToString:card.subType]) {
                        [self reorderChild:card.thumbSprite z:boardCard.thumbSprite.zOrder-[boardCard.attachedCards count]];
                        card.host = boardCard;
                        [boardCard.attachedCards addObject:card];
                        shouldStack = YES;
                    }
                }
                if (shouldStack == NO)
                    [playerBoard addObject:card];
            }
            else {
                BOOL shouldStack = NO;
                for (Card *boardCard in player.board) {
                    if ([boardCard.type isEqualToString:@"Money"]) {
                        [self reorderChild:card.thumbSprite z:boardCard.thumbSprite.zOrder-[boardCard.attachedCards count]];
                        card.host = boardCard;
                        [boardCard.attachedCards addObject:card];
                        shouldStack = YES;
                    }
                }
                if (shouldStack == NO)
                    [playerBoard insertObject:card atIndex:0];
            }
            
            if (tutorial && gamePhase == PLAYER_TURN && [player.board count] == 1 && [player.graveyard count] == 0) {
                id delay = [CCDelayTime actionWithDuration:2.0];
                id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"End Phase"];
                [playButton runAction:[CCSequence actions:delay, showPopUp, nil]];
            }
        }
        else if ([card.type isEqualToString:@"Enhancement"]) {
            [self reorderChild:card.thumbSprite z:targetCard.thumbSprite.zOrder-1];
            card.host = targetCard;
            [targetCard.attachedCards addObject:card];
            //[self floatTextOverCard:targetCard withText:card.name];
            if (card.owner == targetCard.owner)
                [self flashCard:targetCard withColor:ccc3(0, 200, 0)];
            else
                [self flashCard:targetCard withColor:ccc3(200, 0, 0)];
        }
        else if ([card.type isEqualToString:@"Action"]) {
            [card retain];
            [playerHand removeObject:card];
            
            if ([card hasTargetType:@"Global"]) {
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onCard:nil];
                }
            }
            if (targetCard) {
                if (card.owner == targetCard.owner)
                    [self flashCard:targetCard withColor:ccc3(0, 200, 0)];
                else if ([card hasAbility:@"Bribe"])
                    ;// Do nothing
                else
                    [self flashCard:targetCard withColor:ccc3(200, 0, 0)];
                
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onCard:targetCard];
                }
            }
            if (targetPlayer) {
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onPlayer:targetPlayer];
                }
            }
            
            [self destroyCard:card];
        }
        else if ([card.type isEqualToString:@"Resource"]) {
            [playerSideBoard addObject:card];
            for (Resource *generatedResource in card.generatedResources) {
                [self addResource:generatedResource toPlayer:player];
            }
        }
        [playerHand removeObject:card];
    }
    else if (player == opponentPlayer) {
        [card.thumbSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:card.getThumbPath]];
        if ([card.type isEqualToString:@"Fighter"]) {
            [opponentBoard addObject:card];
        }
        else if ([card.type isEqualToString:@"Enhancement"]) {
            [self reorderChild:card.thumbSprite z:targetCard.thumbSprite.zOrder-1];
            card.host = targetCard;
            NSLog(@"Card has been assigned host with name %@ and retaincount %d",card.host.name,card.host.retainCount);
            [targetCard.attachedCards addObject:card];
            [self hideBigCard];
            [self showBigCard:card];
            //[self floatTextOverCard:targetCard withText:card.name];
            if (card.owner == targetCard.owner)
                [self flashCard:targetCard withColor:ccc3(0, 200, 0)];
            else
                [self flashCard:targetCard withColor:ccc3(200, 0, 0)];
        }
        else if ([card.type isEqualToString:@"Action"]) {
            [self hideBigCard];
            [self showBigCard:card];
            [card retain];
            [opponentHand removeObject:card];
            
            if ([card hasTargetType:@"Global"]) {
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onCard:nil];
                }
            }
            if (targetCard) {
                if (card.owner == targetCard.owner)
                    [self flashCard:targetCard withColor:ccc3(0, 200, 0)];
                else
                    [self flashCard:targetCard withColor:ccc3(200, 0, 0)];
                
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onCard:targetCard];
                }
            }
            if (targetPlayer) {
                for (NSString *ability in card.passiveAbilities) {
                    [self procAbility:ability fromCard:card onPlayer:targetPlayer];
                }
            }
            [self destroyCard:card];
        }
        else if ([card.type isEqualToString:@"Resource"]) {
            [opponentSideBoard addObject:card];
            for (Resource *generatedResource in card.generatedResources) {
                [self addResource:generatedResource toPlayer:player];
            }
        }        
        [opponentHand removeObject:card];
    }
    
    [self procCardPlayedAbilities:card];
    [self updateResourcePanel];
}
- (BOOL)cardIsInPlay:(Card *)card {
    BOOL cardFound = NO;
    for (Card *loopCard in playerBoard) {
        if (loopCard == card)
            cardFound = YES;
        for (Card *enhancementCard in loopCard.attachedCards) {
            if (enhancementCard == card) {
                cardFound = YES;
            }
        }
    }
    for (Card *loopCard in playerSideBoard) {
        if (loopCard == card)
            cardFound = YES;
    }
    for (Card *loopCard in opponentBoard) {
        if (loopCard == card)
            cardFound = YES;
        for (Card *enhancementCard in loopCard.attachedCards) {
            if (enhancementCard == card) {
                cardFound = YES;
            }
        }
    }
    for (Card *loopCard in opponentSideBoard) {
        if (loopCard == card)
            cardFound = YES;
    }
    return cardFound;
}
- (Card*)getBoardCardAtLocation:(CGPoint)location {
    Card *selectedCard = nil;
    for (Card *card in playerBoard) {
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            selectedCard = card;
        }
    }
    for (Card *card in opponentBoard) {
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            selectedCard = card;
        }
    }
    return selectedCard;
}
- (void)destroyCard:(Card *)card {
    if (!card.dying) {
        for (Card *loopCard in playerHand)
            [self procUpdateOnCardStats:loopCard];
        for (Card *loopCard in opponentHand)
            [self procUpdateOnCardStats:loopCard];
        
        [card.thumbSprite stopAllActions];
        card.dying = YES;
        id moveForward;
        if (card.type == @"Fighter")
            [self procCardDeathAbilities:card];
        else if (card.type == @"Enhancement") {
            NSLog(@"Card host name is %@", card.host.name);
        }
        
        if ([card.type isEqualToString:@"Action"] && gamePhase != GAME_FINISHED) {
            id fadeOut = [CCFadeTo actionWithDuration:0.1 opacity:0];
            [card.thumbSprite runAction:[CCSpawn actions:fadeOut, nil]];
        }
        else {
            [[SimpleAudioEngine sharedEngine] playEffect:@"death.wav"];
            if (card.owner == localPlayer)
                moveForward = [CCMoveBy actionWithDuration:0.4 position:ccp(0,[self makeScaledy:CARD_USED_DISTANCE])];
            else
                moveForward = [CCMoveBy actionWithDuration:0.4 position:ccp(0,[self makeScaledy:-CARD_USED_DISTANCE])];
            id tintToRed = [CCTintTo actionWithDuration:0.4 red:150 green:0 blue:0];
            id fadeOut = [CCFadeTo actionWithDuration:0.4 opacity:0];
            [card.thumbSprite runAction:[CCSpawn actions:moveForward, tintToRed, fadeOut, nil]];
        }
        
        [card.owner.graveyard addObject:card];
        [self performSelector:@selector(cleanUpDestroyedCard:) withObject:card afterDelay:0.4];
        for (Card *enhancementCard in card.attachedCards) {
            if (card.owner == localPlayer)
                moveForward = [CCMoveTo actionWithDuration:0.4 position:ccp(card.thumbSprite.position.x,[self makeScaledy:BOARD_Y+CARD_USED_DISTANCE-ENHANCEMENT_SPACING])];
            else
                moveForward = [CCMoveTo actionWithDuration:0.4 position:ccp(card.thumbSprite.position.x,[self makeScaledy:320-BOARD_Y-CARD_USED_DISTANCE+ENHANCEMENT_SPACING])];
            id tintToRed = [CCTintTo actionWithDuration:0.4 red:150 green:0 blue:0];
            id fadeOut = [CCFadeTo actionWithDuration:0.4 opacity:0];
            [enhancementCard.thumbSprite runAction:[CCSpawn actions:moveForward, tintToRed, fadeOut, nil]];
            [self performSelector:@selector(cleanUpDestroyedCard:) withObject:enhancementCard afterDelay:0.4];
        }
        if ([card.type isEqualToString:@"Enhancement"])
            [card.host.attachedCards removeObject:card];
    }
}
- (void)resolveBattleBetweenCard:(Card*)playerCard andCard:(Card*)opponentCard {
}
- (void)useAbilityFromCard:(Card*)sourceCard onCard:(Card*)targetCard {
    if (sourceCard.owner == localPlayer) {
        if (opponentIsHuman) {
            [self sendUseAbilityWithCard:sourceCard onTarget:targetCard];
        }
    }
    [self useCardWithAnimation:sourceCard withEffect:@"Ability"];
    for (NSString *ability in sourceCard.activeAbilities) {
        [self procAbility:ability fromCard:sourceCard onCard:targetCard];
    }
}
- (void)useCardWithAnimation:(Card*)card withEffect:(NSString*)effect {
    if (card.owner == localPlayer) {
        id moveForward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:BOARD_Y+CARD_USED_DISTANCE])];
        id moveBackward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:BOARD_Y])];
        if ([effect isEqualToString:@"Ability"]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"empower.wav"];
            id fadeToBlue = [CCTintTo actionWithDuration:0.2 red:255-170 green:255-170 blue:255];
            id fadeToUsed = [CCTintTo actionWithDuration:0.2 red:255-170 green:255-170 blue:255-170];
            id moveForwardAndBlue = [CCSpawn actions:fadeToBlue,moveForward, nil];
            id moveBackwardAndUse = [CCSpawn actions:fadeToUsed, moveBackward, nil];
            [card.thumbSprite runAction:[CCSequence actions:moveForwardAndBlue, moveBackwardAndUse, nil]];
        }
        else {
            id fadeToUsed = [CCTintTo actionWithDuration:0.4 red:255-170 green:255-170 blue:255-170];
            if (!([card hasEnhancementWithAbility:@"Frenzy"]))
                [card.thumbSprite runAction:fadeToUsed];
            else {
                id fadeToWhite = [CCTintTo actionWithDuration:0.4 red:255 green:255 blue:255];
                [card.thumbSprite runAction:fadeToWhite];
            }

            [card.thumbSprite runAction:[CCSequence actions:moveForward, moveBackward, nil]];
        }
        card.used = YES;
        for (Card* enhancementCard in card.attachedCards) {
            id moveForward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:BOARD_Y+CARD_USED_DISTANCE-ENHANCEMENT_SPACING])];
            id moveBackward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:BOARD_Y-ENHANCEMENT_SPACING])];
            id fadeToUsed = [CCTintTo actionWithDuration:0.4 red:255-170 green:255-170 blue:255-170];
            if (!([card hasEnhancementWithAbility:@"Frenzy"])) {
                enhancementCard.used = YES;
                [enhancementCard.thumbSprite runAction:fadeToUsed];
            }
            else if ([enhancementCard hasAbility:@"Frenzy"])
                [enhancementCard.thumbSprite runAction:fadeToUsed];
            
                [enhancementCard.thumbSprite runAction:[CCSequence actions:moveForward, moveBackward, nil]];
        }
    }
    else {
        id moveForward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:320-BOARD_Y-CARD_USED_DISTANCE])];
        id moveBackward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:320-BOARD_Y])];
        if ([effect isEqualToString:@"Ability"]) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"empower.wav"];
            id fadeToBlue = [CCTintTo actionWithDuration:0.2 red:255-170 green:255-170 blue:255];
            id fadeToUsed = [CCTintTo actionWithDuration:0.2 red:255-170 green:255-170 blue:255-170];
            id moveForwardAndBlue = [CCSpawn actions:fadeToBlue,moveForward, nil];
            id moveBackwardAndUse = [CCSpawn actions:fadeToUsed, moveBackward, nil];
            [card.thumbSprite runAction:[CCSequence actions:moveForwardAndBlue, moveBackwardAndUse, nil]];
        }
        else {
            id fadeToUsed = [CCTintTo actionWithDuration:0.4 red:255-170 green:255-170 blue:255-170];
            if (!([card hasEnhancementWithAbility:@"Frenzy"]))
                [card.thumbSprite runAction:fadeToUsed];
            else {
                id fadeToWhite = [CCTintTo actionWithDuration:0.4 red:255 green:255 blue:255];
                [card.thumbSprite runAction:fadeToWhite];
            }
            
            [card.thumbSprite runAction:[CCSequence actions:moveForward, moveBackward, nil]];
        }
        card.used = YES;
        for (Card* enhancementCard in card.attachedCards) {
            id moveForward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:320-BOARD_Y-CARD_USED_DISTANCE+ENHANCEMENT_SPACING])];
            id moveBackward = [CCMoveTo actionWithDuration:0.2 position:ccp(card.thumbSprite.position.x,[self makeScaledy:320-BOARD_Y+ENHANCEMENT_SPACING])];
            id fadeToUsed = [CCTintTo actionWithDuration:0.4 red:255-170 green:255-170 blue:255-170];
            if (!([card hasEnhancementWithAbility:@"Frenzy"])) {
                enhancementCard.used = YES;
                [enhancementCard.thumbSprite runAction:fadeToUsed];
            }
            else if ([enhancementCard hasAbility:@"Frenzy"])
                [enhancementCard.thumbSprite runAction:fadeToUsed];

            [enhancementCard.thumbSprite runAction:[CCSequence actions:moveForward, moveBackward, nil]];
        }
    }
}
- (void)stopAttackingCard:(Card*)card {
    if (gamePhase == PLAYER_DEFEND) {
        if (opponentActiveCard.dying == NO) {
            [opponentActiveCard.thumbSprite stopAllActions];
            [self setCardToProperBrightness:opponentActiveCard withDelay:NO];
        }
        [self opponentFinishedAttack];
    }
    else if (gamePhase == OPPONENT_DEFEND) {
        if (playerActiveCard.dying == NO) {
            [playerActiveCard.thumbSprite stopAllActions];
            [self setCardToProperBrightness:playerActiveCard withDelay:NO];
        }
        [self setGamePhase:PLAYER_TURN];
    }
}
- (CCSequence*)destroyAllCardsForPlayer:(Player*)player {
    float delayTime = 0.25;
    NSMutableArray *actions = [[NSMutableArray alloc] init];
    [actions addObject:[CCDelayTime actionWithDuration:1.5]];
    for (Card *card in player.board) {
        id delay = [CCDelayTime actionWithDuration:delayTime];
        id destroyCard = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDestroyCard:data:) data:card];
        [actions addObject:delay];
        [actions addObject:destroyCard];
    }
    
    for (Card *card in player.sideBoard) {
        id delay = [CCDelayTime actionWithDuration:delayTime];
        id destroyCard = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDestroyCard:data:) data:card];
        [actions addObject:delay];
        [actions addObject:destroyCard];
    }
    
    for (Card *card in player.hand) {
        id delay = [CCDelayTime actionWithDuration:delayTime];
        id destroyCard = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDestroyCard:data:) data:card];
        [actions addObject:delay];
        [actions addObject:destroyCard];
    }
    
    return [CCSequence actionsWithArray:actions];
    [actions autorelease];
}
- (void)destroyResourceBarForPlayer:(Player*)player {
    CCSprite *resourceBar;
    CCSprite *healthLabel;
    CCSprite *healthSprite;
    id fade = [CCFadeOut actionWithDuration:0.4];
    id tintToRed = [CCTintTo actionWithDuration:0.4 red:150 green:0 blue:0];
    id playDeathSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"death.wav"];
    id move;
    
    if (player == localPlayer) {
        healthLabel = playerHPLabel;
        healthSprite = playerHPSprite;
        resourceBar = playerResourceBar;
        move = [CCMoveBy actionWithDuration:0.4 position:[self makeScaledPointx:0 y:-20]];
    }
    else {
        healthLabel = opponentHPLabel;
        healthSprite = opponentHPSprite;
        resourceBar = opponentResourceBar;
        move = [CCMoveBy actionWithDuration:0.4 position:[self makeScaledPointx:0 y:20]];
    }

    id spawn = [CCSpawn actions:[fade copy],[tintToRed copy],[playDeathSound copy],[move copy], nil];
    for (Resource *resource in player.resourcePool.resources) {
        [resource.label runAction:[spawn copy]];
        [resource.sprite runAction:[spawn copy]];
    }
    
    [healthLabel runAction:[spawn copy]];
    [healthSprite runAction:[spawn copy]];    
    [resourceBar runAction:[spawn copy]];
}
- (Card*)createCardWithSprites:(NSString*)cardName {
    Card *card = [factory spawnCard:cardName];
    
    card.sprite = [CCSprite spriteWithFile:card.imagePath];
    card.thumbSprite = [CCSprite spriteWithFile:[card getThumbPath]];
    
    [self addChild:card.thumbSprite];
    
    return card;
}
- (void)revealOpponentHand {
    NSLog(@"Revealing hand");
    opponentHandRevealed = YES;
    
    for (Card *card in opponentHand)
        [card.thumbSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:card.getThumbPath]];
}
- (void)hideOpponentHand {
    opponentHandRevealed = NO;
    
    for (Card *card in opponentHand)
        [card.thumbSprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"cardback.png"]];
}
- (void)spawnCardWithName:(NSString*)name forPlayer:(Player*)player used:(BOOL)used{
    Card *newCard = [self createCardWithSprites:name];
    newCard.owner = player;
    [newCard.thumbSprite setColor:ccc3(0, 0, 0)];
    [newCard.thumbSprite setOpacity:0];
    if (newCard.owner == opponentPlayer)
        newCard.thumbSprite.rotation = CC_RADIANS_TO_DEGREES(3.14);
    id fadeIn = [CCFadeIn actionWithDuration:0.6];
    id colourIn;
    if (used) {
        colourIn = [CCTintTo actionWithDuration:0.6 red:255-170 green:255-170 blue:255-170];
        newCard.used = YES;
    }
    else {
        colourIn = [CCTintTo actionWithDuration:0.6 red:255 green:255 blue:255];
    }
    id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:newCard.playedSound];
    id moveCards = [CCCallFunc actionWithTarget:self selector:@selector(cocosMoveAllCardToProperLocation:)];
    id everything = [CCSpawn actions:moveCards,fadeIn,playSound,colourIn, nil];
    id delay = [CCDelayTime actionWithDuration:0.8];
    //newCard.justPlayed = YES;
    [newCard.thumbSprite runAction:[CCSequence actions:delay,everything, nil]];
    [self addCardToBoard:newCard forPlayer:player onTarget:nil chargeForCard:NO];
    [self animateCardToProperLocation:newCard forPlayer:player];
}

// CARD ABILITY PROCS
- (void)procBuffsOfOtherCardsOnCard:(Card*)card {

}
- (void)procCardPlayedAbilities:(Card*)card {
    if ([card hasAbility:@"Lookout"]) {
        if (card.owner == localPlayer)
            [self revealOpponentHand];
    }
    if ([card hasAbility:@"Health2"]) {
        [self giveDamage:-2 toPlayer:card.owner];
    }
    if ([card hasAbility:@"Aberration"]) {
        NSMutableArray *deadZombies = [[NSMutableArray alloc] init];
        for (Card *graveyardCard in card.owner.graveyard) {
            if ([graveyardCard hasSubType:@"Zombie"]) {
                [deadZombies addObject:graveyardCard];
            }
        }
        
        for (Card *deadCard in deadZombies) {
            [card.owner.graveyard removeObject:deadCard];
        }
        [deadZombies release];
        
        for (Card *handCard in card.owner.hand)
            [self procUpdateOnCardStats:handCard];
    }
    if ([card hasAbility:@"Smith"]) {
        for (Card *handCard in card.owner.hand)
            [self procUpdateOnCardStats:handCard];
    }
}
- (void)procCardAbility:(Card*)card killedByOtherCard:(Card*)otherCard {
    if ([card hasAbility:@"Burst3"]) {
        // Play a burst sound here
        //[[SimpleAudioEngine sharedEngine] playEffect:@"empower.wav"];
        [self giveDamage:3 toCard:otherCard];
    }
    if ([otherCard hasAbility:@"Infected"]) {
        [self spawnCardWithName:@"Zombie" forPlayer:otherCard.owner used:NO];
    }
}
- (void)procCardDeathAbilities:(Card*)card {
    // CHECK FOR EFFECTS FROM OTHER CARDS
    for (Card *loopCard in card.owner.board) {
        if ([loopCard hasAbility:@"Butcher"] && loopCard != card && [card hasSubType:@"Zombie"]) {
            for (Resource *resource in card.costs) {
                Resource *halfCost = [[Resource alloc] init];
                halfCost.type = resource.type;
                halfCost.amount = resource.amount/2;
                [self addResource:halfCost toPlayer:card.owner];
                [halfCost release];
            }
            break;
        }
        if ([loopCard hasAbility:@"Salvage"] && loopCard != card && [card hasSubType:@"Robot"]) {
            [self placeCardInHand:[factory spawnCard:@"Augment"] forPlayer:card.owner withDelay:1.0];
            break;
        }
    }
    if ([card hasAbility:@"Smith"]) {
        for (Card *handCard in card.owner.hand)
            [self procUpdateOnCardStats:handCard];
    }
}
- (void)procCardAttackPlayerAbilities:(Card*)card onPlayer:(Player *)player {
    if ([card hasAbility:@"Steal Resources"]) {
        // CHECK IF PLAYER HAS ANY RESOURCES
        BOOL hasResources = NO;
        for (Resource *loopResource in player.resourcePool.resources) {
            if (loopResource.amount > 0)
                hasResources = YES;
        }
        if (hasResources) {
            Resource *resource = nil;
            while (resource == nil) {
                for (Resource *loopResource in player.resourcePool.resources) {
                    if (resource == nil)
                        resource = loopResource;
                    
                    if (loopResource.amount > resource.amount)
                        resource = loopResource;
                }
                int amount = ([card totalAttack] * 10);
                if (resource.amount >= amount) {
                    Resource *stolenResource = [[Resource alloc] initWithType:resource.type amount:amount];
                    [self addResource:stolenResource toPlayer:card.owner];
                    [self removeResource:stolenResource toPlayer:player];
                    [stolenResource release];
                }
                else if (resource.amount > 0 && resource.amount < amount) {
                    Resource *stolenResource = [[Resource alloc] initWithType:resource.type amount:resource.amount];
                    [self addResource:stolenResource toPlayer:card.owner];
                    [self removeResource:stolenResource toPlayer:player];
                    [stolenResource release];
                }
                else if (resource.amount <= 0) {
                    resource = nil;
                }
            }
        }
    }
    if ([card hasAbility:@"Suicide"])
        [self destroyCard:card];
    if ([card hasAbility:@"Pillage"])
        [self addResource:[[Resource alloc] initWithType:@"Money" amount:5] toPlayer:card.owner];
}
- (void)procCardAttackAbilitiesBetween:(Card*)playerCard OpponentCard:(Card*)opponentCard {
}
- (void)procCardUpkeepAbilities:(Card*)card {
    if ([card hasAbility:@"Generate Zombie"]) {
        [self spawnCardWithName:@"Zombie" forPlayer:card.owner used:NO];
    }
    if ([card hasAbility:@"Mushroom Shaman"]) {
        int resourceAmount = 0;
        for (Card *boardCard in card.owner.board) {
            if ([boardCard hasSubType:@"Mushroom"])
                resourceAmount += 5;
        }
        [card.generatedResources removeAllObjects];
        [card addGeneratedResource:[[Resource alloc] initWithType:@"Magic" amount:resourceAmount]];
    }
}
- (void)procCardUpkeepAbilitiesForPlayer:(Player*)player {
    Player *otherPlayer;
    if (player == localPlayer)
        otherPlayer = opponentPlayer;
    else
        otherPlayer = localPlayer;
}
- (void)procUpdateOnCardStats:(Card*)card {

}
- (void)procAbility:(NSString*)ability fromCard:(Card*)originCard onCard:(Card*)targetCard {
    // CHECK IF SKILL IS BEING USED ON ATTACKING CARD
    if ([ability isEqualToString:@"DamageEnemies"]) {
        Player *targetPlayer;
        if (originCard.owner == localPlayer)
            targetPlayer = opponentPlayer;
        else if (originCard.owner == opponentPlayer)
            targetPlayer = localPlayer;
        
        for (Card *card in targetPlayer.board) {
        }
    }
    if ([ability isEqualToString:@"Bribe"]) {
        Player *originOwner = originCard.owner;
        if (targetCard.owner != originCard.owner) {
            [targetCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.2 angle:180]];
            for (Card *attachmentCard in targetCard.attachedCards) {
                [attachmentCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.2 angle:180]];
            }
            [originCard.owner.board insertObject:targetCard atIndex:[originCard.owner.board count]];
            for (Card *attachmentCard in originCard.attachedCards) {
                [self animateCardToProperLocation:attachmentCard forPlayer:attachmentCard.owner];
            }
            
            [targetCard.owner.board removeObject:targetCard];
            targetCard.owner = originOwner;
        }
        
        [self setCardToProperBrightness:targetCard withDelay:YES];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],[CCCallFunc actionWithTarget:self selector:@selector(animateAllCardsToProperLocation)], nil]];
    }
    if ([ability isEqualToString:@"Distract"]) {
        id fadeToUsed = [CCTintTo actionWithDuration:0.4 red:255-170 green:255-170 blue:255-170];
        [targetCard.thumbSprite runAction:fadeToUsed];
        targetCard.used = YES;
    }
    else if ([ability isEqualToString:@"Swap"]) {
        [self deselectCard];
        Player *originOwner = originCard.owner;
        Player *targetOwner = targetCard.owner;
        if (targetCard.owner != originCard.owner) {
            [originCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.5 angle:180]];
            for (Card *attachmentCard in originCard.attachedCards) {
                [attachmentCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.5 angle:180]];
            }
            [targetCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.5 angle:180]];
            for (Card *attachmentCard in targetCard.attachedCards) {
                [attachmentCard.thumbSprite runAction:[CCRotateBy actionWithDuration:0.5 angle:180]];
            }
        }
        [originCard.owner.board insertObject:targetCard atIndex:[originCard.owner.board indexOfObject:originCard]];
        [originCard.thumbSprite runAction:[CCMoveTo actionWithDuration:0.5 position:targetCard.thumbSprite.position]];
        for (Card *attachmentCard in originCard.attachedCards) {
            [self animateCardToProperLocation:attachmentCard forPlayer:attachmentCard.owner];
        }
        [targetCard.owner.board insertObject:originCard atIndex:[targetCard.owner.board indexOfObject:targetCard]];
        [targetCard.thumbSprite runAction:[CCMoveTo actionWithDuration:0.5 position:originCard.thumbSprite.position]];
        for (Card *attachmentCard in targetCard.attachedCards) {
            [self animateCardToProperLocation:attachmentCard forPlayer:targetCard.owner];
        }
        
        
        [originCard.owner.board removeObject:originCard];
        [targetCard.owner.board removeObject:targetCard];
        [self setCardToProperBrightness:originCard withDelay:YES];
        [self setCardToProperBrightness:targetCard withDelay:YES];
        originCard.owner = targetOwner;
        targetCard.owner = originOwner;
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.5],[CCCallFunc actionWithTarget:self selector:@selector(animateAllCardsToProperLocation)], nil]];
    }
    else if ([ability isEqualToString:@"Overrun"]) {
        Player *owner = originCard.owner;
        int damage = 0;
        
        for (Card *card in owner.board) {
            if ([card hasSubType:@"Zombie"]) {
                damage++;
            }
        }
        [self giveDamage:damage toCard:targetCard];
    }
    else if ([ability isEqualToString:@"Consume"]) {
        [self destroyCard:targetCard];
    }
    else if ([ability isEqualToString:@"Disintegrate"]) {
        [self destroyCard:targetCard];
    }
    else if ([ability isEqualToString:@"Treasure Map"]) {
        Resource *money = [[Resource alloc] initWithType:@"Money" amount:60];
        [self addResource:money toPlayer:originCard.owner];
        [money release];
    }
    else if ([ability isEqualToString:@"Barrel of Monkeys"]) {
        for (int i=0; i<2; i++) {
            Card *newCard = [self createCardWithSprites:@"Monkey Pirate"];
            newCard.owner = originCard.owner;
            [newCard.thumbSprite setOpacity:0];
            [newCard.thumbSprite setColor:ccc3(0, 0, 0)];
            if (originCard.owner != localPlayer)
                newCard.thumbSprite.position = [self makeScaledPointx:0 y:360];
            if (newCard.owner == opponentPlayer)
                newCard.thumbSprite.rotation = CC_RADIANS_TO_DEGREES(3.14);
            id fadeIn = [CCFadeIn actionWithDuration:0.6];
            id colourIn = [CCTintTo actionWithDuration:0.6 red:255 green:255 blue:255];
            id moveCards = [CCCallFunc actionWithTarget:self selector:@selector(cocosMoveAllCardToProperLocation:)];
            id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"monkey.wav"];
            id everything = [CCSpawn actions:moveCards,fadeIn,playSound,colourIn, nil];
            [newCard.thumbSprite runAction:everything];
            [self addCardToBoard:newCard forPlayer:originCard.owner onTarget:nil chargeForCard:NO];
            [self animateCardToProperLocation:newCard forPlayer:originCard.owner];
        }
    }
}
- (void)procAbility:(NSString*)ability fromCard:(Card*)card onPlayer:(Player*)targetPlayer {

}

// ANIMATION FUNCTIONS
- (void)dealHandForPlayer:(Player *)player {
    [self startGame];
    
    // GET FIRST CARDS
    for (int i = 0; i < 5; i++) {
        [self addCardToHand:[deck drawCard] forPlayer:player];
    }
    
    Card *card;
    int x = CARD_STARTX;
    if (player == localPlayer) {
        id delay;
        for (int i = 0; i < [playerHand count]; i++) {
            card = [playerHand objectAtIndex:i];
            card.sprite = [CCSprite spriteWithFile:card.imagePath];
            card.thumbSprite = [CCSprite spriteWithFile:card.imagePath];
            card.thumbSprite.position = [self makeScaledPointx:x y:CARD_PLAYERY - 80];
            card.thumbSprite.scale = 0.3;
            [self addChild:card.thumbSprite];
            delay = [CCDelayTime actionWithDuration:(i * DEAL_SPEED)];
            id move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:CARD_PLAYERY]];
            id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
            [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, nil]];
            x = x + CARD_SPACING;
        }
        /*if (gamePhase == PREGAME) {
            id lowerPlayButton = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X y:ENDPHASE_Y]];
            id lowerRedealButton = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X+TOP_BUTTON_BUFFER y:ENDPHASE_Y]];
            id secondDelay = [CCDelayTime actionWithDuration:1.0];
            [playButton runAction:[CCSequence actions:delay, secondDelay, lowerPlayButton, nil]];
            if (redealCount < 1)
                [redealButton runAction:[CCSequence actions:delay, secondDelay, lowerRedealButton, nil]];
            
            if (tutorial) {
                id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Deck"];
                [playButton runAction:[CCSequence actions:delay, secondDelay, showPopUp, nil]];
            }
        }*/
    }
    else {
        int cardSpacing = CARD_SPACING/2;
        if (player == opponentPlayer)
            x = 260;
        else if (player == leftPlayer)
            x = 0;
        else if (player == rightPlayer)
            x = 0;
        
        for (int i = 0; i < [player.hand count]; i++) {
            card = [player.hand objectAtIndex:i];
            card.sprite = [CCSprite spriteWithFile:card.imagePath];
            [card.sprite retain];
            card.thumbSprite = [CCSprite spriteWithFile:@"cardback.png"];
            card.thumbSprite.scale = 0.15;
            [card.thumbSprite retain];
            id delay = [CCDelayTime actionWithDuration:(i * DEAL_SPEED)];
            id move;
            id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
            if (player == opponentPlayer) {
                card.thumbSprite.rotation = 180;
                card.thumbSprite.position = [self makeScaledPointx:x y:320-CARD_PLAYERY + 80];
                move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:320-CARD_PLAYERY+10]];
                x = x - cardSpacing;
            }
            else if (player == leftPlayer) {
                card.thumbSprite.rotation = 90;
                card.thumbSprite.position = [self makeScaledPointx:CARD_PLAYERY-80 y:NAMETAG_SIDE_Y-x+40];
                move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:CARD_PLAYERY - 30 y:NAMETAG_SIDE_Y-x+20]];
                x = x + cardSpacing;
            }
            else if (player == rightPlayer) {
                card.thumbSprite.rotation = 270;
                card.thumbSprite.position = [self makeScaledPointx:480+80 y:320-NAMETAG_SIDE_Y-30+x];
                move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:480-CARD_PLAYERY + 30 y:320-NAMETAG_SIDE_Y-20+x]];
                x = x + cardSpacing;
            }
            [self addChild:card.thumbSprite];
            [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, nil]];
        } 
    }
}
- (void)redealHandForPlayer:(Player*)player {
    Card* card;
    if (player == localPlayer) {
        for (int i = 0; i < [playerHand count]; i++) {
            card = [playerHand objectAtIndex:i];
            id delay = [CCDelayTime actionWithDuration:(([playerHand count]-i) * DEAL_SPEED/2)];
            id move = [CCMoveBy actionWithDuration:DEAL_SPEED/2 position:[self makeScaledPointx:0 y:-40]];
            id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
            id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
            [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, removeSprite, nil]];
            [player.deck addCard:card];
        }
        [player.deck shuffle];
        [playButton runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:+20]]];
        [redealButton runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:+20]]];
        id delay = [CCDelayTime actionWithDuration:([playerHand count] * DEAL_SPEED)];
        id dealHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:localPlayer];
        [self runAction:[CCSequence actions:delay,dealHand, nil]];
        [playerHand removeAllObjects];
        redealCount++;
    }
    else {
        for (int i = 0; i < [opponentHand count]; i++) {
            card = [opponentHand objectAtIndex:i];
            id delay = [CCDelayTime actionWithDuration:(([opponentHand count]-i) * DEAL_SPEED/2)];
            id move = [CCMoveBy actionWithDuration:DEAL_SPEED/2 position:[self makeScaledPointx:0 y:+40]];
            id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
            id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
            [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, removeSprite, nil]];
            [opponentPlayer.deck addCard:card];
        }
        [opponentPlayer.deck shuffle];
        id delay = [CCDelayTime actionWithDuration:([opponentHand count] * DEAL_SPEED)];
        id dealHand = [CCCallFuncND actionWithTarget:self selector:@selector(cocosDealHandForPlayer:data:) data:opponentPlayer];
        [self runAction:[CCSequence actions:delay,dealHand, nil]];
        [opponentHand removeAllObjects];
    }
}
- (BOOL)drawCardForPlayer:(Player*)player {
    if (player == localPlayer) {
        int x = CARD_STARTX + [playerHand count]*CARD_SPACING;
        Card *card = [deck drawCard];
        if (card == nil)
            return NO;
        [self addCardToHand:card forPlayer:player];
        card.sprite = [CCSprite spriteWithFile:card.imagePath];
        card.thumbSprite = [CCSprite spriteWithFile:card.imagePath];
        card.thumbSprite.scale = 0.5;
        card.thumbSprite.position = [self makeScaledPointx:x y:CARD_PLAYERY - 80];
        [self addChild:card.thumbSprite z:zOrder];
        id move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:CARD_PLAYERY]];
        id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
        [card.thumbSprite runAction:[CCSequence actions:playSound, move, nil]];
    }
    else {
        int x = CARD_STARTX + [opponentHand count]*CARD_SPACING;
        Card *card = [player.deck drawCard];
        if (card == nil)
            return NO;
        [self addCardToHand:card forPlayer:player];
        card.thumbSprite = [CCSprite spriteWithFile:@"cardback.png"];
        card.thumbSprite.position = [self makeScaledPointx:x y:320-CARD_PLAYERY + 80];
        card.thumbSprite.rotation = CC_RADIANS_TO_DEGREES(3.14);
        [self addChild:card.thumbSprite z:zOrder];
        id move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:320-CARD_PLAYERY]];
        id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
        [card.thumbSprite runAction:[CCSequence actions:playSound, move, nil]];
    }
    [self reorderChild:endTurnButton z:zOrder];
    return YES;
}
- (void)placeCardInHand:(Card*)card forPlayer:(Player*)player withDelay:(float)delayTime {
    id delay = [CCDelayTime actionWithDuration:delayTime];
    
    if (player == localPlayer) {
        int x = CARD_STARTX + [player.hand count]*CARD_SPACING;
        [self addCardToHand:card forPlayer:player];
        card.sprite = [CCSprite spriteWithFile:card.imagePath];
        card.thumbSprite = [CCSprite spriteWithFile:[card getThumbPath]];
        card.thumbSprite.position = [self makeScaledPointx:x y:CARD_PLAYERY - 80];
        [self addChild:card.thumbSprite z:zOrder];
        id move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:CARD_PLAYERY]];
        id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
        [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, nil]];
    }
    else {
        int x = CARD_STARTX + [opponentHand count]*CARD_SPACING;
        [self addCardToHand:card forPlayer:player];
        card.thumbSprite = [CCSprite spriteWithFile:@"cardback.png"];
        card.thumbSprite.position = [self makeScaledPointx:x y:320-CARD_PLAYERY + 80];
        card.thumbSprite.rotation = CC_RADIANS_TO_DEGREES(3.14);
        [self addChild:card.thumbSprite z:zOrder];
        id move = [CCMoveTo actionWithDuration:DEAL_SPEED position:[self makeScaledPointx:x y:320-CARD_PLAYERY]];
        id playSound = [CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"];
        [card.thumbSprite runAction:[CCSequence actions:delay, playSound, move, nil]];
    }
    [self reorderChild:endTurnButton z:zOrder];
}
- (void)moveCardToFrontOfHand:(Card *)card {
    Card* foundCard = nil;
    for (Card *loopCard in playerHand) {
        if (loopCard == card) {
            foundCard = loopCard;
        }
    }
    if (foundCard != nil) {
        int handIndex = [playerHand indexOfObject:foundCard];
        int handCount = [playerHand count];
        for (int i = handIndex; i < handCount-1; i++) {
            [playerHand exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
        [self reorderChild:foundCard.thumbSprite z:zOrder];
        zOrder++;
    }
    
    for (int i = 0; i < ([playerHand count]-1); i++) {
        Card *loopCard = [playerHand objectAtIndex:i];
        [self animateCardToProperLocation:loopCard forPlayer:localPlayer];
    }
}
- (void)animateAllCardsToProperLocation {
    for (Card *card in playerHand) {
        [self animateCardToProperLocation:card forPlayer:localPlayer];
    }
    for (Card *card in playerBoard) {
        [self animateCardToProperLocation:card forPlayer:localPlayer];
    }
    for (Card *card in playerSideBoard) {
        [self animateCardToProperLocation:card forPlayer:localPlayer];
    }
    for (Card *card in opponentHand) {
        [self animateCardToProperLocation:card forPlayer:opponentPlayer];
    }
    for (Card *card in opponentBoard) {
        [self animateCardToProperLocation:card forPlayer:opponentPlayer];
    }
    for (Card *card in opponentSideBoard) {
        [self animateCardToProperLocation:card forPlayer:opponentPlayer];
    }
}
- (void)animateCardToProperLocation:(Card *)card forPlayer:(Player*)player {
    if (gamePhase != GAME_FINISHED) {
        NSArray *board;
        NSArray *sideBoard;
        NSArray *hand;
        int boardX;
        int boardY;
        int sideBoardY;
        int handY;
        if (player == localPlayer) {
            board = playerBoard;
            sideBoard = playerSideBoard;
            hand = playerHand;
            boardY = BOARD_Y;
            boardX = BOARD_CENTER_X;
            sideBoardY = SIDEBOARD_Y;
            handY = CARD_PLAYERY;
        }
        else {
            board = opponentBoard;
            sideBoard = opponentSideBoard;
            hand = opponentHand;
            boardY = 320-BOARD_Y;
            boardX = 480-BOARD_CENTER_X;
            sideBoardY = 320-SIDEBOARD_Y;
            handY = 320-CARD_PLAYERY; 
        }
        int targetX = 0;
        
        // FOR BOARD CARDS
        if ([self cardIsInPlay:card]) {
            // FOR MAIN BOARD CARDS
            if ([card.type isEqualToString:@"Property"] || [card.type isEqualToString:@"Money"]) {
                [self reorderChild:card.thumbSprite z:[card.owner.board indexOfObject:card]];
                int boardCount = [board count];
                int cardSpacing = BOARD_SPACING;
                int offset;
                /*if (boardCount > 4) {
                    cardSpacing = 200/(boardCount-1);
                    offset = -100;
                }
                else*/
                offset = -((boardCount-1)*cardSpacing/2);
                for (int i = 0; i < boardCount; i++) {
                    Card *loopCard = [board objectAtIndex:i];
                    if (loopCard == card) {
                        if (player == localPlayer)
                            targetX = boardX + offset;
                        else
                            targetX = boardX - offset;
                    }
                    offset = offset + cardSpacing;
                }
                [card.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:targetX y:boardY]]];
                // DEAL WITH ENHANCEMENT CARDS
                int enhancementBuffer = ENHANCEMENT_SPACING;
                for (Card *enhancementCard in card.attachedCards) {
                    if (card.owner == localPlayer) {
                        [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:targetX y:boardY-enhancementBuffer]]];
                    }
                    else {
                        [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:targetX y:boardY+enhancementBuffer]]];
                    }
                    
                    if (enhancementCard.owner != card.owner) {
                        if (card.owner == opponentPlayer)
                            [enhancementCard.thumbSprite runAction:[CCRotateTo actionWithDuration:0.0 angle:180]];
                        else
                            [enhancementCard.thumbSprite runAction:[CCRotateTo actionWithDuration:0.0 angle:0]];
                    }
                    enhancementBuffer += ENHANCEMENT_SPACING;
                }
                for (int i = [card.attachedCards count]-1; i >= 0; i--) {
                    Card *loopCard = [card.attachedCards objectAtIndex:i];
                    [self reorderChild:loopCard.thumbSprite z:card.thumbSprite.zOrder-1];
                }
                //[self hideEnhancementsForCard:card];
            }
        }
        // FOR HAND CARDS
        else {
            for (int i = 0; i < [hand count]; i++) {
                Card *loopCard = [hand objectAtIndex:i];
                if (loopCard == card) {
                    if (player == localPlayer)
                        targetX = CARD_STARTX + i * CARD_SPACING;
                    else
                        targetX = 480-CARD_STARTX - i * CARD_SPACING;
                }
            }
            [card.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:targetX y:handY]]];
        }
    }
}
- (void)setAllCardsToProperBrightness {
    for (Card *card in playerHand) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
    for (Card *card in playerBoard) {
        [self setCardToProperBrightness:card withDelay:YES];
        for (Card *enhancementCard in card.attachedCards) {
            [self setCardToProperBrightness:enhancementCard withDelay:YES];
        }
    }
    for (Card *card in playerSideBoard) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
    for (Card *card in opponentHand) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
    for (Card *card in opponentBoard) {
        [self setCardToProperBrightness:card withDelay:YES];
        for (Card *enhancementCard in card.attachedCards) {
            [self setCardToProperBrightness:enhancementCard withDelay:YES];
        }
    }
    for (Card *card in opponentSideBoard) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
}
- (void)setCardToProperBrightness:(Card *)card withDelay:(BOOL)delay {
    int offset = 0;
    
    if (card != opponentActiveCard && card != playerActiveCard) {
        if (card == pickedCard) {
            if (card.used == YES || card.justPlayed == YES) {
                if (delay)
                    [card.thumbSprite runAction:[CCTintTo actionWithDuration:0.1 red:240-offset green:240-offset blue:240-offset]];
                else
                    [card.thumbSprite setColor:ccc3(240-offset, 240-offset, 240-offset)];
            }
            else {
                if (delay)
                    [card.thumbSprite runAction:[CCTintTo actionWithDuration:0.1 red:200-offset green:200-offset blue:200-offset]];
                else
                    [card.thumbSprite setColor:ccc3(200-offset, 200-offset, 200-offset)];            
            }
        }
        else {
            if (delay)
                [card.thumbSprite runAction:[CCTintTo actionWithDuration:0.1 red:255-offset green:255-offset blue:255-offset]];
            else
                [card.thumbSprite setColor:ccc3(255-offset, 255-offset, 255-offset)];
        }
    }
    if (!card.dying) {
        [card.thumbSprite runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
    }
    
    for (Card *attachedCard in card.attachedCards)
        [self setCardToProperBrightness:attachedCard withDelay:delay];
}
- (void)showEnhancementsForCard:(Card *)card {
    /*int enhancementBuffer = ENHANCEMENT_BUFFER;
    for (Card *enhancementCard in card.attachedCards) {
        [self reorderChild:enhancementCard.thumbSprite z:card.thumbSprite.zOrder+1];
        if (card.owner == localPlayer) {
            [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:CGPointMake(enhancementCard.thumbSprite.position.x, [self makeScaledy:BOARD_Y-enhancementBuffer])]];
            enhancementBuffer += ENHANCEMENT_BUFFER;
        }
        else {
            [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:CGPointMake(enhancementCard.thumbSprite.position.x, [self makeScaledy:320-BOARD_Y+enhancementBuffer])]];
            enhancementBuffer += ENHANCEMENT_BUFFER;
        }
        
    }*/
}
- (void)hideEnhancementsForCard:(Card *)card {
    /*for (Card *enhancementCard in card.attachedCards) {
        [self reorderChild:enhancementCard.thumbSprite z:card.thumbSprite.zOrder-1];
        if (card.owner == localPlayer) {
            [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:CGPointMake(enhancementCard.thumbSprite.position.x, [self makeScaledy:BOARD_Y-ENHANCEMENT_SPACING])]];
        }
        else {
            [enhancementCard.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:CGPointMake(enhancementCard.thumbSprite.position.x, [self makeScaledy:320-BOARD_Y+ENHANCEMENT_SPACING])]];
        }
    }*/
    for (int i = [card.attachedCards count]-1; i >= 0; i--) {
        Card *attachedCard = [card.attachedCards objectAtIndex:i];
        [self reorderChild:attachedCard.thumbSprite z:card.thumbSprite.zOrder-1];
    }
}
- (void)updateResourcePanel {

}
- (void)floatText:(int)amount forResource:(Resource*)resource forPlayer:(Player*)player {
    NSString *prefix;
    if (amount > 0) prefix = @"+";
    else prefix = @"";

    CCLabelTTF *damageLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@%d",prefix,amount] fontName:@"Hobo.ttf" fontSize:[self makeScaledInt:14]];
    [self addChild:damageLabel z:1000];
    
    CCSprite *icon;
    if (resource)
        icon = [resource getSpriteForType:resource.type];
    else {
        icon = [CCSprite spriteWithFile:@"Heart.png"];
    }
    
    if (amount < 0) {
        [damageLabel setColor:ccc3(200, 0, 0)];
        [icon setColor:ccc3(255, 0, 0)];
    }
    else if (amount > 0) {
        [damageLabel setColor:ccc3(0, 230, 0)];
        [icon setColor:ccc3(0, 255, 0)];
    }
    else {
        [damageLabel setColor:ccc3(200, 200, 200)];
        [icon setColor:ccc3(255, 255, 255)];
    }
    [self addChild:icon z:1000];
    
    int iconBuffer = [self getIconBufferForAmount:abs(amount)];
    int symbolBuffer = 3;
    int resourceSpacing = 0;
    int poolPosition = 0;

    if (resource) {
        for (int i = 0; i < [player.resourcePool.resources count]; i++) {
            Resource *poolResource = [player.resourcePool.resources objectAtIndex:i];
            if ([resource.type isEqualToString:poolResource.type]) {
                poolPosition = 1 + i;
            }
        }
        resourceSpacing = RESOURCE_SPACING * poolPosition;
    }
    
    id labelAnimation;
    id iconAnimation;
    id removeLabel = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
    id removeIcon = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
    if (player == localPlayer) {
        [damageLabel setPosition:[self makeShiftedPointx:HEARTX+resourceSpacing-symbolBuffer y:RESOURCE_Y+10 withShift:65]];
        [icon setPosition:[self makeShiftedPointx:HEARTX+resourceSpacing+ICON_SPACING+iconBuffer y:RESOURCE_Y+10 withShift:65]];
        id moveUp = [CCMoveTo actionWithDuration:FADE_DURATION position:[self makeShiftedPointx:HEARTX+resourceSpacing-symbolBuffer y:RESOURCE_Y+35 withShift:65]];
        id fade = [CCFadeOut actionWithDuration:FADE_DURATION];
        labelAnimation = [CCSpawn actions:moveUp, fade, nil];
        id moveUpIcon = [CCMoveTo actionWithDuration:FADE_DURATION position:[self makeShiftedPointx:HEARTX+resourceSpacing+ICON_SPACING+iconBuffer y:RESOURCE_Y+35 withShift:65]];
        id fadeIcon = [CCFadeOut actionWithDuration:FADE_DURATION];
        iconAnimation = [CCSpawn actions:moveUpIcon, fadeIcon, nil];
    }
    else {
        [damageLabel setPosition:[self makeShiftedPointx:HEARTX+resourceSpacing-symbolBuffer y:320-RESOURCE_Y-10 withShift:65]];
        [icon setPosition:[self makeShiftedPointx:HEARTX+resourceSpacing+ICON_SPACING+iconBuffer y:320-RESOURCE_Y-10 withShift:65]];
        id moveDown = [CCMoveTo actionWithDuration:FADE_DURATION position:[self makeShiftedPointx:HEARTX+resourceSpacing-symbolBuffer y:320-RESOURCE_Y-35 withShift:65]];
        id fade = [CCFadeOut actionWithDuration:FADE_DURATION];
        labelAnimation = [CCSpawn actions:moveDown, fade, nil];
        id moveDownIcon = [CCMoveTo actionWithDuration:FADE_DURATION position:[self makeShiftedPointx:HEARTX+resourceSpacing+ICON_SPACING+iconBuffer y:320-RESOURCE_Y-35 withShift:65]];
        id fadeIcon = [CCFadeOut actionWithDuration:FADE_DURATION];
        iconAnimation = [CCSpawn actions:moveDownIcon, fadeIcon, nil];
    }
    [damageLabel runAction:[CCSequence actions:labelAnimation, removeLabel, nil]];
    [icon runAction:[CCSequence actions:iconAnimation, removeIcon, nil]];
}
- (void)floatTextOverCard:(Card*)card withText:(NSString*)text {
    CCLabelTTF *textLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",text] fontName:@"Hobo.ttf" fontSize:[self makeScaledInt:14]];
    [self addChild:textLabel z:1000];
    
    if ([text isEqualToString:@"Buff"])
        [textLabel setColor:ccc3(0, 230, 0)];
    else if ([text isEqualToString:@"Debuff"])
        [textLabel setColor:ccc3(230, 0, 0)];
    else
        [textLabel setColor:ccc3(230, 0, 0)];
    

    id labelAnimation;
    id removeLabel = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
    if (card.owner == localPlayer) {
        [textLabel setPosition:CGPointMake(card.thumbSprite.position.x, card.thumbSprite.position.y + [self makeScaledInt:40])];
        id moveUp = [CCMoveTo actionWithDuration:FADE_DURATION position:CGPointMake(card.thumbSprite.position.x, card.thumbSprite.position.y + [self makeScaledInt:60])];
        id fade = [CCFadeOut actionWithDuration:FADE_DURATION];
        labelAnimation = [CCSpawn actions:moveUp, fade, nil];
    }
    else {
        [textLabel setPosition:CGPointMake(card.thumbSprite.position.x, card.thumbSprite.position.y - [self makeScaledInt:40])];
        id moveDown = [CCMoveTo actionWithDuration:FADE_DURATION position:CGPointMake(card.thumbSprite.position.x, card.thumbSprite.position.y - [self makeScaledInt:60])];
        id fade = [CCFadeOut actionWithDuration:FADE_DURATION];
        labelAnimation = [CCSpawn actions:moveDown, fade, nil];
    }
    [textLabel runAction:[CCSequence actions:labelAnimation, removeLabel, nil]];
}
- (void)animateBoardsToProperLocation:(Player *)player {
    if (player == localPlayer) {
        for (Card *loopCard in playerBoard) {
            [self animateCardToProperLocation:loopCard forPlayer:player];
        }
    }
    else {
        for (Card *loopCard in opponentBoard) {
            [self animateCardToProperLocation:loopCard forPlayer:player];
        }
    }
}
- (void)flashCard:(Card*)card withColor:(ccColor3B)color {
    [card.thumbSprite stopAllActions];
    id fadeToColor = [CCTintTo actionWithDuration:0.2 red:color.r green:color.g blue:color.b];
    id fadeToStandard = [CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255];
    id fadeToOriginal = [CCCallFuncND actionWithTarget:self selector:@selector(cocosSetCardToProperBrightness:data:) data:card];
    id checkForReflash = [CCCallFunc actionWithTarget:self selector:@selector(checkForReflash)];
    [card.thumbSprite runAction:[CCSequence actions:fadeToColor,fadeToStandard,fadeToColor,fadeToStandard,fadeToOriginal,checkForReflash,nil]];
}
- (void)checkForReflash {
    if (gamePhase == PLAYER_DEFEND) {
        id darken = [CCTintTo actionWithDuration:0.5 red:220 green:30 blue:30];
        id brighten = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
        id flash = [CCSequence actions:darken, brighten, nil];
        CCRepeatForever *repeatFlash = [CCRepeatForever actionWithAction:flash];
        repeatFlash.tag = 1000;
        [opponentActiveCard.thumbSprite runAction:repeatFlash];
    }
    else if (gamePhase == OPPONENT_DEFEND) {
        id darken = [CCTintTo actionWithDuration:0.5 red:220 green:30 blue:30];
        id brighten = [CCTintTo actionWithDuration:0.5 red:255 green:255 blue:255];
        id flash = [CCSequence actions:darken, brighten, nil];
        CCRepeatForever *repeatFlash = [CCRepeatForever actionWithAction:flash];
        repeatFlash.tag = 1000;
        [playerActiveCard.thumbSprite runAction:repeatFlash];
    }
}
- (void)showBigCard:(Card *)card {
    bigCard = [CardSprite node];
    bigCard.position = [self makeScaledPointx:BIG_CARDX y:BIG_CARDY];
    [bigCard setScale:1.0];
    [bigCard showStatsForCard:card];
    [self addChild:bigCard z:zOrder+1];
    
    [self showButtonsForBigCard];
}
- (void)hideBigCard {
    if (bigCard != nil) {
        [self removeChild:bigCard cleanup:YES];
        bigCard = nil;
        if (attackButton != nil) {
            [self removeChild:attackButton cleanup:YES];
            attackButton = nil;
        }
        if (defendButton != nil) {
            [self removeChild:defendButton cleanup:YES];
            defendButton = nil;
        }
        if (abilityButton != nil) {
            [self removeChild:abilityButton cleanup:YES];
            abilityButton = nil;
        }
        if (targetButton != nil) {
            [self removeChild:targetButton cleanup:YES];
            targetButton = nil;
        }
    }
}
- (void)deselectCard {
    Card *lastPickedCard = pickedCard;
    pickedCard = nil;
    [self setCardToProperBrightness:lastPickedCard withDelay:YES];
    [self hideBigCard];
}
- (void)showButton:(NSString*)buttonName {
    if ([buttonName isEqualToString:@"AttackButton"]) {
        attackButton = [CCSprite spriteWithFile:@"AttackButton.png"];
        [attackButton setScale:1.0];
        [self addChild:attackButton z:zOrder+2];
        attackButton.position = [self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y];
        [attackButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X y:TOP_BUTTON_Y]]];
    }
    else if ([buttonName isEqualToString:@"AbilityButton"]) {
        abilityButton = [CCSprite spriteWithFile:@"AbilityButton.png"];
        [self addChild:abilityButton z:zOrder+2];
        abilityButton.position = [self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:BOTTOM_BUTTON_Y];
        [abilityButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X y:BOTTOM_BUTTON_Y]]]; 
    }
    else if ([buttonName isEqualToString:@"DefendButton"]) {
        defendButton = [CCSprite spriteWithFile:@"DefendButton.png"];
        [defendButton setScale:1.0];
        [self addChild:defendButton z:zOrder+2];
        defendButton.position = [self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y];
        [defendButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X y:TOP_BUTTON_Y]]];
    }
    else if ([buttonName isEqualToString:@"TargetButton"]) {
        targetButton = [CCSprite spriteWithFile:@"AbilityButton.png"];
        [self addChild:targetButton z:zOrder+2];
        targetButton.position = [self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y];
        [targetButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X y:TOP_BUTTON_Y]]];
    }
    else if ([buttonName isEqualToString:@"Cancel"]) {
        cancelButton = [CCSprite spriteWithFile:@"Cancel.png"];
        [self addChild:cancelButton z:zOrder+2];
        cancelButton.position = [self makeScaledPointx:ENDPHASE_X-5 y:ENDPHASE_Y+20];
        [cancelButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X-5 y:ENDPHASE_Y]]];
    }
    else if ([buttonName isEqualToString:@"SelectATarget"]) {
        selectATargetGraphic = [CCSprite spriteWithFile:@"SelectATarget.png"];
        [self addChild:selectATargetGraphic z:zOrder+2];
        selectATargetGraphic.position = [self makeScaledPointx:MID_TAB_X y:ENDPHASE_Y+20];
        [selectATargetGraphic runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:MID_TAB_X y:ENDPHASE_Y]]];
    }
}
- (void)hideButton:(NSString*)buttonName {
    if ([buttonName isEqualToString:@"AttackButton"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y]];
        [attackButton runAction:[CCSequence actions:moveCard, removeSprite, nil]];
        attackButton = nil;
    }
    else if ([buttonName isEqualToString:@"AbilityButton"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:BOTTOM_BUTTON_Y]];
        [abilityButton runAction:[CCSequence actions:moveCard, removeSprite, nil]]; 
        abilityButton = nil;
    }
    else if ([buttonName isEqualToString:@"DefendButton"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y]];
        [defendButton runAction:[CCSequence actions:moveCard, removeSprite, nil]];
        defendButton = nil;
    }
    else if ([buttonName isEqualToString:@"TargetButton"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y]];
        [targetButton runAction:[CCSequence actions:moveCard, removeSprite, nil]];
        targetButton = nil;
    }
    else if ([buttonName isEqualToString:@"Cancel"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X-5 y:ENDPHASE_Y+20]];
        [cancelButton runAction:[CCSequence actions:moveCard, removeSprite, nil]];
        cancelButton = nil;
    }
    else if ([buttonName isEqualToString:@"SelectATarget"]) {
        id removeSprite = [CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)];
        id moveCard = [CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:MID_TAB_X y:ENDPHASE_Y+20]];
        [selectATargetGraphic runAction:[CCSequence actions:moveCard, removeSprite, nil]];
        selectATargetGraphic = nil;
    }
}
- (void)showButtonsForBigCard {
    Card *card = pickedCard;
    
    if (targetMode) {
        if ([pickedCard canBeTargetOfAbilityFromCard:playerActiveCard])
            [self showButton:@"TargetButton"];
    }
    else {
        if (gamePhase == PLAYER_TURN) {
            if ([self cardIsInPlay:card] && card.owner == localPlayer && card.type == @"Fighter" && card.used == NO && card.justPlayed == NO && ![card hasAbility:@"Defender"]) {
                [self showButton:@"AttackButton"];
                if ([card.activeAbilities count] > 0) {
                    [self showButton:@"AbilityButton"];
                }
            }
        }
        else if (gamePhase == PLAYER_DEFEND) {
            if ([self cardIsInPlay:card] && card.owner == localPlayer && card.type == @"Fighter" && card.used == NO) {
                if (!([opponentActiveCard hasAbility:@"Flying"] && !([card hasAbility:@"Ranged"] || [card hasAbility:@"Flying"])))
                    [self showButton:@"DefendButton"];
                if ([card.activeAbilities count] > 0) {
                    [self showButton:@"AbilityButton"];
                }
            }
        }
    }
}
- (void)showBlackBarWithText:(NSString*)text {
    if ([text isEqualToString:@"Ready!"])
        [[SimpleAudioEngine sharedEngine] playEffect:@"readysound.wav"];
    //else if ([text isEqualToString:@"Begin!"])
        //[[SimpleAudioEngine sharedEngine] playEffect:@"wardrums.wav"];
    
    float screenTime = 1.5;
    id onScreenTime = [CCDelayTime actionWithDuration:screenTime];
    
    CCSprite *blackBar = [CCSprite spriteWithFile:@"BlackBar.png"];
    [blackBar setPosition:[self makeScaledPointx:240 y:160]];
    [blackBar setOpacity:0];
    [self addChild:blackBar z:1000];
    float blackBarTime = 0.2;
    id blackBarFadeIn = [CCFadeIn actionWithDuration:blackBarTime];
    id blackBarFadeOut = [CCFadeOut actionWithDuration:0.2];
    id removeBlackBar = [CCCallFuncND actionWithTarget:self selector:@selector(cocosRemoveSprite:) data:blackBar];
    [blackBar runAction:[CCSequence actions:blackBarFadeIn,onScreenTime,blackBarFadeOut,removeBlackBar, nil]];
    
    id delay = [CCDelayTime actionWithDuration:blackBarTime];
    CCLabelTTF *textLabel = [CCLabelTTF labelWithString:text dimensions:CGSizeMake([self makeScaledInt:450], [self makeScaledInt:100]) alignment:UITextAlignmentCenter fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:45]];
    [textLabel setPosition:[self makeScaledPointx:225 y:135]];
    [textLabel setOpacity:0];
    [self addChild:textLabel z:1001];
    id fadeIn = [CCFadeIn actionWithDuration:0.2];
    id fadeOut = [CCFadeOut actionWithDuration:0.2];
    id move = [CCMoveBy actionWithDuration:0.3 position:[self makeScaledPointx:20 y:0]];
    id textScreenTime = [CCDelayTime actionWithDuration:screenTime-0.3];
    id spawn = [CCSpawn actions:fadeIn,move, nil];
    id removeText = [CCCallFuncND actionWithTarget:self selector:@selector(cocosRemoveSprite:) data:textLabel];
    [textLabel runAction:[CCSequence actions:delay,spawn,textScreenTime,fadeOut,removeText, nil]];
}
- (void)loadBackgroundWithName:(NSString*)name {
    CCSprite *background;
    if ([name isEqualToString:@"Graveyard"]) {
        background = [CCSprite spriteWithFile: @"Graveyard.png"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Evidence of Doom.mp3"];
    }
    else if ([name isEqualToString:@"Beach"]) {
        background = [CCSprite spriteWithFile: @"MonkeyBeach.png"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SeasAtWar.mp3"];
    }
    else if ([name isEqualToString:@"Castle"]) {
        background = [CCSprite spriteWithFile: @"RobotCity.png"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DeadlyIntentions.mp3"];
    }
    else if ([name isEqualToString:@"Cave"]) {
        background = [CCSprite spriteWithFile: @"MagicCave.png"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"DistantTales.mp3"];
    }
    [background setPosition:[self makeScaledPointx:240 y:160]];
    [background setOpacity:0];
    [background runAction:[CCFadeIn actionWithDuration:0.5]];
    [self addChild:background z:-1];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [background setScale:1.2];
    }
}
- (void)flashEndTurn {
    id fadeToColor = [CCTintTo actionWithDuration:1.0 red:0 green:0 blue:0];
    id fadeToStandard = [CCTintTo actionWithDuration:1.0 red:255 green:255 blue:255];
    id repeatForever = [CCRepeatForever actionWithAction:[CCSequence actions:fadeToColor,fadeToStandard,nil]];
    [endTurnButton runAction:repeatForever];
}
- (void)stopFlashingEndTurn {
    [endTurnButton stopAllActions];
    id fadeToStandard = [CCTintTo actionWithDuration:0.2 red:255 green:255 blue:255];
    [endTurnButton runAction:fadeToStandard];
}

// SOUND FUNCTIONS
- (void)playSoundForCard:(Card*)card forAction:(NSString *)action {
    //if ([action isEqualToString:@"Hit Player"] && [card hasAbility:@"Steal Resources"])
    //return;
    
    if ([action isEqualToString:@"Played"] && card.playedSound != nil)
        [[SimpleAudioEngine sharedEngine] playEffect:card.playedSound];
    else if ([action isEqualToString:@"Attack"] && card.attackSound != nil) {
        [[SimpleAudioEngine sharedEngine] playEffect:card.attackSound];
    }
    else
        [self playSoundForResource:[card getPrimaryResource]];
}
- (void)playSoundForResource:(Resource*)resource {
    if ([resource.type isEqualToString:@"Metal"])
        [[SimpleAudioEngine sharedEngine] playEffect:@"clank.wav"];
    else if ([resource.type isEqualToString:@"Meat"])
        [[SimpleAudioEngine sharedEngine] playEffect:@"squash.wav"];
    else if ([resource.type isEqualToString:@"Money"])
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
    else if ([resource.type isEqualToString:@"Magic"])
        [[SimpleAudioEngine sharedEngine] playEffect:@"empower.wav"];
}

// DATA FUNCTIONS
- (void)giveDamage:(int)damage toPlayer:(Player *)player {
    [player takeDamage:damage];
    [self floatText:0-damage forResource:nil forPlayer:player];
    [self updateResourcePanel];
    [self checkIfGameIsFinished];
    
    if (tutorial && player == opponentPlayer && player.hp == 19) {
        id delay = [CCDelayTime actionWithDuration:2.0];
        id showPopUp = [CCCallFuncND actionWithTarget:self selector:@selector(cocosShowTutorialWithName:data:) data:@"Health"];
        [playButton runAction:[CCSequence actions:delay, showPopUp, nil]];
    }
}
- (void)giveDamage:(int)damage toCard:(Card*)card {

}
- (void)addResource:(Resource*)resource toPlayer:(Player*)player {
    [player.resourcePool addResource:resource];
    [self updateResourcePanel];
    [self floatText:resource.amount forResource:resource forPlayer:player];
    [self playSoundForResource:resource];
}
- (void)removeResource:(Resource*)resource toPlayer:(Player*)player {
    [player.resourcePool payResource:resource];
    [self updateResourcePanel];
    [self floatText:0-resource.amount forResource:resource forPlayer:player];
}
         
// HELPER FUNCTIONS
- (void)cocosSetCardToProperBrightness:(id)sender data:(Card*)card {
    [self setCardToProperBrightness:card withDelay:YES];
}
- (void)cocosDealHandForPlayer:(id)sender data:(Player*)player {
    [self dealHandForPlayer:player];
}
- (void)cocosDestroyResourcesForPlayer:(id)sender data:(Player*)player {
    [self destroyResourceBarForPlayer:player];
}
- (void)cocosPlaySoundForCard:(id)sender data:(Card *)card {
    [self playSoundForCard:card forAction:nil];
}
- (void)cocosPlaySoundWithName:(id)sender data:(NSString *)name {
    [[SimpleAudioEngine sharedEngine] playEffect:name];
}
- (void)cocosFlashCardGreen:(id)sender data:(Card*)card {
    [self flashCard:card withColor:ccc3(0, 200, 0)];
}
- (void)cocosFlashCardRed:(id)sender data:(Card*)card {
    [self flashCard:card withColor:ccc3(200, 0, 0)];
}
- (void)cocosFloatTextOverCard:(id)sender data:(NSArray*)cardAndText {
    [self floatTextOverCard:[cardAndText objectAtIndex:0] withText:[cardAndText objectAtIndex:1]];
    [cardAndText release];
}
- (void)cocosFinishGameWithCondition:(id)sender data:(NSString*)condition {
    [self finishGameWithCondition:condition];
}
- (void)cocosDestroyCard:(id)sender data:(Card*)card {
    [self destroyCard:card];
}
- (void)cocosMoveAllCardToProperLocation:(id)sender {
    [self animateAllCardsToProperLocation];
}
- (void)cocosShowBlackBarWithText:(id)sender data:(NSString*)text {
    [self showBlackBarWithText:text];
}
- (void)cocosShowTutorialWithName:(id)sender data:(NSString*)name {
    popUpMenuLayer = [PopUpLayer node];
    [popUpMenuLayer showTutorialPopUp:name];
    [self addChild:popUpMenuLayer z:MAX_Z+1];
}
- (void)cocosShowAbilityPopUpWithName:(id)sender data:(NSString*)abilityPath {
    PopUpLayer *popUp = [PopUpLayer node];
    [popUp showAbilityPopUp:abilityPath];
    [self addChild:popUp z:MAX_Z+1];
}

// UI FUNCTIONS
- (void)showOpponentsTurn {
    [opponentTurnGraphic runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X+OPPONENT_TURN_GRAPHIC_X y:ENDPHASE_Y]]];
}
- (void)hideOpponentsTurn {
    [opponentTurnGraphic runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X+OPPONENT_TURN_GRAPHIC_X y:ENDPHASE_Y+20]]];
}
- (void)showWaitingForOpponent {
    [waitingForOpponentGraphic runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X+WAITING_FOR_OPPONENT_GRAPHIC_X y:ENDPHASE_Y]]];
}
- (void)hideWaitingForOpponent {
    [waitingForOpponentGraphic runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X+WAITING_FOR_OPPONENT_GRAPHIC_X y:ENDPHASE_Y+20]]];
}
- (void)showEndPhase {
    [endTurnButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X y:ENDPHASE_Y]]];
}
- (void)hideEndPhase {
    [endTurnButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:ENDPHASE_X y:ENDPHASE_Y+20]]];
}
- (void)selectCardAtLocation:(CGPoint)location {
    Card *lastPickedCard = pickedCard;
    pickedCard = nil;
    for (Card *card in playerHand) {
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            pickedCard = card;
            if (zoomedOnHand)
                [self setAllCardsToProperBrightness];
            else
                [self zoomIntoCards];
        }
    }
    
    /*for (Card *card in playerBoard) {
        [self hideEnhancementsForCard:card];
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            pickedCard = card;
            // SHOW ENHANCEMENTS AND CYCLE THROUGH THEM
            if ([card.attachedCards count] > 0) {
                Card *lastCard = [card.attachedCards objectAtIndex:[card.attachedCards count]-1];
                if (lastPickedCard == card) {
                    if ([card.attachedCards count] > 0) {
                        [self showEnhancementsForCard:card];
                        pickedCard = [card.attachedCards objectAtIndex:0];
                        [self reorderChild:pickedCard.thumbSprite z:card.thumbSprite.zOrder+2];
                    }
                }
                else if (lastPickedCard == lastCard) {
                    pickedCard = card;
                    [self hideEnhancementsForCard:card];
                }
                else if ([card.attachedCards containsObject:lastPickedCard]) {
                    int index = [card.attachedCards indexOfObject:lastPickedCard];
                    index++;
                    [self hideEnhancementsForCard:card];
                    pickedCard = [card.attachedCards objectAtIndex:index];
                    [self reorderChild:pickedCard.thumbSprite z:card.thumbSprite.zOrder+2];
                }
            }
        }
    }
    
    // OPPONENT CARDS
    if (opponentHandRevealed) {
        for (Card *card in opponentHand) {
            if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
                pickedCard = card;
            }
        }
    }
    for (Card *card in opponentBoard) {
        //[self hideEnhancementsForCard:card];
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            pickedCard = card;
            // SHOW ENHANCEMENTS AND CYCLE THROUGH THEM
            if (lastPickedCard == card) {
                if ([card.attachedCards count] > 0) {
                    //[self showEnhancementsForCard:card];
                    pickedCard = [card.attachedCards objectAtIndex:[card.attachedCards count]-1];
                    [self reorderChild:pickedCard.thumbSprite z:card.thumbSprite.zOrder+100];
                }
            }
            else if ([card.attachedCards containsObject:lastPickedCard]) {
                if ([card.attachedCards count] > 1) {
                    // CYCLE CARDS
                    /*for (int i = 1; i < [card.attachedCards count]; i++) {
                        [card.attachedCards exchangeObjectAtIndex:0 withObjectAtIndex:i];
                    }*/
                    //[self showEnhancementsForCard:card];
                    /*pickedCard = [card.attachedCards objectAtIndex:[card.attachedCards count]-1];
                    [self reorderChild:pickedCard.thumbSprite z:card.thumbSprite.zOrder+100];                    
                }
                else {
                    //[self hideEnhancementsForCard:card];
                }
            }
        }
    }*/
    
    if (pickedCard != nil) {
        //[self hideBigCard];
        //[self showBigCard:pickedCard];
    }
    else {
        //[self hideBigCard];
    }
}
- (void)zoomIntoCards {
    showTableButton.visible = YES;
    zoomedOnHand = YES;
    int x = 80;
    int y = 120;
    int rotation = -20;
    for (Card *card in playerHand) {
        [card.thumbSprite runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:0.2 scale:1.0],[CCRotateTo actionWithDuration:0.2 angle:rotation],[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:x y:y]], nil]];
        
        switch ([playerHand indexOfObject:card]) {
            case 0: [self reorderChild:card.thumbSprite z:1]; break;
            case 1: [self reorderChild:card.thumbSprite z:2]; break;
            case 2: [self reorderChild:card.thumbSprite z:3]; break;
            case 3: [self reorderChild:card.thumbSprite z:2]; break;
            case 4: [self reorderChild:card.thumbSprite z:1]; break;
            default: break;
        }
        
        x += 80;
        
        if ([playerHand indexOfObject:card] < 2)
            y += 30;
        else {
            y -= 30;
        }
        
        rotation += 10;
    }
}
- (void)zoomOutOfCards {
    showTableButton.visible = NO;
    zoomedOnHand = NO;
    int x = CARD_STARTX;
    for (Card *card in playerHand) {
        [card.thumbSprite runAction:[CCSpawn actions:[CCScaleTo actionWithDuration:0.2 scale:0.3],[CCRotateTo actionWithDuration:0.2 angle:0],[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:x y:CARD_PLAYERY]], nil]];
        x += CARD_SPACING;
        [self reorderChild:card.thumbSprite z:2];
    }
    
    pickedCard = nil;
    [self setAllCardsToProperBrightness];
}
- (BOOL)selectButtonsAtLocation:(CGPoint)location {
    // CHECK IF MENU BUTTON IS PRESSED
    if (menuButton != nil && CGRectContainsPoint(menuButton.boundingBox, location)) {
        [self launchMenu];
    }
    
    // CHECK IF END PHASE BUTTON IS PRESSED
    if (endTurnButton != nil && CGRectContainsPoint(endTurnButton.boundingBox, location)) {
        if (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND) {
            [self endPhase];
            return YES;
        }
    }
    
    if (showTableButton.visible == YES && CGRectContainsPoint(showTableButton.boundingBox, location)) {
        [self zoomOutOfCards];
    }
    
    // CHECK IF ATTACK BUTTON IS PRESSED
    if (attackButton != nil && CGRectContainsPoint(attackButton.boundingBox, location)) {
        if (gamePhase == PLAYER_TURN) {
            [self attackWithCard:pickedCard forPlayer:localPlayer];
            [attackButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y]]];
            return YES;
        }
    }
    // CHECK IF DEFEND BUTTON IS PRESSED
    if (defendButton != nil && CGRectContainsPoint(defendButton.boundingBox, location)) {
        if (gamePhase == PLAYER_DEFEND) {
            [self defendWithCard:pickedCard forPlayer:localPlayer];
            [defendButton runAction:[CCMoveTo actionWithDuration:0.2 position:[self makeScaledPointx:SIDE_BUTTON_X+SIDE_BUTTON_MOVE_X y:TOP_BUTTON_Y]]];
            return YES;
        }
    }
    // CHECK IF ABILITY BUTTON IS PRESSED
    if (abilityButton != nil && CGRectContainsPoint(abilityButton.boundingBox, location)) {
        if (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND) {
            [self enterTargetMode];
            return YES;
        }
    }
    
    // CHECK IF CANCEL BUTTON IS PRESSED
    if (cancelButton != nil && CGRectContainsPoint(cancelButton.boundingBox, location)) {
        if (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND) {
            [self exitTargetMode];
            return YES;
        }
    }
    
    // CHECK IF TARGET BUTTON IS PRESSED
    if (targetButton != nil && CGRectContainsPoint(targetButton.boundingBox, location)) {
        if (targetMode && (gamePhase == PLAYER_TURN || gamePhase == PLAYER_DEFEND)) {
            [self useAbilityFromCard:playerActiveCard onCard:pickedCard];
            [self exitTargetMode];
            return YES;
        }
    }    
    
    if (playButton != nil && CGRectContainsPoint(playButton.boundingBox, location)) {
        if (gamePhase == PREGAME) {
            if (opponentIsHuman) {
                readyToPlay = YES;
                
                [self showWaitingForOpponent];
                [self sendDeckAndHand];
                [self sendReadyToPlay];
                if (opponentReadyToPlay) {
                    ourRoll = arc4random() % 100 + 1;
                    CCLOG(@"Sending roll %d", ourRoll);
                    
                    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
                    message.code = @"Roll";
                    message.number = ourRoll;
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
                    [self sendData:data];
                    [message release];
                    
                    [self tryToDetermineHost];
                }
            }
            else {
                [self startGame];
            }
            [playButton runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:+20]]];
            [redealButton runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:+20]]];
        }
    }
    if (redealButton != nil && CGRectContainsPoint(redealButton.boundingBox, location)) {
        if (gamePhase == PREGAME && tutorial != YES) {
            [self redealHandForPlayer:localPlayer];
        }
    }

    
    return NO;
}
- (void)launchMenu {
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.wav" pitch:0.8 pan:1.0 gain:0.8];
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    popUpMenuLayer = [PopUpLayer node];
    [popUpMenuLayer showGameQuitMenu];
    [self addChild:popUpMenuLayer z:MAX_Z+1];
}
- (void)removeMenu {
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    [self removeChild:popUpMenuLayer cleanup:YES];
}
- (void)showDisconnectPopUp {
    PopUpLayer *popUpLayer = [PopUpLayer node];
    [popUpLayer showDisconnectPopUp];
    [self addChild:popUpLayer z:10000];
}
- (void)showVersionPopUp {
    PopUpLayer *popUpLayer = [PopUpLayer node];
    [popUpLayer showVersionPopUp];
    [self addChild:popUpLayer z:10001];
}

// TECHNICAL FUNCTIONS
- (int)getIconBufferForAmount:(int)amount {
    int iconBuffer = 0;
    if (amount < 10)
        iconBuffer = -3;
    if (amount/100 >= 1)
        iconBuffer = 3;
    if (amount/1000 >= 1)
        iconBuffer = 5;
    return iconBuffer;
}
- (void)cleanUpDestroyedCard:(Card*)card {
    [self removeChild:card.sprite cleanup:YES];
    [self removeChild:card.thumbSprite cleanup:YES];
    if (card.owner == localPlayer) {
        pickedCard = nil;
        [playerBoard removeObject:card];
        [playerSideBoard removeObject:card];
    }
    else {
        [opponentBoard removeObject:card];
        [opponentSideBoard removeObject:card];
    }
    [self animateBoardsToProperLocation:card.owner];
}
- (void)registerWithTouchDispatcher {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// MATCH FUNCTIONS
- (void)matchStarted {    
    CCLOG(@"Match started");
    [self sendVersion];
    [self dealFirstHand:localPlayer];
    
    int random = arc4random() % 3;
    if (random == 0) {
        [self loadBackgroundWithName:@"Castle"];
    }
    else if (random == 1) {
        [self loadBackgroundWithName:@"Beach"];
    }
    else if (random == 2) {
        [self loadBackgroundWithName:@"Graveyard"];
    }
    //[self startGame];
}
- (void)matchEnded {    
    CCLOG(@"Match ended");
}
- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    CCLOG(@"Received data");
    MultiplayerMessage *message = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if ([message.code isEqualToString:@"Version"]) {
        if ([Profile sharedProfile].gameVersion != message.number) {
            [self showVersionPopUp];
        }
            
    }
    else if ([message.code isEqualToString:@"Roll"]) {
        CCLOG(@"Received Roll %d", message.number);
        theirRoll = message.number;
        [self tryToDetermineHost];
    }
    else if ([message.code isEqualToString:@"Ready To Play"]) {
        opponentReadyToPlay = YES;
        if (readyToPlay) {
            ourRoll = arc4random() % 100 + 1;
            CCLOG(@"Sending roll %d", ourRoll);
            
            MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
            message.code = @"Roll";
            message.number = ourRoll;
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
            [self sendData:data];
            [message release];
            
            [self tryToDetermineHost];
        }
    }
    else if ([message.code isEqualToString:@"Deck and Hand"]) {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        // GET HAND
        for (NSString *cardName in message.cardArray) {
            Card *receivedCard = [factory spawnCard:cardName];
            [tempArray addObject:receivedCard];
        }
        for (Card* card in tempArray) {
            [self addCardToHand:card forPlayer:opponentPlayer];
        }
        
        [tempArray removeAllObjects];
        
        // GET DECK
        for (NSString *cardName in message.deckArray) {
            Card *receivedCard = [factory spawnCard:cardName];
            [tempArray addObject:receivedCard];
        }
        for (Card* card in tempArray) {
            [opponentPlayer.deck addCard:card];
        }
        [tempArray release];
        [self dealFirstHand:opponentPlayer];
    }
    else if ([message.code isEqualToString:@"Play Card"]) {
        CCLOG(@"Opponent Played Card %@", message.cardName);
        Card *receivedCard = [factory spawnCard:message.cardName];
        Card *foundCard = nil;
        for (Card *card in opponentHand) {
            if ([card isEqualToCard:receivedCard]) {
                foundCard = card;
            }
        }
        
        if (foundCard) {
            if ([foundCard.type isEqualToString:@"Enhancement"] || [foundCard.type isEqualToString:@"Action"]) {
                CCLOG(@"Card is enhancement or action");
                Card *foundTarget = nil;
                if (message.targetCard) {
                    for (Card *card in playerBoard) {
                        if ([card isEqualToCard:message.targetCard]) {
                            foundTarget = card;
                        }
                    }
                    for (Card *card in opponentBoard) {
                        if ([card isEqualToCard:message.targetCard]) {
                            foundTarget = card;
                        }
                    }
                    if ([message.targetPlayer isEqualToString:@"Friendly"]) {
                        for (Card *card in opponentBoard) {
                            if ([card isEqualToCard:message.targetCard]) {
                                foundTarget = card;
                            }
                        }
                    }
                    if ([message.targetPlayer isEqualToString:@"Enemy"]) {
                        for (Card *card in playerBoard) {
                            if ([card isEqualToCard:message.targetCard]) {
                                foundTarget = card;
                            }
                        }
                    }
                }
                if ([message.targetPlayer isEqualToString:@"LocalPlayer"] || [message.targetPlayer isEqualToString:@"OpponentPlayer"]) {
                    if ([message.targetPlayer isEqualToString:@"LocalPlayer"]) {
                        [self playCard:foundCard forPlayer:opponentPlayer onTarget:opponentPlayer];
                    }
                    else if ([message.targetPlayer isEqualToString:@"OpponentPlayer"]) {
                        [self playCard:foundCard forPlayer:opponentPlayer onTarget:localPlayer];
                    }
                }
                else
                    [self playCard:foundCard forPlayer:opponentPlayer onTarget:foundTarget];
            }
            else
                [self playCard:foundCard forPlayer:opponentPlayer onTarget:nil];
        }
    }
    else if ([message.code isEqualToString:@"Attack"]) {
        Card *foundCard = nil;
        for (Card *card in opponentBoard) {
            if ([card isEqualToCard:message.card]) {
                foundCard = card;
            }
        }
        if (foundCard) {
            [self attackWithCard:foundCard forPlayer:opponentPlayer];
        }
    }
    else if ([message.code isEqualToString:@"Defend"]) {
        Card *foundCard = nil;
        for (Card *card in opponentBoard) {
            if ([card isEqualToCard:message.card]) {
                foundCard = card;
            }
        }
        if (foundCard) {
            [self defendWithCard:foundCard forPlayer:opponentPlayer];
        }
        else {
            NSLog(@"CARD WAS NOT FOUND frumpus!!!");
        }
    }
    else if ([message.code isEqualToString:@"Don't Defend"]) {
        [self defendWithCard:nil forPlayer:opponentPlayer];
    }
    else if ([message.code isEqualToString:@"Use Ability"]) {
        // CHECK FOR SOURCE CARD
        Card *sourceCard = nil;
        for (Card *card in opponentBoard) {
            if ([card isEqualToCard:message.card]) {
                sourceCard = card;
            }
        }
        // CHECK FOR TARGET CARD
        Card *targetCard = nil;
        for (Card *card in opponentBoard) {
            if ([card isEqualToCard:message.targetCard]) {
                targetCard = card;
            }
        }
        for (Card *card in playerBoard) {
            if ([card isEqualToCard:message.targetCard]) {
                targetCard = card;
            }
        }
        
        if (sourceCard && targetCard) {
            [self useAbilityFromCard:sourceCard onCard:targetCard];;
        }
        else {
            NSLog(@"Ability Source or Target could not be found.");
        }    }
    else if ([message.code isEqualToString:@"End Phase"]) {
        CCLOG(@"Opponent Ended Phase.");
        [self endPhase];
    }
    
}
- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {       
    switch (state) {
        case GKPlayerStateConnected: 
            // handle a new player connection.
            break; 
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            [self disconnect];
            [self showDisconnectPopUp];
            break;
    }                     
}
- (void)sendData:(NSData *)data {
    NSError *error;
    BOOL success = [[GCHelper sharedInstance].match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    if (!success) {
        CCLOG(@"Error sending init packet");
        [self matchEnded];
    }
}

// MULTIPLAYER FUNCTIONS
- (void)inviteReceived {
    NSLog(@"Invite Received");
    //[self restartTapped:nil];    
}
- (void)disconnect {
    NSLog(@"Disconnecting...");
    if (opponentIsHuman)
        [[GCHelper sharedInstance].match disconnect];
}
- (void)noMatchesFound {
    PopUpLayer *popUpMenuLayer = [PopUpLayer node];
    [popUpMenuLayer showNoMatchPopup];
    [self addChild:popUpMenuLayer z:1001];
}
- (void)tryToDetermineHost {
    // MAKE SURE BOTH DEVICES ARE READY
    if (ourRoll == 0) {
        CCLOG(@"We haven't rolled yet");
        return;
    }
    else if (theirRoll == 0) {
        CCLOG(@"They haven't rolled yet");
        return;
    }
    
    if (ourRoll > theirRoll) {
        CCLOG(@"We are the host");
        [self setGamePhase:PLAYER_TURN];
        [self startGame];
        host = YES;
    }
    else if (ourRoll < theirRoll) {
        CCLOG(@"They are the host");
        [self setGamePhase:OPPONENT_TURN];
        [self startGame];
        host = NO;
    }
    else {
        CCLOG(@"Numbers were the same, resending");
        ourRoll = arc4random() % 100 + 1;
        MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
        message.code = @"Roll";
        message.number = ourRoll;
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
        [self sendData:data];
        [message release];
    }
}
- (void)sendVersion {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Version";
    message.number = [Profile sharedProfile].gameVersion;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendDeckAndHand {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Deck and Hand";
    message.cardArray = [[NSMutableArray alloc] init];
    for (Card *card in playerHand) {
        [message.cardArray addObject:card.name];
    }
    message.deckArray = [[NSMutableArray alloc] init];
    for (Card *card in localPlayer.deck.cards) {
        [message.deckArray addObject:card.name];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendReadyToPlay {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Ready To Play";
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendPhaseChange:(int)phase {
    if (phase == PLAYER_TURN)
        phase = OPPONENT_TURN;
    else if (phase == PLAYER_DEFEND)
        phase = OPPONENT_DEFEND;
    else if (phase == OPPONENT_TURN)
        phase = PLAYER_TURN;
    else if (phase == OPPONENT_DEFEND)
        phase = PLAYER_DEFEND;
    
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Phase Change";
    message.number = phase;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendEndPhase {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"End Phase";
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendAttackWithCard:(Card*)card {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Attack";
    message.card = card;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendDefendWithCard:(Card*)card {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    if (card == nil) {
        message.code = @"Don't Defend";
    }
    else {
        message.code = @"Defend";
        message.card = card;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}
- (void)sendUseAbilityWithCard:(Card*)card onTarget:(Card*)targetCard {
    MultiplayerMessage *message = [[MultiplayerMessage alloc] init];
    message.code = @"Use Ability";
    message.card = card;
    message.targetCard = targetCard;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:message];
    [self sendData:data];
    [message release];
}

@end
