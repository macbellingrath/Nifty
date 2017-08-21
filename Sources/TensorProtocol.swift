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

    internal(set) var size : [Int] { 
        get {
            return _size        
        }
        set {
            _size = newValue
        }
    }

    internal(set) var data : [Element] { 
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
    
    internal func getValue(index: Int) -> Element
    {
        // FIXME: replace this precondition by an error
        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        return self.data[index]            
    }

    internal mutating func setValue(index: Int, value: Element)
    {
        // FIXME: replace this precondition by an error
        precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }

    internal func getValue(subscripts: [Int]) -> Element
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        return self.data[index]
    }

    internal mutating func setValue(subscripts: [Int], value: Element)
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        precondition(index >= 0, "TensorProtocol subscript out of bounds")
        self.data[index] = value
    }   
}

public struct TensorX<T>: TensorProtocol
{
    public typealias Element = T

    public var _size : [Int]

    public var _data : [T]

    /// Optional name of tensor (e.g., for use in display).
    public var name: String?

    /// Determine whether to show name when displaying tensor.
    public var showName: Bool

    /// Formatter to be used in displaying tensor elements.
    public var format: NumberFormatter

    /// Initialize a new tensor of the given size from a row-major ordered array of data.
    ///
    /// - Parameters:
    ///    - size: number of elements in each dimension of the tensor
    ///    - data: tensor data in row-major order
    ///    - name: optional name of tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ size: [Int], _ data: [T], name: String? = nil, showName: Bool? = nil)
    {       
        let n = size.reduce(1, *)

        precondition(n > 0, "Tensor must have at least 1 element")
        precondition((size.filter({$0 <= 0})).count == 0, "Tensor must have all dimensions > 0")
        precondition(data.count == n, "Tensor dimensions must match data")

        self._size = size
        self._data = data    
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
    public init(_ size: [Int], value: T, name: String? = nil, showName: Bool? = nil)
    {
        let n = size.reduce(1, *)
        precondition(n > 0, "Tensor must contain at least one element")
        let data = Array<T>(repeating: value, count: n)
        self.init(size, data, name: name, showName: showName)
    }
   
    /// Initialize a new tensor from the data in a given vector.
    ///
    /// - Parameters:
    ///    - vector: vector to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ vector: Vector<T>, name: String? = nil, showName: Bool? = nil)
    {
        self.init([1, vector.count], vector.data, name: name, showName: showName)

        // need to create new formatter instance, copying values
        self.format = _copyNumberFormatter(vector.format)
    }
    
    /// Initialize a new tensor from the data in a given matrix.
    ///
    /// - Parameters:
    ///    - matrix: matrix to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ matrix: Matrix<T>, name: String? = nil, showName: Bool? = nil)
    {
        self.init(matrix.size, matrix.data, name: name, showName: showName)

        // need to create new formatter instance, copying values
        self.format = _copyNumberFormatter(matrix.format)
    }

    /// Initialize a new tensor from the data in a given tensor.
    ///
    /// - Parameters:
    ///    - tensor: tensor to initialize from
    ///    - name: optional name of new tensor
    ///    - showName: determine whether to print the tensor name; defaults to true if the tensor is
    ///        given a name, otherwise to false
    public init(_ tensor: TensorX<T>, name: String? = nil, showName: Bool? = nil)
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

    /// Access a slice of the tensor with a subscript range.
    ///
    /// If only one range is given, it is interpretted as a row-major order linear index. Otherwise,
    /// the given subscripts are treated as indexes into each dimension.
    ///
    /// - Parameters:
    ///    - s: subscripts 
    /// - Returns: new tensor composed of slice
    public subscript(_ s: SliceIndex...) -> TensorX<T>
    {
        get
        {
            assert(s.count > 0)

            if s.count == 1
            {
                return self.getSlice(index: s[0])
            }
            else
            {
                return self.getSlice(subscripts: s)
            }
        }

        set(newValue)
        {    
            assert(s.count > 0)

            if s.count == 1
            {
                self.setSlice(index: s[0], value: newValue)
            }
            else
            {
                self.setSlice(subscripts: s, value: newValue)
            }

        }
    }
    
    private func getSlice(index: SliceIndex) -> TensorX<T>
    {
        let range = _convertToCountableClosedRange(index)

        // inherit name, add slice info
        var sliceName = self.name     
        if sliceName != nil { sliceName = "\(_parenthesizeExpression(sliceName!))[\(index)]" }
      
        let d = Array(self.data[range])
        return TensorX([1, d.count], d, name: sliceName, showName: self.showName)
    }

    private mutating func setSlice(index: SliceIndex, value: TensorX<T>)
    {
        // FIXME: there's no shape checking here! E.g. a [1,1,4] slice could 
        // be assigned a [1,2,2] Tensor. How should that be handled?
        let range = _convertToCountableClosedRange(index)
        self.data[range] = ArraySlice(value.data)
    } 

    private func getSlice(subscripts: [SliceIndex]) -> TensorX<T>
    {        
        let ranges = _convertToCountableClosedRanges(subscripts)

        precondition(ranges.count == self.size.count, "Subscript must match tensor dimension")

        // determine size of resulting tensor slice, and start/end subscripts to read
        var newSize = [Int](repeating: 0, count: ranges.count)
        var startSub = [Int](repeating: 0, count: ranges.count)
        var endSub = [Int](repeating: 0, count: ranges.count)
        for (i, range) in ranges.enumerated()
        {
            newSize[i] = range.count                
            startSub[i] = range.lowerBound
            endSub[i] = range.upperBound
        }    

        // start reading from tensor, rolling over each dimension
        var newData = [T]()
        var curSub = startSub
        while true
        {
            newData.append(self.getValue(subscripts: curSub))
            guard let inc = _cascadeIncrementSubscript(curSub, min: startSub, max: endSub) else
            {
                break
            }

            curSub = inc
        }        

        // inherit name, add slice info
        var sliceName = self.name
        if sliceName != nil 
        { 
            // closed countable ranges print with quotes around them, which clutters display
            let subsDescrip = "\((subscripts.map({"\($0)"})))".replacingOccurrences(of: "\"", with: "")
            sliceName = "\(_parenthesizeExpression(sliceName!))\(subsDescrip)" 
        }

        return TensorX(newSize, newData, name: sliceName, showName: self.showName)        
    }

    private mutating func setSlice(subscripts: [SliceIndex], value: TensorX<T>)
    {
        let ranges = _convertToCountableClosedRanges(subscripts)

        precondition(ranges.count == self.size.count, "Subscript must match tensor dimension")

        // determine range of writes in each dimension
        var startSub = [Int](repeating: 0, count: ranges.count)
        var endSub = [Int](repeating: 0, count: ranges.count)
        for (i,range) in ranges.enumerated()
        {
            startSub[i] = range.lowerBound
            endSub[i] = range.upperBound
        }    

        // ensure that new data size matches size of slice to write to
        var sliceSize = [Int](repeating: 0, count: ranges.count)
        for i in 0..<ranges.count
        {
            sliceSize[i] = endSub[i]-startSub[i]+1
        }

        precondition(sliceSize == value.size, "Provided data must match tensor slice size")        

        // start writing to matrix, rolling over each dimension
        var newData = value.data
        var curSub = startSub
        for i in 0..<newData.count
        {
            self.setValue(subscripts: curSub, value: newData[i])
            
            guard let inc = _cascadeIncrementSubscript(curSub, min: startSub, max: endSub) else
            {
                return
            }

            curSub = inc                
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
        // create tensor title
        var title = ""
        if self.showName
        {
            title = ""
            // FIXME: this should be uncommented after 
            // refactoring Vector and Matrix
            //title = (self.name ?? "\(self.size.map({"\($0)"}).joined(separator: "x")) tensor") + ":\n"
        }

        // handle 1D tensor
        if self.size.count == 1
        {
            return ""
            // FIXME: this should be uncommented after 
            // refactoring Vector and Matrix
            // return "\(Vector(self, name: title, showName: self.showName))"
        }

        // handle 2D tensor
        else if self.size.count == 2
        {
            return ""
            // FIXME: this should be uncommented after 
            // refactoring Vector and Matrix
            // return "\(Matrix(self, name: title, showName: self.showName))"                
        }

        // break 3D+ tensors into 2D tensor chunks
        else
        {
            // The approach here is to increment across only the third and higher dimensions. At
            // each point, we can slice off the first and second dimensions and print those as a 
            // matrix. To do this though, we need to increment the lower dimensions faster, rather 
            // than the higher dimensions as row-major order does. This is because we'd expect to 
            // see the third dimension slices printed together, then the fourth, etc.
            var str = title

            // slice of third and higher dimensions
            let hiDims = self.size[2..<self.size.count]

            // reverse dimensions so cascade increment goes through low dimension fastest
            let hiDimsRev = Array(hiDims.reversed())
            let startRev = Array(repeating: 0, count: hiDimsRev.count)
            let endRev = hiDimsRev.map({$0-1})

            var curSubRev = Array<Int>(repeating: 0, count: hiDimsRev.count)
            while true
            {
                // create a slice over entire dims 1 and 2 for the current spot in dims 3+
                let curSliceLoSubs: [SliceIndex] = [0..<self.size[0], 0..<self.size[1]] 
                let curSliceHiSubs: [SliceIndex] = Array(curSubRev.reversed())
                let curSliceSubs = curSliceLoSubs + curSliceHiSubs
                let curSlice = self.getSlice(subscripts: curSliceSubs)

                // create a header to identify current matrix location in tensor
                let mName = "[..., ..., " + curSliceHiSubs.map({"\($0)"}).joined(separator: ", ") + "]"

                // turn slice into matrix for easy printing
                let m = Matrix(curSlice.size[0], curSlice.size[1], curSlice.data, name: mName, showName: true)
                str += "\(m)\n\n"

                // increment through higher dimensions until we've reached the end
                guard let inc = _cascadeIncrementSubscript(curSubRev, min: startRev, max: endRev) else
                {
                    return str
                }

                curSubRev = inc 
            }
        }  
    }    
}