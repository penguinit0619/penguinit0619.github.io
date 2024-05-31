+++
author = "penguinit"
title = "Avro에 대해서 알아보기"
date = "2024-05-31"
description = "최근에 Kafka를 사용해서 프로젝트를 진행하고 있습니다. 현재는 JSON으로 데이터를 관리하고 있는데 읽거나 디버깅에는 좋지만 성능이나, 스키마 관리가 안되는 단점이 있습니다. Avro는 이런 단점들을 보완할 수 있는 방법 중 하나인데 이번 포스팅에서 자세히 알아보려고 합니다."
tags = [
"avro"
]
categories = [
"serialization"
]
+++

## 개요
최근에 Kafka를 사용해서 프로젝트를 진행하고 있습니다. 현재는 JSON으로 데이터를 관리하고 있는데 디버깅에는 좋지만 성능이나, 스키마 관리가 안되는 단점이 있습니다. Avro는 이런 단점들을 보완할 수 있는 방법 중 하나인데 이번 포스팅에서 자세히 알아보려고 합니다.

## Kafka에서 JSON 사용
Kafka에서 데이터를 주고 받을 때 JSON을 사용하면 다음과 같은 단점이 있습니다.

- JSON은 텍스트 기반의 데이터 포맷이기 때문에 크기가 크고, 직렬화/역직렬화 속도가 느립니다.
- 스키마 관리가 어렵습니다. 데이터의 필드가 추가되거나 변경될 때, 모든 데이터를 업데이트 해야 합니다.
- JSON은 데이터의 타입을 명확하게 표현하지 않기 때문에 데이터의 무결성을 보장하기 어렵습니다.
- JSON은 데이터의 필드명을 텍스트로 표현하기 때문에 데이터의 크기가 커집니다.

위에 단점 중에서 성능과 스키마 관리가 가장 큰 문제입니다. 데이터가 크지 않을 때는 문제가 안되지만 데이터가 커지면 성능이 떨어지고, 특히 변경이 잦은 스키마의 경우에는 관리가 어렵습니다.

예를 들어서 아래와 같이 특정 필드의 타입을 변경한다고 가정해보겠습니다.


- AS-IS
```json
{
  "id": 1,
  "name": "penguinit",
  "age": 30
}
```

- TO-BE
```json
{
  "id": 1,
  "email_name": "penguinit",
  "age": 30,
  "email": "penguinit0619@gmail.com"
}
```

위에 예시처럼 필드명이 변경되거나, 필드가 추가되는 경우에는 모든 데이터를 업데이트 해야합니다. 또한 이전에 호환성을 유지하기 위해서 필드명을 변경하거나, 필드를 추가할 때 별도의 로직을 추가해야 할 수도 있습니다.
필드의 추가는 문제가 되지 않을 수 있지만 변경의 경우에는 `name`과 `email_name`이 동시에 존재할 수 있기 때문에 데이터의 무결성을 보장하기 어렵습니다.

## Avro란?
Avro는 Apache Hadoop의 하위 프로젝트로 데이터 직렬화 포맷입니다. Avro는 JSON과 유사하지만, JSON보다 빠르고, 스키마 관리가 쉽습니다. Avro는 데이터의 스키마를 정의하고, 데이터를 직렬화할 때 스키마를 함께 저장하기 때문에 데이터의 무결성을 보장할 수 있습니다.

- 빠른 직렬화/역직렬화 속도
- 데이터의 크기가 작음
- 데이터의 타입을 명확하게 표현
- 데이터의 스키마를 함께 저장하기 때문에 데이터의 무결성을 보장

Json은 스키마가 없고 데이터의 타입을 명확하게 표현하지 않기 때문에 데이터의 무결성을 보장하기 어렵다고 했는데 Avro에서는 위에 케이스를 아래처럼 정의할 수 있습니다.

- Avro 스키마 정의
```json
{
  "type": "record",
  "name": "User",
  "fields": [
    {"name": "id", "type": "int"},
    {
      "name": "email_name",
      "type": "string",
      "aliases": ["name"],
      "default": ""
    },
    {"name": "age", "type": "int"},
    {
      "name": "email",
      "type": ["null", "string"],
      "default": null
    }
  ]
}
```

- email_name: 새로운 필드 이름으로 정의되었으며, 이전 이름인 name과의 호환성을 위해 aliases 속성이 사용되었습니다.
- email: 새로운 필드로 추가되었으며, 기본값으로 null을 가집니다.


### Go를 이용한 Avro 예시
위에 예시를 이용를 참조하여 Avro 스키마를 정의하고, Go 언어를 이용하여 Avro 데이터를 직렬화/역직렬화 하는 예시를 보겠습니다.

```go
package main

import (
	"fmt"
	"log"

	"github.com/linkedin/goavro/v2"
)

func main() {
	// Avro 스키마 정의
	schema := `{
        "type": "record",
        "name": "User",
        "fields": [
            {"name": "id", "type": "int"},
            {
              "name": "email_name",
              "type": "string",
              "aliases": ["name"],
              "default": ""
            },
            {"name": "age", "type": "int"},
            {
              "name": "email",
              "type": ["null", "string"],
              "default": null
            }
        ]
    }`

	// 코덱 생성
	codec, err := goavro.NewCodec(schema)
	if err != nil {
		log.Fatal(err)
	}

	// 기존 데이터 준비 (AS-IS)
	oldData := map[string]interface{}{
		"id":   1,
		"name": "penguinit",
		"age":  30,
	}

	// 직렬화 (AS-IS 데이터)
	binaryOld, err := codec.BinaryFromNative(nil, oldData)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Serialized Old Data:", binaryOld)

	// 새로운 데이터 준비 (TO-BE)
	newData := map[string]interface{}{
		"id":         1,
		"email_name": "penguinit",
		"age":        30,
		"email":      map[string]interface{}{"string": "penguinit0619@gmail.com"},
	}

	// 직렬화 (TO-BE 데이터)
	binaryNew, err := codec.BinaryFromNative(nil, newData)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Serialized New Data:", binaryNew)

	// 역직렬화
	nativeOld, _, err := codec.NativeFromBinary(binaryOld)
	if err != nil {
		log.Fatal(err)
	}

	nativeNew, _, err := codec.NativeFromBinary(binaryNew)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Deserialized Old Data:", nativeOld)
	fmt.Println("Deserialized New Data:", nativeNew)
}
```

- 결과
```
Serialized Old Data: [2 0 60 0]
Serialized New Data: [2 18 112 101 110 103 117 105 ...]
Deserialized Old Data: map[age:30 email:<nil> ...]
Deserialized New Data: map[age:30 email:map[string:...] email_name:penguinit id:1]
```

## 정리
이번 포스팅에서는 Avro에 대해서 알아보았습니다. Avro는 데이터의 직렬화/역직렬화를 빠르게 수행할 수 있고 데이터 크기가 작아 대규모 데이터를 처리할 때 유용합니다. 시간이 지남에 따라 스키마가 복잡해지면서 관리에 어려움을 겪을 수 있는데 Avro는 이런 문제를 해결할 수 있는 좋은방법 중 하나입니다.