//
//  Computer.m
//  Effective_Obj-C_Demo
//
//  Created by 买明 on 2019/3/19.
//  Copyright © 2019 kingcos. All rights reserved.
//

#import "Computer.h"

@implementation Computer
- (instancetype)init
{
    self = [super init];
    if (self) {
        self->_name = @"COMPUTER";
    }
    return self;
}

@end
