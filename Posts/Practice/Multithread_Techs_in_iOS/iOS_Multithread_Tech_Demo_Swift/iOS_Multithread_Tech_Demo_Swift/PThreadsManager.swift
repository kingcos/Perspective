//
//  PThreadsManager.swift
//  iOS_Multithread_Tech_Demo
//
//  Created by kingcos on 2019/3/10.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

class PThreadsManager {
    class func tryCreate() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForCreate, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForCreate, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        sleep(1)
        exit(3)
    }
    
    class func tryJoin() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForJoin, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForJoin, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }
        
        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }
    }
    
    class func tryMutex() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_mutex_init(&mutex, nil) != 0 {
            print("pthread_mutex_init error.")
        }
        
        if pthread_create(&thread_1, nil, runForMutex, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }

        if pthread_create(&thread_2, nil, runForMutex, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }

        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }

        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }

        print("Result count \(current_count)")
    }
    
    class func trySemaphore() {
        var thread_1, thread_2: pthread_t?
        
        if pthread_create(&thread_1, nil, runForSemaphore1, encode("Thread 1")) != 0 {
            print("pthread_create thread_1 error.")
            exit(1)
        }
        
        if pthread_create(&thread_2, nil, runForSemaphore2, encode("Thread 2")) != 0 {
            print("pthread_create thread_2 error.")
            exit(1)
        }
        
        if pthread_join(thread_1!, nil) != 0 {
            print("pthread_join thread_1 error.")
            exit(1)
        }
        
        if pthread_join(thread_2!, nil) != 0 {
            print("pthread_join thread_2 error.")
            exit(1)
        }
    }
}

let START_NUMBER = 0
let END_NUMBER = 10
let THREAD_NUMBER = 2
let COUNT_PER_THREAD = (END_NUMBER - START_NUMBER) / THREAD_NUMBER

var current_count = START_NUMBER
var mutex = pthread_mutex_t()

var sem: [CChar] = "sem".cString(using: String.Encoding.utf8)!
var semaphore = sem_open(&sem, 0, 0, 0)

func runForCreate(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    print("\(decode(context) as String) is running.")
    exit(2)
}

func runForJoin(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    print("\(decode(context) as String) is running.")
    exit(2)
}

func runForMutex(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    for _ in 0..<COUNT_PER_THREAD {
        sleep(1)
        pthread_mutex_lock(&mutex)

        current_count += 1
        print("Now - \(current_count)")
        
        pthread_mutex_unlock(&mutex)
    }
    pthread_exit(nil)
}

func runForSemaphore1(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    if sem_wait(semaphore) != 0 {
        perror("sem_wait error.")
        exit(1)
    }
    print("runForSemaphore1")
    pthread_exit(nil)
}

func runForSemaphore2(_ context: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
    sleep(1)
    
    if sem_post(semaphore) != 0 {
        print("sem_post error.")
        exit(1)
    }
    
    print("runForSemaphore2")
    pthread_exit(nil)
}

class Box<T> {
    let value: T
    
    init(_ value: T) {
        self.value = value
    }
}

private func decode<T>(_ memory: UnsafeMutableRawPointer) -> T {
    let unmanaged = Unmanaged<Box<T>>.fromOpaque(memory)
    defer { unmanaged.release() }
    return unmanaged.takeUnretainedValue().value
}

private func encode<T>(_ t: T) -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(Box(t)).toOpaque()
}
