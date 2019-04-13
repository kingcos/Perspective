//
//  Person+Life.m
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/13.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Person+Life.h"

@implementation Person (Life)

// Instance method
- (void)run {
    NSLog(@"%s", __func__);
}

// Class method
+ (void)foo {
    NSLog(@"%s", __func__);
}

// Protocol method
- (void)eat {
    NSLog(@"%s", __func__);
}

@end
