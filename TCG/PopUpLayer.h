//
//  PopUpLayer.h
//  TCG
//
//  Created by Stephen Mashalidis on 12-07-02.
//  Copyright 2012 Smashware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "BaseLayer.h"

@interface PopUpLayer : BaseLayer {
    int index;
    NSString *name;
    NSMutableArray *pages;
    CCSprite *tutorialImage;
    CCSprite *nextButton;
    CCSprite *backButton;
}

- (void)showGameQuitMenu;
- (void)showDisconnectPopUp;
- (void)showVersionPopUp;
- (BOOL)showAbilityPopUp:(NSString*)abilityPath;
- (void)showTutorialPopUp:(NSString*)popUp;
- (void)showPopUpWithText:(NSString *)text;
- (void)showYesNoPopUpWithText:(NSString*)text;
- (void)showNewPatchPopup;
- (void)showNoMatchPopup;

@end
