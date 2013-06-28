//
//  DeckBuilderLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-04-30.
//  Copyright 2012 Smashware. All rights reserved.
//

#define CARD_SPACING 34

#import "DeckBuilderLayer.h"
#import "CardFactory.h"
#import "CardSprite.h"
#import "MenuLayer.h"

#define STARTING_X 30
#define CURRENT_DECK_Y 240
#define AVAILABLE_CARDS_Y 45
#define BIG_CARDX 375
#define BIG_CARDY 142
#define ENDPHASE_Y 311
#define CARD_SPACING 60
#define LEFT 0
#define RIGHT 1

Card *pickedCard;
CardSprite *bigCard;
CardFactory *factory;
CCSprite *menuButton;
CCSprite *changeDeckButton;
CCSprite *dragLine;
CCSprite *gear;
CCLabelTTF *currentDeckLabel;
CCLabelTTF *availableCardsLabel;
float availableCardsMovement;
int availableCardsOffset;
float currentDeckMovement;
int currentDeckOffset;
int zOrder;
BOOL dragging;
BOOL availableCardsDragging;
BOOL currentDeckDragging;
BOOL advancedOptions;
CGPoint lastMovedPoint;
CGPoint touchStartPoint;
NSMutableArray *currentDeck;
NSMutableArray *availableCards;
NSMutableArray *deckFrontCards;
NSMutableArray *advancedOptionsSprites;

