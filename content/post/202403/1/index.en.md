+++
author = "penguinit"
title = "Golang 1.22 HTTP Server Routing"
date = "2024-03-05"
images = ["images/Untitled.png"]
description = "On February 6, 2024, version 1.22 of Golang was released.  There are a number of feature updates, but the most interesting ones for me were related to HTTP server routing, so I thought I'd post about them."
tags = [
"golang", "http"
]
categories = [
"language"
]
+++

![Untitled](images/Untitled.png)

## Overview

On February 6, 2024, Golang version 1.22 was released.  There are a number of feature updates, but the most interesting ones for me were related to HTTP server routing, so I thought I'd post about them.

## Multiplexers

Implementing an HTTP server in Golang is pretty straightforward. However, in the real world, it's hard to implement it with just the default HTTP multiplexer, and one of the main reasons is that its URL matching capabilities are too limited.

I've had to implement things before without using external packages for some reason, and I've had a hard time matching path values, etc. So the default package is mostly used for examples, and last year there was a PR like this.

[https://github.com/golang/go/issues/61410](https://github.com/golang/go/issues/61410)

This PR adds functionality for the following two elements, and I think the Golang developers were aware of this inconvenience from the beginning, but I think they wanted to keep the standard library extensible through simplicity, which is the philosophy of the Golang language design.

- Adding Path Value to HTTP Request
- Added HTTP Method, Path Wildcard pattern matching.

### Simple HTTP server example

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, request *http.Request) {
		fmt.Fprintf(w, "hello world")
	})

	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Panicf("panic listen and server : %v", err)
	}
}
```

If the request is made to the root path, it will always print hello world. If the call was made with a POST or other method, the router would have to branch and build it based on the method of the request.

### Example of a complex HTTP server

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
)

// GET request handler that returns "Hello World"
func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/" && r.Method == "GET" {
		fmt.Fprintf(w, "Hello World")
	} else {
		http.NotFound(w, r)
	}
}

// POST request handler that returns the data contained in the request body verbatim
func echoPostHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/echo" && r.Method == "POST" {
		fmt.Fprintf(w, "Echo")
	} else {
		http.NotFound(w, r)
	}
}

// GET request handler that extracts the `id` via path analysis and returns "Received ID: [id]"
func getIdHandler(w http.ResponseWriter, r *http.Request) {
	if strings.HasPrefix(r.URL.Path, "/get/") && r.Method == "GET" {
		id := strings.TrimPrefix(r.URL.Path, "/get/")
		fmt.Fprintf(w, "Received ID: %s", id)
	} else {
		http.NotFound(w, r)
	}
}

func main() {
	http.HandleFunc("/", helloWorldHandler) // root path handler
	http.HandleFunc("/echo", echoPostHandler) // POST request handler
	http.HandleFunc("/get/", getIdHandler) // GET request handler with an ID

	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Panicf("panic listen and server : %v", err)
	}
}

```

The function implemented above is the server's implementation for the HTTP request defined below.

- GET /get/{_id}
- POST /echo
- GET /

As mentioned above, if you want to get more complicated, you need to handle various tasks inside the router. Creating a real API server is much more complicated than this, and you need to handle many APIs, so it is not practical to develop with the default package.

The **Golang Web Framework**

- [gin](https://github.com/gin-gonic/gin)
- [fiber](https://github.com/gofiber/fiber)
- [echo](https://github.com/labstack/echo)

**Simple ECHO example

```go
package main

import (
	"net/http"
	
	"github.com/labstack/echo/v4"
)

func main() {
	e := echo.New()
	e.GET("/users/:id", getUser)
	e.Logger.Fatal(e.Start(":1323"))
}

// e.GET("/users/:id", getUser)
func getUser(c echo.Context) error {
  	// User ID from path `users/:id`
  	id := c.Param("id")
	return c.String(http.StatusOK, id)
}
```

Compared to the default **http** package, you can easily utilize Method or Path Values in a structured form.

### Example HTTP server since 1.22

```go
package main

import (
	"fmt"
	"log"
	"net/http"
)

func main() {

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello World")
	}) // Root path handler
	http.HandleFunc("POST /echo", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Echo")
	}) // POST request handler
	http.HandleFunc("/get/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		fmt.Fprintf(w, "Received ID: %s", id)
	}) // GET request handler with id

	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Panicf("panic listen and server : %v", err)
	}
}
````

The example above achieves 100% the same result as the complex HTTP server example we **wrote** earlier. However, you'll notice that the code is much more concise and readable.

The first parameter of **HandleFunc** has been changed to accept a pattern, and we've made it easier to pass a value from the Request object via a function called PathValue.

## Cleanup

When Generics were introduced in Golang in 1.18, there were some people who argued that it was against the philosophy of Golang, but I thought it was great that the developers were listening to the users and improving it, and I also thought it was great that Gophers were so passionate about it.

I think we've found a good compromise, and as we add more features here, I think we'll lose some of the simplicity that I mentioned above. I still think I'll use external packages in the real world, but I think it's improved enough that I can use the standard packages in some cases, so I'm happy about this change.