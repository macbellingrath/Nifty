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


/// Data structure for an N-D, row-major order array.
public protocol TensorProtocol: CustomStringConvertible
{   
    //TODO for Swift 4, replace the associatedtype line with this one.
    // associatedtype Element : Numeric
    associatedtype Element    

    /// Number of elements in the tensor.
    var count: Int { get set }

    /// Number of elements in each dimension of the tensor.
    var size: [Int] { get set }

    // FIXME: this might not be correct.
    // Should only be able to change the members, and not the 
    // Array itself.
    var data: [Element] { get set }

    /// Optional name of tensor (e.g., for use in display).
    var name: String? { get set }

    /// Determine whether to show name when displaying tensor.
    var showName: Bool { get set }

    /// Formatter to be used in displaying tensor elements.
    var format: NumberFormatter { get set }

    // FIXME: this is a hack to allow for a default constructor.
    // Maybe we can avoid it?
    init()

    /// Initialize a new tensor of the given size from a row-major ordered array of data.
    init(_ size: [Int], _ data: [Element], name: String?, showName: Bool?)

    /// Initialize a new tensor of the given size and uniform value.
    init(_ size: [Int], value: Element, name: String?, showName: Bool?)


    /// Initialize a new tensor from the data in a given tensor.
    ///
    /// - Parameters:
    ///    - tensor: tensor to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    init(_ tensorP: Self, name: String?, showName: Bool?)
    
    /// Initialize a new tensor from a comma separated string.
    ///
    /// The given csv string must be in the format returned by Tensor.csv.
    ///
    /// - Parameters:
    ///    - csv: comma separated string containing tensor data
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    init(_ csv: String, name: String?, showName: Bool?)
    
    /// Access a single element of the tensor with a subscript.
    ///
    /// If only one subscript is given, it is interpretted as a row-major order linear index. 
    /// Otherwise, the given subscripts are treated as indexes into each dimension.
    ///
    /// - Parameters:
    ///    - s: subscripts
    /// - Returns: single value at index
    subscript(_ s: [Int]) -> Element { get set }
    
    subscript(_ s: Int...) -> Element { get set }
    
    subscript(_ s: SliceIndex...) -> Self { get set }

    /// Return tensor representation in unformatted, comma separated list.
    ///
    /// Elements of a row are comma separated. Rows are separated by newlines. Higher dimensional 
    /// slices are separated by a line consisting entirely of semicolons, where the number of
    /// semicolons indicates the dimension that ended; e.g. ";" comes between matrices in a 3D 
    /// tensor, ";;" comes between 3D tensors in a 4D tensor, ";;;" between 4D tensors in 5D, etc.
    var csv: String { get }
}


// Default implementations for the structs that adhere to the TensorProtocol
extension TensorProtocol {

    /// Initialize a new tensor of the given size from a row-major ordered array of data.
    ///
    /// - Parameters:
    ///    - size: number of elements in each dimension of the tensor
    ///    - data: tensor data in row-major order
    ///    - name: optional name of tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ size: [Int], _ data: [Element], name: String? = nil, showName: Bool? = nil)
    {       
        self.init()
        let n = size.reduce(1, *)

        precondition(n > 0, "TensorProtocol must have at least 1 element")
        precondition((size.filter({$0 <= 0})).count == 0, "TensorProtocol must have all dimensions > 0")
        precondition(data.count == n, "TensorProtocol dimensions must match data")

        self.size = size
        self.count = n
        self.data = data    
        self.name = name    

        if let show = showName
        {
            self.showName = show
        }
        else
        {
            self.showName = name != nil
        }

        // default display settings
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.usesSignificantDigits = true
        fmt.paddingCharacter = " "
        fmt.paddingPosition = .afterSuffix
        fmt.formatWidth = 8
        self.format = fmt
    }