@implementation DeckBuilderLayer

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	    
	// 'layer' is an autorelease object.
	DeckBuilderLayer *layer = [DeckBuilderLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
- (id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		// create and initialize our seeker sprite, and add it to this layer
        
        buttons = [[NSMutableArray alloc] init];
        deckFrontCards = [[NSMutableArray alloc] init];
        currentDeck = [[NSMutableArray alloc] init];
        availableCards = [[NSMutableArray alloc] init];
        
        factory = [[CardFactory alloc] init];
        profile = [Profile sharedProfile];
        
        for (NSString* cardName in profile.availableCards) {
            [availableCards addObject:[factory spawnCard:cardName]];
        }
        for (NSString* cardName in profile.currentDeck) {
            [currentDeck addObject:[factory spawnCard:cardName]];
        }
        
        // SET BACKGROUND
        CCSprite *background = [CCSprite spriteWithFile: @"PaperBackgroundDark.png"];
        [background setPosition:[self makeScaledPointx:240 y:160]];
        [self addChild:background z:-1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [background setScale:1.2];
        }
        
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        if (!profile.muted) {
            [audioEngine playBackgroundMusic:@"StoreMusic.mp3" loop:YES];
            [audioEngine setBackgroundMusicVolume:BACKGROUND_VOLUME];
        }
        
        [self showCurrentCards];
        
        CCSprite *toolbar = [CCSprite spriteWithFile:@"DeckBuilderToolbar.png"];
        [toolbar setPosition:[self makeScaledPointx:240 y:304]];
        [self addChild:toolbar z:10000];
        
        menuButton = [CCSprite spriteWithFile: @"ToolBarBack.png"];
        [menuButton setPosition:[self makeScaledPointx:40 y:303]];
        menuButton.tag = 1;
        [buttons addObject:menuButton];
        [self addChild:menuButton z:10001];
        
        changeDeckButton = [CCSprite spriteWithFile: @"ChangeDeck.png"];
        [changeDeckButton setPosition:[self makeScaledPointx:410 y:303]];
        changeDeckButton.tag = 2;
        [buttons addObject:changeDeckButton];
        [self addChild:changeDeckButton z:10001];
        
        dragLine = [CCSprite spriteWithFile:@"DragLine.png"];
        [dragLine setPosition:[self makeScaledPointx:240 y:145]];
        [dragLine setOpacity:40];
        [self addChild:dragLine];
        
        gear = [CCSprite spriteWithFile:@"Gear.png"];
        [gear setPosition:[self makeScaledPointx:450 y:145]];
        gear.tag = 4;
        [gear setScale:2.0];
        [gear setOpacity:255];
        [self addChild:gear];
        
        advancedOptionsSprites = [[NSMutableArray alloc] init];
        
        currentDeckLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Current Deck - %d Cards",[currentDeck count]]  dimensions:CGSizeMake(300, 50) alignment:UITextAlignmentLeft fontName:@"Hobo.ttf" fontSize:[self makeScaledInt:20]];
        currentDeckLabel.color = ccc3(40, 40, 40);
        [currentDeckLabel setPosition:[self makeScaledPointx:185 y:152]];
        [currentDeckLabel setOpacity:0];
        [advancedOptionsSprites addObject:currentDeckLabel];
        [self addChild:currentDeckLabel z:10000];
        
        availableCardsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Available - %d Cards",[availableCards count]]  dimensions:CGSizeMake(300, 50) alignment:UITextAlignmentLeft fontName:@"Hobo.ttf" fontSize:[self makeScaledInt:20]];
        availableCardsLabel.color = ccc3(40, 40, 40);
        [availableCardsLabel setPosition:[self makeScaledPointx:185 y:112]];
        [availableCardsLabel setOpacity:0];
        [advancedOptionsSprites addObject:availableCardsLabel];
        [self addChild:availableCardsLabel z:10000];
        
        CCSprite *sortLabel = [CCSprite spriteWithFile:@"SortButton.png"];
        [sortLabel setPosition:[self makeScaledPointx:380 y:165]];
        [sortLabel setOpacity:0];
        sortLabel.tag = 5;
        [buttons addObject:sortLabel];
        [advancedOptionsSprites addObject:sortLabel];
        [self addChild:sortLabel z:10000];
        
        CCSprite *sortLabel2 = [CCSprite spriteWithFile:@"SortButton.png"];
        [sortLabel2 setPosition:[self makeScaledPointx:380 y:125]];
        [sortLabel2 setOpacity:0];
        sortLabel2.tag = 6;
        [buttons addObject:sortLabel2];
        [advancedOptionsSprites addObject:sortLabel2];
        [self addChild:sortLabel2 z:10000];
        
        /*
        CCSprite *cardFurnace = [CCSprite spriteWithFile:@"CardFurnaceBW.png"];
        [cardFurnace setPosition:[self makeScaledPointx:275 y:142]];
        [cardFurnace setOpacity:0];
        [advancedOptionsSprites addObject:cardFurnace];
        [self addChild:cardFurnace z:10000];*/
        
        [self scheduleUpdateWithPriority:0];
        
        self.isTouchEnabled = YES;
	}
	return self;
}
- (void)dealloc {
    [buttons release];
    [deckFrontCards release];
    [currentDeck release];
    [availableCards release];
    [factory release];
    //[advancedOptionsSprites release];
    [super dealloc];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    touchStartPoint = location;
    [self touchStartedForButtonAtLocation:location];
    [self selectCardAtLocation:location];
    
    currentDeckMovement = 0;
    availableCardsMovement = 0;
    
    return YES;
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    if (pickedCard != nil) {
        [pickedCard.thumbSprite setPosition:location];
        
        if (!dragging) {
            [self moveCardToFrontOfHand:pickedCard];
            [self reorderChild:pickedCard.thumbSprite z:10000];
            if (bigCard != nil) {
                [bigCard runActionOnChildren:[CCFadeTo actionWithDuration:0.2 opacity:0]];
            }
            dragging = YES;
        }
    }
    
    if (!dragging) {
        if (location.y > 145 && !availableCardsDragging && [currentDeck count] != 0) {
            currentDeckMovement = location.x - lastMovedPoint.x;
            for (Card *card in currentDeck) {
                CCSprite *cardSprite = card.thumbSprite;
                [cardSprite setPosition:CGPointMake(cardSprite.position.x + (location.x-touchStartPoint.x), cardSprite.position.y)];
            }
            Card *firstCard = [currentDeck objectAtIndex:0];
            currentDeckOffset = STARTING_X - firstCard.thumbSprite.position.x;
            currentDeckDragging = YES;
        }
        else if (!currentDeckDragging && [availableCards count] != 0) {
            availableCardsMovement = location.x - lastMovedPoint.x;
            for (Card *card in availableCards) {
                CCSprite *cardSprite = card.thumbSprite;
                [cardSprite setPosition:CGPointMake(cardSprite.position.x + (location.x-touchStartPoint.x), cardSprite.position.y)];
            }
            Card *firstCard = [availableCards objectAtIndex:0];
            availableCardsOffset = STARTING_X - firstCard.thumbSprite.position.x;
            availableCardsDragging = YES;
        }
        lastMovedPoint = location;
    }
    
    touchStartPoint = location;
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    BOOL dragBack = NO;
    BOOL cardChangedDecks = NO;
    
    [self touchFinishedForButtonAtLocation:location];
    
    if (CGRectContainsPoint(gear.boundingBox, location) && !currentDeckDragging && !availableCardsDragging) {
        [self actionForButton:gear];
    }
    
    if (dragging) {
        if (pickedCard) {
            if (location.y > 160) {
                Card *targetCard = nil;
                for (Card *card in currentDeck) {
                    if (CGRectContainsPoint(card.thumbSprite.boundingBox, location) && card != pickedCard) {
                        targetCard = card;
                    }
                }
                if (targetCard) {
                    [self moveCard:pickedCard toDeck:currentDeck atIndex:[currentDeck indexOfObject:targetCard]];
                }
                else {
                    if ([currentDeck containsObject:pickedCard])
                        [self moveCardToFrontOfHand:pickedCard];
                    else
                        [self moveCard:pickedCard toDeck:currentDeck];
                }
                for (Card *card in currentDeck) {
                    [self animateCardToProperLocation:card];
                }
                cardChangedDecks = YES;
            }
            else if (location.y <= 160) {
                Card *targetCard = nil;
                for (Card *card in availableCards) {
                    if (CGRectContainsPoint(card.thumbSprite.boundingBox, location) && card != pickedCard) {
                        targetCard = card;
                    }
                }
                if (targetCard) {
                    [self moveCard:pickedCard toDeck:availableCards atIndex:[availableCards indexOfObject:targetCard]];
                }
                else {
                    if ([availableCards containsObject:pickedCard])
                        [self moveCardToFrontOfHand:pickedCard];
                    else
                        [self moveCard:pickedCard toDeck:availableCards];
                }
                for (Card *card in availableCards) {
                    [self animateCardToProperLocation:card];
                }                cardChangedDecks = YES;
            }
        }
        
        dragBack = YES;
    }
    
    if (dragBack) {
        // DRAG CARD BACK
        [self animateCardToProperLocation:pickedCard];
        if (bigCard != nil) {
            [self hideBigCard];
            pickedCard = nil;
            [self setAllCardsToProperBrightness];
            //[bigCard showStatsForCard:pickedCard];
            //[bigCard runActionOnChildren:[CCFadeTo actionWithDuration:0.2 opacity:255]];
        }
    }
    
    if (cardChangedDecks) {
        pickedCard = nil;
        [self hideBigCard];
        [self setAllCardsToProperBrightness];
    }

    dragging = NO;
    availableCardsDragging = NO;
    currentDeckDragging = NO;
}

