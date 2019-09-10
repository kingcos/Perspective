//
//  xnu-memcpy.h
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/14.
//  Copyright © 2019 kingcos. All rights reserved.
//

#ifndef xnu_memcpy_h
#define xnu_memcpy_h

#include <stdio.h>

void * _libkernel_memmove(void *dst0, const void *src0, size_t length);
void _libkernel_memmove2(void *dst0, void *src0, size_t length);
void _libkernel_memmove3(void *dst0, void *src0, size_t length);

void * v_memcpy(void * dest, const void * src, size_t n);

#endif /* xnu_memcpy_h */
