+++
author = "penguinit"
Title = "Understanding Process & Threaded Goroutine Parallelism"
date = "2024-01-29"
Description = "This article summarizes the process and thread and details what characteristics Gorutin has in the Golang language and how it works."
tags = [
"goroutine", "process", "thread", "golang"
]

categories = [
"os", "language",
]
+++

## Overview

This article summarizes what processes and threads are and delves into what gorutin has a specificity in the Golang language and how it works.

## Processes

A process is an instance of a program that is running. When an operating system loads a program into memory and runs it, it becomes a process. Each process has a separate memory space (code, data, heap, stack, etc.) and does not share information with others.

When you issue the (Mac/Linux) 'ps -ef' command on a Unix-like operating system, you can check the running processes.

![Untitled](images/Untitled.png)

1. **UID**: ID of the user running the process.
2. **PID**: Process ID, unique identification number for the process.
3. **PPID**: Parent Process ID, the parent process ID of the process.
4. **C**: CPU utilization.
5. **STIME**: Time the process started.
6. **TTY**: The terminal to which the process is connected.
7. **TIME**: Total CPU time spent by the process.
8. **CMD**: The command line that started the process.

### Parent Process

Every process has a parent process. Within an operating system, process creation consists of a hierarchical structure in which the parent process creates the child process. This structure has several important characteristics.

1. **Initial process**: When the system boots up, the operating system starts the initial process (**0 times**). This initial process is the ancestor of all other user-level processes and is usually referred to as 'init' or a similar name.
2. **Parent-child relationship**: When a user runs a new program or the system starts a new service, the existing process (parent) creates a new process (child). This child process can create another process, and this is how the process tree is formed.
3. **Process termination and orphan process**: If the parent process is terminated and the child process is still running, the child process becomes an orphan process. The orphan process is automatically adopted and managed by the 'init' process on most systems.
4. **Signal at shutdown**: Typically, the parent process checks the child process's shutdown status and cleans up resources at the end of the child process.

## IPC

In the above summary, it is said that there is an independent memory space between processes and no information is shared between processes, so how do we communicate between processes?

Interprocess communication (**IPC**, Inter-Process Communication) is a mechanism that allows processes with independent memory spaces to exchange information and work together.

![Untitled](images/Untitled%201.png)

- **Shared Memory**: Allow indirect memory sharing by setting up separate memory zones to allow multiple processes to access.
- **Message Queues**: Communicate in a way that delivers messages between processes.

## Thread

Threads are execution flows within a process that share its resources (memory, file handles, etc.). Threads run independently with their own stacks, sharing code, data, and heap space within the process.

![Untitled](images/Untitled%202.png)

- Threads within the same process share memory, so if one thread changes **data, the other thread can see that change**.
- Context switching between threads has relatively low overhead; efficient resource use is possible thanks to shared memory.
- Process creation is relatively time-consuming and resource-intensive, but with threads, it can be created and managed relatively lightly.
- Each thread is assigned its own stack, which stores function calls, local variables, etc
- To maintain data consistency, use synchronization mechanisms such as Mutex, Semaphore, etc.

![Untitled](images/Untitled%203.png)

- Threads are CPU-allocated and run commands independently. **Multi-core processors** may run multiple threads simultaneously.
- Sharing memory makes it easy to exchange data and communicate, but this can cause synchronization problems.

### What is a multi-core processor?

A multi-core processor is a combination of multiple CPU cores on a single chip. Each core functions as a separate processing unit, and is capable of performing its own operations. This means that more tasks can be performed simultaneously than a single-core processor. For example, a **4 core processor** can run up to four threads** at the same time.

Simply put, you can do one task per core, and if you have multiple cores, you can do multiple tasks at the same time. There are several ways to do parallelism in the operating system.

- multiprocessing
- Multi-testing
- Multi-threading

The content can only be extended to that topic, so I've schematized the contents that show the tasks. The above description corresponds to **multiprocessing**. (One task per core)

In modern operating systems, to get the most out of the CPU, not only multiprocessing, but also the following tasks are basically performed. That's why we can feel a lot of programs running at the same time today.

![Untitled](images/Untitled%204.png)

## Goroutine

Goroutines are **lightweight threads introduced in the Go language. They use **much less memory than threads,** making it easy to generate and manage thousands of goroutines. Goroutines are managed by Go runtime, which effectively distributes them across multiple threads.

![Untitled](images/Untitled%205.png)

In fact, if you create one thread, you'll consume about **1MB** of memory, but in the case of Goroutine, you'll only consume about **2KB**.

To paraphrase CPU and Thread and Goroutine, we can explain it below. → [Source] (https://www.youtube.com/watch?v=5LfqrEGwDmE) )

![Untitled](images/Untitled%206.png)

![Untitled](images/Untitled%207.png)

![Untitled](images/Untitled%208.png)

As shown above, if a viable gorutin is waiting in the local queue and the gorutin assigned to the system thread is waiting for a system call or some other reason, it is performed in the form of a waiting gorutin coming to the workspace. And an idle gorutin is waiting in the local queue to wait for it to cook again.

This series of tasks is performed by runtime and goes back to multi-threads in today's environment, so if a queue is empty in the runtime scheduler, the queue in another thread is moved to the empty queue. (**Go Work-Stealing**)

![Untitled](images/Untitled%209.png)

![Untitled](images/Untitled%2010.png)

## Clean up

Through this article, I understood what processes and threads are and learned about Gorutin, a key element of Golang. Many people say that Gorutin is good, but I think I'm less concerned about why it's good.

I haven't learned everything about Gorutin, but I've learned that Gorutin is lighter than Thread, so it can be used and managed efficiently, and that it can take advantage of multicore through a high runtime scheduler.