+++
author = "penguinit"
title = "What it means to be Thread Safe in Golang"
date = "2024-02-06"
description = "In development, you're bound to find yourself dealing with asynchronous functions at least once. In this post, I'll explain what that term means and how it relates to Golang's strength in handling concurrency, using code to demonstrate what it means to be Thread Safe."
tags = [
    "golang"
]

categories = [
    "language"
]
+++

## Overview

As a developer, you'll find yourself dealing with asynchronous functions at least once in your career. In this post, I'll show you what the term means and what it means for Golang's strengths in handling concurrency through code.

## What is Thread Safe?

In multithreaded programming, it generally means that a function, variable, or object can be accessed simultaneously from multiple threads without causing problems in the program's execution. More strictly, it is defined as when a function is called and executing from one thread, and another thread calls the function and executes it simultaneously, the result of the function's execution in each thread is correct, even if they are executing together. (See [wiki documentation](https://ko.wikipedia.org/wiki/%EC%8A%A4%EB%A0%88%EB%93%9C_%EC%95%88%EC%A0%84))

It can be complicated to understand, but in a nutshell, ensuring that **two concurrently executed tasks do what they're supposed to do** is called Thread Safe. There are so many different ways to do this, and so many different situations where it can go wrong, that whenever I have to do concurrency programming, I remember running a simulation in my head repeatedly to see if my code is Thread Safe.

### Things that can happen if you don't make it Thread Safe

Let's look at a real-life example of what can happen with concurrency issues.

- You and your friend try to buy tickets to a concert, but both of you succeed, so you end up with 4 tickets (you originally intended to buy 2) → **DATA INTEGRITY ISSUE**.
- Two people tried to log in with the same account at the same time and kept logging each other out (only one person could log in) → **Deadlocks**.
- In a panic, the baggage screening system could only do one thing at a time and could not process properly when customers pushed their luggage through the scanner at the same time → **RACE CONDITION**.

![Untitled](Golang%E1%84%8B%E1%85%A6%E1%84%89%E1%85%A5%20Thread%20Safe%E1%84%92%E1%85%A1%E1%84%83%E1%85%A1%E1%84%82%E1%85%B3%E1%86%AB%20%E1%84%8B%E1%85%B4%E1%84%86%E1%85%B5%203c6dd0195fef489e86812d7a4f97e5b9/Untitled.png)

If you have logic that accesses, reads, adds, and allocates a shared resource at the same time, as shown in the image above, there is a high probability that your programming will behave differently than intended because the user's intent was to add, but the user saw a value of 1 at the time of the read.

### Writing Thread Safe Code

This part will vary depending on your development needs, but when programming for concurrency, you should think about whether you have any of the following issues

- Data integrity issues (data integrity)
- Deadlocks (deadlocks)
- Data races (race condition)

**To solve these problems, you can consider the following method**

- Synchronize data access via locks
- Use atomic operations
- Utilize immutable data structures
- Utilize testing and analysis tools

## Thread Safe in Golang

Golang uses lightweight threads called goroutines to write asynchronous programs. Traditionally, a lot of communication between threads is done through shared memory, but we also use locks and queues to control messages. This complicates the flow of code and makes it difficult to manage over time.

**In Golang, we utilize Channels to solve this problem.**

> Do not communicate by sharing memory; instead, share memory by communicating

See: [https://go.dev/blog/codelab-share](https://go.dev/blog/codelab-share)

### Channel Examples

Let's write an example of a channel in a case-by-case manner. First, we have 5 workers and each worker increments a counter by 1 in a loop of 1000 times.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	const numWorkers = 10
	const numNumbers = 10000

	// Create a channel
	numberChannel := make(chan int)
	sumChannel := make(chan int)
	totalSum := 0

	// Use WaitGroup to wait for all goroutines to complete their work
	var wg sync.WaitGroup

	// Start the addition goroutines
	for i := 0; i < numWorkers; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			sum := 0
			for num := range numberChannel {
				sum += num
			}

			sumChannel <- sum
			fmt.Printf("Goroutine %d: sum = %d\n", id, sum)
		}(i)
	}

	wg.Add(1)
	go func() {
		defer wg.Done()

		workerDoneCount := 0
		for sum := range sumChannel {
			totalSum += sum

			workerDoneCount++
			if workerDoneCount == numWorkers {
				close(sumChannel)
			}
		}
	}()

	// Send a number
	for i := 1; i <= numNumbers; i++ {
		numberChannel <- i
	}

	// all goroutines complete their work and close the channel
	close(numberChannel)

	// wait for all goroutines to finish their work
	wg.Wait()

	fmt.Printf("Total Total ==> %d\n", totalSum)
}
```

**The flow**

1. each goroutine receives numbers from the **`numberChannel`** channel, accumulates them, and computes a sum.
2. Once the sum is calculated, the goroutine sends the sum through the **`sumChannel`** channel.
3. A separate goroutine receives the sum from the **`sumChannel`** channel and calculates the grand total.
4. When all the goroutines have finished, they wait using **`sync.WaitGroup`**, and the main goroutine outputs the total

By using channels to control execution over a shared resource, a shared total, for tasks that are handled asynchronously to each other, and synchronization and channels to control execution, we can safely and intentionally perform tasks as intended.

But channels have their limitations. Depending on the pattern of the channel, there may be situations where it is difficult to control the order, and it is necessary to use locks or atomic operations to prevent data races.

### Using atomic operations

In Golang, most operations are not atomic by default. For example, the counter++ operation is not atomic because it reads and increments data. To achieve this, we need to use functions from the sync/atomic package provided by golang.

```go
package main

import (
	"fmt"
	"sync"
	"sync/atomic"
)

func main() {
	var counter int64
	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			atomic.AddInt64(&counter, 1)
			wg.Done()
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

We use the `atomic.AddInt64` function to ensure this atomicity. This allows us to output a value of 1000 as intended, even if multiple goroutines are running at the same time.

### Using Locks

In Golang, you can also declare locks to control access to shared resources. In this case, we won't use the functions from the sync/atomic package that we used in the example above because they are controlled via locks.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var counter int64
	var mu sync.Mutex // declare a mutex

	var wg sync.WaitGroup

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			mu.Lock() // get a mutex lock
			counter++ // increment shared variable
			mu.Unlock() // unlock the mutex lock
			wg.Done()
		}()
	}

	wg.Wait()
	fmt.Println("Counter:", counter)
}
```

The result is the same as above, and you can see that counter is 1000 as intended.

### Detailed debugging with the -race option

Golang has the -race option to report if there are concurrent reads or writes to memory. If a data race condition is detected in your code, it will report like below.

```go
go run -race main.go

==================
WARNING: DATA RACE
Read at 0x00c000014108 by goroutine 8:
  main.main.func1()
      /path/to/yourprog.go:25 +0x3e

Previous write at 0x00c000014108 by goroutine 7:
  main.updateData()
      /path/to/yourprog.go:15 +0x2f

Goroutine 8 (running) created at:
  main.main()
      /path/to/yourprog.go:23 +0x86

Goroutine 7 (finished) created at:
  main.main()
      /path/to/yourprog.go:22 +0x68
==================
```

## Summary

In this post, I explained what Thread Safe is, the situations where it can go wrong, and what you need to consider to prevent it.

I wrote an example of a channel through Golang code and examples of cases and examples that you can consider for thread-safe code, and I hope this helps you understand what you need to consider for thread-safe code.