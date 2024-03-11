+++
author = "penguinit"
title = "Closure through Golang"
date = "2024-03-11"
images = ["images/Untitled.png"]
description = "Learn the concept of closures, which are often used in functional programming, and learn more about how they work through a Golang example."
tags = [
"golang", "closure"
]
categories = [
"language"
]
+++

## Overview

Learn about the concept of closures, which are often used in functional programming, and learn more about how they work with Golang examples.

## What is a closure

A closure is a function that captures the state of a particular function and the surrounding lexical environment that was accessible when the function was declared, and makes that state accessible when the function is executed later.

In simpler terms, a closure "remembers" the environment (variables, constants, etc.) when a function is defined.
This means that even if the function is called outside of that environment, it can still access the variables that were in the environment at the time the function was defined

"A closure is an internal function that can access variables from **external functions**"

![Untitled](images/Untitled%201.png)

- The outer function named A has a variable of type int named a.
- The external function named A returns an anonymous function that +1s the value of the external function's variable, a (closure function)
- When you declare function A externally, function A returns an anonymous function (closure).
- The closure can capture and reference the values of variables or constants at the time of A function initialization.

## Why use closures?

### Data hiding and encapsulation

Closures allow you to hide variables inside a function. This prevents variables from being directly accessed or changed, which can protect data and reduce misuse. Similar to encapsulation in object-oriented programming, closures help you write modular code.

### Statefulness

There are times when you need to maintain state values within a context when a particular function is called, which can be implemented using closures. This is a safer way to write code than using global variables to maintain state.

### Modularization

Closures allow you to break your code into small, reusable parts. This allows you to modularize your code into appropriate units, which helps you write more reusable and maintainable code.

## Closures in Golang

Golang also supports anonymous functions, so we can implement closures.

```go
package main

import "fmt"

func adder() func(int) int {
    sum := 0
    return func(x int) int {
        sum += x
        return sum
    }
}

func main() {
    add := adder()
    fmt.Println(add(1)) // 1
    fmt.Println(add(20)) // 21
    fmt.Println(add(300))// 321
}
```

In the above example, the `adder` function returns a closure. This closure "remembers" the `sum` variable and adds a new value to `sum` each time it is called. In this way, closures allow us to preserve the state of a variable even after the function has ended.

## Summary

We've explained what closure functions are and what their advantages are, and we've seen how they work through a Golang example.

Closures allow developers to hide state, encapsulate data, and write modular code. More than just a technology, closures have become an integral part of modern programming, especially functional programming, as one of the tools that represents a mindset shift for better software design.