+++
author = "penguinit"
title = "멱등성이란 무엇인가?"
date = "2024-02-03"
description = "HTTP API를 개발하다 보면 멱등성에 대해서 한번씩 들어본적들이 있을 것입니다. 오늘 포스팅에서는 멱등성이 무엇인지에 대해서 알아보고 HTTP API 사례를 통해서 멱등성에 대해서 좀 더 이해해 보고자 합니다."
tags = [
    "http", "rfc", "idempotent"
]

categories = [
    "api",
]
+++

## 개요

HTTP API를 개발하다 보면 멱등성에 대해서 한번씩 들어본적들이 있을 것입니다. 오늘 포스팅에서는 멱등성이 무엇인지에 대해서 알아보고 HTTP API 사례를 통해서 멱등성에 대해서 좀 더 이해해 보고자 합니다.

## 멱등하다라는 뜻

예전에 일하던 팀에서 어떻게 하면 RESTful한 API를 설계할 수 있을까에 대한 얘기를 하다가 처음 듣게 된 용어였습니다. 지금은 이해하고 있지만 처음에 이 단어를 들었을 때 처음 들어보는 단어에 유추조차 되지 않아서 당황했던 기억이 있습니다.

우선 멱등하다에 대한 사전적 의미를 간단하게 요약해보자면 아래와 같습니다.

> 수학이나 전산학에서 연산의 한 성질을 나타내는 것으로, 연산을 여러 번 적용하더라도 결과가 달라지지 않는 성질을 의미한다.

