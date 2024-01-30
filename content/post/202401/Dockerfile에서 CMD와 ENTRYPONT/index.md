+++
author = "penguinit"
title = "Dockerfile에서 CMD와 ENTRYPONT"
date = "2024-01-30"
description = "Dockerfile에서 `ENTRYPOINT`와 `CMD`가 무슨 역할을 하는지를 알아보고 두가지 명령어의 차이점에 대해서 알아봅니다."
tags = [
"docker"
]

categories = [
"infra"
]
+++

## 개요

Dockerfile에서 `ENTRYPOINT`와 `CMD`가 무슨 역할을 하는지를 알아보고 두가지 명령어의 차이점에 대해서 알아봅니다.

![Untitled](images/Untitled.png)

## ENTRYPOINT

`ENTRYPOINT`는 컨테이너가 시작될 때 실행할 명령을 정의합니다. 첫번째 인자는 실행할 명령어를 의미하고 나머지 인자들은 매개변수를 의미합니다.

```docker
FROM centos:7
ENTRYPOINT ["echo", "Hello, Penguin"]
```

위에 처럼 수행을 하게 되면 아래처럼 echo 명령어에 인자로 “Hello, Penguin” 을 받아서 출력하게 됩니다.

```bash
$ docker run hello-world
Hello, Penguin
```

## CMD

`CMD` 는 `ENTRYPOINT` 에 전달되는 기본 매개변수를 제공하거나 `ENTRYPOINT` 가 제공되지 않았을 때 실행할 기본 명령을 정의합니다.

간단한 Dockerfile을 작성하다보면 `CMD` 혹은 `ENTRYPOINT`로 둘중 하나만 선택하게 됩니다. 그래서 두 명령어가 비슷한 의미로 쓰인다고 생각할 수 있는데 정확하게 말하면 `CMD`는 `ENTRYPOINT`의 보조역할을 하고 있습니다. 밑에 예시 코드를 보면 좀 더 이해가 되실 수 있습니다.

위에 작성했던 Hello, Penguin!!! 코드는 `ENTRYPOINT`와 `CMD`를 조합하면 이렇게 작성할 수 있습니다.

### CMD가 ENTRYPOINT의 매개변수로 사용

```docker
FROM centos:7
CMD ["Hello Penguin!!!"]
ENTRYPOINT ["echo"]
```

```bash
$ docker run hello-world
Hello, Penguin!!!
```

### CMD가 단독으로 사용되어 명령어로 사용

```docker
FROM centos:7
CMD ["echo", "Hello Penguin!!!"]
```

```bash
$ docker run hello-world
Hello, Penguin!!!
```

위에 설명했던 것 처럼 `CMD`는 `ENTRYPOINT`의 매개변수로 사용되거나 단독으로 사용되었을 때 실행할 기본명령을 정의하는 역할이 됩니다.

## 사용 예시

`ENTRYPOINT`와 `CMD`의 이러한 특성을 이용해서 다음과 같은 작업을 할 수 있습니다.

- `ENTRYPONT`는 echo 명령을 실행하면서 수행
- `CMD`는 echo 인자에 들어가는 기본값을 설정 : Hello, World!
- docker 수행시 인자값으로 Penguin을 전달하면 `CMD`의 값을 사용자 인자 값으로 오버라이딩 합니다.

방금 전 `CMD` 예시를 들면서 작성했던 코드를 조금 수정해서 붙여보겠습니다.

```docker
FROM centos:7
CMD ["Hello, World"]
ENTRYPOINT ["echo"]
```

이렇게 수행이 되어있을 때 docker 수행시 “Hello, Penguin” 이라는 값을 넘겨주면 `CMD`의 값이 무시되고 사용자가 입력한 값으로 대체됩니다.

```bash
$ docker run hello-world
Hello, World

$ docker run hello-world 'Hello, Penguin'
Hello, Penguin
```

사용 예시에 대해서 정리하자면 `CMD`는 유연하게 요청에 대해서 처리할 수 있고 사용자가 실행시점에 명령을 쉽게 변경할 수 있습니다. 반면 `ENTRYPOINT`는 컨테이너가 특정 명령을 실행하도록 강제합니다

## CMD/ENTRYPOINT 상관관계

`CMD`와 `ENTRYPOINT`의 상관관계를 표로 정리하면 아래와 같습니다.

|                            | No ENTRYPOINT              | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT ["exec_entry", "p1_entry"]          |
| -------------------------- | -------------------------- | ------------------------------ | ---------------------------------------------- |
| No CMD                     | error, not allowed         | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry                            |
| CMD ["exec_cmd", "p1_cmd"] | exec_cmd p1_cmd            | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry exec_cmd p1_cmd            |
| CMD exec_cmd p1_cmd        | /bin/sh -c exec_cmd p1_cmd | /bin/sh -c exec_entry p1_entry | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

## 정리

해당 글을 통해서 `CMD`와 `ENTRYPOINT`에 대해서 개념과 차이점에 대해서 알아보았습니다. 실무에서 사용하게 되면 크게 고민없이 `ENTRYPOINT`만 사용하거나 `CMD`만 사용하는 경우들이 있는데 적절하게 잘 조합해서 유연한 컨테이너를 만들어보시면 좋을 것 같습니다