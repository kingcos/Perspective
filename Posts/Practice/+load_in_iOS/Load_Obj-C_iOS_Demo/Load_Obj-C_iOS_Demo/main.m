//
//  main.m
//  Load_Obj-C_iOS_Demo
//
//  Created by kingcos on 2019/4/20.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface Fruit : NSObject

@end

@implementation Fruit

+ (void)load {
    NSLog(@"------");
    sleep(3);
    NSLog(@"------");
}

@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
