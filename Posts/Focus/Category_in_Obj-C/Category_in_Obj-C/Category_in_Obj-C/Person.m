//
//  Person.m
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/13.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Person.h"
#import "Person+Inner.h"

@interface Person () {
    // 默认为 private
    int _age;
    @protected
    NSString *_name;
}

@end

@implementation Person

+ (void)load {

}

- (void)smile {
    NSLog(@"Person - %s", __func__);
}

- (void)bar {
    NSLog(@"Person - %s", __func__);
}

@end

@interface Student : Person

@end

@implementation Student

- (void)bar {
//    NSLog(@"%d", _age);
    NSLog(@"%@", _name);
}

@end
