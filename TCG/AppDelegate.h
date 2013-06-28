//
//  AppDelegate.h
//  TCG
//
//  Created by Stephen Mashalidis on 11-12-03.
//  Copyright Smashware 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate,SKProductsRequestDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RootViewController *viewController;


@end
