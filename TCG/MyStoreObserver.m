//
//  MyStoreObserver.m
//  Teamopolis
//
//  Created by Stephen Mashalidis on 12-02-13.
//  Copyright (c) 2012 Smashware. All rights reserved.
//

#import "MyStoreObserver.h"
#import "SimpleAudioEngine.h"
#import "Profile.h"

@implementation MyStoreObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
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

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Transaction Completed");
    // Your application should implement these two methods.
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Restore Completed");
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"Failed Transaction");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Store Error" message:[NSString stringWithFormat:@"There was an error with the transaction, please try again."] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        [alert release];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)recordTransaction: (SKPaymentTransaction *)transaction {
    
}

- (void)provideContent:(NSString *)productIdentifier {
    Profile *profile = [Profile sharedProfile];
    
    if ([productIdentifier isEqualToString:@"US200"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        profile.coins += 200;
    }
    else if ([productIdentifier isEqualToString:@"US600"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        profile.coins += 600;
    }
    else if ([productIdentifier isEqualToString:@"US2000"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        profile.coins += 2000;
    }
    else if ([productIdentifier isEqualToString:@"US5000"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        profile.coins += 5000;
    }
    else if ([productIdentifier isEqualToString:@"CoinMultiplier"]) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"coins.wav"];
        profile.coinMultiplier = YES;
    }
    
    [profile saveProfile];
}

@end
