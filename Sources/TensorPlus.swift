import Foundation
// TODO @Swift 4, add Codable conformance somewhere in the tree

/*
	Missing in this draft:
	- CustomStringConvertible conformance
	- Set/Get Slice functions
*/

public protocol Tensory {
	// TODO: @Swift 4: add : Numeric here
	associatedtype Element

	var count: Int { get }
	var size: [Int] { get }
	var data: [Element] { get }

    // TODO for Swift 4, use the new indexing capabilities for the
    // subscripting functions :)
    subscript(_ s: [Int]) -> Element { get set }
    
    subscript(_ s: Int...) -> Element { get set }
}

internal protocol TensoryCore : Tensory {

	var _data: [Element] { get set }
}

extension TensoryCore {
	
	public var count : Int { 
		return size.reduce(1, *) 
	}	

	public var data : [Element] { 
		return _data
	}

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
        //precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        return self._data[index]            
    }

    private mutating func setValue(index: Int, value: Element)
    {
        // FIXME: replace this precondition by an error
        //precondition(index >= 0 && index < self.count, "TensorProtocol subscript out of bounds")
        self._data[index] = value
    }

    private func getValue(subscripts: [Int]) -> Element
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        //precondition(index >= 0, "TensorProtocol subscript out of bounds")
        return self._data[index]
    }

    private mutating func setValue(subscripts: [Int], value: Element)
    {
        let index = sub2ind(subscripts, size: self.size)
        // FIXME: replace this precondition by an error
        //precondition(index >= 0, "TensorProtocol subscript out of bounds")
        self._data[index] = value
    }   
}

public struct TensorXX<T> : TensoryCore {
	// Tensory and TCore conformance
	public typealias Element = T

	public let size: [Int]
	internal var _data: [Element]

	/*	Missing:
		- Custom initializers
		- Custom subscripts (should all be in TensoryCore tho)
		- CustomStringConvertible conformance
	*/
}

public struct VectorXX<T> : TensoryCore {
	// Tensory and TCore conformance
	public typealias Element = T

	public let size: [Int]
	internal var _data: [Element]	

	// Vector-only specifications

	/*	Missing:
		- Custom initializers
		- Custom subscripts
		- CustomStringConvertible conformance
	*/
}

public struct MatrixXX<T> : TensoryCore {
	// Tensory and TCore conformance
	public typealias Element = T

	public let size: [Int]
	internal var _data: [Element]	

	// Matrix-only specifications
	public var rows: Int {
		return self.size[0]
	}
	public var columns: Int {
		return self.size[1]
	}

	/*	Missing:
		- Custom initializers
		- Custom subscripts
		- CustomStringConvertible conformance
	*/
}