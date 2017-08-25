# Tensor Protocol

* Proposal: [001](https://github.com/nifty-swift/Nifty/blob/master/Documents/Evolution/001-tensor-protocol.md)
* Author: Felix Fischer
* Status: **Proposed**

## Introduction

This proposal refactors all of the existing *Tensor*-derived types into protocols and extensions that generalize their common behavior.

## Motivation

By *Tensor*-derived types, I refer to all of the types that are based on the more general concept of *Tensor*. In our current implementation, these are `Matrix`, `Vector` and `Tensor` itself.

There is an extensive repetition of code between them, as can be seen here:

```swift

@Tensor
    /// Number of elements in the tensor.
    public let count: Int

    /// Number of elements in each dimension of the tensor.
    public var size: [Int]

    /// Data contained in tensor in row-major order.
    public var data: [T]

    /// Optional name of tensor (e.g., for use in display).
    public var name: String?

    /// Determine whether to show name when displaying tensor.
    public var showName: Bool

    /// Formatter to be used in displaying tensor elements.
    public var format: NumberFormatter
@Matrix
    /// Number of elements in the matrix.
    public let count: Int

    /// Number of [rows, columns] in the matrix.
    public var size: [Int]
    public var rows: Int { return self.size[0] }
    public var columns: Int { return self.size[1] }

    /// Data contained in matrix in row-major order.
    public var data: [T]

    /// Optional name of matrix (e.g., for use in display).
    public var name: String?

    /// Determine whether to show name when displaying matrx.
    public var showName: Bool

    /// Formatter to be used in displaying matrix elements.
    public var format: NumberFormatter    

@Vector
    /// Number of elements in vector.
    public let count: Int

    /// Data contained in vector.
    public var data: [T]

    /// Optional name of vector for use in display
    public var name: String?

    /// Determine whether to show name when displaying matrx.
    public var showName: Bool

    /// Formatter to be used in displaying matrix elements.
    public var format: NumberFormatter

```

This implementation has two important problems:

1. Duplication of code leads to bugs.
2. We're not making the most out of the types we use, since what they have in common is not reflected in their relationship with one another. Such relationships could be used to reutilize tests and generic algorithms.

This proposal addresses both of them, at least partially.

## Proposed solution

We propose a **new protocol** and its **extension**:

* `Tensory`/`TensorProtocol`: intended as the public API and main schematic of the *Tensor* types. Here is a gist of how it could look like:

```swift
public protocol Tensory 
{
    associatedtype Element

    var count: Int { get }
    var size: [Int] { get set }
    var data: [Element] { get set }

    subscript(_ s: [Int]) -> Element { get set }
    
    subscript(_ s: Int...) -> Element { get set }
}
```

* `Tensory`/`TensorProtocol`'s `extension`: intended as the default implementation of the *Tensor* types' behavior. It implements `count` (which is computable from `size`), the `subscript` functions of `Tensory`/`TensorProtocol` and related helper functions. 

It also contains correctness-enforcing observers for both `size` and `data`, so that users can't change them in a way that would result in corrupt data. Here's a snippet showing code it would include:

```swift
extension Tensory 
{    
    public var count : Int 
    { 
        return size.reduce(1, *) 
    }   

    public var size : [Int] 
    {
        willSet(newSize)
        {
            if(newSize.reduce(1, *) != count)
            {
                print("Error: wrong size. New count is different from current count")
                newSize = size
            }
        }
    }

    public var data : [Element] 
    { 
        willSet(newData)
        {
            if(newData.count != count)
            {
                print("Error: wrong data. New count is different from current count")
                newData = data
            }
        }
    }

    public subscript(_ s: [Int]) -> Element
    {
        get
        {
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
        return self._data[index]            
    }

    private mutating func setValue(index: Int, value: Element)
    {
        self._data[index] = value
    }

    private func getValue(subscripts: [Int]) -> Element
    {
        let index = sub2ind(subscripts, size: self.size)
        return self._data[index]
    }

    private mutating func setValue(subscripts: [Int], value: Element)
    {
        let index = sub2ind(subscripts, size: self.size)
        self._data[index] = value
    }   
}
```

## Detailed design

Straightforward:

1. Existing API common to the three types is refactored into `TensorProtocol`. The three `structs` conform to the protocol.
2. Existing common implementation to the three types is refactored into the `protocol extension`.

## Impact on existing code

The API of the three types shouldn't change. Before implementing the change, it will be tested and whatever code gets broken, fixed.

The total amount of code should be noticeably reduced, since a good piece of the structs' original declaration is behavior common to the three of them.

## Alternatives considered

We considered using another protocol to provide encapsulation of the `data` field. But for both order and direct manipulation, we decided that the current design, aided by the `property observers`, should be picked.