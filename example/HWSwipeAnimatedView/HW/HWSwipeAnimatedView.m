//
//  HWSwipeAnimatedView.m
//
//  Created by Hugues Blocher on 03/09/13.
//  Copyright (c) 2013 Hugues Blocher. All rights reserved.
//

#import "HWSwipeAnimatedView.h"

#pragma Constants

#define kHWViewStop 0.50 // Limit to trigger action
#define kHWBounceDuration 0.2 // Bounce animation duration
#define kHWDurationLowLimit 0.25 // Lowest swipping duration
#define kHWDurationHightLimit 0.1 // Highest swipping duration
#define kHWBounceAmplitude 20.0 // Bounce amplitude

#define kHWWidthIcon 60 // Icon width
#define kHWHeightIcon 60 // Icon height

@implementation HWSwipeAnimatedView

#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Custom Initialization
-(id)initWithFrame:(CGRect)frame leftImage:(NSString *)leftImage leftColor:(UIColor *)leftColor rightImage:(NSString *)rightImage rightColor:(UIColor *)rightColor {
    self = [self initWithFrame:frame];
    if (self) {
        [self setLeftImage:leftImage leftColor:leftColor rightImage:rightImage rightColor:rightColor];
    }
    return self;
}
- (void)setup {
    _mode = HWSwipeAnimatedViewModeBounce;
    _exitModeLeft = HWSwipeAnimatedViewExitModeLeft;
    _exitModeRight = HWSwipeAnimatedViewExitModeRight;
    
    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:_colorIndicatorView];
    
    _stateTitle = [[UILabel alloc] initWithFrame:_colorIndicatorView.frame];
    [_stateTitle setTextColor:[UIColor whiteColor]];
    [_stateTitle setBackgroundColor:[UIColor clearColor]];
    [_stateTitle setTextAlignment:NSTextAlignmentCenter];
    [_colorIndicatorView addSubview:_stateTitle];
    
    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];
    
    _slideView = [[UIView alloc] initWithFrame:self.bounds];
    [_slideView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self addSubview:_slideView];
    
    _leftIcon = [[UIImageView alloc] init];
    [_leftIcon setContentMode:UIViewContentModeCenter];
    [_leftIcon setFrame:CGRectMake((self.bounds.size.width / 4) - (kHWWidthIcon / 2), (self.bounds.size.height / 2) - (kHWHeightIcon / 2), kHWWidthIcon, kHWHeightIcon)];
    [_slideView addSubview:_leftIcon];
    
    _rightIcon = [[UIImageView alloc] init];
    [_rightIcon setContentMode:UIViewContentModeCenter];
    [_rightIcon setFrame:CGRectMake(((self.bounds.size.width / 4) * 3) - (kHWWidthIcon / 2), (self.bounds.size.height / 2) - (kHWHeightIcon / 2), kHWWidthIcon, kHWHeightIcon)];
    [_slideView addSubview:_rightIcon];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [_slideView addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
    
    _isDragging = NO;
    _shouldDrag = YES;
    _indicator = YES;
}


#pragma mark - Setter
- (void)setLeftImage:(NSString *)leftImage leftColor:(UIColor *)leftColor rightImage:(NSString *)rightImage rightColor:(UIColor *)rightColor {
    [self setLeftImage:leftImage];
    [self setLeftColor:leftColor];
    [self setRightImage:rightImage];
    [self setRightColor:rightColor];
}
-(void)setSlideViewBackgroundColor:(UIColor *)color {
    [_slideView setBackgroundColor:color];
}
-(void)setStateLabelTextColor:(UIColor *)color {
    [_stateTitle setTextColor:color];
}
-(void)setTextStateIndicator:(BOOL)active {
    [_stateTitle setHidden:!active];
    _indicator = active;
}
-(void)setLeftIconImage:(NSString *)image {
    [_leftIcon setImage:[UIImage imageNamed:image]];
}
-(void)setRightIconImage:(NSString *)image {
    [_rightIcon setImage:[UIImage imageNamed:image]];
}


