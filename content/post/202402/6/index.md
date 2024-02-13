+++
author = "penguinit"
title = "Golang에서 시간은 어떻게 저장하고 관리해야 할까"
date = "2024-02-13"
description = "해당 포스팅을 통해서 Golang에서 기본적으로 제공하는 time 패키지에 대해서 알아보고 시간 데이터를 저장하고 사용할 때 유의해야 할 점들에 대해서 알아봅니다."
tags = [
"golang"
]

categories = [
"language"
]
+++

## 개요

해당 포스팅을 통해서 Golang에서 기본적으로 제공하는 time 패키지에 대해서 알아보고 시간 데이터를 저장하고 사용할 때 유의해야 할 점들에 대해서 알아봅니다.

## Time 패키지

**`time`** 패키지는 시간 관련 기능을 제공하는 Golang 표준 라이브러리 패키지입니다. 이를 활용하면 현재 시간 조회, 시간 비교, 시간 덧셈 및 뺄셈, 시간 포맷팅 등 다양한 시간 관련 작업을 수행할 수 있습니다.

### 현재 시간 조회

Golang에서 현재 시간을 조회하는 방법은 아주 간단합니다.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	fmt.Println("현재 시간:", currentTime)
}
```

### 시간 포맷팅

**`time`** 패키지는 시간을 다양한 형식으로 포맷팅할 수 있는 기능을 제공합니다. **`Time.Format`** 메서드를 사용하여 원하는 형식의 문자열로 시간을 변환할 수 있습니다.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	fmt.Println("기본 포맷:", currentTime.Format("2006-01-02 15:04:05"))
	fmt.Println("RFC1123 포맷:", currentTime.Format(time.RFC1123))
}
```

### 시간 연산

시간 더하기 및 빼기 연산도 매우 간단합니다. **`time.Add`** 메서드를 사용하여 특정 시간 간격을 더하거나 뺄 수 있습니다.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	oneWeekLater := currentTime.Add(7 * 24 * time.Hour)
	fmt.Println("일주일 후:", oneWeekLater)
}
```

## 타임존 다루기

Golang의 **`time`** 패키지에서 다루는 시간은 기본적으로 타임존(time zone) 정보를 포함하고 있습니다. 이를 통해 다양한 시간대에서의 시간 계산과 변환을 쉽게 할 수 있습니다. 다만 유의해야 할 것은 **`time`** 패키지를 사용할 때 타임존(Time Zone)을 별도로 명시하지 않으면, 기본적으로 Golang이 실행되는 환경의 로컬 타임존이 사용됩니다.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// 로컬 타임존을 사용하여 현재 시간을 출력
	currentTime := time.Now()
	fmt.Println("현재 시간(로컬 타임존):", currentTime)

	// UTC로 현재 시간을 출력
	utcTime := time.Now().UTC()
	fmt.Println("현재 시간(UTC):", utcTime)
}
```

### Golang에서 전역적으로 타임존 변경하기

Golang 자체에서 프로그램 실행 중 전역적으로 타임존을 변경하는 기능을 직접 제공하지는 않습니다. 대신, 시스템 또는 환경 변수를 통해 타임존을 설정할 수 있습니다.

```bash
export TZ=Asia/Seoul
./my_go_application
```

### 도커에서 타임존 변경하기

Docker 컨테이너의 기본 타임존은 일반적으로 UTC로 설정되어 있습니다. 컨테이너 내의 타임존을 변경하기 위해서는 다음 방법 중 하나를 사용할 수 있습니다.

```docker
RUN apk add --no-cache tzdata \
    && ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo "Asia/Tokyo" > /etc/timezone
```

## JSON 문자열과 Time 패키지

Golang에서 JSON 타입을 **`time.Time`** 타입으로 unmarshal할 때, 타임존 처리는 JSON 문자열에 포함된 날짜와 시간 데이터의 형식에 따라 달라집니다. 기본적으로, JSON 내의 날짜와 시간 문자열이 RFC 3339 표준(예: **`2006-01-02T15:04:05Z07:00`**)을 따르고 있으면, 이 표준에 따라 타임존 정보를 포함할 수 있습니다.

이때, JSON 문자열에 타임존 정보가 명시되어 있지 않으면, Go의 **`time.Time`** 타입은 해당 시간을 UTC로 해석합니다.

