//
//  MenuLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-02-25.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BaseLayer.h"

@interface MenuLayer : BaseLayer {
}

+(CCScene *) scene;
+(CCScene *) sceneWithAnimation:(BOOL)animation;

- (void)showMenuWithAnimation:(BOOL)animation;
- (void)switchToMenu:(NSString*)menu;


@end
