+++
author = "penguinit"
title = "Golang으로 알아보는 Mocking과 Stubbing"
date = "2024-02-15"
description = "유닛 테스트를 작성할 때, Mocking과 Stubbing은 많은 도움을 줄 수 있습니다. 이번 포스팅에서는 Mocking과 Stubbing이 무엇이며 어떤 차이점을 가지는지 알아보고, Golang 예제 코드를 통해 더 자세히 이해해 보도록 하겠습니다."
tags = [
"golang", "mocking", "stubbing"
]

categories = [
"language", "testing"
]
+++

# 

## 개요

유닛 테스트를 작성할 때, Mocking과 Stubbing은 많은 도움을 줄 수 있습니다. 이번 포스팅에서는 Mocking과 Stubbing이 무엇이며 어떤 차이점을 가지는지 알아보고, Golang 예제 코드를 통해 더 자세히 이해해 보도록 하겠습니다.

## Mocking이란

Mocking은 객체의 행동을 시뮬레이션합니다. 이는 테스트 대상 코드가 외부 시스템, 메소드, 또는 다른 클래스와 상호작용할 때 사용됩니다. **Mock 객체는 기대하는 행동(예: 메소드 호출, 반환 값)을 정의하고, 실제 코드가 이러한 기대를 충족하는지 검증하는 데 사용됩니다**. Mocking은 주로 **행동 검증**(behavior verification)에 초점을 맞춥니다.

## Stubbing이란

Stubbing은 테스트 중인 코드가 호출하는 메소드로부터 **특정한 응답**을 반환하기 위해 사용됩니다. Stub 객체는 테스트 중인 코드가 의존하는 다른 컴포넌트를 대신하여, 미리 정의된 응답을 제공합니다. Stubbing은 주로 **상태 검증**(state verification)에 사용되며, 테스트 케이스가 예상하는 상태 변경이나 반환 값을 검증하는 데 초점을 맞춥니다.

## Mocking과 Stubbing의 차이

Mocking과 Stubbing은 모두 소프트웨어 테스트, 특히 단위 테스트에서 사용되는 기술로, 외부 의존성을 제거하거나 단순화하여 테스트 대상 코드의 독립적인 검증을 가능하게 합니다. 이 두 방식은 비슷해 보일 수 있지만, 사용 목적과 방법에 있어 중요한 차이점이 있습니다.

