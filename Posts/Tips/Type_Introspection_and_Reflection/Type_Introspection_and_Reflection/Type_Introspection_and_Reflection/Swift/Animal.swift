//
//  Animal.swift
//  Type_Introspection_and_Reflection
//
//  Created by 买明 on 2019/4/10.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

class Toy: NSObject {
    func playWithToy() {
        print(#function)
    }
}

class Ball: Toy {
    func playWithBall() {
        print(#function)
    }
}

class Doll: Toy {
    func playWithDoll() {
        print(#function)
    }
}

struct ToyCar {
    func playWithToyCar() {
        print(#function)
    }
}

class Animal {
    func play(_ toy: AnyObject) {
        // 检查是否是 Toy 或其子类
        if toy.isKind(of: Toy.self) {
            if toy.isMember(of: Ball.self) {
                // 检查是否是 Ball 类
                (toy as! Ball).playWithBall()
            } else if toy.isMember(of: Doll.self) {
                // 检查是否是 Doll 类
                (toy as! Doll).playWithDoll()
            } else {
                (toy as! Toy).playWithToy()
            }
        }
    }
    
    func play2(_ toy: Any) {
        // 检查是否是 Toy 或其子类
        if toy is Toy {
            (toy as! Toy).playWithToy()
        } else if (toy is ToyCar) {
            // 检查是否是 ToyCar 结构体类型
            (toy as! ToyCar).playWithToyCar()
        }
    }
    
    class func introspectionDemo() {
        let ball = Ball()
        let dog = Animal()
        
        dog.play(ball)
    }
    
    class func introspectionDemo2() {
        let car = ToyCar()
        let dog = Animal()
        
        dog.play2(car)
    }
    
    class func reflectionDemo() {
        
    }
}
