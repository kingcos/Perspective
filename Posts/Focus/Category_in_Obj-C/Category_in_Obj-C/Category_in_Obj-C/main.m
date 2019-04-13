//
//  main.m
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/13.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Person+Life.h"
#import "Person+Work.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Person *p = [[Person alloc] init];
        [p smile];
    }
    return 0;
}
