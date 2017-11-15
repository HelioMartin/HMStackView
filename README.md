# HMStackView

Install manually by downloading the files from GitHub and then use
```ObjC
#import "HMStackView.h"
```

## Usage

Add the below reference to the @interface method in the header file(.h)
```ObjC
@property (nonatomic, strong) IBOutlet HMStackView *stackView;
```

Initialize the HMStackView in the Implementation File (.m)
```ObjC
self.stackView.swipeDirections = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
self.stackView.forwardDirections = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionUp;
self.stackView.backwardDirections = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionDown;
self.stackView.changeAlphaOnSendAnimation = YES;
[self.stackView configureWithViews:views];
self.stackView.delegate = self;
```

Customize constraints
```ObjC
self.stackView.contraintsConfigurator.top = 20.;
self.stackView.contraintsConfigurator.bottom = 50.;
self.stackView.contraintsConfigurator.leading = 10.;
self.stackView.contraintsConfigurator.trailing = 10.;
[self.stackView configureWithViews:views];
```

## Requirements
  * iOS 8.0 or higher
  * ARC

## Author

Modification of a great component [BSStackView](https://github.com/iBlacksus/BSStackView) created by iBlacksus, iblacksus@gmail.com

## License

HMStackView is available under the MIT license. See the LICENSE file for more info.
