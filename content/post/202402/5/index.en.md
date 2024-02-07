+++
author = "penguinit"
title = "What are Rune Types in Golang"
date = "2024-02-07"
description = "In this post, we'll learn about the Rune type and summarize why we use it in Golang."
tags = [
"golang"
]

categories = [
"language"
]
+++

![Untitled](Golang%E1%84%8B%E1%85%A6%E1%84%89%E1%85%A5%20Rune%20%E1%84%90%E1%85%A1%E1%84%8B%E1%85%B5%E1%86%B8%E1%84%8B%E1%85%B5%E1%84%85%E1%85%A1%E1%86%AB%208b08e7fe1d6f48588c64e2c0205bf5c1/Untitled.png)

## Overview

In this post, we'll introduce the Rune type and summarize why we use it in Golang.

## What is the Rune type

The `rune` type is an integer type used in Golang to represent the `UTF-8` character code. In fact, **`rune`** is an alias of **`int32`**, which can hold Unicode `code points`. This provides a way to store and process characters in memory.

### What is a Unicode codepoint?

First of all, if you want to learn more about Unicode, you can check out my previous blog post.

[AsciCode, EUC-EN, Unicode in a Nutshell](/en/post/202401/asciCode-euc-en-unicode-in-a-nutshell/)

A code point is one of the components of Unicode, represented as a hexadecimal number and starting with U+.

If you want to find the code points for Hangul, you can find them in the table on this site.

[https://jjeong.tistory.com/696](https://jjeong.tistory.com/696)

## Background on the Rune type

When the Go language was first designed, the developers kept in mind that programmers around the world use many different languages and writing systems, and the `Rune` type was introduced to effectively support the full range of Unicode.

## Relationship between String and Rune types

In Golang, a `string` type consists of a sequence of UTF-8 encoded bytes. This means that each character within a ``string`` does not have a fixed length, but can vary from 1 to 4 bytes. Therefore, in order to access the actual characters that make up a ``string``, we need to decode the UTF-8 encoding to determine the Unicode code point of each character. This is where the `rune` type comes into play.

### Output the Bytes value of the String

```go
func main() {
	// UTF-8 encoded string
	str := "안녕, World"

	// traverse the bytes of the string and print them out
	for i := 0; i < len(str); i++ {
		fmt.Printf("%dth byte: 0x%X\n", i, str[i])
	}
}

// 0th byte: 0xEC
// 1st byte: 0x95
// 2nd byte: 0x88
// 3rd byte: 0xEB
// 4th byte: 0x85
// 5th byte: 0x95
// 6th byte: 0x2C
// 7th byte: 0x20
// 8th byte: 0x57
// 9th byte: 0x6F
// 10th byte: 0x72
// 11th byte: 0x6C
// 12th byte: 0x64
```

If you look at the code above, you can see that when you iterate through the string, it prints out hexadecimal byte values. If you analyze those bytes, you'll see that the UTF-8 encoded value of the character "not" for the **0xEC 0x95 0x88** taken at the beginning looks the same.

[https://www.compart.com/en/unicode/U+C548](https://www.compart.com/en/unicode/U+C548)

### Output after converting String to Rune

```go
package main

import "fmt"

func main() {
	// UTF-8 encoded string
	str := "안녕, World"

	// convert string to a rune slice
	runes := []rune(str)

	for i, r := range runes {
		fmt.Printf("%dth rune: %c (Unicode: U+%04X)\n", i, r, r)
	}
}

// 0th rune: 안 (Unicode: U+C548)
// 1st rune: 녕 (Unicode: U+B155)
// 2nd rune: , (Unicode: U+002C)
// 3rd rune: (Unicode: U+0020)
// 4th rune: W (Unicode: U+0057)
// 5th rune: o (Unicode: U+006F)
// 6th rune: r (Unicode: U+0072)
// 7th rune: l (Unicode: U+006C)
// 8th rune: d (Unicode: U+0064)
```

This code is an example of changing a string to a rune and then looping through the for statement to output the code points of that rune. Notice that the UTF-8 based string value is converted to a rune slice value and the output value is stored and output in Unicode syllables.

### Example of manipulating multilingual terms

In Golang, Rune makes it easy to handle string processing for multiple languages. For example, let's write an example that outputs a string with multiple languages in reverse order.

```go
package main

import "fmt"

func main() {
    // Multilingual string
    str := "안녕, World"
    
    // convert string to rune slice
    runes := []rune(str)
    
    // print the string in reverse order
    fmt.Print("String in reverse order: ")
    for i := len(runes) - 1; i >= 0; i-- {
        fmt.Print(string(runes[i]))
    }
}

// dlroW ,녕안
```

Because we've converted the string to a rune, we can easily handle the reverse-ordered output without having to do anything special with the bytes. If we didn't have rune, we would have had to print the bytes in reverse order, validating them one by one for each language.

## Summary

In this post, we've summarized what Rune is and why Golang introduced it. Rune is an int32-based data type that represents code points in Unicode, and this relationship between UTF-8 strings and Rune gives Go a powerful advantage when dealing with strings in different languages.