```go
package main

import (
	"encoding/json"
	"fmt"
	"time"
)

type EventWithTimezone struct {
	StartTime time.Time `json:"start_time"`
}

func main() {
	jsonStringWithTimezone := `{"start_time": "2024-02-13T15:04:05+09:00"}`
	jsonStringWithoutTimezone := `{"start_time": "2024-02-13T15:04:05"}`

	var eventWithTimezone EventWithTimezone
	var eventWithoutTimezone EventWithTimezone

	// 타임존 정보를 포함하는 JSON unmarshal
	if err := json.Unmarshal([]byte(jsonStringWithTimezone), &eventWithTimezone); err != nil {
		fmt.Println("Unmarshal with timezone failed:", err)
		return
	}
	fmt.Println("With timezone:", eventWithTimezone.StartTime)

	// 타임존 정보를 포함하지 않는 JSON unmarshal
	if err := json.Unmarshal([]byte(jsonStringWithoutTimezone), &eventWithoutTimezone); err != nil {
		fmt.Println("Unmarshal without timezone failed:", err)
		return
	}
	// 기본적으로 UTC로 해석됩니다.
	fmt.Println("Without timezone (interpreted as UTC):", eventWithoutTimezone.StartTime)
}
```

JSON 데이터를 처리할 때는 위와 같은 동작을 고려하여 적절한 타임존 처리를 해야 합니다.

## MYSQL 시간관련 타입과 Golang 타임존 처리

MySQL에서 **`DATETIME`** 과 **`TIMESTAMP`** 타입 모두 날짜와 시간을 저장하는 데 사용되지만, 타임존을 다루는 방식에서 차이가 있습니다.

- **`DATETIME`**: 이 타입은 타임존 정보 없이 날짜와 시간을 저장합니다. 즉, **`DATETIME`** 타입은 데이터베이스 서버의 타임존 설정에 영향을 받지 않으며, 애플리케이션에서 별도로 시간대를 관리해야 합니다.
- **`TIMESTAMP`**: **`TIMESTAMP`** 타입은 UTC로 변환하여 저장하고, 조회 시에는 현재 MySQL 서버의 타임존 설정을 기준으로 변환하여 반환합니다. 이는 **`TIMESTAMP`** 타입이 내부적으로 타임존 정보를 고려한다는 것을 의미합니다.

예를 들어, 서울 시간대에서 **`2023-01-01 12:00:00`** 을 **`DATETIME`** 과 **`TIMESTAMP`** 타입으로 각각 저장하면, **`DATETIME`** 타입은 그대로 **`2023-01-01 12:00:00`** 로 저장되지만, **`TIMESTAMP`** 타입은 UTC로 변환되어 저장됩니다.  즉 Seoul/Asia가 UTC+9  값을 가지고 있음으로 데이터베이스에 저장은 **`2023-01-01 03:00:00`** 으로 저장되게 됩니다.

### 데이터 바인딩

Golang에서 대다수의 DB 드라이브에서 컬럼들을 객체에 맵핑해주는 기능들을 제공하는데 이때 저장된 시간 관련 데이터들이 타입에 따라 어떻게 바인딩이 되는지에 대해서 알아보려고 합니다.

우선 **`DATETIME`** 의 경우에는 타임존이 없기 때문에 타임존이 없는 형태로 값이 바인딩 되게 됩니다. 사용하다 보면 명시적으로 특정 시간대의 시간 데이터를 만들어야 하는 경우가 있는데 이때 확인해 보시면 타임존이 없어도 시간을 생성할 수 있음을 알 수 있습니다.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// 타임존 없는 시간 생성
	// 예시 1: time.Date 함수와 nil Location 사용
	noZoneTime := time.Date(2023, time.January, 1, 0, 0, 0, 0, nil)
	fmt.Println("타임존 없는 시간 예시 1:", noZoneTime)
}
```

두번째로 **`TIMESTAMP`** 입니다. **`DATETIME`** 과 다르게 타임존을 가지고 있고 데이터를 불러올 때는 Golang 서버의 타임존에 영향을 받습니다. 예를 들어서 현재 서울로 서버의 타임존이 설정이 되어있다면 UTC 타임존이 서울 타임 존으로 변경이 되어서 객체에 바인딩 됩니다.

## 정리

해당 포스팅을 통해서 Golang의 Time 패키지에 대해서 간략하게 알아보았고 클라이언트나 DB에서 시간을 가지고 작업을 할 때 타임존에 대해서 유의를 해야 하는 부분들이 있는데 해당 부분에 대해서 상세한 코드와 함께 정리하였습니다. 어떻게 관리하느냐는 프로젝트마다 성격에 따라 달라질 수 있는 부분으로 보이지만 그럼에도 불구하고 시간 데이터를 정확히 처리하려면, 데이터베이스 서버와 애플리케이션 클라이언트 간에 일관된 타임존 처리가 중요합니다.

특히 다국적 사용자를 대상으로 하는 애플리케이션에서는 이런 타임존을 명확하게 관리하는 것이 중요합니다.