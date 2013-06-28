//
//  MyStoreObserver.h
//  Teamopolis
//
//  Created by Stephen Mashalidis on 12-02-13.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface MyStoreObserver : NSObject <SKPaymentTransactionObserver>

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void)failedTransaction: (SKPaymentTransaction *)transaction;
- (void)restoreTransaction: (SKPaymentTransaction *)transaction;
- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void)provideContent:(NSString *)productIdentifier;

@end
