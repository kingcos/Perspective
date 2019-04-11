//
//  Person.m
//  Type_Introspection_and_Reflection
//
//  Created by 买明 on 2019/4/10.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Person.h"
#import <objc/runtime.h>

@implementation Fruit
- (void)taste {
    NSLog(@"%@ - %s", NSStringFromClass(self.class), __func__);
}
@end

@implementation Apple
- (void)tasteApple {
    NSLog(@"%@ - %s", NSStringFromClass(self.class), __func__);
}
@end

@implementation Orange
- (void)tasteOrange {
    NSLog(@"%@ - %s", NSStringFromClass(self.class), __func__);
}
@end

@implementation Person
- (void)eat:(id)fruit {
    // 检查是否是 Fruit 类或其子类
    if ([fruit isKindOfClass:Fruit.class]) {
        if ([fruit isMemberOfClass:Apple.class]) {
            // 检查是否是 Apple 类
            [(Apple *)fruit tasteApple];
        } else if ([fruit isMemberOfClass:Orange.class]) {
            // 检查是否是 Orange 类
            [(Orange *)fruit tasteOrange];
        } else {
            [fruit taste];
        }
    }
}

+ (void)introspectionDemo {
    Person *person = [[Person alloc] init];
    Apple *apple = [[Apple alloc] init];
    
    [person eat:apple];
}

+ (void)reflectionDemo {
    id person = [[NSClassFromString(@"Person") alloc] init];
    id orange = [[NSClassFromString(@"Orange") alloc] init];
    [person performSelector:NSSelectorFromString(@"eat:") withObject:orange];
}
@end