#pragma mark - Handle Gestures
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    // The user do not want you to be dragged!
    if (!_shouldDrag) return;
    
    UIGestureRecognizerState state = [gesture state];
    CGPoint translation = [gesture translationInView:self];
    CGPoint velocity = [gesture velocityInView:self];
    CGFloat percentage = [self percentageWithOffset:CGRectGetMinX(_slideView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration = [self animationDurationWithVelocity:velocity];
    _direction = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged) {
        _isDragging = YES;
        
        CGPoint center = {_slideView.center.x + translation.x, _slideView.center.y};
        [_slideView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(_slideView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled) {
        _isDragging = NO;
        
        _currentImageName = [self imageNameWithPercentage:percentage];
        _currentPercentage = percentage;
        HWSwipeAnimatedViewState cellState= [self stateWithPercentage:percentage];
        
        if (_mode == HWSwipeAnimatedViewModeExit && _direction != HWSwipeAnimatedViewDirectionCenter && [self validateState:cellState])
            [self moveWithDuration:animationDuration andDirection:_direction];
        else
            [self bounceToOrigin];
    }
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [g velocityInView:self];
        if (fabsf(point.x) > fabsf(point.y) ) {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Utils
- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width {
    CGFloat offset = percentage * width;
    
    if (offset < -width) offset = -width;
    else if (offset > width) offset = width;
    
    return offset;
}
- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width {
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}
- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity {
    CGFloat width = CGRectGetWidth(self.bounds);
    NSTimeInterval animationDurationDiff = kHWDurationHightLimit - kHWDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (kHWDurationHightLimit + kHWDurationLowLimit) - fabs(((horizontalVelocity / width) * animationDurationDiff));
}
- (HWSwipeAnimatedViewDirection)directionWithPercentage:(CGFloat)percentage {
    if (percentage < -kHWViewStop)
        return HWSwipeAnimatedViewDirectionLeft;
    else if (percentage > kHWViewStop)
        return HWSwipeAnimatedViewDirectionRight;
    else
        return HWSwipeAnimatedViewDirectionCenter;
}
- (NSTextAlignment)alignementWithPercentage:(CGFloat)percentage {
    if (percentage > 0 && percentage <= kHWViewStop)
        return NSTextAlignmentLeft;
    else if (percentage < 0 && percentage >= -kHWViewStop)
        return NSTextAlignmentRight;
    else
        return NSTextAlignmentCenter;
}
- (NSString *)labelNameWithAlignement:(NSTextAlignment)alignement {
    if (alignement == NSTextAlignmentLeft)
        return _stateLeftText;
    else if (alignement == NSTextAlignmentRight)
        return _stateRightText;
    else
        return @"";
}
- (NSString *)imageNameWithPercentage:(CGFloat)percentage {
    NSString *imageName;

    if (percentage >= kHWViewStop)
        imageName = _leftImage;
    else if (percentage <= -kHWViewStop)
        imageName = _rightImage;
    
    return imageName;
}
- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage {
    CGFloat alpha;
    
    if (percentage >= 0 && percentage < kHWViewStop)
        alpha = percentage / kHWViewStop;
    else if (percentage < 0 && percentage > -kHWViewStop)
        alpha = fabsf(percentage / kHWViewStop);
    else alpha = 1.0;
    
    return alpha;
}
- (UIColor *)colorWithPercentage:(CGFloat)percentage {
    UIColor *color;
    
    if (percentage >= kHWViewStop)
        color = _leftColor;
    else if (percentage <= -kHWViewStop)
        color = _rightColor;
    else
        color = [UIColor clearColor];
    
    return color;
}

- (HWSwipeAnimatedViewState)stateWithPercentage:(CGFloat)percentage {
    HWSwipeAnimatedViewState state;
    
    state = HWSwipeAnimatedViewStateNone;
    
    if (percentage >= kHWViewStop && [self validateState:HWSwipeAnimatedViewStateLeft])
        state = HWSwipeAnimatedViewStateLeft;
    
    if (percentage <= -kHWViewStop && [self validateState:HWSwipeAnimatedViewStateRight])
        state = HWSwipeAnimatedViewStateRight;
    
    
    return state;
}
- (BOOL)validateState:(HWSwipeAnimatedViewState)state {
    BOOL isValid = YES;
    
    switch (state) {
        case HWSwipeAnimatedViewStateNone:
            isValid = NO;
            break;
        case HWSwipeAnimatedViewStateLeft:
            if (!_leftColor && !_leftImage)
                isValid = NO;
            break;
        case HWSwipeAnimatedViewStateRight:
            if (!_rightColor && !_rightImage)
                isValid = NO;
            break;
        default:
            break;
    }
    
    return isValid;
}


#pragma mark - Movements
- (void)animateWithOffset:(CGFloat)offset {
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];
    
    // Image Name
    NSString *imageName = [self imageNameWithPercentage:percentage];
    
    // Image Position
    if (imageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
    }
    [self slideImageWithPercentage:percentage imageName:imageName isDragging:YES];
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
    
    NSTextAlignment alignement = [self alignementWithPercentage:percentage];
    if (alignement != NSTextAlignmentCenter) {
        CGRect frame = _colorIndicatorView.frame;
        frame.origin.x += (alignement == NSTextAlignmentLeft) ? (self.bounds.size.width / 8) :  -(self.bounds.size.width / 8);
        [_stateTitle setFrame:frame];
        [_stateTitle setTextAlignment:alignement];
    }
    [_stateTitle setText:[self labelNameWithAlignement:alignement]];
}
- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging {
    UIImage *slidingImage = [UIImage imageNamed:imageName];
    CGSize slidingImageSize = slidingImage.size;
    CGRect slidingImageRect;
    
    CGPoint position = CGPointZero;
    
    position.y = CGRectGetHeight(self.bounds) / 2.0;
    
    if (isDragging) {
        if (percentage >= 0 && percentage < kHWViewStop) {
            position.x = [self offsetWithPercentage:(kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
            if (_indicator) [_stateTitle setHidden:NO];
            [_slidingImageView setHidden:YES];
        }
        else if (percentage >= kHWViewStop) {
            position.x = [self offsetWithPercentage:percentage - (kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
            if (_indicator) [_stateTitle setHidden:YES];
            [_slidingImageView setHidden:NO];
        }
        else if (percentage < 0 && percentage >= -kHWViewStop) {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
            if (_indicator) [_stateTitle setHidden:NO];
            [_slidingImageView setHidden:YES];
        }
        else if (percentage < -kHWViewStop) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
            if (_indicator) [_stateTitle setHidden:YES];
            [_slidingImageView setHidden:NO];
        }
    }
    else {
        if (_direction == HWSwipeAnimatedViewDirectionRight) {
            position.x = [self offsetWithPercentage:percentage - (kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (_direction == HWSwipeAnimatedViewDirectionLeft) {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kHWViewStop / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else {
            return;
        }
    }
    
    slidingImageRect = CGRectMake(position.x - slidingImageSize.width / 2.0,
                                  position.y - slidingImageSize.height / 2.0,
                                  slidingImageSize.width,
                                  slidingImageSize.height);
    
    slidingImageRect = CGRectIntegral(slidingImageRect);
    [_slidingImageView setFrame:slidingImageRect];
}
-(void)exitWithMode:(HWSwipeAnimatedViewExitMode)exitMode {
    switch (exitMode) {
        case 0: //left
            self.frame = CGRectMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
        case 1: //right
            self.frame = CGRectMake(self.frame.origin.x - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            break;
        case 2: //top
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - self.frame.size.height);
            break;
        case 3: //bottom
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height - self.frame.size.height);
            break;
        case 4: //horizontal center
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + (self.frame.size.height / 2), self.frame.size.width, self.frame.size.height - self.frame.size.height);
            break;
        case 5: //vertical center
            self.frame = CGRectMake(self.frame.origin.x + (self.frame.size.width / 2), self.frame.origin.y, self.frame.size.width - self.frame.size.width, self.frame.size.height);
            break;
        default:
            break;
    }
}
- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(HWSwipeAnimatedViewDirection)direction {
    
    CGFloat origin;
    
    if (direction == HWSwipeAnimatedViewDirectionLeft)
        origin = -CGRectGetWidth(self.bounds);
    else
        origin = CGRectGetWidth(self.bounds);
    
    CGFloat percentage = [self percentageWithOffset:origin relativeToWidth:CGRectGetWidth(self.bounds)];
    CGRect rect = _slideView.frame;
    rect.origin.x = origin;
    
    // Color
    UIColor *color = [self colorWithPercentage:_currentPercentage];
    if (color != nil) {
        [_colorIndicatorView setBackgroundColor:color];
    }
    
    // Image
    if (_currentImageName != nil) {
        [_slidingImageView setImage:[UIImage imageNamed:_currentImageName]];
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         [_slideView setFrame:rect];
                         [_slideView setAlpha:0];
                         [_slidingImageView setAlpha:0];
                         [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              if (direction == HWSwipeAnimatedViewDirectionLeft)
                                                  [self exitWithMode:_exitModeRight];
                                              else
                                                  [self exitWithMode:_exitModeLeft];
                                          }
                                          completion:^(BOOL finished){
                                              [self removeFromSuperview];
                                              [self notifyDelegate];
                                          }];
                     }];
}
- (void)bounceToOrigin {
    CGFloat bounceDistance = kHWBounceAmplitude * _currentPercentage;
    
    [UIView animateWithDuration:kHWBounceDuration
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut)
                     animations:^{
                         CGRect frame = _slideView.frame;
                         frame.origin.x = -bounceDistance;
                         [_slideView setFrame:frame];
                         [_slidingImageView setAlpha:0.0];
                         [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
                     }
                     completion:^(BOOL finished1) {
                         
                         [UIView animateWithDuration:kHWBounceDuration
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              CGRect frame = _slideView.frame;
                                              frame.origin.x = 0;
                                              [_slideView setFrame:frame];
                                              if (_indicator) [_stateTitle setHidden:NO];
                                          }
                                          completion:^(BOOL finished2) {
                                              [self notifyDelegate];
                                          }];

                     }];
}

#pragma mark - Delegate Notification
- (void)notifyDelegate {
    HWSwipeAnimatedViewState state = [self stateWithPercentage:_currentPercentage];
    if (state != HWSwipeAnimatedViewStateNone) {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeAnimatedView:didTriggerState:withMode:withExitModeLeft:withExitModeRight:)]) {
            [_delegate swipeAnimatedView:self didTriggerState:state withMode:_mode withExitModeLeft:_exitModeLeft withExitModeRight:_exitModeRight];
        }
    }
}

@end
