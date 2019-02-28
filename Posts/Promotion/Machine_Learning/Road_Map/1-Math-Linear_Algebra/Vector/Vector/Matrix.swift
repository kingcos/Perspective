//
//  Matrix.swift
//  Vector
//
//  Created by kingcos on 2019/2/26.
//  Copyright © 2019 kingcos. All rights reserved.
//

import Foundation

struct Matrix: CustomStringConvertible {
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

extension Matrix {
    static func zero(_ shape: (rows: Int, columns: Int)) -> Matrix {
        return Matrix([[Double]](repeating: [Double](repeating: 0.0, count: shape.columns),
                                 count: shape.rows))
    }
    
    static func + (left: Matrix, right: Matrix) -> Matrix {
        var left = left
        assert(left.shape() == right.shape(),
               "Error in adding. Length of matrixes must be same.")
        
        right.values.enumerated().forEach { t in
            t.element.enumerated().forEach {
                left.values[t.offset][$0.offset] += $0.element
            }
        }
        
        return left
    }
    
    static func - (left: Matrix, right: Matrix) -> Matrix {
        var left = left
        assert(left.shape() == right.shape(),
               "Error in subtracting. Length of matrixes must be same.")
        
        right.values.enumerated().forEach { t in
            t.element.enumerated().forEach {
                left.values[t.offset][$0.offset] -= $0.element
            }
        }
        
        return left
    }
    
    static func * (left: Double, right: Matrix) -> Matrix {
        return Matrix(right.values.map { t in t.map { $0 * left } })
    }
    
    static func * (left: Matrix, right: Double) -> Matrix {
        return right * left
    }
}

extension Matrix {
    func rows() -> [Vector] {
        return values.map { Vector($0) }
    }
    
    func columns() -> [Vector] {
        var columns = [Vector]()
        for i in 0..<shape().columns {
            columns.append(Vector(values.enumerated().map { $0.element[i] }))
        }
        return columns
    }
    
    static func dot(_ left: Matrix, _ right: Vector) -> Vector {
        assert(left.shape().columns == right.len,
               "Error in Matrix-Matrix Multiplication.")
        return Vector(left.rows().map { Vector.dot($0, right) })
    }
    
    static func dot(_ left: Matrix, _ right: Matrix) -> Matrix {
        assert(left.shape().columns == right.shape().rows,
               "Error in Matrix-Matrix Multiplication.")
        return Matrix(left.rows().map { leftRow in
            right.columns().map { rightColumn in
                Vector.dot(leftRow, rightColumn)
            }
        })
    }
}
