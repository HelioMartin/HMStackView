//
//  HMStackViewProtocol.h
//  stack
//
//  Created by Oleg Musinov on 7/11/17.
//  Copyright © 2017 iBlacksus. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HMStackView;

typedef NS_ENUM(NSInteger, HMStackViewItemDirection) {
    HMStackViewItemDirectionBack,
    HMStackViewItemDirectionFront
};

@protocol HMStackViewProtocol <NSObject>
@optional

- (void)stackView:(HMStackView *)stackView willSendItem:(UIViewController *)item direction:(HMStackViewItemDirection)direction;
- (void)stackView:(HMStackView *)stackView didSendItem:(UIViewController *)item direction:(HMStackViewItemDirection)direction;

@end
