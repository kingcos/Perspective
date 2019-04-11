//
//  main.swift
//  Type_Introspection_and_Reflection
//
//  Created by kingcos on 2019/4/10.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

// Obj-C
print("--- Obj-C introspection demo: ---")
Person.introspectionDemo()

print("--- Obj-C reflection demo: ---")
Person.reflectionDemo()

// Swift
print("--- Swift introspection demo 1: ---")
Animal.introspectionDemo()
print("--- Swift introspection demo 2: ---")
Animal.introspectionDemo2()

// Swift Inflection
print("--- Swift reflection demo: ---")
let cpt = Computer(system: "macOS", memorySize: 16)
let mirror = Mirror(reflecting: cpt)

if let displayStyle = mirror.displayStyle {
    print("mirror's style: \(displayStyle).")
}

print("mirror's properties count: \(mirror.children.count)")

for (label, value) in mirror.children {
    switch value {
    case let function as () -> Void:
        function()
    case let function as (String) -> Void:
            function("Param")
    default:
        print("\(label ?? "nil") - \(value)")
    }
}
