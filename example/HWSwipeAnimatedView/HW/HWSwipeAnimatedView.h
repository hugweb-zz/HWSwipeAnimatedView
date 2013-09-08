//
//  HWSwipeAnimatedView.h
//
//  Created by Hugues Blocher on 03/09/13.
//  Copyright (c) 2013 Hugues Blocher. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HWSwipeAnimatedView;

#pragma ENUM
typedef NS_ENUM (NSUInteger, HWSwipeAnimatedViewState){
    HWSwipeAnimatedViewStateNone = 0,
    HWSwipeAnimatedViewStateLeft,
    HWSwipeAnimatedViewStateRight
};

typedef NS_ENUM (NSUInteger, HWSwipeAnimatedViewDirection){
    HWSwipeAnimatedViewDirectionLeft = 0,
    HWSwipeAnimatedViewDirectionCenter,
    HWSwipeAnimatedViewDirectionRight
};

typedef NS_ENUM (NSUInteger, HWSwipeAnimatedViewMode){
    HWSwipeAnimatedViewModeExit = 0,
    HWSwipeAnimatedViewModeBounce
};

typedef NS_ENUM (NSUInteger, HWSwipeAnimatedViewExitMode){
    HWSwipeAnimatedViewExitModeLeft = 0,
    HWSwipeAnimatedViewExitModeRight,
    HWSwipeAnimatedViewExitModeTop,
    HWSwipeAnimatedViewExitModeBottom,
    HWSwipeAnimatedViewExitModeHorizontalCenter,
    HWSwipeAnimatedViewExitModeVerticalCenter
};

#pragma Protocol
@protocol HWSwipeAnimatedViewDelegate <NSObject>

@optional
- (void)swipeAnimatedView:(HWSwipeAnimatedView *)view didTriggerState:(HWSwipeAnimatedViewState)state withMode:(HWSwipeAnimatedViewMode)mode withExitModeLeft:(HWSwipeAnimatedViewExitMode)exitModeLeft withExitModeRight:(HWSwipeAnimatedViewExitMode)exitModeRight;
@end


#pragma Interface
@interface HWSwipeAnimatedView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id <HWSwipeAnimatedViewDelegate> delegate;

@property (nonatomic, copy) NSString *leftImage;
@property (nonatomic, copy) NSString *rightImage;

@property (nonatomic, copy) UIImageView *leftIcon;
@property (nonatomic, copy) UIImageView *rightIcon;

@property (nonatomic, strong) UIColor *leftColor;
@property (nonatomic, strong) UIColor *rightColor;

@property (nonatomic, assign) HWSwipeAnimatedViewDirection direction;
@property (nonatomic, assign) HWSwipeAnimatedViewMode mode;
@property (nonatomic, assign) HWSwipeAnimatedViewExitMode exitModeLeft;
@property (nonatomic, assign) HWSwipeAnimatedViewExitMode exitModeRight;
@property (nonatomic, assign) CGFloat currentPercentage;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) BOOL shouldDrag;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *slidingImageView;
@property (nonatomic, strong) NSString *currentImageName;
@property (nonatomic, strong) UIView *colorIndicatorView;
@property (nonatomic, strong) UIView *slideView;
@property (nonatomic, strong) UILabel *stateTitle;
@property (nonatomic, assign) BOOL indicator;

@property (nonatomic, strong) NSString *stateLeftText;
@property (nonatomic, strong) NSString *stateRightText;

// Init
- (id)initWithFrame:(CGRect)frame leftImage:(NSString *)leftImage leftColor:(UIColor *)leftColor rightImage:(NSString *)rightImage rightColor:(UIColor *)rightColor;
- (void)setup;

// Setter
- (void)setLeftImage:(NSString *)leftImage leftColor:(UIColor *)leftColor rightImage:(NSString *)rightImage rightColor:(UIColor *)rightColor;
- (void)setSlideViewBackgroundColor:(UIColor *)color;
- (void)setStateLabelTextColor:(UIColor *)color;
- (void)setTextStateIndicator:(BOOL)active;
- (void)setLeftIconImage:(NSString *)image;
- (void)setRightIconImage:(NSString *)image;

// Handle Gestures
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture;

// Utils
- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width;
- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width;
- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity;
- (HWSwipeAnimatedViewDirection)directionWithPercentage:(CGFloat)percentage;
- (NSString *)imageNameWithPercentage:(CGFloat)percentage;
- (UIColor *)colorWithPercentage:(CGFloat)percentage;
- (HWSwipeAnimatedViewState)stateWithPercentage:(CGFloat)percentage;
- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage;
- (BOOL)validateState:(HWSwipeAnimatedViewState)state;

// Movement
- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging;
- (void)animateWithOffset:(CGFloat)offset;
- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(HWSwipeAnimatedViewDirection)direction;
- (void)bounceToOrigin;
- (void)exitWithMode:(HWSwipeAnimatedViewExitMode)exitMode;

// Delegate
- (void)notifyDelegate;

@end