참조 : [https://martinfowler.com/bliki/TestDouble.html](https://martinfowler.com/bliki/TestDouble.html)

### Mocking 검증방식

![[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)](images/Untitled.png)

[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)

Mock 객체는 일반적으로 테스트에서 설정한 특정 메서드 호출이 기대한 대로 이루어지는지 검증합니다. 예를 들어, 특정 메서드가 특정 인자와 함께 호출되었는지, 몇 번 호출되었는지 등을 검사할 수 있습니다.

### Stubbing 검증방식

![[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)](images/Untitled%201.png)

[https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da](https://blog.pragmatists.com/test-doubles-fakes-mocks-and-stubs-1a7491dfa3da)

Stubbing은 호출된 메서드의 결과값만을 제공하며, 테스트는 이 결과값을 사용하여 특정 로직이 기대한 대로 작동하는지 확인합니다. Stubbing은 호출되었는지, 몇 번 호출되었는지 등의 행동을 검증하지 않습니다.

## Golang으로 알아보는 Mocking과 Stubbing

Golang을 이용해서 Mocking과 Stubbing을 간단하게 구현해 보려고 합니다. 외부 데이터를 Fetch하는 인터페이스에 대해서 Mocking과 Stubbing 구현체를 작성합니다. Golang에서 Mocking은 직접 작성하기보다는 지원 해주는 외부 라이브러리를 사용하면 편하게 검증할 수 있습니다.

- [https://github.com/uber-go/mock](https://github.com/uber-go/mock)
- [https://github.com/vektra/mockery](https://github.com/vektra/mockery)

> Golang 예제는 mockery를 이용해서 구현할 예정이고 mockery에 대한 상세 이용법은 나중에 다른 포스팅으로 한번 따로 다뤄보겠습니다.

`인터페이스 정의`
```go
// DataService.go

type DataService interface {
    FetchData(param string) (string, error)
}
```

### Mocking 예제

아래 예시에서는 Mockery 라이브러리를 사용해서 **`DataService`** 인터페이스에 대한 Mock 객체를 생성하고, 이를 사용하여 **`FetchData`** 메소드의 호출을 시뮬레이션합니다.

해당 테스트에서는 Mock 객체에서  `AssertExpectations`함수를 통해서 FetchData가 제대로 호출되었는지를 검증하고 있습니다.

`구현체 작성`
```bash
mockery --name=DataService --dir=./mypackage --output=./mypackage/mocks --outpkg=mocks
```

`테스트코드`
```go
// DataService_test.go
func TestFetchData(t *testing.T) {
	// Mock 객체 생성
	mockDataService := &mocks.DataService{}

	// 기대치 설정
	expectedData := "mocked data"
	mockDataService.On("FetchData", mock.Anything).Return(expectedData, nil)

	// 테스트 대상 함수 호출
	result, err := mockDataService.FetchData("param")

	// 검증
	mockDataService.AssertExpectations(t)
	if err != nil {
		t.Fatalf("Expected no error, but got %s", err)
	}
	if result != expectedData {
		t.Fatalf("Expected %s, but got %s", expectedData, result)
	}
}
```

### Stubbing 예제

Stubbing을 사용하여 같은 케이스를 표현하는 경우, 인터페이스의 구현체를 직접 작성하고, 이 구현체에서 테스트에 필요한 특정 데이터를 반환하도록 설정합니다. Stub은 복잡한 로직이나 외부 시스템과의 실제 상호작용 없이, 단순히 예상되는 결과를 반환하는 데 중점을 둡니다.

Mocking이 구체적인 행동에 대해서 검증을 하는데 초점을 둔다면 Stubbing에서 특정 함수는 단순히 값을 반환하고 이후에 상태를 확인하기 위한 용도입니다.

고차원적인 검증은 불가능하지만 Mocking에 비해서 장점도 있습니다. 보시면 알겠지만 Mocking에 비해서 재사용성이 좋고 만약 복잡한 검증이 필요 없다면 Stubbing을 사용하는 것도 좋은 선택이 될 수 있을 것 같습니다.

`구현체 작성`

```go
// stubs.go
package mypackage

type StubDataService struct{}

func (s *StubDataService) FetchData(param string) (string, error) {
    // 고정된 데이터 반환
    return "stubbed data", nil
}
```

`테스트코드`

```go
// DataService_test.go
func TestFetchDataWithStub(t *testing.T) {
	// Stub 객체 생성
	stubDataService := &StubDataService{}

	// 테스트 대상 함수 호출
	result, err := stubDataService.FetchData("param")

	// 검증
	if err != nil {
		t.Fatalf("Expected no error, but got %s", err)
	}
	expectedData := "stubbed data"
	if result != expectedData {
		t.Fatalf("Expected %s, but got %s", expectedData, result)
	}
}
```

## 정리

본 포스팅에서는 Golang을 사용하여 Mocking과 Stubbing의 개념을 살펴보았습니다. Mocking은 객체의 행동을 시뮬레이션하고 기대한 행동을 검증하는 데 사용되는 반면, Stubbing은 특정한 응답을 반환하여 특정 로직이 기대한 대로 작동하는지 확인하는 데 사용됩니다. 유닛 테스트를 작성할 때 무조건 Mocking만을 고려할 것이 아니라 상황에 따라 다양한 선택지를 고려한다면 좀 더 효율적으로 테스트를 작성하실 수 있을 것이라고 생각합니다.