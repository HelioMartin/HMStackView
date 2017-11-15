//
//  HMStackView.m
//  stack
//
//  Created by Oleg Musinov on 7/10/17.
//  Copyright © 2017 iBlacksus. All rights reserved.
//
// Modify by Helio Martín on 15/11/2017

#import "HMStackView.h"
#import "EXTScope.h"
#import "HMStackViewLayoutHelper.h"

static CGFloat const HMStackViewMinAlpha = .50;
static CGFloat const HMStackViewMinBackgroundWhite = .0;
static CGFloat const HMStackViewAnimationDurationDefault = .25;

@interface HMStackView ()

@property (copy, nonatomic) NSArray<UIViewController*> *views;
@property (strong, nonatomic) NSMutableDictionary *viewConstraints;
@property (copy, nonatomic) NSArray *gestures;
@property (assign, nonatomic) UIViewController *dontUpdateItem;

@end

@implementation HMStackView

#pragma mark - Accessors -

- (void)setSwipeDirections:(UISwipeGestureRecognizerDirection)swipeDirections {
    _swipeDirections = swipeDirections;
    
    NSMutableArray *gestures = [NSMutableArray array];
    
    if (swipeDirections & UISwipeGestureRecognizerDirectionLeft) {
        [gestures addObject:[self addSwipeWithDirection:UISwipeGestureRecognizerDirectionLeft]];
    }
    
    if (swipeDirections & UISwipeGestureRecognizerDirectionUp) {
        [gestures addObject:[self addSwipeWithDirection:UISwipeGestureRecognizerDirectionUp]];
    }
    
    if (swipeDirections & UISwipeGestureRecognizerDirectionRight) {
        [gestures addObject:[self addSwipeWithDirection:UISwipeGestureRecognizerDirectionRight]];
    }
    
    if (swipeDirections & UISwipeGestureRecognizerDirectionDown) {
        [gestures addObject:[self addSwipeWithDirection:UISwipeGestureRecognizerDirectionDown]];
    }
    
    self.gestures = gestures;
    
    [self enableGestures:self.views.count > 0];
}

#pragma mark - Life cycle -

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    
    return self;
}

#pragma mark - Initialization -

- (void)initialize {
    _viewConstraints = [NSMutableDictionary dictionary];
    _gestures = @[];
    _contraintsConfigurator = [[HMStackViewConstraints alloc] init];
    _animationDuration = HMStackViewAnimationDurationDefault;
}

#pragma mark - Public -

- (void)configureWithViews:(NSArray<UIViewController *> *)views {
    [self removeAllViews];
    
    self.views = views;
    
    [self enableGestures:views.count > 0];
    [self removeAllConstraints];
    
    NSInteger index = 0;
    for (UIViewController *vc in views) {
        vc.view.backgroundColor = [UIColor whiteColor];
        vc.view.layer.cornerRadius = 10.;
        vc.view.layer.masksToBounds = NO;
        vc.view.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
        vc.view.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        vc.view.layer.shadowRadius = 5.f;
        vc.view.layer.shadowOpacity = 1.0f;
        [vc.view setTranslatesAutoresizingMaskIntoConstraints:NO];
        vc.view.tag = index;
        [self addSubview:vc.view];
        [self sendSubviewToBack:vc.view];
        
        index++;
    }
    
    [self updateViews];
}

#pragma mark - Private -

- (void)removeAllViews {
    for (UIViewController *vc in self.views) {
        [vc.view removeFromSuperview];
    }
}

- (void)enableGestures:(BOOL)enable {
    for (UIGestureRecognizer *gesture in self.gestures) {
        gesture.enabled = enable;
    }
}

- (void)removeAllConstraints {
    for (NSArray *constraints in self.viewConstraints) {
        [self removeConstraints:constraints];
    }
}

- (UISwipeGestureRecognizer *)addSwipeWithDirection:(UISwipeGestureRecognizerDirection)direction {
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeGesture.direction = direction;
    [self addGestureRecognizer:swipeGesture];
    
    return swipeGesture;
}

- (void)updateViews {
    for (NSInteger i = 0; i < self.views.count; i++) {
        [self updateViewAtIndex:i];
    }
}

- (void)updateViewAtIndex:(NSInteger)index {
    if (index >= self.views.count) {
        return;
    }
    
    UIViewController *vc = self.views[index];
    if (self.dontUpdateItem == vc) {
        return;
    }
    
    NSArray *oldConstraints = self.viewConstraints[@(vc.view.tag)];
    vc.view.alpha = [self calculateAlphaForIndex:index];
    vc.view.backgroundColor = [UIColor colorWithWhite:[self calculateBackgroundWhiteForIndex:index] alpha:1.];
    
    NSArray *contraints = [self.contraintsConfigurator constraintsForView:vc.view index:index];
    [self removeConstraints:oldConstraints];
    [self addConstraints:contraints];
    self.viewConstraints[@(vc.view.tag)] = contraints;
}

- (CGFloat)calculateAlphaForIndex:(NSInteger)index {
    return (1. - HMStackViewMinAlpha) / self.views.count * (self.views.count - index) + HMStackViewMinAlpha;
}

