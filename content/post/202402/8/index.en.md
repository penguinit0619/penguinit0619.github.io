+++
author = "penguinit"
title = "Mocking and Stubbing with Golang"
date = "2024-02-15"
description = "When writing unit tests, mocking and stubbing can help you a lot. In this post, we'll take a look at what mocking and stubbing are and how they differ from each other, and then go through some Golang example code to understand them in more detail."
tags = [
"golang", "mocking", "stubbing"
]

categories = [
"language", "testing"
]
+++


## Overview

When writing unit tests, mocking and stubbing can help you a lot. In this post, we'll take a look at what mocking and stubbing are and how they differ from each other, and then go through some Golang example code to understand them in more detail.

## What is Mocking

Mocking simulates the behavior of an object. It is used when the code under test interacts with external systems, methods, or other classes. **Mock objects define expected behavior (e.g., method calls, return values) and are used to verify that the actual code meets those expectations**. Mocking is primarily focused on **behavior verification**.

## What is Stubbing

Stubbing is used to return a **specific response** from a method called by the code under test. The Stub object takes the place of other components that the code under test relies on, and provides a predefined response. Stubbing is primarily used for **state verification**, focusing on validating the state changes or return values that a test case expects.

## Difference between Mocking and Stubbing

Mocking and stubbing are both techniques used in software testing, especially unit testing, to enable independent verification of the code under test by removing or simplifying external dependencies. While they may seem similar, there are important differences in their purpose and methods.

See: [https://martinfowler.com/bliki/TestDouble.html](https://martinfowler.com/bliki/TestDouble.html)

### Mocking verification

![[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)](images/Untitled.png)

[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)

Mock objects typically verify that a specific method call you set up in a test happens as expected. For example, you might want to check if a certain method is called with certain arguments, how many times it's called, etc.

### Stubbing verification method

![[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)](images/Untitled%201.png)

[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)

Stubbing provides only the result of the called method, and tests use this result to verify that certain logic works as expected. Stubbing does not validate the behavior of whether it was called, how many times it was called, etc.

## Mocking and stubbing with Golang

Let's take a look at a simple implementation of mocking and stubbing with Golang: write a mocking and stubbing implementation for an interface that fetches external data. In Golang, it's easier to validate Mocking by using an external library that supports it rather than writing it yourself.

- [https://github.com/uber-go/mock](https://github.com/uber-go/mock)
- [https://github.com/vektra/mockery](https://github.com/vektra/mockery)

> The Golang example will be implemented using mockery, and I'll save the detailed usage of mockery for another post.

Define `interface`
```go
// DataService.go

type DataService interface {
    FetchData(param string) (string, error)
}
```

### Mocking Example

The example below uses the Mockery library to create a Mock object for the **`DataService`** interface, and uses it to simulate a call to the **`FetchData`** method.

In this test, we are verifying that FetchData is called correctly through the `AssertExpectations` function on the mock object.

Writing an Implementation
```bash
mockery --name=DataService --dir=./mypackage --output=./mypackage/mocks --outpkg=mocks
```

`testcode`
```go
// DataService_test.go
func TestFetchData(t *testing.T) {
// Create a Mock object
mockDataService := &mocks.DataService{}

	// Set expectations
	expectedData := "mocked data"
	mockDataService.On("FetchData", mock.Anything).Return(expectedData, nil)

	// Call the function under test
	result, err := mockDataService.FetchData("param")

	// Validate
	mockDataService.AssertExpectations(t)
	if err != nil {
		t.Fatalf("Expected no error, but got %s", err)
	}
	if result != expectedData {
		t.Fatalf("Expected %s, but got %s", expectedData, result)
	}
}
```

### Stubbing examples

When you use stubbing to express the same case, you write your own implementation of the interface and set it up to return the specific data you need for your tests. Stubs focus on simply returning the expected result, without any complex logic or actual interaction with external systems.

Whereas mocking focuses on validating against specific behaviors, in stubbing, a specific function is simply intended to return a value and check its state afterward.

High-level verification is not possible, but it has advantages over mocking. As you can see, stubbing is more reusable than mocking, and if you don't need complex verification, stubbing can be a good choice.

``Create an Implementation``

```go
// stubs.go
package mypackage

type StubDataService struct{}

func (s *StubDataService) FetchData(param string) (string, error) {
    // Return stubbed data
    return "stubbed data", nil
}
```

`TestCode`

```go
// DataService_test.go
func TestFetchDataWithStub(t *testing.T) {
	// Create a Stub object
	stubDataService := &StubDataService{}

	// Call the function under test
	result, err := stubDataService.FetchData("param")

	// Validate
	if err != nil {
		t.Fatalf("Expected no error, but got %s", err)
	}
	expectedData := "stubbed data"
	if result != expectedData {
		t.Fatalf("Expected %s, but got %s", expectedData, result)
	}
}
```

## Summary

In this post, we explored the concepts of mocking and stubbing using Golang. Mocking is used to simulate the behavior of an object and validate the expected behavior, while stubbing is used to verify that certain logic works as expected by returning a specific response. When writing unit tests, I think you'll be able to write more efficient tests if you don't always consider Mocking, but instead consider different options depending on the situation.