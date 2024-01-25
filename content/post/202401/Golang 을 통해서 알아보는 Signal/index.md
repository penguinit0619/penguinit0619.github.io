+++
author = "penguinit"
title = "Golang 을 통해서 알아보는 시그널 (Signal) "
date = "2024-01-25"
description = "최근에 시그널 (Signal) 에 대해서 회사 사람들과 잠깐 얘기하는 시간이 있었는데 생각보다 내가 모르고 있는 게 많다고 생각이 들어서 해당 글을 통해서 Signal 이 무엇이고 어떻게 사용되는지를 Golang 을 통해서 좀 더 자세히 알아보려고 합니다"
tags = [
    "golang", "signal"
]

categories = [
    "linux", "language"
]
+++

## 개요

최근에 시그널 (Signal) 에 대해서 회사 사람들과 잠깐 얘기하는 시간이 있었는데 생각보다 내가 모르고 있는 게 많다고 생각이 들어서 해당 글을 통해서 Signal 이 무엇이고 어떻게 사용되는지를 Golang 을 통해서 좀 더 자세히 알아보려고 합니다.

## Signal 이란?

시그널 (Signal) 은 운영 체제 (OS) 와 프로세스 간, 또는 프로세스 간에 통신하는 방법으로 사용됩니다. 주로 유닉스와 유닉스 계열 시스템 (Linux, BSD, macOS 등) 에서 널리 사용되며 시그널은 프로세스에게 어떤 이벤트가 발생했음을 알려주는 매카니즘들을 통칭을 합니다.

![Untitled](images/Untitled.png)

### Signal 목록

현재 Mac 이나 Linux 계열의 데스크탑을 사용하고 있다면 kill -l 을 통해서 시그널의 목록들을 확인하실 수 있습니다.

```bash
kill -l 
HUP INT QUIT ILL TRAP ABRT BUS FPE KILL USR1 SEGV USR2 PIPE ALRM TERM STKFLT 
CHLD CONT STOP TSTP TTIN TTOU URG XCPU XFSZ VTALRM PROF WINCH POLL PWR SYS
```

### kill 명령어

우선 잘못 알 수 있는 부분도 있어서 조금 정리하고 넘어가면 보통 우리가 특정 프로세스를 종료할 때 `kill -9 [pid]` 형태로 많이 종료들 하는데 그러다 보니 kill 이라는 명령어가 프로세스를 종료하는 명령어라고 알고 있는 사람들이 있습니다. (나도 그중에 하나였다…)

그런 오해 중에 하나가 `man` 명령어를 쳐보면 알지만 디폴트 값이 `SIGTERM`을 넘기게 되어 있어서 별도 시그널을 주지 않으면 프로세스 종료가 됩니다.

```
man kill

KILL(1)                          User Commands                         KILL(1)

NAME
       kill - send a signal to a process

SYNOPSIS
       kill [options] <pid> [...]

DESCRIPTION
       The  default  signal  for kill is TERM.  Use -l or -L to list available
       signals.  Particularly useful signals include  HUP,  INT,  KILL,  STOP,
       CONT,  and  0.   Alternate  signals may be specified in three ways: -9,
       -SIGKILL or -KILL.  Negative PID values may be  used  to  choose  whole
       process  groups; see the PGID column in ps command output.  A PID of -1
       is special; it indicates all processes except the kill  process  itself
       and init.
```

정리하면 kill 명령어는 특정 프로세스에 특정 시그널을 보내주는 명령어라고 할 수 있습니다.

### 종료 시그널

시그널 중에서 가장 자주 사용하고 개발을 하면서 자주 마주하게 되는 녀석들 중에 뽑자면 SIGINT, SIGTERM, SIGKILL 일 것 같습니다.

- **SIGTERM (Signal Terminate)**

15 번 번호를 가지고 있으며 프로그램에게 종료를 요청하는 신호입니다. 해당 신호를 받으면 프로세스에 의해 예외 처리되거나 무시를 할 수 가 있기 때문에 프로세스에서 종료 방식을 결정할 수 있습니다.

- **SIGKILL (Signal Kill)**

9 번 번호를 가지고 있으며 해당 시그널을 받으면 프로세스를 즉시 강제 종료 시켜버립니다. SIGKILL 을 SIGTERM 과 다르게 예외 처리 할 수 없고 무시할 수도 없습니다.

- **SIGINT (Signal Interrupt)**

2 번 번호를 가지고 있으며 인터럽트 신호로 사용자가 Ctrl+C 를 눌러 프로세스를 중단하려고 할 때 발생합니다. 프로세스 입장에서는 SIGTERM 과 동일하게 동작하지만 사용자에 의해서 비동기적으로 신호가 발생할 수 있다는 점이 SIGTERM 과 차이점이 있습니다.