- (CGFloat)calculateBackgroundWhiteForIndex:(NSInteger)index {
    return 1.0f; // (1. - HMStackViewMinBackgroundWhite) / self.views.count * (self.views.count - index) + HMStackViewMinBackgroundWhite;
}

- (void)sendView:(UIViewController *)vc direction:(UISwipeGestureRecognizerDirection)direction {
    NSMutableArray *constraints = [NSMutableArray arrayWithArray:self.viewConstraints[@(vc.view.tag)]];
    BOOL forward = [self isForwardDirection:direction];
    
    NSLayoutAttribute attribute = [HMStackViewLayoutHelper layoutAttributeForDirection:direction];
    NSLayoutAttribute invertAttribute = [HMStackViewLayoutHelper invertLayoutAttribute:attribute];
    BOOL isVertical = [HMStackViewLayoutHelper isVerticalAttribute:attribute];
    CGFloat x = isVertical ? CGRectGetHeight(self.frame) : CGRectGetWidth(self.frame);
    NSMutableArray *oldConstraints = [NSMutableArray array];
    CGFloat firstConstraint = 0.;
    CGFloat secondConstraint = 0.;
    
    for (NSLayoutConstraint *constraint in constraints) {
        if ([HMStackViewLayoutHelper isConstraint:constraint hasAttribute:attribute forItem:self]) {
            [oldConstraints addObject:constraint];
            firstConstraint = forward ? constraint.constant - x : constraint.constant + x;
            
        } else if ([HMStackViewLayoutHelper isConstraint:constraint hasAttribute:invertAttribute forItem:self]) {
            [oldConstraints addObject:constraint];
            secondConstraint = forward ? constraint.constant + x : constraint.constant - x;
        }
    }
    
    [self removeConstraints:oldConstraints];
    [constraints removeObjectsInArray:oldConstraints];
    NSArray *newConstraints = @[];
    
    if (isVertical) {
        CGFloat top = attribute == NSLayoutAttributeTop ? firstConstraint : secondConstraint;
        CGFloat bottom = attribute == NSLayoutAttributeBottom ? firstConstraint : secondConstraint;
        newConstraints = [self.contraintsConfigurator verticalConstraintsForView:vc.view top:top bottom:bottom];
    } else {
        CGFloat leading = attribute == NSLayoutAttributeLeading ? firstConstraint : secondConstraint;
        CGFloat trailing = attribute == NSLayoutAttributeTrailing ? firstConstraint : secondConstraint;
        newConstraints = [self.contraintsConfigurator horizontalConstraintsForView:vc.view leading:leading trailing:trailing];
    }
    
    [self addConstraints:newConstraints];
    [constraints addObjectsFromArray:newConstraints];
    self.viewConstraints[@(vc.view.tag)] = constraints;
}

- (void)sendViewAnimationCompletion:(UISwipeGestureRecognizerDirection)direction {
    self.dontUpdateItem = nil;
    BOOL forward = [self isForwardDirection:direction];
    UIViewController *vc = forward ? self.views.lastObject : self.views.firstObject;
    NSInteger index = forward ? self.views.count - 1 : 0;
    [self updateViewAtIndex:index];
    if (self.changeAlphaOnSendAnimation) {
        vc.view.alpha = 0.;
    }
    
    if (forward) {
        [self sendSubviewToBack:vc.view];
    } else {
        [self bringSubviewToFront:vc.view];
    }
    
    @weakify(self);
    [UIView animateWithDuration:self.animationDuration animations:^{
        @strongify(self);
        if (self.changeAlphaOnSendAnimation) {
            vc.view.alpha = [self calculateAlphaForIndex:index];
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(stackView:didSendItem:direction:)]) {
            HMStackViewItemDirection direction = forward ? HMStackViewItemDirectionBack : HMStackViewItemDirectionFront;
            [self.delegate stackView:self didSendItem:vc direction:direction];
        }
    }];
}

#pragma mark - Gestures -

- (void)checkDirections {
    if (self.forwardDirections == 0 && self.backwardDirections == 0) {
        self.forwardDirections = self.swipeDirections;
    }
}

- (BOOL)isForwardDirection:(UISwipeGestureRecognizerDirection)direction {
    return direction & self.forwardDirections;
}

- (void)swipe:(UISwipeGestureRecognizer *)gesture {
    [self checkDirections];
    BOOL forward = [self isForwardDirection:gesture.direction];
    UIViewController *vc = forward ? self.views.firstObject : self.views.lastObject;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(stackView:willSendItem:direction:)]) {
        HMStackViewItemDirection direction = forward ? HMStackViewItemDirectionBack : HMStackViewItemDirectionFront;
        [self.delegate stackView:self willSendItem:vc direction:direction];
    }
    
    [self sendView:vc direction:gesture.direction];
    
    NSMutableArray *views = self.views.mutableCopy;
    [views removeObject:vc];
    if (forward) {
        [views addObject:vc];
    } else {
        [views insertObject:vc atIndex:0];
    }
    
    self.views = views;
    
    self.dontUpdateItem = vc;
    [self updateViews];
    
    @weakify(self);
    [UIView animateWithDuration:self.animationDuration animations:^{
        @strongify(self);
        if (self.changeAlphaOnSendAnimation) {
            vc.view.alpha = 0.;
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        @strongify(self);
        [self sendViewAnimationCompletion:gesture.direction];
    }];
}

@end
