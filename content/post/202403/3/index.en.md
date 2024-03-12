+++
author = "penguinit"
title = "What is a first-class function? Learn it with Golang"
date = "2024-03-12"
description = "Let's take a closer look at what a first-class function is and why we use it with a Golang example."
tags = [
"golang", "fp"
]
categories = [
"language"
]
+++

## Overview

Let's take a look at what a first-class function is and why we use it in Golang.

## What is a first-class function

First-Class Function refers to the concept of treating functions as first-class citizens in a programming language. This means that functions can be treated in the same way as other data types. This means that functions can be assigned to variables, passed as arguments to other functions, and returned by other functions.

### Higher-order functions

A programming language that supports first-class functions naturally supports higher-order functions as well. Higher-order functions are functions that take other functions as parameters or return functions as results, and since functions must be treated as values, higher-order functions exist based on first-order functions.

### List of languages that support first-class functions

Languages with these characteristics tend to adopt or support the functional programming paradigm.

- Javascript
- Python
- Ruby
- Scala
- Haskell
- Lisp
- Elixir
- Go
- Swift
- Rust

## First-class function features

- Reusability:** By storing functions in variables and allowing them to be passed to other functions, code can be reused more flexibly.
- Abstraction:** With Higher-Order Functions, you can manipulate your code at a higher level of abstraction. This improves the readability and maintainability of your code.

## Example of a first-order function in Golang

### Assign to variable

```go
package main

import "fmt"

func main() {
    // assign a function to a variable
    add := func(x, y int) int {
        return x + y
    }

    // call a function through a variable
    result := add(3, 4)
    fmt.Println(result) // output: 7
}

```

### Function that takes a function as an argument

```go
package main

import "fmt"

// Define the type of function that takes an argument
func operate(a, b int, operation func(int, int) int) int {
    return operation(a, b)
}

func main() {
    // addition function
    add := func(a, b int) int {
        return a + b
    }

    // multiply function
    multiply := func(a, b int) int {
        return a * b
    }

    // Execute addition and multiplication operations using the operate function
    sum := operate(5, 2, add)
    product := operate(5, 2, multiply)

    fmt.Println("Sum:", sum) // Output: Sum: 7
    fmt.Println("Product:", product) // Output: Product: 10
}
```

The sort package, one of Golang's default packages, implements functions that take advantage of these first-class features.

### Sort package

```go
package main

import (
    "fmt"
    "sort"
)

func main() {
    numbers := []int{4, 2, 3, 1, 5}

    // The sort.Slice function uses a comparison function that takes a slice 
	// and the indices of two elements in the slice as arguments.
    // If the comparison function returns true, the order of the elements is preserved.
    sort.Slice(numbers, func(i, j int) bool {
        return numbers[i] < numbers[j]
    })

    fmt.Println(numbers) // print [1, 2, 3, 4, 5]
}
```

In this example, the **`sort.Slice`** function takes an anonymous function as its second argument, which takes the indices of two elements in the slice as arguments and implements the comparison logic to determine the sort order. Passing a function as an argument to another function like this is a typical usage of first-class functions.

## Summary

In this article, we've seen what a first-class function is and how you can benefit from using it through a Golang code example. Similar to [closures](/en/post/202403/2/), first-class functions are used as a key concept in functional programming.

Most modern programming languages support functional programming, and while it's not exactly the same in Java, there was a process of introducing lambda expressions and functional interfaces after version 1.8 to follow the functional paradigm.

I haven't used functional programming in the field, but I would like to study and post about it if I have time.