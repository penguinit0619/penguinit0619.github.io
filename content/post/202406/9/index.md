+++
author = "penguinit"
title = "docker logs 명령어 알아보기"
date = "2024-06-12"
description = "이번 포스팅에서는 기존에 docker에서 로그를 볼 때 잘못알고 있던 명령어가 있어서 이를 정리하고 추가로 docker logs 명령어에 대해서 알아보려고 합니다."
tags = [
"docker"
]
categories = [
"infra"
]
+++

## 개요
이번 포스팅에서는 기존에 docker에서 로그를 볼 때 잘못알고 있던 명령어가 있어서 이를 정리하고 추가로 docker logs 명령어에 대해서 알아보려고 합니다.

## docker logs 명령어
docker logs 명령어는 컨테이너의 로그를 확인할 때 사용하는 명령어입니다. 기본적으로 docker logs 명령어는 컨테이너의 표준 출력(stdout)과 표준 에러(stderr)를 출력합니다.

```bash
docker logs [OPTIONS] {CONTAINER}
```

### OPTIONS

- `-f, --follow`: 실시간으로 로그를 출력합니다.
- `--since`: 특정 시간 이후의 로그를 출력합니다.
- `--tail`: 마지막 로그부터 출력할 라인 수를 지정합니다.
- `--timestamps`: 로그에 타임스탬프를 출력합니다.
- `--details`: 로그에 추가적인 정보를 출력합니다.
- `--until`: 특정 시간 이전의 로그를 출력합니다.
- `--no-log-prefix`: 로그에 컨테이너 ID를 출력하지 않습니다.
- `--no-color`: 로그에 색상을 출력하지 않습니다.
- `--raw`: 로그를 JSON 형식으로 출력합니다.
- `--tail`: 마지막 로그부터 출력할 라인 수를 지정합니다.

### docker logs -f {CONTAINER}
실제로 운영하면서 제일 자주사용하는 명령어였는데 잘못알고 사용하고 쓰고 있었다는 사실을 이번에 알게 되었습니다. 기존까지는 logs -f {CONTAINER}를 사용해서 실시간으로 로그를 확인하고 있었는데 로그양이 많아지니 이전 로그를 확인하기가 어려웠습니다. 

기존에는 이 명령어가 tail과 비슷하게 동작한다고 생각하고 있었는데 실제로는 실시간으로 로그를 출력하는 명령어입니다. 

무슨 말이냐면 logs -f 명령어를 이용하면 처음부터 끝까지 로그를 한번 훑고가기 때문에 로그가 많아지면 로그를 확인하기가 어려워집니다.

### docker logs -f --tail {NUMBER} {CONTAINER}
만약에 실시간 로그를 보고 싶다면 --tail 옵션과 -f 옵션을 같이 사용해야 합니다. 이렇게 하면 실시간으로 로그를 출력하면서 마지막 로그부터 지정한 라인 수만큼 출력합니다.

## CONTAINER 팁
많이 아시는 사실이긴 하지만 docker logs 명령어를 사용할 때 CONTAINER ID를 전부 입력하지 않고 앞의 몇자리만 입력해도 인식이 됩니다. 예를 들어서 CONTAINER ID가 `1234567890ab`라면 `docker logs 123`으로 입력해도 인식이 됩니다.

## 정리
개인적으로 저는 docker logs 명령어에서 -f 옵션말고는 잘 사용하지 않는 편입니다. 실제로 운영하면서 로그를 확인할 때는 이렇게 직접 들어가서 확인하는 경우가 많지 않기 때문인데요 하지만 실시간 로그는 필요할 때가 있기 때문에 이런 옵션들을 알아두면 좋을 것 같습니다.