# (@Swift4) Field-oriented `Elements`

* Proposal: [002](https://github.com/nifty-swift/Nifty/blob/master/Documents/Evolution/002-numeric-elements.md)
* Author: Felix Fischer
* Status: **Early Draft. Needs more research.**

## Introduction

This proposal imposes a restriction over all of the generic types used in the structs that conform to the *Tensory*/*TensorProtocol* protocols.

**NOTE:** since I don't know how far down the binding to specific floating-point behavior, I don't really know how feasible is this proposal. Therefore, *needs more research*.

## Motivation

Nifty works over **Vector Spaces**, the heart of Linear Algebra. And Vector Spaces base themselves over some **Scalar field**. The elements and operations in scalar fields satisfy certain [properties](https://en.wikipedia.org/wiki/Field_(mathematics)#Classic_definition) that allow the vector spaces to be properly behaved:

1. **Associativity** of addition and multiplication
2. **Commutativity** of addition and multiplication
3. **Identity** elements in addition and multiplication
4. **Additive inverse**
5. **Multiplicative inverse**, for every element `a` `!=` `0`, with `0` being the *additive identity*
6. **Distributiviy** of multiplication over addition

The field properties are hard, if not currently impossible, to enforce with the type system. But we can use just a subset of them that allows us to safely compile our generic types:

1. **Existence of `+` operator and `*` operator**
2. **Identity** for both operations
<!-- CHECK THAT FIRST -->
3. **Unary operator of negation (`-`)**
4. **Existence of `/` operator** (used for multiplicative inverse)

With those conditions, we can safely generalize over *Real numbers*, *Complex numbers*, *finite fields* and such, without having to restrict ourselves too much. The alternative would be to have **Nifty** work only with *floating-point* types, which is already great but could be better.

## Proposed solution

//WIP

## Detailed design

//WIP

## Impact on existing code

//TBD

## Alternatives considered

//WIP
