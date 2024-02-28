+++
author = "penguinit"
title = "우분투에서 사용하고 있는 특정포트 알아내기"
date = "2024-02-28"
description = "우분투 혹은 리눅스 계열 서버를 운영하다도면 사용자의 실수나 알수 없는이유로 포트가 열려있는 채로 종료가 될 수 있습니다. 이렇게 되면 다시 서버를 올릴 때 이미 포트가 점유되어있어서 문제가 발생했던 경험들을 한번씩은 다 경험해보셨으리라 생각하는데요 오늘 포스팅에서는 사용하고 있는 포트를 확인하는 방법들에 대해서 소개해보려고 합니다."
tags = [
"netstat", "ss", "lsof"
]
categories = [
"linux"
]
+++

![Untitled](images/Untitled.png)

## 개요

우분투 혹은 리눅스 계열 서버를 운영하다도면 사용자의 실수나 알수 없는이유로 포트가 열려있는 채로 종료가 될 수 있습니다. 이렇게 되면 다시 서버를 올릴 때 이미 포트가 점유되어있어서 문제가 발생했던 경험들을 한번씩은 다 경험해보셨으리라 생각하는데요 오늘 포스팅에서는 사용하고 있는 포트를 확인하는 방법들에 대해서 소개해보려고 합니다.

## 이미 사용하고 있는 포트

이미 포트를 점유하고 있으면 아래처럼 포트를 할당받지 못해서 에러가 납니다. 다른 언어에서도 출력하는 에러는 다르지만 모두 같습니다.
(예제는 Golang Echo 프레임워크)

![Untitled](images/Untitled%201.png)

손쉽게 서버를 꺼서 포트를 유휴상태로 만든다면 크게 문제는 없지만 모종의 이유로 서버를 꺼도 계속해서 포트가 잡혀있을 수 있습니다. 이럴 때는 해당 포트를 잡고 있는 프로세스를 찾아서 kill 명령어를 통해서 종료 시그널을 보내 줘야 합니다.

## 특정 포트 확인하기

Ubuntu에서는 여러가지 방법으로 사용하고 있는 포트들을 확인할 수 있습니다.

### netstat 사용하기

`netstat`는 네트워크 연결, 라우팅 테이블, 인터페이스 통계 등 네트워크 관련 정보를 보여주는 도구입니다. Ubuntu 18.04 이상 버전에서는 기본적으로 설치되어 있지 않으므로, `net-tools` 패키지를 설치해야 사용할 수 있습니다.

- 설치 방법

```bash
sudo apt update
sudo apt install net-tools
```

- 사용 중인 포트 & 프로세스 확인

```bash
> netstat -ltnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:1313          0.0.0.0:*               LISTEN      25411/hugo          
tcp        0      0 127.0.0.1:631           0.0.0.0:*               LISTEN      1266/cupsd          
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      1110/systemd-resolv 
tcp6       0      0 127.0.0.1:52829         :::*                    LISTEN      2584/./jetbrains-to 
tcp6       0      0 ::1:631                 :::*                    LISTEN      1266/cupsd          
tcp6       0      0 127.0.0.1:63342         :::*                    LISTEN      14295/java          
tcp6       0      0 :::8080                 :::*                    LISTEN      23185/main   
```

- `l` (listen): 리스닝 상태의 소켓만 표시합니다. 리스닝 소켓은 외부 연결을 기다리고 있는 상태의 소켓을 의미합니다.
- `t` (TCP): TCP 프로토콜에 대한 연결만 표시합니다.
- `n` (numeric): 주소와 포트 번호를 숫자로 표시합니다. 기본적으로 `netstat`은 주소와 포트 번호를 해당하는 이름으로 변환하여 표시하는데, 이 옵션을 사용하면 변환 과정을 생략하여 숫자 그대로 표시합니다.
- `p` (program): 각 소켓에 대해 해당 소켓을 사용 중인 프로세스의 PID와 프로그램 이름을 표시합니다. 이 옵션을 사용하기 위해서는 루트 권한이 필요할 수 있습니다.

### ss 사용하기

`ss` 명령어는 `netstat`보다 더 빠르게 시스템의 소켓을 조사할 수 있습니다. 최근 Ubuntu 버전에서는 `ss`를 `netstat`의 대체제로 권장하고 있습니다.

```bash
> ss -ltnp
State    Recv-Q   Send-Q          Local Address:Port  Peer     Address:Port    Process
LISTEN   0        4096            127.0.0.53%lo:53             0.0.0.0:*
LISTEN   0        5                   127.0.0.1:631            0.0.0.0:*
LISTEN   0        4096                127.0.0.1:1313           0.0.0.0:*       users:(("hugo",pid=25411,fd=3))
LISTEN   0        5                       [::1]:631            [::]:*
LISTEN   0        50         [::ffff:127.0.0.1]:52829          *:*             users:(("jetbrains-toolb",pid=2584,fd=55))
LISTEN   0        4096       [::ffff:127.0.0.1]:63342          *:*             users:(("java",pid=14295,fd=47))
LISTEN   0        4096                        *:8080           *:*             users:(("main",pid=23185,fd=7))
```

-ltnp 옵션의 의미는 netstat과 동일합니다.

### lsof 명령어 사용하기

`lsof`는 "List Open Files"의 약자로, 현재 시스템에서 열려 있는 파일의 목록을 보여줍니다. 이 도구를 사용하여 특정 포트를 사용 중인 프로세스를 찾을 수 있습니다.

- 설치방법

```bash
sudo apt update
sudo apt install lsof
```

- 특정 포트 사용 중인 프로세스 찾기

```bash
sudo lsof -i :포트번호
COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
chrome   2954 penguin   56u  IPv4 673112      0t0  TCP localhost:58570->localhost:xtel (ESTABLISHED)
hugo    25411 penguin    3u  IPv4 663660      0t0  TCP localhost:xtel (LISTEN)
hugo    25411 penguin    8u  IPv4 677744      0t0  TCP localhost:xtel->localhost:58570 (ESTABLISHED)
```

## 정리

Ubuntu에서 현재 사용 중인 포트를 찾는 방법은 다양합니다. 상황에 따라 `netstat`, `ss`, `lsof` 등의 도구를 적절히 선택하여 사용할 수 있습니다.  어느 것이 좋은지는 상황이나 개인 취향이 갈리는 부분이다 보니 손에 익숙한 걸 사용하시고 (저는 ss가 짧아서 편합니다) 필요하실 때 유용하게 쓰면 좋을 것 같습니다.