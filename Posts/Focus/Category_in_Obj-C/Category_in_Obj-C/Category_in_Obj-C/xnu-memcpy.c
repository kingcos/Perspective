//
//  xnu-memcpy.c
//  Category_in_Obj-C
//
//  Created by kingcos on 2019/4/14.
//  Copyright © 2019 kingcos. All rights reserved.
//

#include "xnu-memcpy.h"

/*
 * sizeof(word) MUST BE A POWER OF TWO
 * SO THAT wmask BELOW IS ALL ONES
 */
typedef    int word;        /* "word" used for optimal copy speed "字"用作优化拷贝速度 */

#define    wsize    sizeof(word)
#define    wmask    (wsize - 1)

/*
 * Copy a block of memory, handling overlap.
 * 拷贝一块内存，并处理重叠部分。
 * This is the routine that actually implements
 * (the portable versions of) bcopy, memcpy, and memmove.
 * 这是个实际实现了（可移植版本的）bcopy、memcpy、以及 memmove 的例行程序。
 */

// visibility("hidden")：隐藏函数符号
__attribute__((visibility("hidden")))
void * _libkernel_memmove(void *dst0, const void *src0, size_t length)
{
    // 保存一份目标、源，但源是常量，而目标是可变的
    char *dst = dst0;
    const char *src = src0;
    size_t t;
    
    // 长度为 0 或目标等于源时，无需移动
    if (length == 0 || dst == src)        /* nothing to do */
        goto done;
    
    /*
     * Macros: loop-t-times; and loop-t-times, t>0
     * 定义循环宏，t 大于 0 时，循环 t 次
     */
#define    TLOOP(s) if (t) TLOOP1(s)
#define    TLOOP1(s) do { s; } while (--t)
    
    // 如果源 > 目标（高地址 -> 低地址，小端就是向前）
    printf("(unsigned long)dst: %lu; (unsigned long)src: %lu\n", (unsigned long)dst, (unsigned long)src);
    if ((unsigned long)dst < (unsigned long)src) {
        /*
         * Copy forward.
         * 正向拷贝。
         */
        // typedef unsigned long           uintptr_t;
        t = (uintptr_t)src;    /* only need low bits 只需要低位 */
        printf("(t | (uintptr_t)dst) & wmask: %lu\n", (t | (uintptr_t)dst) & wmask);
        if ((t | (uintptr_t)dst) & wmask) {
            /*
             * Try to align operands.  This cannot be done
             * unless the low bits match.
             * 尝试对齐操作数。除非低位匹配，否则不可这样做。
             */
            if ((t ^ (uintptr_t)dst) & wmask || length < wsize)
                t = length;
            else
                t = wsize - (t & wmask);
            length -= t;
            //
//            TLOOP1(*dst++ = *src++);
            do {
                *dst++ = *src++;
            } while (--t);
        }
        /*
         * Copy whole words, then mop up any trailing bytes.
         * 拷贝整个字，然后删除所有尾字节。
         */
        t = length / wsize;
        printf("t: %zu\n", t);
//        TLOOP(*(word *)dst = *(word *)src; src += wsize; dst += wsize);
        if (t) {
            do {
                // 更改指针指向的一个字长的内容（src -> dst）
                *(word *)dst = *(word *)src;
                // dst & src 向前移动一个字长
                src += wsize;
                dst += wsize;
            } while (--t);
        }
        printf("(unsigned long)dst: %lu; (unsigned long)src: %lu\n", (unsigned long)dst, (unsigned long)src);
        
        t = length & wmask;
        printf("t: %zu\n", t);
//        TLOOP(*dst++ = *src++);
        if (t) {
            do {
                *dst++ = *src++;
            } while (--t);
        }
    } else {
        /*
         * Copy backwards.  Otherwise essentially the same.
         * Alignment works as before, except that it takes
         * (t&wmask) bytes to align, not wsize-(t&wmask).
         * 反向拷贝。否则基本一致。
         * 与之前一样对齐，除了它是以 (t&wmask) 字节对齐，而非 wsize-(t&wmask)。
         */
        src += length;
        dst += length;
        t = (uintptr_t)src;
        printf("(t | (uintptr_t)dst) & wmask: %lu\n", (t | (uintptr_t)dst) & wmask);
        if ((t | (uintptr_t)dst) & wmask) {
            if ((t ^ (uintptr_t)dst) & wmask || length <= wsize)
                t = length;
            else
                t &= wmask;
            length -= t;
//            TLOOP1(*--dst = *--src);
            do {
                *--dst = *--src;
            } while (--t);
        }
        t = length / wsize;
//        TLOOP(src -= wsize; dst -= wsize; *(word *)dst = *(word *)src);
        if (t) {
            do {
                src -= wsize;
                dst -= wsize;
                *(word *)dst = *(word *)src;
            } while (--t);
        }
        
        t = length & wmask;
//        TLOOP(*--dst = *--src);
        if (t) {
            do {
                *--dst = *--src;
            } while (--t);
        }
    }
done:
    printf("(unsigned long)dst: %lu; (unsigned long)src: %lu\n", (unsigned long)dst, (unsigned long)src);
    return (dst0);
}

void _libkernel_memmove2(void *dst0, void *src0, size_t length)
{
    // 保存一份目标、源
    char *dst = dst0;
    char *src = src0;
    
    // 如果源 > 目标（高地址 -> 低地址，小端就是向前）
    if ((unsigned long)dst < (unsigned long)src) {
        // 由于是整型的移动，这里可直接简化为 src -> dst
        *dst = *src;
    }
}

void _libkernel_memmove3(void *dst0, void *src0, size_t length)
{
    // 保存一份目标、源
    char *dst = dst0;
    char *src = src0;
    size_t t;
    
    // 如果源 < 目标（高地址 <- 低地址，小端就是向后）
    printf("(unsigned long)dst: %lu; (unsigned long)src: %lu\n", (unsigned long)dst, (unsigned long)src);
    if ((unsigned long)dst > (unsigned long)src) {
        src += length;
        dst += length;
        t = (uintptr_t)src;
        t = length / wsize;
        do {
            src -= wsize;
            dst -= wsize;
            *(word *)dst = *(word *)src;
        } while (--t);
    }
}

void * v_memcpy(void * dest, const void * src, size_t n)
{
    char * d = (char *) dest;
    const char * s = (const char*) src;
    while (n--)
        *d++ = *s++;
    return dest;
}
