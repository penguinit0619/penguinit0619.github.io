+++
author = "penguinit"
title = "Improved loop syntax in Golang 1.22"
date = "2024-03-21"
description = "In today's post, I'd like to summarize what improvements and changes have been made to the for statement in Golang 1.22."
tags = [
"golang"
]
categories = [
"language"
]
+++

## Overview

In today's post, I'd like to summarize the improvements and changes made in Golang 1.22 for iterators.

## Referencing loop variables in goroutines

Below is code to print the strings "a", "b", and "c" in sequence through a loop. The only difference is that we are using a goroutine inside the loop, and we don't want the function to exit first, so we use a channel to wait.

```go
package main

import "fmt"

func main() {
	done := make(chan bool)

	values := []string{"a", "b", "c"}
	for _, v := range values {
		go func() {
			fmt.Println(v)
			done <- true
		}()
	}

	// wait for all goroutines to complete before exiting
	for range values {
		<-done
	}
}
```

Result: c is printed 3 times
```go
$ go run main.go
c
c
c
```

However, the result is not what you would expect: the last value is printed three times, because the goroutine refers to the last variable in the loop. In my previous development, I actually encountered this case, so I solved it with a workaround like below.

```go
package main

import "fmt"

func main() {
	done := make(chan bool)

	values := []string{"a", "b", "c"}
	for _, v := range values {
		t := v

		go func() {
			fmt.Println(t)
			done <- true
		}()
	}

	// wait for all goroutines to complete before exiting
	for range values {
		<-done
	}
}
```

This was done by reassigning the variable inside the clause and passing it around, rather than referencing the loop variable when outputting from inside the goroutine. At the time, I didn't think this was a problem, just something to be aware of in asynchronous programming.

The Golang developers have been aware of this issue for a while now, and in 1.22 they made a change to make references in loops unambiguous: after 1.22, if a goroutine runs inside a loop, the variable it references doesn't change!

**Done in Golang 1.22** Using

```bash
$gvm use go1.22.0
$gvm list

gvm gos (installed)

   go1.21.0
=> go1.22.0
   system

$go run main.go
c
b
a
```

## Integer loops

Previously, if you wanted to iterate over a certain number of times, Go would require you to do something like this

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Println(i)
	}
}
```

However, starting in 1.22, it is possible to implement iterations with a single integer value as simple as

```go
package main

import "fmt"

func main() {
	for i := range 5 {
		fmt.Println(i)
	}
}

```

## GOEXPERIMENT

GOEXPERIMENT` is an environment variable that allows Go language developers to experimentally test new features or optimizations. It is designed to enable or disable various experimental features in the Go compiler and runtime. It is primarily used internally during Go's development process, and is useful for evaluating the performance impact of certain features or testing the stability of new features.

### rangefunc

In 1.22, a function called rangefunc is available internally, which implements a function iteration in the form of recursive calls to functions. Below is an example code.

```go
package main

import (
	"fmt"
	"strings"
)

func Split(s string) func(func(int, string) bool) {
	parts := strings.Split(s, " ")
	return func(f func(int, string) bool) {
		for i, p := range parts {
			if !f(i, p) {
				break
			}
		}
	}
}

func main() {
	str := "hello my name is penguin"
	for i, x := range Split(str) {
		fmt.Println(i, x)
	}
}

```

```bash
GOEXPERIMENT=rangefunc go run main.go
0 hello
1 my
2 name
3 is
4 penguin
```

It's an interesting idea, but personally, I don't think it looks that attractive... I don't think it's good because I don't think it's Go. (This is a personal opinion)

## Summary

We've seen the changes in Golang 1.22 related to iterations through the example code, and explained the GOEXPERIENCE variable and one experimental function (rangefunc) added in 1.22 as an example.

Translated with DeepL.com (free version)