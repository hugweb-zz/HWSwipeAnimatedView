//
//  ViewController.h
//  HWSwipeAnimatedView
//
//  Created by Hugues Blocher on 08/09/2013.
//  Copyright (c) 2013 Hugues Blocher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWSwipeAnimatedView.h"

@interface ViewController : UIViewController <HWSwipeAnimatedViewDelegate>

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *retry;

@end
