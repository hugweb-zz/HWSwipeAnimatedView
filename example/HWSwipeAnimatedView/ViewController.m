//
//  ViewController.m
//  HWSwipeAnimatedView
//
//  Created by Hugues Blocher on 08/09/2013.
//  Copyright (c) 2013 Hugues Blocher. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize label, retry;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create label and retry button
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height / 2) - 160, self.view.frame.size.width, 80)];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.label];
    
    self.retry = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.retry setFrame:CGRectMake(0, (self.view.frame.size.height / 2) + 100, self.view.frame.size.width, 80)];
    [self.retry setTitle:@"Retry" forState:UIControlStateNormal];
    [self.retry addTarget:self action:@selector(createHWSwipeAnimatedView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.retry];
    
    // Create swipe View
    [self createHWSwipeAnimatedView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma Methods
-(void)createHWSwipeAnimatedView {
    HWSwipeAnimatedView *swipeView = [[HWSwipeAnimatedView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height / 2) - 40, self.view.frame.size.width, 80)
                                                                      leftImage:@"check.png"
                                                                      leftColor:[UIColor colorWithRed:37.0 / 255.0 green:174.0 / 255.0 blue:96.0 / 255.0 alpha:1.0]
                                                                     rightImage:@"cross.png"
                                                                     rightColor:[UIColor colorWithRed:236.0 / 255.0 green:104.0 / 255.0 blue:89.0 / 255.0 alpha:1.0]];
    [swipeView setBackgroundColor:[UIColor grayColor]];
    [swipeView setSlideViewBackgroundColor:[UIColor darkGrayColor]];
    [swipeView setDelegate:self];
    [swipeView setStateLabelTextColor:[UIColor whiteColor]];
    [swipeView setStateLeftText:@"Supprimer"];
    [swipeView setLeftIconImage:@"trash.png"];
    [swipeView setStateRightText:@"Annuler"];
    [swipeView setRightIconImage:@"undo.png"];
    [swipeView setTextStateIndicator:YES];
    [swipeView setMode:HWSwipeAnimatedViewModeExit];
    [self.view addSubview:swipeView];
    
    [self.label setHidden:YES];
    [self.retry setHidden:YES];
}

#pragma Delegate
-(void)swipeAnimatedView:(HWSwipeAnimatedView *)view didTriggerState:(HWSwipeAnimatedViewState)state withMode:(HWSwipeAnimatedViewMode)mode withExitModeLeft:(HWSwipeAnimatedViewExitMode)exitModeLeft withExitModeRight:(HWSwipeAnimatedViewExitMode)exitModeRight {
    [self.label setHidden:NO];
    (mode == HWSwipeAnimatedViewModeBounce) ? [self.retry setHidden:YES] : [self.retry setHidden:NO];
    [self.label setText:[NSString stringWithFormat:@"Action --> %@", (state == 1) ? @"delete" : @"cancel"]];
}

@end