- (void)update:(ccTime)deltaTime {
    if (!dragging) {
        // CURRENT DECK
        if (!currentDeckDragging && [currentDeck count] != 0) {
            Card *firstCard = [currentDeck objectAtIndex:0];
            Card *lastCard = [currentDeck objectAtIndex:[currentDeck count]-1];
            if (firstCard.thumbSprite.position.x > [self makeScaledInt:STARTING_X]) {
                currentDeckMovement = ([self makeScaledx:STARTING_X] - firstCard.thumbSprite.position.x)/12;
            }
            else if (lastCard.thumbSprite.position.x < [self makeWidescreenInt:480 - STARTING_X]) {
                if ([currentDeck count] > 8)
                    currentDeckMovement = ([self makeScaledx:480-STARTING_X] - lastCard.thumbSprite.position.x)/12;
                else
                    currentDeckMovement = ([self makeScaledx:STARTING_X] - firstCard.thumbSprite.position.x)/12;
            }
            else {
                currentDeckMovement = currentDeckMovement/1.03;
            }
            
            if (currentDeckMovement < 1 && currentDeckMovement > -1) {
                currentDeckMovement = 0;
            }
            
            for (int i = 0; i < [currentDeck count]; i++) {
                Card *card = [currentDeck objectAtIndex:i];
                CCSprite *cardSprite = card.thumbSprite;
                [cardSprite setPosition:CGPointMake(cardSprite.position.x+currentDeckMovement, cardSprite.position.y)];
                currentDeckOffset = STARTING_X - firstCard.thumbSprite.position.x;
            }
        }
        
        // AVAILABLE CARDS
        if (!availableCardsDragging && [availableCards count] != 0) {
            Card *firstCard = [availableCards objectAtIndex:0];
            Card *lastCard = [availableCards objectAtIndex:[availableCards count]-1];
            if (firstCard.thumbSprite.position.x > [self makeScaledInt:STARTING_X]) {
                availableCardsMovement = ([self makeScaledx:STARTING_X] - firstCard.thumbSprite.position.x)/12;
            }
            else if (lastCard.thumbSprite.position.x < [self makeWidescreenInt:480 - STARTING_X]) {
                if ([availableCards count] > 8)
                    availableCardsMovement = ([self makeScaledx:480-STARTING_X] - lastCard.thumbSprite.position.x)/12;
                else
                    availableCardsMovement = ([self makeScaledx:STARTING_X] - firstCard.thumbSprite.position.x)/12;
            }
            else {
                availableCardsMovement = availableCardsMovement/1.03;
            }
            if (availableCardsMovement < 1 && availableCardsMovement > -1) {
                availableCardsMovement = 0;
            }
            
            for (int i = 0; i < [availableCards count]; i++) {
                Card *card = [availableCards objectAtIndex:i];
                CCSprite *cardSprite = card.thumbSprite;
                [cardSprite setPosition:CGPointMake(cardSprite.position.x+availableCardsMovement, cardSprite.position.y)];
                availableCardsOffset = STARTING_X - firstCard.thumbSprite.position.x;
            }
        }
    }
}

