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

#import "Person+Category.h"
#import "Person+Extension.h"

#import "xnu-memcpy.h"

// Class Extension
@interface Person ()
- (void)secret;
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // Category:
        Person *p = [[Person alloc] init];
        [p smile];
        
        [p eat];
        [p drink];
        
        // memmove
        // b -> a
        int a = 10;
        int b = 20;
        NSLog(@"Before: a: %d, b: %d", a, b);
//        _libkernel_memmove(void *dst0, const void *src0, size_t length)
        _libkernel_memmove(&a, &b, sizeof(int));
//        memmove(&a, &b, sizeof(int));
//        memcpy(&a, &b, sizeof(int));
        NSLog(@"After: a: %d, b: %d", a, b);
        
        // c -> d
        int c = 30;
        int d = 40;
        NSLog(@"Before: c: %d, d: %d", c, d);
        // _libkernel_memmove2 是个简化版本的 _libkernel_memmove
        _libkernel_memmove2(&d, &c, sizeof(int));
        NSLog(@"After: c: %d, d: %d", c, d);
                
        // e[0, 1] -> e[1, 2]
        int e[5] = {1, 2, 3};
        NSLog(@"Before: e[0]: %d, e[1]: %d, e[2]: %d, e[3]: %d, e[4]: %d", e[0], e[1], e[2], e[3], e[4]);
        _libkernel_memmove3(&e[2], &e[0], sizeof(int) * 3);
        NSLog(@"After: e[0]: %d, e[1]: %d, e[2]: %d, e[3]: %d, e[4]: %d", e[0], e[1], e[2], e[3], e[4]);
        
        // f[0, 1] -> f[1, 2]
        int f[5] = {1, 2, 3};
        NSLog(@"Before: f[0]: %d, f[1]: %d, f[2]: %d, f[3]: %d, f[4]: %d", f[0], f[1], f[2], f[3], f[4]);
        v_memcpy(&f[2], &f[0], sizeof(int) * 3);
        NSLog(@"After: f[0]: %d, f[1]: %d, f[2]: %d, f[3]: %d, f[4]: %d", f[0], f[1], f[2], f[3], f[4]);
    }
    return 0;
}
