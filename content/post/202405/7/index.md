+++
author = "penguinit"
title = "Golang에서 loop 레이블을 사용하는 이유"
date = "2024-05-29"
description = "Golang에서 loop 레이블을 사용해야만 하는 케이스가 있습니다. 이번 포스팅에서는 loop 레이블을 사용하는 이유에 대해서 알아보려고 합니다."
tags = [
"golang"
]
categories = [
"language"
]
+++

## 개요
Golang에서 loop 레이블을 사용해야만 하는 케이스가 있습니다. 이번 포스팅에서는 loop 레이블을 사용하는 이유에 대해서 알아보려고 합니다.

## Loop 레이블 사용의 필요성
Loop 레이블은 중첩된 루프 구조에서 특정 루프를 명확하게 빠져나오거나 건너뛸 때 사용됩니다. 단순 break 문으로는 해당 루프만 빠져나오기 때문에 중첩된 루프에서 특정 루프를 빠져나오거나 건너뛸 때 사용합니다.

```go
package main

import "fmt"

func main() {
    outerLoop:
    for i := 0; i < 5; i++ {
        for j := 0; j < 5; j++ {
            switch {
            case i == 3 && j == 3:
                fmt.Println("Breaking out of both loops")
                break outerLoop
            default:
                fmt.Printf("i: %d, j: %d\n", i, j)
            }
        }
    }
    fmt.Println("Exited the outer loop")
}
```

이 예제에서 i와 j가 모두 3일 때, outerLoop 레이블을 사용하여 두 개의 루프를 모두 빠져나옵니다. 만약 레이블이 없다면, switch 문 내에서 break는 가장 안쪽의 루프만 벗어나게 됩니다.

## Loop 레이블에 대한 비난
Loop 레이블 사용은 종종 goto 문과 유사하다는 비판을 받습니다. goto와 동일한 기능을 하고는 있지만 loop 레이블은 루프 내에서 특정 목적을 가지고 사용되는 것이 일반적입니다. 실제로 **Go 표준 라이브러리**에서도 Loop 레이블을 사용하고 있습니다.

- net/http 패키지 내부에 버퍼에서 데이터를 읽어오는 함수에서 사용 : [파일링크](https://github.com/golang/go/blob/13c49096fd3b08ef53742dd7ae8bcfbfa45f3173/src/net/http/cgi/host_test.go#L65)
```go
readlines:
	for {
	    line, err := rw.Body.ReadString('\n')
        switch {
        case err == io.EOF:
            break readlines
        case err != nil:
			t.Fatalf("Unexpected error reading from CGI: %v", err)
        }
		// ...
    }
```

## 정리
이번 포스팅에서는 Golang에서 loop 레이블을 사용하는 이유에 대해서 알아보았습니다. loop 레이블은 중첩된 루프 구조에서 특정 루프를 명확하게 빠져나오거나 건너뛸 때 사용됩니다. goto와 용도가 비슷해서 사용하는 것을 나쁘게 생각하는 경우가 있는데 loop 레이블은 루프 구조에서만 사용되는 것이 일반적이기에 무조건 비난할 필요는 없다고 생각합니다.