- (void)actionForButton:(CCSprite*)button {
    if (button.tag == 1) {
        [self saveDecks];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer sceneWithAnimation:NO]]];
    }
    else if (button.tag == 2) {
        [self saveDecks];
        if (advancedOptions == YES)
            [self actionForButton:gear];
        for (Card *card in availableCards) {
            [card.thumbSprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
            card.thumbSprite = nil;
        }
        for (Card *card in currentDeck) {
            [card.thumbSprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
            card.thumbSprite = nil;
        }
        [buttons removeObject:changeDeckButton];
        [changeDeckButton runAction:[CCFadeOut actionWithDuration:0.2]];
        [dragLine runAction:[CCFadeTo actionWithDuration:0.2 opacity:0]];
        [gear runAction:[CCFadeTo actionWithDuration:0.2 opacity:0]];
        [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCCallFunc actionWithTarget:self selector:@selector(showAllDecks)], nil]];
    }
    else if (button.tag == 3) {
        if ([profile.decks count] >= 5)
            [self showPopUpWithText:@"You can have a maximum of 5 decks at any one time!"];
        else {
            [currentDeck removeAllObjects];
            NSMutableArray *newDeck = [[NSMutableArray alloc] init];
            profile.currentDeck = newDeck;
            [profile.decks addObject:newDeck];
            profile.currentDeckIndex = [profile.decks indexOfObject:newDeck];
            [self showCurrentCards];
            [self hideDeckThumbs];
        }
    }
    else if (button.tag == 4) {
        if (advancedOptions == NO) {
            [gear runAction:[CCFadeTo actionWithDuration:0.2 opacity:100]];
            [gear runAction:[CCScaleTo actionWithDuration:0.2 scale:2.0]];
            [gear runAction:[CCRotateTo actionWithDuration:0.2 angle:-90]];
            advancedOptions = YES;
            for (CCSprite *sprite in advancedOptionsSprites) {
                [sprite runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
                [sprite runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:-10 y:0]]];
            }
        }
        else {
            [gear runAction:[CCRotateTo actionWithDuration:0.2 angle:0]];
            [gear runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
            [gear runAction:[CCScaleTo actionWithDuration:0.2 scale:2.0]];
            advancedOptions = NO;
            for (CCSprite *sprite in advancedOptionsSprites) {
                [sprite runAction:[CCFadeTo actionWithDuration:0.2 opacity:0]];
                [sprite runAction:[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:10 y:0]]];
            }
        }
    }
    else if (button.tag == 5) {
        [self sortDeck:currentDeck];
        [self animateAllCardsToProperLocation];
    }
    else if (button.tag == 6) {
        [self sortDeck:availableCards];
        [self animateAllCardsToProperLocation];
    }
    else if (button.tag >= 100) {
        [currentDeck removeAllObjects];
        profile.currentDeck = [profile.decks objectAtIndex:button.tag-100];
        profile.currentDeckIndex = button.tag-100;
        for (NSString* cardName in profile.currentDeck) {
            [currentDeck addObject:[factory spawnCard:cardName]];
        }
        [self showCurrentCards];
        [self hideDeckThumbs];
    }
}
- (void)showCurrentCards {
    for (int i = 0; i < [currentDeck count]; i++) {
        Card *card = [currentDeck objectAtIndex:i];
        //card.sprite = [CCSprite spriteWithFile:card.imagePath];
        card.thumbSprite = [CCSprite spriteWithFile:[card getThumbPath]];
        card.thumbSprite.position = ccp(STARTING_X+(i*CARD_SPACING),CURRENT_DECK_Y);//[self makeScaledPointx:STARTING_X+(i*CARD_SPACING) y:CURRENT_DECK_Y];
        [self addChild:card.thumbSprite];
    }
    
    for (int i = 0; i < [availableCards count]; i++) {
        Card *card = [availableCards objectAtIndex:i];
        //card.sprite = [CCSprite spriteWithFile:card.imagePath];
        card.thumbSprite = [CCSprite spriteWithFile:[card getThumbPath]];
        card.thumbSprite.position = ccp(STARTING_X+(i*CARD_SPACING),AVAILABLE_CARDS_Y);//[self makeScaledPointx:STARTING_X+(i*CARD_SPACING) y:AVAILABLE_CARDS_Y];
        [self addChild:card.thumbSprite];
    }
    [currentDeckLabel setString:[NSString stringWithFormat:@"Current Deck - %d Cards",[currentDeck count]]];
    [availableCardsLabel setString:[NSString stringWithFormat:@"Available - %d Cards",[availableCards count]]];
}
- (void)hideDeckThumbs {
    for (CCSprite *deckThumb in deckFrontCards) {
        [buttons removeObject:deckThumb];
        [deckThumb runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.2],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
    }
    [deckFrontCards removeAllObjects];
    [buttons addObject:changeDeckButton];
    [changeDeckButton runAction:[CCFadeIn actionWithDuration:0.2]];
    [dragLine runAction:[CCFadeTo actionWithDuration:0.2 opacity:40]];
    [gear runAction:[CCFadeTo actionWithDuration:0.2 opacity:255]];
}
- (void)removeEmptyDecks {
    NSMutableArray *deckToBeRemoved = nil;
    for (NSMutableArray *deck in profile.decks) {
        if ([deck count] == 0) {
            deckToBeRemoved = deck;
        }
    }
    if (deckToBeRemoved != nil) {
        [profile.decks removeObject:deckToBeRemoved];
    }
}
- (void)showAllDecks {
    [self removeEmptyDecks];
    int numCards = 0;
    int midPoint = 240 - [profile.decks count]*35;
    for (NSMutableArray *deck in profile.decks) {
        Card *firstCard = [factory spawnCard:[deck objectAtIndex:0]];
        firstCard.sprite = [CCSprite spriteWithFile:firstCard.imagePath];
        firstCard.thumbSprite = [CCSprite spriteWithFile:[firstCard getThumbPath]];
        firstCard.thumbSprite.position = [self makeScaledPointx:midPoint+numCards*70 y:150];
        firstCard.thumbSprite.opacity = 0;
        [firstCard.thumbSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2*numCards],[CCSpawn actions:[CCFadeIn actionWithDuration:0.2],[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:10]], nil], nil]];        
        firstCard.thumbSprite.tag = 100+numCards;
        [deckFrontCards addObject:firstCard.thumbSprite];
        [buttons addObject:firstCard.thumbSprite];
        [self addChild:firstCard.thumbSprite];
        numCards++;
    }
    CCSprite *newDeckButton = [CCSprite spriteWithFile:@"CreateNewDeck.png"];
    newDeckButton.position = [self makeScaledPointx:midPoint+numCards*70 y:150];
    newDeckButton.opacity = 0;
    newDeckButton.tag = 3;
    [newDeckButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2*numCards],[CCSpawn actions:[CCFadeIn actionWithDuration:0.2],[CCMoveBy actionWithDuration:0.2 position:[self makeScaledPointx:0 y:10]], nil], nil]];
    [deckFrontCards addObject:newDeckButton];
    [buttons addObject:newDeckButton];
    [self addChild:newDeckButton];
}
- (void)selectCardAtLocation:(CGPoint)location {
    pickedCard = nil;
    for (Card *card in currentDeck) {
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            pickedCard = card;
        }
    }
    for (Card *card in availableCards) {
        if (CGRectContainsPoint(card.thumbSprite.boundingBox, location)) {
            pickedCard = card;
        }
    }
    
    [self setAllCardsToProperBrightness];
    if (pickedCard != nil) {
        [self hideBigCard];
        [self showBigCard:pickedCard];
    }
    else {
        [self hideBigCard];
    }
}
- (void)setAllCardsToProperBrightness {
    for (Card *card in currentDeck) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
    for (Card *card in availableCards) {
        [self setCardToProperBrightness:card withDelay:YES];
    }
}
- (void)setCardToProperBrightness:(Card *)card withDelay:(BOOL)delay {
    int offset = 0;
    
    if (card == pickedCard) {
        if (delay)
            [card.thumbSprite runAction:[CCTintTo actionWithDuration:0.1 red:200-offset green:200-offset blue:200-offset]];
        else
            [card.thumbSprite setColor:ccc3(200-offset, 200-offset, 200-offset)];            
    }
    else {
        if (delay)
            [card.thumbSprite runAction:[CCTintTo actionWithDuration:0.1 red:255-offset green:255-offset blue:255-offset]];
        else
            [card.thumbSprite setColor:ccc3(255-offset, 255-offset, 255-offset)];
    }
}

