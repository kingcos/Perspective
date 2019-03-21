# Practice - iOS 中的 KVO 

| Date | Notes | Source Code |
|:-----:|:-----:|:-----:|
| 2019-03-13 | 首次提交 |  |

## What

KVO 即 Key-Value Observing，译作键值监听。通常用于监听对象的某个属性值的变化。

## How

```objc
#import "ViewController.h"

@interface Computer : NSObject
@property (nonatomic, strong) NSString *name;
@end

@implementation Computer
@end


@interface ViewController ()
@property (nonatomic, strong) Computer *cpt;
@end

@implementation ViewController

- (Computer *)cpt {
    if (!_cpt) {
        _cpt = [[Computer alloc] init];
    }
    return _cpt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.cpt addObserver:self
               forKeyPath:@"name"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:@"viewDidLoad - ViewController"];
}

- (void)dealloc
{
    [self.cpt removeObserver:self forKeyPath:@"name"];
}

- (IBAction)clickOnButton:(id)sender {
    self.cpt.name = @"Mac";
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"viewDidLoad - ViewController") {
        NSLog(@"%@ - %@ - %@ - %@", change, keyPath, object, context);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
```


## Why

## Reference
