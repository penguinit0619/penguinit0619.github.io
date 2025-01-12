+++
author = "penguinit"
title = "'CORS는 멍청하다' 포스팅을 읽고"
date = "2025-01-12"
description = "'CORS는 멍청하다' 포스팅을 읽고 어떤 제약점이 있고 개인적인 생각에 대해서 정리를 하였습니다."
tags = [
"cors", "browser"
]
categories = [
"web"
]
+++

## 개요
[CORS는 멍청하다](https://kevincox.ca/2024/08/24/cors/?ref=dailydev) 포스팅을 읽고 어떤 제약점이 있고 개인적인 생각에 대해서 정리를 하였습니다.

## CORS란?
CORS에 대해서 제대로 알고 있지 않으신 분들은 제가 이전에 정리해뒀던 내용이 있으니 참고해주세요. [CORS란 무엇인가?](/post/202401/cors란-무엇인가)

## 주요내용
포스팅 저자는 아래 같은 내용으로 CORS에 대한 제약점을 설명하고 있습니다.

- CORS는 웹의 레거시 문제를 해결하기 위한 불완전한 해결책입니다 (해킹이라고 표현했는데 좀 더 자연스럽게 말하자면 꼼수정도라고 생각됩니다)
- 가장 주된 문제는 브라우저가 cross-origin 요청에 자동으로 인증 정보(쿠키 등)를 전달한다는게 문제입니다.
- CORS의 기본 정책(요청은 허용하되 응답 읽기는 제한)은 실제로 보안 문제를 완전히 해결하지 못합니다.

## 개인적인 생각
우선 포스팅 저자의 내용에 전반적으로 동의를 합니다. 그리고 엄연히 말하면 어떤 해결책이든 실버불렛이 될 수 없다고 생각하기 때문에 CORS만을 믿어서는 안되고 불완전함을 인지하는게 중요하다고 생각합니다. 

"웹의 레거시"란 쿠키를 초기에 디자인 했을 때 웹이 현재처럼 그렇게 복잡하지 않았기 때문에 보안적으로 간과한 부분이 있다는 걸 의미합니다. 넷스케이프에서 1994년 쿠키가 처음 제안되고 웹의 발전에 따라 CSRF 공격에 대한 대응책으로 CORS가 등장했습니다.

### CORS의 문제점
cross-origin에 대해서 응답은 브라우저 단에서 제한이 되어있지만, 요청은 허용이 되어있기 때문에 서버단에서는 여전히 보안적인 문제가 발생할 수 있습니다.

- 돈 이체 요청
- 비밀번호 변경 요청
- 계정 삭제 요청

브라우저에서 조회는 막을 수 있지만 서버에 들어가는 요청까지 CORS가 제어할 수는 없습니다. 이를 위해서 보안요소가 추가로 필요합니다.

### 추가적인 보안요소

- 서버 미들웨어에서 cross-origin 요청의 암묵적 인증을 무시
- 명시적 인증 사용 (Authorization 헤더 등)
- SameSite 쿠키 속성 사용

포스팅 저자는 여기서 더 나아가 CORS를 사용하지 않고 다른 방법을 사용하는 것을 권장하고 있습니다. 이에 대한 근거는 아래와 같습니다.
- 실제로는 CORS 프록시 등으로 우회 가능
- 불필요하게 복잡한 CORS 정책은 오히려 유용한 기능을 막음

## 결론
전반적으로 포스팅 저자의 의견에 동의를 합니다. CORS에 대해서 그렇게 크게 의문을 가지고 있지는 않았는데 완전하지 않은 방법이라는 것에는 개발하면서 많이 느꼈습니다. 

당장에 CORS 정책이 브라우저에서 빠지거나 그럴 일은 없겠지만 오히려 잘못된 믿음으로 CORS를 사용하는 것이 더 큰 문제가 될 수 있고 오히려 정책을 간단하게 가져가면서 Same-Site 쿠키정책이나 명시적 인증을 사용하는 것이 더 좋을 것 같습니다.