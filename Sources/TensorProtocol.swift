/***************************************************************************************************
 *  TensorProtocol.swift
 *
 *  This file defines the TensorProtocol protocol, an n-dimensional array.
 *  It serves as the common basis for the behavior of Vector, Matrix and Tensor. 
 *
 *  Author: Félix Fischer
 *  Creation Date: 26 May 2017
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License. You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under the 
 *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
 *  express or implied. See the License for the specific language governing permissions and 
 *  limitations under the License.
 *
 *  Copyright 2017 Félix Fischer
 **************************************************************************************************/

import Foundation

// TODO for Swift 4, add Codable conformance.
/// Data structure for an N-D, row-major order array.
public protocol TensorProtocol: CustomStringConvertible
{   
    // TODO for Swift 4, replace the associatedtype line with this one.
    // associatedtype Element : Numeric
    associatedtype Element    

    /// Number of elements in the tensor.
    var count: Int { get }

    /// Internal property. Set at your own risk
    var _size: [Int] { get set }
    /// Number of elements in each dimension of the tensor.
    var size:  [Int] { get }

    /// Internal property. Set at your own risk
    var _data: [Element] { get set }
    /// Data contained in tensor in row-major order.
    var data:  [Element] { get  }
    
    // TODO: check if these are implementable for every TensorProtocol type
    // Even though they are basic initializers, they might not be general enough.
    // init(_ size: [Int], _ data: [Element], name: String? = nil, showName: Bool? = nil)
    // init(_ size: [Int], value: T, name: String? = nil, showName: Bool? = nil)
    // init(_ size: [Int], value: Element, name: String?, showName: Bool?)
    
    // This is a copy initializer. The only truly general initializer, I think.
    init(_ otherTP: Self, name: String?, showName: Bool?)
    
    // TODO for Swift 4, use the new indexing capabilities for the
    // subscripting functions :)
    subscript(_ s: [Int]) -> Element { get set }
    
    subscript(_ s: Int...) -> Element { get set }
    
    // TODO: check if this is implementable for every TensorProtocol type
    // subscript(_ s: SliceIndex...) -> Self { get set }
}


// Default implementations for the structs that adhere to the TensorProtocol
public extension TensorProtocol {

    // We compute count on the fly, because it's less redundant this way.
    var count : Int {
        return size.reduce(1, *)
    }

    private(set) var size : [Int] { 
        get {
            return _size        
        }
        set {
            _size = newValue
        }
    }

    private(set) var data : [Element] { 
        get {
            return _data        
        }
        set {
            _data = newValue
        }
    }

    // Subscripting can be implemented well in the extension! 
    // Horray for DRY code :D
    public subscript(_ s: [Int]) -> Element
    {
        get
        {
            assert(s.count > 0)

            if s.count == 1
            {
                return self.getValue(index: s[0])
            }
            else
            {
                return self.getValue(subscripts: s)
            }
        }

        set(newValue)
        {    
            assert(s.count > 0)

            if s.count == 1
            {
                self.setValue(index: s[0], value: newValue)
            }
            else
            {
                self.setValue(subscripts: s, value: newValue)
            }

        }
    }

    public subscript(_ s: Int...) -> Element
    {
        get { return self[s] }
        set (newValue) { self[s] = newValue }
    }
    
    private func getValue(index: Int) -> Element
    {
        // FIXME: replace this precondition by an error
        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        return self.data[index]            
    }

    private mutating func setValue(index: Int, value: Element)
    {
        // FIXME: replace this precondition by an error
        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }

    private func getValue(subscripts: [Int]) -> Element
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        return self.data[index]
    }

    private mutating func setValue(subscripts: [Int], value: Element)
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }   
}