//
//  Computer.swift
//  Type_Introspection_and_Reflection
//
//  Created by 买明 on 2019/4/11.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

struct Computer {
    var system: String
    var memorySize: Int
    
    let run: () -> Void = {
        print(#function)
    }
    
    let runWithParam: (String) -> Void = { param in
        print("param: \(param)")
    }
}
