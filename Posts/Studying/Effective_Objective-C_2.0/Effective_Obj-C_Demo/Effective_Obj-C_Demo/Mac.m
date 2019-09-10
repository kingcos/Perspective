//
//  Mac.m
//  Effective_Obj-C_Demo
//
//  Created by 买明 on 2019/3/19.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Mac.h"

@implementation Mac
- (void)setName:(NSString *)name {
    if (![name isEqualToString:@"Mac"]) {
        [NSException raise:NSInvalidArgumentException format:@"ERROR IN MAC."];
    }
    self.name = name;
}


- (void)run {
    
}

@end
