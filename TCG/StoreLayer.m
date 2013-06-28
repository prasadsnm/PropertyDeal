//
//  StoreLayer.m
//  TCG
//
//  Created by Stephen Mashalidis on 12-07-22.
//  Copyright 2012 Smashware. All rights reserved.
//

#import "StoreLayer.h"
#import "MenuLayer.h"
#import "Profile.h"
#import "CardFactory.h"
#import "CardSprite.h"
#import <StoreKit/StoreKit.h>

#define BIG_CARDX 365
#define BIG_CARDY 142

@implementation StoreLayer

Card *pickedCard;
CCSprite *menuButton;
CCSprite *buyButton;
CCSprite *ownedBanner;
CCSprite *coinMultiplier;
CCSprite *restorePurchases;
CardSprite *bigCard;
CCLabelTTF *infoLabel;
CCLabelTTF *infoSubLabel;
CCLabelTTF *coinsLabel;
CCSprite *processingTransaction;
CCSprite *okButton;
CCSprite *goldTitle;
CCSprite *gold;
CCSprite *gold2;
CCSprite *gold3;
CCSprite *gold4;
NSMutableArray *packCards;
BOOL processing;

+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	StoreLayer *layer = [StoreLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

CCScrollLayer *scroller;
int lastScrolledLayer;

-(id) init {
	if( (self=[super init])) {
        buttons = [[NSMutableArray alloc] init];
        packCards = [[NSMutableArray alloc] init];
        
        // SET BACKGROUND
        CCSprite *background = [CCSprite spriteWithFile: @"PaperBackground.png"];
        [background setPosition:[self makeScaledPointx:240 y:160]];
        [self addChild:background z:-1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            //[background setScale:1.2];
        }
        
        SimpleAudioEngine *audioEngine = [SimpleAudioEngine sharedEngine];
        [audioEngine playBackgroundMusic:@"StoreMusic.mp3" loop:YES];
        [audioEngine setBackgroundMusicVolume:BACKGROUND_VOLUME];
        
        CCSprite *toolbar = [CCSprite spriteWithFile:@"UltimateStoreToolbar.png"];
        [toolbar setPosition:[self makeScaledPointx:240 y:304]];
        [self addChild:toolbar z:10000];
        
        menuButton = [CCSprite spriteWithFile: @"ToolBarBack.png"];
        [menuButton setPosition:[self makeScaledPointx:40 y:303]];
        menuButton.tag = 1;
        [buttons addObject:menuButton];
        [self addChild:menuButton z:10001];
        
        buyButton = [CCSprite spriteWithFile:@"CostBadge100.png"];
        [buyButton setPosition:[self makeScaledPointx:450 y:25]];
        buyButton.tag = 2;
        [buttons addObject:buyButton];
        [self addChild:buyButton z:10000];
        
        ownedBanner = [CCSprite spriteWithFile:@"OwnedBanner.png"];
        [ownedBanner setPosition:[self makeScaledPointx:440 y:50]];
        ownedBanner.visible = NO;
        [self addChild:ownedBanner z:10000];
        
        // Set up the swipe-able layers
        NSMutableArray *layers = [[NSMutableArray alloc] init];
        
        CCLayer *layer = [CCLayer node];
        CCSprite *deck = [CCSprite spriteWithFile:@"IntroBooster.png"];
        [layer addChild:deck];
        [deck setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        layer = [CCLayer node];
        deck = [CCSprite spriteWithFile:@"MedievalRobotsStore.png"];
        [layer addChild:deck];
        [deck setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        layer = [CCLayer node];
        deck = [CCSprite spriteWithFile:@"ZombieOutbreakStore.png"];
        [layer addChild:deck];
        [deck setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        layer = [CCLayer node];
        deck = [CCSprite spriteWithFile:@"MonkeyPiratesStore.png"];
        [layer addChild:deck];
        [deck setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        layer = [CCLayer node];
        coinMultiplier = [CCSprite spriteWithFile:@"CoinMultiplier.png"];
        [layer addChild:coinMultiplier];
        [coinMultiplier setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        layer = [CCLayer node];
        goldTitle = [CCSprite spriteWithFile:@"BuyGold.png"];
        [layer addChild:goldTitle];
        [goldTitle setPosition:[self makeScaledPointx:250 y:250]];
        
        gold = [CCSprite spriteWithFile:@"BuyGold200.png"];
        [gold setPosition:[self makeScaledPointx:140 y:155]];
        gold.tag = 4;
        [layer addChild:gold];
        
        gold2 = [CCSprite spriteWithFile:@"BuyGold600.png"];
        [gold2 setPosition:[self makeScaledPointx:345 y:155]];
        gold2.tag = 5;
        [layer addChild:gold2];
        
        gold3 = [CCSprite spriteWithFile:@"BuyGold2000.png"];
        [gold3 setPosition:[self makeScaledPointx:140 y:50]];
        gold3.tag = 6;
        [layer addChild:gold3];
        
        gold4 = [CCSprite spriteWithFile:@"BuyGold5000.png"];
        [gold4 setPosition:[self makeScaledPointx:345 y:50]];
        gold4.tag = 7;
        [layer addChild:gold4];
        
        processingTransaction = [CCSprite spriteWithFile:@"ProcessingTransaction.png"];
        processingTransaction.opacity = 0;
        [processingTransaction setPosition:[self makeScaledPointx:240 y:155]];
        [self addChild:processingTransaction z:1000];
        processing = NO;
        
        [layers addObject:layer];
        
        layer = [CCLayer node];
        restorePurchases = [CCSprite spriteWithFile:@"RestorePurchases.png"];
        [layer addChild:restorePurchases];
        [restorePurchases setPosition:[self makeScaledPointx:240 y:160]];
        [layers addObject:layer];
        
        scroller = [[CCScrollLayer alloc] initWithLayers:layers
                                                            widthOffset:0];
        [self addChild:scroller];
        scroller.position = [self makeScaledPointx:0 y:0];
        [scroller setShowPagesIndicator:NO];
        [scroller release];
        [layers release];
        
        CCSprite *toolbarCoins = [CCSprite spriteWithFile: @"ToolbarCoins.png"];
        [toolbarCoins setPosition:[self makeShiftedPointx:460 y:303]];
        //toolbarCoins.tag = 1;
        [self addChild:toolbarCoins z:10001];
        
        coinsLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",[[Profile sharedProfile] coins]]  dimensions:CGSizeMake(70, 50) alignment:UITextAlignmentRight fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:20]];
        coinsLabel.color = ccc3(176, 121, 31);
        [coinsLabel setPosition:[self makeShiftedPointx:407 y:289]];
        [self addChild:coinsLabel z:10002];
        
        [self scheduleUpdateWithPriority:0];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)dealloc {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [packCards release];
    [super dealloc];
}

- (void)update:(ccTime)deltaTime {
    if ([scroller currentScreen] != lastScrolledLayer) {
        [buyButton setVisible:YES];
        [ownedBanner setVisible:NO];
        
        if (![buttons containsObject:buyButton]) {
            [buttons addObject:buyButton];
            [buttons removeObject:gold];
            [buttons removeObject:gold2];
            [buttons removeObject:gold3];
            [buttons removeObject:gold4];
        }
        lastScrolledLayer = [scroller currentScreen];
        if ([scroller currentScreen] == 1)
            [buyButton setTexture:[[CCTextureCache sharedTextureCache] addImage:@"CostBadge100.png"]];
        else if ([scroller currentScreen] == 5) {
            if ([Profile sharedProfile].coinMultiplier == NO)
                [buyButton setTexture:[[CCTextureCache sharedTextureCache] addImage:@"199Badge.png"]];
            else {
                [buyButton setVisible:NO];
                [ownedBanner setVisible:YES];
            }
        }
        else if ([scroller currentScreen] == 6) {
            [buyButton setVisible:NO];
            [buttons removeObject:buyButton];
            [buttons addObject:gold];
            [buttons addObject:gold2];
            [buttons addObject:gold3];
            [buttons addObject:gold4];
        }
        else if ([scroller currentScreen] == 7)
            [buyButton setTexture:[[CCTextureCache sharedTextureCache] addImage:@"OkBadge.png"]];
        else
            [buyButton setTexture:[[CCTextureCache sharedTextureCache] addImage:@"CostBadge.png"]];
    }
    
    if ([coinsLabel.string intValue] != [[Profile sharedProfile] coins]) {
        if ([coinsLabel.string intValue] < [[Profile sharedProfile] coins])
            coinsLabel.string = [NSString stringWithFormat:@"%d",[coinsLabel.string intValue]+10];
        else
            coinsLabel.string = [NSString stringWithFormat:@"%d",[coinsLabel.string intValue]-10];
    }
}
- (void)buyPack {
    Profile *profile = [Profile sharedProfile];
    
    if (profile.coins < 100) {
        [scroller moveToPage:6];
    }
    else {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        for (CCLayer *layer in scroller.children) {
            for (CCSprite *sprite in layer.children) 
                [sprite runAction:[CCFadeOut actionWithDuration:0.2]];
        }
        [buyButton runAction:[CCFadeOut actionWithDuration:0.2]];
        [buttons removeObject:buyButton];
        NSLog(@"%d",[buttons count]);
        
        CardFactory *factory = [[CardFactory alloc] init];
        
        NSArray *cardNames;
        
        BOOL createNewDeck = NO;
        if (scroller.currentScreen == 1) {
            profile.coins -= 100;
            cardNames = [factory spawnDeck:@"Intro Booster"];
        }
        else if (scroller.currentScreen == 2) {
            profile.coins -= 200;
            cardNames = [factory spawnDeck:@"Robot Starter"];
            createNewDeck = YES;
        }
        else if (scroller.currentScreen == 3) {
            profile.coins -= 200;
            cardNames = [factory spawnDeck:@"Zombie Starter"];
            createNewDeck = YES;
        }
        else if (scroller.currentScreen == 4) {
            profile.coins -= 200;
            cardNames = [factory spawnDeck:@"Monkey Starter"];
            createNewDeck = YES;
        }
        
        NSLog(@"About to add card");
        for (NSString *name in cardNames) {
            [packCards addObject:[factory spawnCard:name]];
        }
        NSLog(@"Card just added");
        if (createNewDeck) {
            NSMutableArray *newDeck = [[NSMutableArray alloc] init];
            
            for (Card *card in packCards) {
                [newDeck addObject:card.name];
            }
            [profile.decks addObject:newDeck];
            [newDeck release];
            [profile saveProfile];
        }
        else {
            for (Card *card in packCards) {
                [profile.availableCards addObject:card.name];
            }
        }
        [profile saveProfile];
            
        int x = 40;
        int y = 232;
        float delay = 0.4;
        for (int i = 0; i < [packCards count]; i++) {
            Card *card = [packCards objectAtIndex:i];
            //card.sprite = [CCSprite spriteWithFile:card.imagePath];
            card.thumbSprite = [CCSprite spriteWithFile:[card getThumbPath]];
            card.thumbSprite.position = [self makeScaledPointx:x y:y-[self makeScaledInt:10]];
            card.thumbSprite.opacity = 0;
            [self addChild:card.thumbSprite];
            [card.thumbSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay],[CCSpawn actions:[CCFadeIn actionWithDuration:0.3],[CCMoveBy actionWithDuration:0.3 position:[self makeScaledPointx:0 y:10]], nil], nil]];
            [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay],[CCCallFunc actionWithTarget:self selector:@selector(hideBigCard)],[CCCallFuncND actionWithTarget:self selector:@selector(cocosPlaySoundWithName:data:) data:@"card.wav"], nil]];
            delay += 0.3;
            if (i+1 < [packCards count]) {
                Card *nextCard = [packCards objectAtIndex:i+1];
                if (![nextCard.name isEqualToString:card.name] || !createNewDeck) {
                    x += 60;
                    if (x > 220) {
                        x = 40;
                        y -= 88;
                    }
                }
            }
        }
        
        infoLabel = [CCLabelTTF labelWithString:@"Pack purchased!" fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:25]];
        [infoLabel setPosition:[self makeScaledPointx:373 y:240]];
        [infoLabel setColor:ccBLACK];
        [infoLabel setOpacity:0];
        [self addChild:infoLabel];
        [infoLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay+0.4],[CCFadeIn actionWithDuration:0.4], nil]];
        
        infoSubLabel = [CCLabelTTF labelWithString:@"(select a card to view it)" fontName:@"Badaboom.ttf" fontSize:[self makeScaledInt:20]];
        [infoSubLabel setPosition:[self makeScaledPointx:370 y:220]];
        [infoSubLabel setColor:ccBLACK];
        [infoSubLabel setOpacity:0];
        [self addChild:infoSubLabel];
        [infoSubLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay+0.4],[CCFadeIn actionWithDuration:0.4], nil]];
        
        okButton = [CCSprite spriteWithFile:@"OkBadge.png"];
        [okButton setPosition:[self makeScaledPointx:450 y:25]];
        okButton.tag = 3;
        [okButton setOpacity:0];
        [self addChild:okButton z:10000];
        [okButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:delay+0.4],[CCFadeIn actionWithDuration:0.4],[CCCallFunc actionWithTarget:self selector:@selector(cocosOKButtonActivation)], nil]];
        
        [factory release];
    }
}
- (void)showProcessing {
    processing = YES;
    [processingTransaction runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.6],[CCFadeIn actionWithDuration:0.4], nil]];
    [goldTitle runAction:[CCFadeOut actionWithDuration:0.4]];
    [gold runAction:[CCFadeOut actionWithDuration:0.4]];
    [gold2 runAction:[CCFadeOut actionWithDuration:0.4]];
    [gold3 runAction:[CCFadeOut actionWithDuration:0.4]];
    [gold4 runAction:[CCFadeOut actionWithDuration:0.4]];
    [buyButton runAction:[CCFadeOut actionWithDuration:0.4]];
    [coinMultiplier runAction:[CCFadeOut actionWithDuration:0.4]];
    [restorePurchases runAction:[CCFadeOut actionWithDuration:0.4]];
    [ownedBanner runAction:[CCFadeOut actionWithDuration:0.4]];
}
- (void)showGoldButtons {
    if ([scroller currentScreen] == 5) {
        if ([Profile sharedProfile].coinMultiplier == YES) {
            [ownedBanner setVisible:YES];
            [buyButton setVisible:NO];
            [ownedBanner runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
        }
    }
    
    [processingTransaction stopAllActions];
    [processingTransaction runAction:[CCFadeOut actionWithDuration:0.2]];
    [goldTitle runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [gold runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [gold2 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [gold3 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [gold4 runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [buyButton runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [coinMultiplier runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [restorePurchases runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];
    [ownedBanner runAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.2],[CCFadeIn actionWithDuration:0.4], nil]];

    processing = NO;
}
- (void)hideBoughtCards {
    [[SimpleAudioEngine sharedEngine] playEffect:@"select.wav" pitch:0.5 pan:1.0 gain:0.5];
    for (CCLayer *layer in scroller.children) {
        for (CCSprite *sprite in layer.children) {
            if (sprite != processingTransaction)
                [sprite runAction:[CCFadeIn actionWithDuration:0.4]];
        }
    }
    for (int i = 0; i < [packCards count]; i++) {
        Card *card = [packCards objectAtIndex:i];
        [card.thumbSprite runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.4 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
    }
    [packCards removeAllObjects];
    [infoLabel runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.4 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
    [infoSubLabel runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.4 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
    [okButton runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.4 opacity:0],[CCCallFuncN actionWithTarget:self selector:@selector(cocosRemoveSprite:)], nil]];
    [buttons removeObject:okButton];
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:1.0],[CCCallFunc actionWithTarget:self selector:@selector(cocosBuyButtonActivation)], nil]];
}
- (void)actionForButton:(CCSprite*)button {
    if (button.tag == 1) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MenuLayer sceneWithAnimation:NO]]];
    }
    else if (button.tag == 2) {
        if (scroller.currentScreen == 5) {
            if ([Profile sharedProfile].coinMultiplier == YES)
                return;
            
            SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"CoinMultiplier"];
            [[SKPaymentQueue defaultQueue] addPayment:payment];
            [self showProcessing];
        }
        else if (scroller.currentScreen == 7) {
            [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            [self showProcessing];
        }
        else
            [self buyPack];
    }
    else if (button.tag == 3) {
        [self hideBoughtCards];
    }
    else if (button.tag == 4) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"US200"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showProcessing];
    }
    else if (button.tag == 5) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"US600"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showProcessing];
    }
    else if (button.tag == 6) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"US2000"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showProcessing];
    }
    else if (button.tag == 7) {
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"US5000"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        [self showProcessing];
    }
}

- (void)selectCardAtLocation:(CGPoint)location {
    pickedCard = nil;
    for (Card *card in packCards) {
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
    for (Card *card in packCards) {
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

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace: touch];
    [self touchStartedForButtonAtLocation:location];
    [self selectCardAtLocation:location];
    return YES;
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
- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    [self showGoldButtons];
}
- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    [self showGoldButtons];
}
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            case SKPaymentTransactionStatePurchasing:
            default:
                break;
        }
    }
}
- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    [self showGoldButtons];
}
- (void)recordTransaction: (SKPaymentTransaction *)transaction {
}
- (void)provideContent:(NSString *)productIdentifier {
}
- (void)cocosShowBigCard:(id)sender data:(Card*)card {
    [self showBigCard:card];
}
- (void)cocosBuyButtonActivation {
    [buyButton runAction:[CCFadeIn actionWithDuration:0.4]];
    [buttons addObject:buyButton];
}
- (void)cocosOKButtonActivation {
    [buttons addObject:okButton];
}

@end
