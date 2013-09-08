HWSwipeAnimatedView
===================

HWSwipeAnimatedView implements the Mailbox gestural table view cell style but with a simple view

<p align="center"><img src="https://github.com/hugweb/HWSwipeAnimatedView/blob/master/example/HWSwipeAnimatedView/Assets/example.gif"/></p>

##Usage

```objc

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
    
```

###Delegate

```objc

@interface UIViewController () <HWSwipeAnimatedViewDelegate>

```

```objc
#pragma mark - UIViewController

-(void)swipeAnimatedView:(HWSwipeAnimatedView *)view didTriggerState:(HWSwipeAnimatedViewState)state withMode:(HWSwipeAnimatedViewMode)mode withExitModeLeft:(HWSwipeAnimatedViewExitMode)exitModeLeft withExitModeRight:(HWSwipeAnimatedViewExitMode)exitModeRight {
  //TODO
}

```

##Requirements
- iOS >= 5.0
- ARC

## Contact

Hugues Blocher

- http://github.com/hugweb
- http://twitter.com/hugweb
- http://www.hugweb.fr

## License

HWSwipeAnimatedView is available under the MIT license.
