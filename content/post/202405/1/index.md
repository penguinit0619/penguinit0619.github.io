+++
author = "penguinit"
title = "Go Module에 대해서 자세히 알아보기"
date = "2024-05-14"
description = "node의 NPM과 같이 Golang 생태계에서는 의존성들을 관리하기 위해서 내장되어있는 Go Module을 사용합니다. Go Module이전에도 여러가지 방식들이 있었지만 Go 1.11 버전부터 공식적으로 지원이 되었고, Go 1.13 버전부터는 Go Module을 사용하는 것이 권장되고 있습니다."
tags = [
"golang", "module"
]
categories = [
"language"
]
+++

## 개요
node의 NPM과 같이 Golang 생태계에서는 의존성들을 관리하기 위해서 내장되어있는 Go Module을 사용합니다. Go Module이전에도 여러가지 방식들이 있었지만 Go 1.11 버전부터 공식적으로 지원이 되었고, Go 1.13 버전부터는 Go Module을 사용하는 것이 권장되고 있습니다.

## 사용법
Go Module을 사용하기 위해서는 Go 1.11 버전 이상이 필요합니다. Go Module을 사용하기 위해서는 아래와 같이 `go mod init` 명령어를 사용해서 초기화를 해주어야 합니다.
모듈의 이름은 보통 작성하신다면 아래 같은 기준으로 작성하게 됩니다.

✅ **github.com/{orgs}/{repo}**

```bash
$ go mod init github.com/penguinit/gomodule
```

루트 폴더에서 수행하게 되면 go.mod 파일이 생성되고 아래와 같은 내용이 들어가게 됩니다.

```go
module github.com/penguinit/gomodule

go 1.22
```

### 의존성 선언
만약에 다른 모듈을 사용하고 싶다면 `go get` 명령어를 사용해서 의존성을 추가할 수 있습니다.

@v1.7.1은 해당 모듈의 버전을 명시하는 것이고, 만약에 명시하지 않는다면 최신 버전을 가져오게 됩니다.

```bash
$ go get github.com/google/uuid@v1.6.0
```

`go get` 명령어를 사용하게 되면 go.mod 파일에 의존성이 추가되게 됩니다.

```go
module github.com/penguinit/gomodule

go 1.22

require github.com/google/uuid v1.6.0

```

위에 방식처럼 명령어를 통해서 의존성을 추가할 수 있지만 go mod download 명령어를 사용해서 go.mod 파일에 있는 의존성을 다운로드 받을 수 있습니다.

```bash
$ go mod download
```

## go.sum 파일
위 명령어를 통해서 의존성을 추가하게 되면 go.sum 파일이 생성되게 됩니다. go.sum 파일은 의존성 모듈의 해시값을 가지고 있어서 의존성 모듈의 버전을 고정시키는 역할을 합니다.

```bash
github.com/google/uuid v1.6.0 h1:NIvaJDMOsjHA8n1jAhLSgzrAzy1Hgr+hNrb57e+94F0=
github.com/google/uuid v1.6.0/go.mod h1:TIyPZe4MgqvfeYDBFedMoGGpEw/LqOeaOT+nhxU+yHo=
```

첫 번째 항목은 의존성 모듈의 실제 코드에 대한 해시 값을 나타내고, 두 번째 항목은 모듈 파일(go.mod)에 대한 해시 값을 나타냅니다.

### go.sum 파일의 역할
go.sum 파일의 가장 주요한 역할은 의존성의 무결성 검증과 재현 가능한 빌드의 보장에 있습니다. go.sum 파일은 의존성 모듈의 버전을 고정시키는 역할을 하기 때문에 의존성 모듈의 버전이 변경되어도 go.sum 파일을 통해서 이전 버전의 의존성 모듈을 다운로드 받을 수 있습니다. 또한 모듈의 해시값을 가지고 있기 떄문에 외부에서 어떤 악의적인 변조가 있을 경우 go.sum 파일을 통해서 확인할 수 있습니다.

그래서 보통은 위와 같은이유로 go.sum은 원격저장소에 같이 포함되어서 관리가 됩니다.