*출처 ([https://ko.wikipedia.org/wiki/멱등법칙](https://ko.wikipedia.org/wiki/%EB%A9%B1%EB%93%B1%EB%B2%95%EC%B9%99))*

>

예를 들어서 특정 숫자에 0을 더하거나 1을 곱하는 행위는 항상 같은 결과를 초래하기 때문에 멱등하다고 할 수 있고 특정 집합에서 특정 함수를 두 번 적용해도 같은 값이 나온다면 그런 함수를 멱등함수라고 부른다고 합니다.

**f(f(x)) = f(x)**

프로그래밍에서 예를 들면 [1,2,3,4,5]라는 집합이 있을 때 이 함수 집단에 Max 함수를 수행하면 5 값이 출력될 것입니다. 이 출력값에 다시 Max 함수를 호출하게 되면 다시 5값이 나올 것이기 때문에 이 함수는 **멱등함수**라고 할 수 있습니다.

## HTTP에서 멱등성

HTTP 메소드에서도 멱등성이 존재합니다. [RFC 7231](https://www.rfc-editor.org/rfc/rfc7231#section-8.1.3)

| 메소드     | 안정성 | 멱등성 |
|---------|-----|-----|
| CONNECT | no  | no  |
| DELETE  | no  | yes |
| GET     | yes | yes |
| HEAD    | yes | yes |
| OPTIONS | yes | yes |
| POST    | no  | no  |
| PUT     | no  | yes |
| TRACE   | yes | yes |

멱등성에 대해서 이해를 처음 할 때 POST와 PATCH는 어느 정도 납득이 갔었는데 PUT과 DELETE가 멱등성을 가진다는 것에 좀 의아한 부분이 있었습니다. 그런데 리소스적인 관점에서 생각해 보면 PUT은 덮어쓰는 것이기 때문에 그 결과가 항상 동일하다고 생각할 수 있고 DELETE 또한 그렇습니다. 그런 관점에서 생각해 보면 PUT과 DELETE 또한 멱등한 메소드라고 생각할 수 있겠습니다.

### 안정성이란

안정성은 리소스와 관계가 있습니다. 안정성이 있는 메소드들은 리소스를 변화하지 않습니다. 예를 들어서 GET이나 HEAD, OPTIONS의 경우에는 아무리 요청해도 해당 리소스를 변경하지 않습니다. 반대로 DELETE나 PUT의 경우에는 멱등성은 가지고 있지만 실제로 리소스가 다른 정보로 엎어지거나 삭제되는 경우가 있기 때문에 이건 안정성을 가지고 있지 않다고 말할 수 있습니다.

## PATCH 메소드

이전 표를 보면 자주 쓰는 메소드가 빠져있는 것을 볼 수가 있습니다. 바로 PATCH 메소드인데 RFC 7231에서는 PATCH 메소드에 대한 언급은 없습니다. 그 이유는 RFC 7231의 문서 이름은 **"HTTP/1.1 Semantics and Content"** 입니다. 즉 HTTP/1.1을 기준으로 그 쓰임에 대해서 정의하는 문서였고 PATCH 메소드는 [RFC 5789](https://www.rfc-editor.org/rfc/rfc5789) **"PATCH Method for HTTP"** 에서 공식적으로 도입되었고 HTTP/1.1 정의에는 PATCH 메소드가 포함되어 있지 않기 때문에 누락이 되어있었습니다.

### 멱등성

결론부터 말하면 PATCH 메서드는 멱등할 수도 아닐 수도 있습니다. 이게 무슨 말이냐라고 하실 수 있지만 실제로 RFC 5789 문서에서는 PATCH는 멱등할 수도 아닐 수도 있다고 언급합니다.

**RFC 5789의 "2. Idempotent Methods" 섹션에서는 다음과 같이 설명합니다**

> PATCH is neither safe nor idempotent as defined by [RFC2616], Section 9.1.
> —
> A PATCH request can be issued in such a way as to be idempotent, which also helps prevent bad outcomes from collisions between two PATCH requests on the same resource in a similar time frame. Collisions from multiple PATCH requests may be more dangerous than PUT collisions because some patch formats need to operate from a known base-point or else they will corrupt the resource. Clients using this kind of patch application SHOULD use a conditional request such that the request will fail if the resource has been updated since the client last accessed the resource. For example, the client can use a strong ETag [RFC2616] in an If-Match header on the PATCH request.

예시를 들면 아래와 같이 상황에 따라서 멱등한경우와 아닌경우로 API를 설계할 수 있습니다.

- **멱등인 경우**: **PATCH** 요청이 리소스의 특정 부분을 특정 값으로 변경하는 경우, 동일한 **PATCH** 요청을 여러 번 반복해도 결과는 동일합니다. 예를 들어, 특정 문서의 특정 섹션을 특정 내용으로 교체하는 요청은 여러 번 수행해도 문서의 해당 섹션에 같은 내용이 반영되므로 멱등합니다.

- **멱등이 아닌 경우**: 반면, **PATCH** 요청이 리소스에 대해 상대적인 변경을 수행하는 경우(예: "현재 값에 1을 더한다"와 같은 연산) 멱등하지 않을 수 있습니다. 이러한 요청을 여러 번 수행하면, 매번 리소스의 상태가 변경됩니다.

## 멱등성 예시

간간하게 유저 API를 만든다고 가정하고 멱등성 사례를 들면서 예시를 들어보고자합니다.

### GET

- **멱등성**: **GET** 메소드는 멱등합니다. 동일한 **GET** 요청을 여러 번 보내도 서버의 데이터나 상태를 변경하지 않습니다.

- **예시**

    - 사용자 프로필 정보를 조회합니다.

    - 요청

    ```http
    GET /users/123
    ```

    - 응답: 사용자 123의 프로필 정보를 반환합니다.

### POST

- **멱등성**: **POST** 메소드는 일반적으로 멱등하지 않습니다. 같은 요청을 여러 번 보내면 서버에 같은 데이터의 여러 복사본이 생성될 수 있습니다.

- **예시**

    - 새로운 사용자를 생성합니다.
    - 요청

  ```http
  POST /users
  {
     "name":"John Doe",
     "email":"john@example.com"
  }
  ```

    - 응답: 새로운 사용자가 생성되고, 생성된 사용자의 정보를 반환합니다

### PUT

- **멱등성**: **PUT** 메소드는 멱등합니다. 같은 **PUT** 요청을 여러 번 보내도, 첫 번째 요청이 생성하거나 수정한 리소스의 상태를 변경하지 않습니다.

- **예시**

    - 사용자의 이메일 주소를 업데이트합니다.
    - 요청

  ```http
  PUT /users/123
  {
     "name":"Jane Doe",
     "email":"janedoe@example.com"
  }
  ```

    - 응답: 사용자 123의 이메일 주소가 업데이트되고, 변경된 사용자 정보를 반환합니다.

### PATCH

- **멱등성**: **PATCH** 메소드는 구현에 따라 멱등할 수도 있고 아닐 수도 있습니다. 하지만, 멱등하게 구현하는 것이 좋습니다.

- **예시**

    - 사용자의 부분적인 정보(이름)을 업데이트합니다.
    - 요청

  ```http
  PATCH /users/123
  {
     "name":"Jane Doe"
  }
  ```

    - 응답: 사용자 123의 이름이 업데이트되고, 변경된 사용자 정보를 반환합니다.

### DELETE

- **멱등성**: **DELETE** 메소드는 멱등합니다. 첫 번째 **DELETE** 요청이 리소스를 성공적으로 삭제한 후, 동일한 요청을 반복하더라도 서버의 상태에 추가적인 변화가 없습니다.

- 예시

    - 사용자를 삭제합니다.
    - 요청

  ```http
  DELETE /users/123
  ```

    - 응답: 사용자 123이 삭제되었습니다. 추가 요청은 상태 변경 없이 **404 Not Found** 또는 **204 No Content** 를 반환할 수 있습니다.

## 정리

멱등성이 무엇인지에 대해서 알아보았고 RFC 문서를 통해서 각 메소드들의 멱등 성과 안정성에 대해서 정리를 하였습니다.

실제로 업무를 경험하다 보면 이런 RFC 문서에 맞지 않는 HTTP API들을 많이 맞닥뜨리게 됩니다. 처음에는 저도 틀린 거라고 생각을 하고 바로잡으려고 노력했던 기억이 있는데요 RFC 문서는 인터넷 표준을 정의한 것이지 이것을 벗어난다고 해서 잘못되었다고 말할 수는 없을 것 같습니다. 특정 비즈니스 요구사항에서는 이런 표준을 벗어나야 할 수도 있고 기존의 구현이 그렇게 따르지 않았기 때문에 어쩔 수 없이 기존 방식대로 개발하는 경우도 있을 수 있습니다.

API 설계는 정말 어렵습니다. 수백 번을 만들었지만 할 때마다 어려운 게 API 설계인 것 같습니다. 답이 없기 때문에 어렵고 또 재미있는 것 같습니다.