실제 개발할 때는 이런 신호들을 받아서 프로그램이 종료될 때 **Graceful Shutdown** 처리를 하게 됩니다.

Graceful Shutdown 이라는건 한마디로 프로그램이 종료될 때 최대한 사이드이펙트 없이 잘 처리하는 걸 의미합니다. HTTP 서버라면 현재 들어온 요청이 제대로 수행이 될 때 까지 기다린다거나 내부에 수행하고 있는 로직이 있으면 기다렸다고 프로세스를 종료시키는등의 행위들이 모두 Graceful Shutdown 에 해당합니다.

## Golang 실습

그럼 이 시그널들이 실제 프로세스를 수행할 때 잡고 처리를 하는 과정에 대해서 간단한 Golang 예제를 통해서 알아보고자 합니다.

### Graceful Shutdown

우선 위에 언급했던 시그널 중에서 정상 종료에 해당하는 SIGTERM 과 SIGINT 에 대해서 실제 시그널을 받아보고 Golang 을 통해서 후처리를 하는 예제를 작성해 보려고 합니다.

```go
package main

import (
    "fmt"
    "os"
    "os/signal"
    "syscall"
	"time"
)

func main() {
    // 현재 프로세스의 PID 를 출력합니다.
    pid := os.Getpid()
    fmt.Printf("My PID is: %d\n", pid)

    // SIGINT (Ctrl+C) 및 SIGTERM 시그널을 처리하기 위한 채널을 생성합니다.
    signals := make(chan os.Signal, 1)

    // Notify 함수를 사용하여 SIGINT 및 SIGTERM 시그널을 받을 수 있도록 합니다.
    signal.Notify(signals, syscall.SIGINT, syscall.SIGTERM)

    // 별도의 go 루틴에서 시그널을 기다립니다.
    go func() {
        sig := <-signals
        fmt.Printf("Received signal: %s\n", sig)
        fmt.Println("Performing cleanup...")
        // 필요한 정리 작업을 수행합니다.

        fmt.Println("Exiting.")
        os.Exit(0)
    }()

    // 메인 루틴은 다른 작업을 계속 수행합니다.
    for {
        fmt.Println("Running...")
        time.Sleep(2 * time.Second)
    }
}
```

해당 코드는 2 초마다 Running… 이라는 문자를 찍어내는 작업을 하고 있다가 중간에 관련 시그널이 들어오면 해당 시그널을 잡아서 필요한 작업들을 모두 한 뒤에 정상 종료 `Exit(0)` 하는 로직을 구현하고 있습니다.

- 수행결과 (실행중 Ctrl + C 수행)

```go
go run main.go
My PID is: 285853
Running...
Running...
Running...
^CReceived signal: interrupt
Performing cleanup...
Exiting.
```

### Kill 명령어를 통한 시그널 전달

이번에는 해당 명령어에서 SIGTERM 을 전달해 보겠습니다. 일반적으로 정상 종료가 되면 SIGTERM 이 호출되지만 kill 명령어를 통해서 직접 시그널을 보낼 수도 있습니다. 위에 코드는 수행을 할 때 본인의 PID 를 보여줍니다.

- 수행결과

![Untitled](images/Untitled%201.png)

kill 명령어를 통해서 `SIGTERM` 시그널을 전달하였고 로그에 보면 terminated 시그널을 받고 정상 종료하는 걸 보실 수 있습니다.

그럼 이번엔 `SIGKILL` 을 보내면 어떻게 될까요? 아마도 위에 설명처럼 예외 처리를 하지 못하고 곧바로 종료가 될 것으로 예상이 됩니다. 이번에는 시그널 번호를 통해서 요청을 해보겠습니다.

- 수행결과

![Untitled](images/Untitled%202.png)

왼쪽에 보이듯이 killed 시그널을 받았지만 관련 후처리에 대한 로그는 없는걸 확인하실 수 있습니다.

## 결론

시그널 처리는 프로그램이 운영 체제로부터 중요한 정보를 받고, 이에 대응하여 적절한 행동을 취할 수 있도록 해줍니다 프로세스와 운영체제와의 통신 혹은 프로세스와 프로세스끼리에서도 시그널은 주고받을 수 있으며 이런 시그널을 통해서 보다 안정적이고 효율적인 소프트웨어를 만들 수 있습니다.

또 Go 언어를 사용하여 시그널을 처리하는 방법을 살펴보았습니다. 개인적인 의견으로는 Go 언어의 고루틴과 채널을 활용한 동시성 처리는 시그널을 효과적으로 처리하는 데 있어 **큰 장점**을 제공한다고 생각합니다. 다른 언어들이 못한다는 건 아니지만 더 쉽고 효율적으로 이런 시그널들을 처리할 수 있다고 생각합니다.