+++
author = "penguinit"
title = "Golang 1.22 HTTP 서버 라우팅"
date = "2024-03-05"
images = ["images/Untitled.png"]
description = "2024년 2월 6일 Golang 1.22 버전이 릴리즈 되었습니다.  다양한 기능들이 업데이트되었는데 그중에서 저에게 가장 흥미로운 내용은 HTTP 서버 라우팅 관련 내용이었는데 관련해서 포스팅 해보려고 합니다."
tags = [
"golang", "http"
]
categories = [
"language"
]
+++

![Untitled](images/Untitled.png)

## 개요

2024년 2월 6일 Golang 1.22 버전이 릴리즈 되었습니다.  다양한 기능들이 업데이트되었는데 그중에서 저에게 가장 흥미로운 내용은 HTTP 서버 라우팅 관련 내용이었는데 관련해서 포스팅 해보려고 합니다.

## 멀티플렉서

Golang에서 HTTP 서버를 구현하는 건 아주 간단합니다. 하지만 실제 현업에서는 기본 HTTP 멀티플렉서로만 구현을 하기가 힘든데 가장 큰 이유중에 하나가 URL 매칭 기능이 너무 제한적이기 때문입니다.

이전에 모종의 이유로 외부 패키지는 사용하지 않고 구현 해야만 했던 일이 있었는데 경로 값을 매칭하거나 할 때 고역을 치렀던 경험이 있습니다. 그래서 기본 패키지는 예제에서만 쓰이는 게 대다수였는데 작년에 아래와 같은 PR이 있었습니다.

[https://github.com/golang/go/issues/61410](https://github.com/golang/go/issues/61410)

해당 PR은 아래 2가지 요소에 대해서 기능을 추가하는 것이고 애초에 Golang 개발진도 이런 불편함을 인지는 하고 있었을 것 같지만 Golang 언어 설계의 철학인 단순성을 통해서 확장 가능한 형태의 표준 라이브러리를 유지하고 싶지 않았나 싶습니다.

- Path Value를 HTTP Request에서 받을 수 있게 추가
- HTTP Method, Path Wildcard 패턴 매칭 기능 추가

### 간단한 HTTP 서버 예제

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

루트 Path로 요청하면 무조건 hello world를 출력합니다. 만약에 POST나 다른 Method로 호출을 한다면 해당 라우터에서 request의 메소드를 기반으로 분기를 해서 작성을 해야만 했습니다. 

### 복잡한 HTTP 서버 예제

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"strings"
)

// "Hello World"를 반환하는 GET 요청 핸들러
func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/" && r.Method == "GET" {
		fmt.Fprintf(w, "Hello World")
	} else {
		http.NotFound(w, r)
	}
}

// 요청 본문에 포함된 데이터를 그대로 반환하는 POST 요청 핸들러
func echoPostHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path == "/echo" && r.Method == "POST" {
		fmt.Fprintf(w, "Echo")
	} else {
		http.NotFound(w, r)
	}
}

// 경로 분석을 통해 `id`를 추출하고 "Received ID: [id]"를 반환하는 GET 요청 핸들러
func getIdHandler(w http.ResponseWriter, r *http.Request) {
	if strings.HasPrefix(r.URL.Path, "/get/") && r.Method == "GET" {
		id := strings.TrimPrefix(r.URL.Path, "/get/")
		fmt.Fprintf(w, "Received ID: %s", id)
	} else {
		http.NotFound(w, r)
	}
}

func main() {
	http.HandleFunc("/", helloWorldHandler)   // 루트 경로 핸들러
	http.HandleFunc("/echo", echoPostHandler) // POST 요청 핸들러
	http.HandleFunc("/get/", getIdHandler)    // ID를 포함한 GET 요청 핸들러

	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Panicf("panic listen and server : %v", err)
	}
}

```

위에 구현한 함수는 아래 정의한 HTTP 요청에 대한 서버의 구현체입니다.

- GET /get/{_id}
- POST /echo
- GET /

위에 언급했듯이 좀 더 복잡해지면 라우터 내부에서는 다양한 작업들을 처리해 줘야 합니다. 실제 API 서버를 만들다 보면 이것보다 훨씬 복잡하고 많은 API들을 다뤄야 하기 때문에 기본 패키지로는 개발을 진행하기가 현실적으로 힘듭니다. 

**Golang 웹 프레임워크**

- [gin](https://github.com/gin-gonic/gin)
- [fiber](https://github.com/gofiber/fiber)
- [echo](https://github.com/labstack/echo)

**간단한 echo 예제**

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

기본 **http** 패키지와 비교했을 때 Method나 Path Value들을 구조화된 형태로 손쉽게 활용할 수 있습니다. 

### 1.22 이후 HTTP 서버예제

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
	}) // 루트 경로 핸들러
	http.HandleFunc("POST /echo", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Echo")
	}) // POST 요청 핸들러
	http.HandleFunc("/get/{id}", func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")
		fmt.Fprintf(w, "Received ID: %s", id)
	}) // ID를 포함한 GET 요청 핸들러

	fmt.Println("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Panicf("panic listen and server : %v", err)
	}
}
```

위에 예제는 기존에 **작성했던 복잡한 HTTP 서버 예제**와 결과가 100퍼센트 동일합니다. 대신 코드의 간결함과 가독성이 훨씬 개선된 것을 보실 수 있습니다. 

기존에 **HandleFunc** 의 첫번 째 매개변수는 패턴을 받을 수 있게 변경 되었고, Request 객체에서 PathValue라는 함수를 통해서 손 쉽게 값을 전달 받을 수 있도록 개선되었습니다.

## 정리

이전에 1.18버전에서 Golang에 Generic 기능이 들어갔을 때 Golang의 철학과 위배된다고 갑론을박이 있었는데 그래도 유저들의 목소리를 듣고 개선해나가는 개발진들이 대단하다고 느끼면서 한편으로 이렇게 열성적으로 의견을 내는 Gopher들도 대단하다고 생각이 들었습니다.

저는 적당한 타협점을 찾았다고 생각이 들고 여기에서 기능이 더 추가되면 그때는 위에서 언급했었던 단순성을 잃어버리지 않을까라고 생각했습니다. 저는 그래도 여전히 현업에서는 외부 패키지를 쓸 것 같지만 일부 경우에서는 표준 패키지로도 충분히 사용 가능할 정도로 많이 개선된 것 같아서 이런 변화가 기분이 좋습니다.