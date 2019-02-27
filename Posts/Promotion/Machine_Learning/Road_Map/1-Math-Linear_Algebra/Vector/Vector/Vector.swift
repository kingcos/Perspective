//
//  Vector.swift
//  Vector
//
//  Created by kingcos on 2019/2/24.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

struct Vector: CustomStringConvertible {
    
    private var values: [Double]
    
    var len: Int
    
    var description: String {
        return "Vector({\(values)}"
    }
    
    init(_ values: [Double]) {
        self.values = values
        len = values.count
    }
    
    static func zero(_ dim: Int) -> Vector {
        return Vector([Double](repeating: 0.0, count: dim))
    }
    
    static func + (left: Vector, right: Vector) -> Vector {
        var left = left
        assert(left.len == right.len,
               "Error in adding. Length of vectors must be same.")
        
        right.values.enumerated().forEach {
            left.values[$0] += $1
        }
        
        return left
    }
    
    static func - (left: Vector, right: Vector) -> Vector {
        var left = left
        assert(left.len == right.len,
               "Error in subtracting. Length of vectors must be same.")
        
        right.values.enumerated().forEach {
            left.values[$0] -= $1
        }
        
        return left
    }
    
    static func * (left: Double, right: Vector) -> Vector {
        return Vector(right.values.map { $0 * left })
    }
    
    static func * (left: Vector, right: Double) -> Vector {
        return right * left
    }
    
    func pos() -> Vector {
        return 1 * self
    }
    
    func neg() -> Vector {
        return -1 * self
    }
    
    func iter() -> IndexingIterator<[Double]> {
        return values.makeIterator()
    }
    
    func get(_ index: Int) -> Double {
        return values[index]
    }
}

extension Vector {
    static func / (left: Vector, right: Double) -> Vector {
        return 1 / right * left
    }
    
    func norm() -> Double {
        return sqrt(values.reduce(0) { $0 + $1 * $1 })
    }
    
    func normalize() -> Vector {
        assert(norm() != 0, "Zero")
        
        return self / norm()
    }
}

extension Vector {
    static func | (left: Vector, right: Vector) -> Double {
        var left = left
        assert(left.len == right.len,
               "Error in dot product. Length of vectors must be same.")
        
        right.values.enumerated().forEach {
            left.values[$0] *= $1
        }
        
        return left.values.reduce(0) { $0 + $1 }
    }
}