    /// Initialize a new tensor of the given size and uniform value.
    ///
    /// - Parameters:
    ///    - size: number of elements in each dimension of the tensor
    ///    - value: single value repeated throughout tensor
    ///    - name: optional name of tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ size: [Int], value: Element, name: String? = nil, showName: Bool? = nil)
    {
        let n = size.reduce(1, *)
        precondition(n > 0, "TensorProtocol must contain at least one element")
        let data = Array<Element>(repeating: value, count: n)
        self.init(size, data, name: name, showName: showName)
    }

    /// Initialize a new tensor from the data in a given tensor.
    ///
    /// - Parameters:
    ///    - tensor: tensor to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ tensor: Self, name: String? = nil, showName: Bool? = nil)
    {
        self.init(tensor.size, tensor.data, name: name, showName: showName)

        // need to create new formatter instance, copying values
        self.format = _copyNumberFormatter(tensor.format)
    }    

    /// Initialize a new tensor from a comma separated string.
    ///
    /// The given csv string must be in the format returned by Tensor.csv.
    ///
    /// - Parameters:
    ///    - csv: comma separated string containing tensor data
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ csv: String, name: String? = nil, showName: Bool? = nil)
    {
        // FIXME: implement
        fatalError("Not yet implemented")
    }

    /// Access a single element of the tensor with a subscript.
    ///
    /// If only one subscript is given, it is interpretted as a row-major order linear index. 
    /// Otherwise, the given subscripts are treated as indexes into each dimension.
    ///
    /// - Parameters:
    ///    - s: subscripts
    /// - Returns: single value at index
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
        set(newValue) { self[s] = newValue }
    }
    
    private func getValue(index: Int) -> Element
    {

        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        return self.data[index]            
    }

    private mutating func setValue(index: Int, value: Element)
    {
        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }

    private func getValue(subscripts: [Int]) -> Element
    {
        let index = sub2ind(subscripts, size: self.size)
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        return self.data[index]
    }

    private mutating func setValue(subscripts: [Int], value: Element)
    {
        let index = sub2ind(subscripts, size: self.size)
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }   

    /// Access a slice of the tensor with a subscript range.
    ///
    /// If only one range is given, it is interpretted as a row-major order linear index. Otherwise,
    /// the given subscripts are treated as indexes into each dimension.
    ///
    /// - Parameters:
    ///    - s: subscripts 
    /// - Returns: new tensor composed of slice
    public subscript(_ s: SliceIndex...) -> Self
    {
        get
        {
            // FIXME: implement
            fatalError("Not yet implemented")

            // assert(s.count > 0)

            // if s.count == 1
            // {
            //     return self.getSlice(index: s[0])
            // }
            // else
            // {
            //     return self.getSlice(subscripts: s)
            // }
        }

        set(newValue)
        {    
            // FIXME: implement
            fatalError("Not yet implemented")
            
            // assert(s.count > 0)

            // if s.count == 1
            // {
            //     self.setSlice(index: s[0], value: newValue)
            // }
            // else
            // {
            //     self.setSlice(subscripts: s, value: newValue)
            // }

        }
    }
    /// Return tensor contents in an easily readable grid format.
    ///
    /// - Note: The formatter associated with this tensor is used as a suggestion; elements may be
    ///     formatted differently to improve readability. Elements that can't be displayed under the 
    ///     current formatting constraints will be displayed as '#'.    
    /// - Returns: string representation of tensor
    public var description: String
    {
        fatalError("Not yet implemented")
    }    

    /// Return tensor representation in unformatted, comma separated list.
    ///
    /// Elements of a row are comma separated. Rows are separated by newlines. Higher dimensional 
    /// slices are separated by a line consisting entirely of semicolons, where the number of
    /// semicolons indicates the dimension that ended; e.g. ";" comes between matrices in a 3D 
    /// tensor, ";;" comes between 3D tensors in a 4D tensor, ";;;" between 4D tensors in 5D, etc.
    public var csv: String
    {  
        fatalError("Not yet implemented")
    }
}