- (BOOL)checkIfCard:(Card*)card belongsToDeck:(NSMutableArray*)deck {
    for (Card *deckCard in deck) {
        if (deckCard == card) {
            return YES;
        }
    }
    return NO;
}
- (void)moveCard:(Card*)card toDeck:(NSMutableArray*)deck {
    [self moveCard:card toDeck:deck atIndex:[deck count]];
}
- (void)moveCard:(Card*)card toDeck:(NSMutableArray*)deck atIndex:(int)index {
    if (deck == availableCards) {
        if ([availableCards containsObject:card]) {
            [card retain];
            [availableCards removeObject:card];
            [availableCards insertObject:card atIndex:index];
            [card release];
        }
        else {
            [availableCards insertObject:card atIndex:index];
            [currentDeck removeObject:card];
        }
    }
    else {
        if ([currentDeck containsObject:card]) {
            [card retain];
            [currentDeck removeObject:card];
            [currentDeck insertObject:card atIndex:index];
            [card release];
        }
        else {
            [currentDeck insertObject:card atIndex:index];
            [availableCards removeObject:card];
        }
    }
    [currentDeckLabel setString:[NSString stringWithFormat:@"Current Deck - %d Cards",[currentDeck count]]];
    [availableCardsLabel setString:[NSString stringWithFormat:@"Available - %d Cards",[availableCards count]]];
}
- (void)saveDecks {
    [profile.currentDeck removeAllObjects];
    for (Card *card in currentDeck)
        [profile.currentDeck addObject:card.name];
    
    [profile.availableCards removeAllObjects];
    for (Card *card in availableCards) {
        [profile.availableCards addObject:card.name];
    }
    
    if (profile.currentDeckIndex != -1) {
        NSLog(@"Current Deck Index is: %d",profile.currentDeckIndex);
        [profile.decks replaceObjectAtIndex:profile.currentDeckIndex withObject:profile.currentDeck];
    }
    
    [profile saveProfile];
}
- (void)sortDeck:(NSMutableArray*)deck {
    NSMutableArray *copyOfDeck = [deck copy];
    [deck removeAllObjects];
    
    // ARRAYS OF DIFFERENT RESOURCES
    NSMutableArray *resourceDecks = [[NSMutableArray alloc] init];
    for (Card *card in copyOfDeck) {
        NSMutableArray *deckForCard = nil;
        for (NSMutableArray *deck in resourceDecks) {
            if ([card.type isEqualToString:@"Resource"]) {
                if ([[[[[deck objectAtIndex:0] costs] objectAtIndex:0] type] isEqualToString:[[[card generatedResources] objectAtIndex:0] type]]) {
                    deckForCard = deck;
                }
            }
            else {
                if ([[[[[deck objectAtIndex:0] costs] objectAtIndex:0] type] isEqualToString:[[[card costs] objectAtIndex:0] type]]) {
                    deckForCard = deck;
                }
            }
        }
        if (deckForCard != nil) {
            [deckForCard addObject:card];
        }
        else {
            NSLog(@"Creating new deck");
            NSMutableArray *newDeck = [[NSMutableArray alloc] init];
            [newDeck addObject:card];
            [resourceDecks addObject:newDeck];
            [newDeck release];
        }
    }
    
    // SORT EACH INDIVIDUAL RESOURCE TYPE DECK BEFORE COMBINING THEM
    for (NSMutableArray *loopDeck in resourceDecks) {
        NSMutableArray *sortedDeck = [[NSMutableArray alloc] init];
        for (int i = 0; i < [loopDeck count]; i++) {
            Card *cardToBeSorted = [loopDeck objectAtIndex:i];
            if ([sortedDeck count] == 0) {
                [sortedDeck addObject:cardToBeSorted];
            }
            else {
                for (int j = 0; j < [sortedDeck count]; j++) {
                    Card *nextCard = [sortedDeck objectAtIndex:j];
                    if (nextCard.totalValue == cardToBeSorted.totalValue) {
                        NSComparisonResult result = [nextCard.name compare:cardToBeSorted.name];
                        if (result == NSOrderedDescending || result == NSOrderedSame) {
                            [sortedDeck insertObject:cardToBeSorted atIndex:j];
                            break;
                        }
                    }
                    else if ((nextCard.totalValue > cardToBeSorted.totalValue && ![cardToBeSorted.type isEqualToString:@"Resource"]) || [nextCard.type isEqualToString:@"Resource"]) {
                        [sortedDeck insertObject:cardToBeSorted atIndex:j];
                        break;
                    }
                    if (j == [sortedDeck count]-1) {
                        [sortedDeck addObject:cardToBeSorted];
                        break;
                    }
                }
            }
        }
        for (Card *card in sortedDeck) {
            [deck addObject:card];
        }
        [sortedDeck release];
    }
    [resourceDecks release];
    [copyOfDeck release];
}
- (void)moveCardToFrontOfHand:(Card *)card {
    Card* foundCard = nil;
    // AVAILABLE CARDS
    for (Card *loopCard in availableCards) {
        if (loopCard == card) {
            foundCard = loopCard;
        }
    }
    if (foundCard != nil) {
        int handIndex = [availableCards indexOfObject:foundCard];
        int handCount = [availableCards count];
        for (int i = handIndex; i < handCount-1; i++) {
            [availableCards exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
        [self reorderChild:foundCard.thumbSprite z:zOrder];
        zOrder++;
    }
    if ([availableCards count] != 0) {
        for (int i = 0; i < ([availableCards count]-1); i++) {
            Card *loopCard = [availableCards objectAtIndex:i];
            [self animateCardToProperLocation:loopCard];
        }
    }
    
    // CURRENT DECK
    for (Card *loopCard in currentDeck) {
        if (loopCard == card) {
            foundCard = loopCard;
        }
    }
    if (foundCard != nil) {
        int handIndex = [currentDeck indexOfObject:foundCard];
        int handCount = [currentDeck count];
        for (int i = handIndex; i < handCount-1; i++) {
            [currentDeck exchangeObjectAtIndex:i withObjectAtIndex:i+1];
        }
        [self reorderChild:foundCard.thumbSprite z:zOrder];
        zOrder++;
    }
    if ([currentDeck count] != 0) {
        for (int i = 0; i < ([currentDeck count]-1); i++) {
            Card *loopCard = [currentDeck objectAtIndex:i];
            [self animateCardToProperLocation:loopCard];
        }
    }
}
- (void)animateCardToProperLocation:(Card *)card {
    int targetX = 0;
    
    for (int i = 0; i < [availableCards count]; i++) {
        Card *loopCard = [availableCards objectAtIndex:i];
        if (loopCard == card) {
            targetX = 30 + i * CARD_SPACING - availableCardsOffset;
            [card.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:ccp(targetX,AVAILABLE_CARDS_Y)]];//[self makeScaledPointx:targetX y:AVAILABLE_CARDS_Y]]];
            [self reorderChild:card.thumbSprite z:i];
        }
    }
    
    for (int i = 0; i < [currentDeck count]; i++) {
        Card *loopCard = [currentDeck objectAtIndex:i];
        if (loopCard == card) {
            targetX = 30 + i * CARD_SPACING - currentDeckOffset;
            [card.thumbSprite runAction: [CCMoveTo actionWithDuration:0.2 position:ccp(targetX,CURRENT_DECK_Y)]];//[self makeScaledPointx:targetX y:CURRENT_DECK_Y]]];
            [self reorderChild:card.thumbSprite z:i];
        }
    }
}
- (void)animateAllCardsToProperLocation {
    for (Card *card in currentDeck) {
        [self animateCardToProperLocation:card];
    }
    for (Card *card in availableCards) {
        [self animateCardToProperLocation:card];
    }
}

- (void)showBigCard:(Card *)card {
    if (card.sprite == nil)
        card.sprite = [CCSprite spriteWithFile:card.imagePath];
    
    bigCard = [CardSprite node];
    bigCard.position = [self makeScaledPointx:BIG_CARDX y:BIG_CARDY];
    [bigCard setScale:1.0];
    [bigCard showStatsForCard:card];
    [self addChild:bigCard z:10000];
}
- (void)hideBigCard {
    if (bigCard != nil) {
        [self removeChild:bigCard cleanup:YES];
        bigCard = nil;
    }
}

@end
