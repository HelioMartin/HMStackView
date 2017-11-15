//
//  BSStackView.h
//  stack
//
//  Created by Oleg Musinov on 7/10/17.
//  Copyright © 2017 iBlacksus. All rights reserved.
//
// Modify by Helio Martín on 15/11/2017

#import <UIKit/UIKit.h>
#import "HMStackViewConstraints.h"
#import "HMStackViewProtocol.h"

@interface HMStackView : UIView

@property (assign, nonatomic) UISwipeGestureRecognizerDirection swipeDirections;
@property (assign, nonatomic) UISwipeGestureRecognizerDirection forwardDirections;
@property (assign, nonatomic) UISwipeGestureRecognizerDirection backwardDirections;
@property (strong, nonatomic, readonly) HMStackViewConstraints *contraintsConfigurator;
@property (assign, nonatomic) CGFloat animationDuration;
@property (assign, nonatomic) BOOL changeAlphaOnSendAnimation;
@property (weak, nonatomic) id<HMStackViewProtocol> delegate;

- (void)configureWithViews:(NSArray<UIViewController *> *)views;

- (void)swipe:(UISwipeGestureRecognizer *)gesture;

@end
