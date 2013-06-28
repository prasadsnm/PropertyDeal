//
//  StoreLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-07-22.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BaseLayer.h"
#import "CCScrollLayer.h"
#import <StoreKit/StoreKit.h>

@interface StoreLayer : BaseLayer <SKPaymentTransactionObserver> {
    
}

+(CCScene *) scene;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void)restoreTransaction: (SKPaymentTransaction *)transaction;
- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

@end
