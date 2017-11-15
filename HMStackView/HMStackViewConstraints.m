//
//  HMStackViewConstraints.m
//  stack
//
//  Created by Oleg Musinov on 7/11/17.
//  Copyright © 2017 iBlacksus. All rights reserved.
//
// Modify by Helio Martín on 15/11/2017

#import "HMStackViewConstraints.h"

static CGFloat const HMStackViewConstraintsLeadingDefault = 40.;
static CGFloat const HMStackViewConstraintsTrailingDefault = 40.;
static CGFloat const HMStackViewConstraintsTopDefault = 100.;
static CGFloat const HMStackViewConstraintsBottomDefault = 140.;
static CGFloat const HMStackViewConstraintsCompressionHorizontalDefault = 10.;
static CGFloat const HMStackViewConstraintsCompressionVerticalDefault = 10.;

@implementation HMStackViewConstraints

- (instancetype)init {
    if (self = [super init]) {
        _leading = HMStackViewConstraintsLeadingDefault;
        _trailing = HMStackViewConstraintsTrailingDefault;
        _top = HMStackViewConstraintsTopDefault;
        _bottom = HMStackViewConstraintsBottomDefault;
        _verticalCompression = HMStackViewConstraintsCompressionVerticalDefault;
        _horizontalCompression = HMStackViewConstraintsCompressionHorizontalDefault;
    }
    
    return self;
}

- (NSArray *)constraintsForView:(UIView *)view index:(NSInteger)index {
    NSMutableArray *contraints = [NSMutableArray array];
    [contraints addObjectsFromArray:[self horizontalConstraintsForView:view index:index]];
    [contraints addObjectsFromArray:[self verticalConstraintsForView:view index:index]];
    
    return contraints;
}

- (NSArray *)horizontalConstraintsForView:(UIView *)view index:(NSInteger)index {
    CGFloat leading = self.leading + self.horizontalCompression * index;
    CGFloat trailing = self.trailing + self.horizontalCompression * index;
    
    return [self horizontalConstraintsForView:view leading:leading trailing:trailing];
}

- (NSArray *)horizontalConstraintsForView:(UIView *)view leading:(CGFloat)leading trailing:(CGFloat)trailing {
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    NSString *format = [NSString stringWithFormat:@"H:|-(%.f)-[view]-(%.f)-|", leading, trailing];
    
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
}

- (NSArray *)verticalConstraintsForView:(UIView *)view index:(NSInteger)index {
    CGFloat top = self.top - self.verticalCompression * index;
    CGFloat bottom = self.bottom + self.verticalCompression * index;
    
    return [self verticalConstraintsForView:view top:top bottom:bottom];
}

- (NSArray *)verticalConstraintsForView:(UIView *)view top:(CGFloat)top bottom:(CGFloat)bottom {
    NSDictionary *views = NSDictionaryOfVariableBindings(view);
    NSString *format = [NSString stringWithFormat:@"V:|-(%.f)-[view]-(%.f)-|", top, bottom];
    
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
}

@end
