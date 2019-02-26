//
//  Matrix.swift
//  Vector
//
//  Created by kingcos on 2019/2/26.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

class Matrix: CustomStringConvertible {
    private var values: [[Double]]
    
    var size: Int {
        return shape().rows * shape().columns
    }
    
    var description: String {
        return "Matrix({\(values)})"
    }
    
    init(_ values: [[Double]]) {
        self.values = values
    }
    
    func shape() -> (rows: Int, columns: Int) {
        return (values.count, values.first?.count ?? 0)
    }
    
    func get(_ pos: (row: Int, column: Int)) -> Double {
        return values[pos.row][pos.column]
    }
    
    func rowVector(_ row: Int) -> Vector {
        assert(row <= shape().rows, "Row is out of range.")
        return Vector(values[row])
    }
    
    func columnVector(_ column: Int) -> Vector {
        assert(column <= shape().columns, "Column is out of range.")
        return Vector(values.compactMap { $0[column] })
    }
}
