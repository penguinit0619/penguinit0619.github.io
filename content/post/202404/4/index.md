+++
author = "penguinit"
title = "Golang workspace에 대해서 자세히 알아보기 1편"
date = "2024-04-19"
description = "이번 포스팅에서는 Golang 1.18 버전에 추가 되었던 workspace에 대해서 자세히 알아보고 어떻게 구성하는지에 대해서 알아보겠습니다."
tags = [
"golang", "workspace"
]
categories = [
"language"
]
+++

## 개요
이번 포스팅에서는 Golang 1.18 버전에 추가 되었던 workspace에 대해서 자세히 알아보고 어떻게 구성하는지에 대해서 알아보겠습니다.

## Golang workspace
Go 1.18 버전부터 `go work` 명령어를 사용하여 workspace를 설정하고 관리할 수 있습니다. 특히 복잡한 프로젝트를 다룰 때 유용하며, 만약 프로젝트를 모노레포로 관리할 경우 여러 의존성과 모듈들을 효과적으로 관리할 수 있습니다. 또 여러개의 모듈에 대해서 통합테스트를 하는데 있어서도 도움을 받을 수 있습니다.

하지만 유의해야 할 점은 go workspace로 관리하는 것도 적정 수준 안에서의 이야기고 프로젝트가 너무 방대해지면 저는 개인적으로는 각자 용도에 맞게 다른 저장소로 분리하는 것이 좋다고 생각합니다.

특히 거대한 양의 코드 베이스를 IDE로 열 때는 느려질 수 있으며, 유지 보수 측면에서도 큰 코드 베이스가 주는 단점들을 잘 고려해 보시는 게 좋습니다.

## 사용법
golang의 철학이 그렇듯 go workspace도 간단하게 사용할 수 있습니다. 우선 `go work` 명령어를 수행하면 아래같이 HELP 명령어가 나오게 됩니다.

```bash

To determine whether the go command is operating in workspace mode, use
the "go env GOWORK" command. This will specify the workspace file being
used.

Usage:

        go work <command> [arguments]

The commands are:

        edit        edit go.work from tools or scripts
        init        initialize workspace file
        sync        sync workspace build list to modules
        use         add modules to workspace file
        vendor      make vendored copy of dependencies

Use "go help work <command>" for more information about a command.
```

### 데모를 위한 사전설정
우선 상황을 가정하려고 합니다. 저희는 간단하게 덧셈/뺄셈을 하는 출력 프로그램을 만들려고 합니다. 이를 위해서 저희는 3가지 모듈을 가정합니다.

- minus
- plus
- calculator

각각 용도에 맞는 모듈 파일을 만들어서 각각의 기능을 구현하고 이를 calculator main.go에서 호출하는 형태로 만들어보겠습니다.

#### 디렉토리 구조

```
.
├── minus/
│   ├── minus.go
│   ├── go.mod
|   └── go.sum
├── plus/
│   ├── plus.go
│   ├── go.mod
│   └── go.sum
└── calculator/
    ├── main.go
    ├── go.mod
    └── go.sum
```

#### minus 모듈

```go
package minus

func Do(a, b int) int {
	return a - b
}

```

#### plus 모듈

```go
package plus

func Do(a, b int) int {
	return a + b
}
```

### replace를 사용해서 여러 모듈 관리하기

calculator 모듈은 위에 2개의 모듈을 참조해서 덧셈/뺄셈을 수행하고 결과를 출력하는 형태로 만들어보겠습니다.

각각에 모듈을 참조하려면 1.18버전 이전에는 replace 명령을 이용해서 아래와 같이 작성을 해야만 했습니다.

```go
module github.com/math/calculator

go 1.22.1

replace (
	github.com/math/minus => ../minus
	github.com/math/plus => ../plus
)

require (
	github.com/math/minus v0.0.0-00010101000000-000000000000
	github.com/math/plus v0.0.0-00010101000000-000000000000
)
```

#### calculator main.go
    
```go
package main

import (
	"fmt"
	"github.com/math/minus"
	"github.com/math/plus"
)

func main() {

	v1 := minus.Do(5, 1)
	v2 := plus.Do(v1, 4)

	fmt.Println("result is :", v2)
}
```

원격 저장소에 올리고 해당 모듈을 다운로드 받는 방식도 가능하지만 여러가지 이유로 모노레포로 관리하고 싶은 경우에는 이게 지금까지 최선이었습니다.
하지만 이런 방식은 모듈간의 의존성을 관리가 쉽지 않습니다. 여러 모듈을 동시에 개발하는 경우, 각 모듈의 의존성을 수동으로 관리해야 하고, replace 지시어를 사용하여 로컬 경로를 지정해야 하는 등의 추가적인 설정 작업이 필요합니다.

하지만 go workspace를 사용하면 이런 문제를 해결할 수 있습니다.

### go workspace 사용하기
우선 최상위 루트 디렉토리에서 아래 go work init 명령어를 수행하면 go.work 파일이 생성됩니다. 해당 파일을 들어가보시면 아무런 데이터도 들어가 있지 않습니다. 
workspace 기능을 사용하기 위해서 go work use 명령어를 사용해서 모듈을 추가해보겠습니다.

```bash
go work use ./minus
go work use ./plus
go work use ./calculator
```

위와 같이 명령어를 수행하면 go.work 파일에 아래와 같이 모듈들이 추가됩니다.

```go
go 1.22.1

use (
	./calculator
	./minus
	./plus
)
```

기존에 있었던 예제에서는 각 모듈별로 의존성 관리를 하고 있었기 때문에 go.sum 파일을 모듈별로 가지고 있는 것을 확인할 수 있습니다. 
하지만 워크스페이스로 관리되는 프로젝트는 루트 디렉토리에 go.work.sum 단일 파일을 하나 가집니다.

go.work.sum 파일은 아래 명령어를 통해서 생성할 수 있습니다.

```bash
go work sync
```

#### 프로젝트 구조
최종적으로 golang workspace로 관리되는 프로젝트 구조는 아래와 같습니다.
```
.
├── minus/
│   ├── minus.go
│   └── go.mod
├── plus/
│   ├── plus.go
│   └── go.mod
├── calculator/
│   ├── main.go
│   └── go.mod
├── go.work
└── go.work.sum
```

## 정리
이번 포스팅에서는 Golang 1.18 버전에 추가 되었던 workspace에 대해서 기본적인 내용들에 대해 알아보았습니다. 의도적으로 다루지 못한 얘기들이 몇 있는데 길어질 것 같아서 해당 내용은 다음 포스팅에서 다루도록 하겠습니다.