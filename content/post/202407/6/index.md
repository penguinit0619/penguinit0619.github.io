+++
author = "penguinit"
title = "Docker Compose에서 서비스 의존성 제어 방법"
date = "2024-07-14"
description = "Docker Compose를 사용할 때 서비스 간의 의존성을 제어하는 것은 매우 중요합니다. 특히 복잡한 애플리케이션에서 서비스의 시작 순서와 종료 순서를 관리하는 것은 필수적입니다. 해당 포스터에서는 서비스 의존성을 제어하는 다양한 방법과 예제를 살펴보겠습니다."
tags = [
"docker-compose", "dependency"
]
categories = [
"infra"
]
+++

## 개요
Docker Compose를 사용할 때 서비스 간의 의존성을 제어하는 것은 매우 중요합니다. 특히 복잡한 애플리케이션에서 서비스의 시작 순서와 종료 순서를 관리하는 것은 필수적입니다. 해당 포스터에서는 서비스 의존성을 제어하는 다양한 방법과 예제를 살펴보겠습니다.

## 디렉토리 구조
다음과 같은 디렉토리 구조를 가정하고 진행하겠습니다. 만약에 설명 중에 별도의 언급이 없다면 이전파일과 동일하다고 가정합니다.

```
/
├── docker-compose.yml
├── go.mod 
└── web/
├──── Dockerfile
└──── main.go
```

## depends_on 속성 사용하기
`depends_on` 속성은 서비스 간의 기본적인 의존성을 설정하는 데 사용됩니다.


- web/main.go
```go
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello, World!")
	})
	http.ListenAndServe(":8080", nil)
}
```

- web/Dockerfile
```dockerfile
FROM golang:1.22

WORKDIR /app

COPY go.mod ./
COPY web/main.go ./

RUN go mod tidy

RUN go build -o main .

CMD ["./main"]
```

- docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: web/Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
```

위의 예제에서는 web 서비스가 db 서비스에 의존하도록 설정되어 있습니다. 따라서 docker-compose up 명령을 실행하면 db 서비스가 먼저 시작되고 web 서비스가 시작됩니다.

하지만 `depends_on` 속성은 서비스가 시작되는 것을 보장하지 않습니다. 기본적으로 `depends_on`은 의존하는 서비스의 컨테이너 상태가 running인지만 확인합니다. 따라서 서비스가 시작되는 것을 보장하려면 `healthcheck`을 사용해야합니다.

## healthcheck을 사용하기
`healthcheck`을 사용하면 서비스가 시작되는 것을 보장할 수 있습니다.

- web/main.go
```go
package main

import (
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"net/http"
)

func main() {
	db, err := sql.Open("postgres", "postgres://user:password@db/mydb?sslmode=disable")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// 데이터베이스 연결 확인
	err = db.Ping()
	if err != nil {
		log.Fatal(err)
	}

	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request for path: %s", r.URL.Path)
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		fmt.Fprintf(w, "Hello, World!")
	})

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received health check request")
		err := db.Ping()
		if err != nil {
			log.Printf("Database health check failed: %v", err)
			http.Error(w, "Database not available", http.StatusServiceUnavailable)
			return
		}
		fmt.Fprintf(w, "OK")
	})

	log.Println("Server is running on :8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatal(err)
	}
}
```

- docker-compose.yml
```yaml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: web/Dockerfile
    ports:
      - "8080:8080"
    depends_on:
      db:
        condition: service_healthy
  db:
    image: postgres:13
    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d mydb"]
      interval: 10s
      timeout: 5s
      retries: 5
```

## 정리
`depends_on` 속성을 사용하면 서비스 간의 기본적인 의존성을 설정할 수 있고, `healthcheck을 사용하면 서비스가 정상적으로 동작하는지 확인할 수 있습니다. docker-compose를 사용할 때는 보통 여러 컨테이너를 함께 실행하게 되는데 이런 의존성 관리를 잘 해야만 문제 없는 서비스를 운영할 수 있습니다. 해당 내용이 도움이 되었으면 좋겠습니다.
