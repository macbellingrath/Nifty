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
    var count: Int { get }

    /// Number of elements in each dimension of the tensor.
    var size: [Int] { get }

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

    /// Initialize a new tensor of the given size from a row-major ordered array of data.
    init(_ size: [Int], _ data: [Element], name: String?, showName: Bool?)

    /// Initialize a new tensor of the given size and uniform value.
    init(_ size: [Int], value: Element, name: String?, showName: Bool?)


    // FIXME: this is not right. Should be able to recieve a TensorProtocol
    /// Initialize a new tensor from the data in a given tensor.
    ///
    /// - Parameters:
    ///    - tensor: tensor to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    init(_ tensor: Tensor<Element>, name: String?, showName: Bool?)
    
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
    
    //FIXME: check that returning Self is correct.
    subscript(_ s: SliceIndex...) -> Self { get set }

    /// Return tensor representation in unformatted, comma separated list.
    ///
    /// Elements of a row are comma separated. Rows are separated by newlines. Higher dimensional 
    /// slices are separated by a line consisting entirely of semicolons, where the number of
    /// semicolons indicates the dimension that ended; e.g. ";" comes between matrices in a 3D 
    /// tensor, ";;" comes between 3D tensors in a 4D tensor, ";;;" between 4D tensors in 5D, etc.
    var csv: String { get }
}