## go mod tidy
프로젝트를 운영하다 보면 go.mod 파일에 필요 없는 의존성이 남아있을 수 있습니다. 이럴 때 go mod tidy 명령어를 사용해서 go.mod 파일에 필요한 의존성만 남기고 나머지는 제거할 수 있습니다.

```bash
$ go mod tidy
```

## go clean -modcache
go mod tidy로 불필요한 의존성을 정리를 함에도 불구하고 프로젝트가 커지다 보면 내부 모듈 캐시가 커질 수 있습니다. 이럴 때 go clean -modcache 명령어를 사용해서 모듈 캐시를 정리할 수 있습니다. 

```bash
$ go clean -modcache
```

## indirect 의존성
go.mod 파일에는 require 외에도 indirect라는 키워드가 있습니다. indirect는 간접적인 의존성을 나타내는 키워드로 직접적으로 사용되지 않는 의존성을 나타냅니다.


### viper 모듈 설치
```bash
go get github.com/spf13/viper
```

viper 모듈 설치로 인해서 go.mod 파일에 indirect 의존성이 추가되게 됩니다.

```go
module github.com/penguinit/gomodule

require (
	github.com/google/uuid v1.6.0
	github.com/spf13/viper v1.18.2
)

require (
	github.com/fsnotify/fsnotify v1.7.0 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/magiconair/properties v1.8.7 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/pelletier/go-toml/v2 v2.1.0 // indirect
	github.com/sagikazarmark/locafero v0.4.0 // indirect
	github.com/sagikazarmark/slog-shim v0.1.0 // indirect
	github.com/sourcegraph/conc v0.3.0 // indirect
	github.com/spf13/afero v1.11.0 // indirect
	github.com/spf13/cast v1.6.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/subosito/gotenv v1.6.0 // indirect
	go.uber.org/atomic v1.9.0 // indirect
	go.uber.org/multierr v1.9.0 // indirect
	golang.org/x/exp v0.0.0-20230905200255-921286631fa9 // indirect
	golang.org/x/sys v0.15.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	gopkg.in/ini.v1 v1.67.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)
```

위에처럼 indirect 의존성은 직접적으로 사용되지 않는 의존성을 나타내고 실제로 indirect 의존성을 지우더라도 프로젝트에는 영향을 주지 않습니다.

만약 의도적으로 indirect 의존성을 지우더라도 `go mod tidy` 명령어를 사용하게 되면 다시 indirect 의존성이 추가되게 됩니다.

## 의존성 충돌
만약에 이런 indirect 의존성이 여러 개가 있을 때 의존성 충돌이 발생할 수 있습니다. 예를 들어서 아래와 같은 상황이 있다고 가정해 보겠습니다.

- A 모듈 : C 모듈 1.4 버전을 사용 중
- B 모듈 : C 모듈 1.2 버전을 사용 중

이 경우에는 indirect 의존성이 각자 생길 것 같지만 Go는 동일한 프로젝트 내에서 동일한 모듈의 여러 버전을 허용하지 않습니다. Go Module에서는 이러한 충돌이 있을 때 최신 버전을 선택하여 의존성을 해결합니다. 즉 이 경우에는 B모듈이 C 모듈의 1.4 버전을 사용하게 됩니다.

하지만 B모듈이 1.4버전을 쓰게 될 경우 문제가 생기는 케이스도 있을 수 있는데 이 경우에는 포크를 하거나 별도의 프로젝트를 만들고 replace 지시어를 통해서 의존성을 해결할 수 있습니다. 이 부분은 내용이 길어질 수도 있어서 따로 시간이 되면 별도 주제로 포스팅을 해보겠습니다. 

## 정리
해당 포스팅에서는 Go Module이 무엇이고 어떻게 사용되는지에 대해서 상세하게 알아보았습니다. 무의식적으로 쓰는 명령어들이지만 실제로는 어떤 역할을 하는지 알고 사용하는 것이 중요하다고 생각합니다. Go Module은 Go 언어의 의존성 관리를 위한 표준화된 방법이기 때문에 Go를 사용하는 개발자라면 꼭 알고 있어야 할 내용이라고 생각합니다.
