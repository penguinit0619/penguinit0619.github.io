+++
author = "penguinit"
title = "Snap 이란 무엇인가"
date = "2024-01-11"
description = "우분투를 사용해서 패키지를 설치하다보면 apt 로 설치할 때와 snap 을 이용해서 설치할 때가 있는데  두개가 어떤 특징이 있는지 모른 상태로 사용하고 있었는데 이번 기회에 정확하게 snap 이 무엇인지에 대해서 정리하고자 합니다."
tags = [
    "package","apt", "snap"
]

categories = [
    "linux",
]
+++

## 개요

우분투를 사용해서 패키지를 설치하다보면 apt 로 설치할 때와 snap 을 이용해서 설치할 때가 있는데  두개가 어떤 특징이 있는지 모른 상태로 사용하고 있었는데 이번 기회에 정확하게 snap 이 무엇인지에 대해서 정리하고자 합니다.

## APT

snap 에 대해서 설명하기전에 apt 에 대해서 짚고 넘어가고자 합니다

APT (Advanced Package Tool) 는 Debian 과 Ubuntu 를 포함한 Debian 기반 리눅스 배포판에서 소프트웨어 패키지를 관리하기 위한 툴입니다. 이 도구는 소프트웨어의 설치, 업그레이드, 구성 및 제거를 손쉽게 할 수 있도록 도와줍니다.

### APT 의 주요 기능

1. **패키지 설치**: 사용자는 APT 를 사용하여 리포지토리에서 소프트웨어 패키지를 검색하고 설치할 수 있습니다.
2. **자동 의존성 해결**: APT 는 필요한 모든 종속 패키지를 자동으로 식별하고 설치하여, 소프트웨어가 제대로 작동하도록 보장합니다.
3. **패키지 업데이트 및 업그레이드**: 시스템에 설치된 패키지를 최신 상태로 유지하기 위해 APT 는 패키지 목록을 업데이트하고, 사용 가능한 업그레이드를 적용합니다.
4. **패키지 제거**: 사용자는 더 이상 필요하지 않은 소프트웨어를 시스템에서 쉽게 제거할 수 있습니다.

### apt vs apt-get

구글링 하면서 패키지를 설치하다보면 어떤 건 **apt**로 설치하고 어떤 건 **apt-get**을 이용해서 설치하게 되는데요 배경을 먼저 설명하자면 apt 는 좀 더 최신버전이고 apt-get 은 옛날에 사용하던 명령어라고 보시면 됩니다. 그럼에도 불구하고 아직까지도 많이들 쓰는 것 같습니다. (저도 습관적으로 apt-get 을 사용합니다)

![Untitled](images/Untitled.png)

- apt 와 apt-get, dpkg 명령어 대응점

| apt update | apt-get update | Refreshes repository index |
| --- | --- | --- |
| apt install [package] | apt-get install [package] | Install a package |
| apt upgrade | apt-get upgrade | Upgrade available package updates |
| apt remove [package] | apt-get remove[package] | Remove a package |
| apt purge [package] | apt-get purge [package] | Remove a package with configuration |
| apt autoremove | apt-get autoremove | Remove unnecessary dependencies |
| apt full-upgrade | apt-get dist-upgrade | Update all packages and remove unnecessary dependencies |
| apt search [package] | apt-cache search [package] | Search for a package |
| apt show [package] | apt-cache show [package] | Show package details |
| apt policy | apt-cache policy | Show active repo information |
| apt policy [package | apt-cache policy [package] | Show installed and available package version |
| apt list --installed | dpkg --list | Show installed package |
- apt 에 추가된 명령어

| apt command      | Description                                     |
|------------------|-------------------------------------------------|
| apt list         | List installed packages and upgradable packages |
| apt edit-sources | Edits sources list                              |

## Snap

### Snap 주요 기능

1. **격리된 환경**: Snap 패키지는 격리된 환경에서 실행되어 시스템의 다른 부분과의 충돌을 방지합니다.
2. **자동 업데이트**: Snap 패키지는 자동으로 업데이트되며, 항상 최신 버전을 유지합니다.
3. **보안 강화**: Snap 은 애플리케이션을 보다 안전하게 실행할 수 있도록 설계되었습니다.
4. **플랫폼 독립성**: 다양한 리눅스 배포판에서 동일한 Snap 패키지를 사용할 수 있습니다.

주요한 명령어로는 `find`, `info`, `install`, `remove`, `list` 등이 있고 상세한 명령어는 help 를 참조하면 됩니다. 예를 들어서 slack 패키지를 다운로드 받고 싶다면 아래처럼 쉘에 치면 설치가 됩니다.
``` bash
> sudo snap install slack

## 설치확인
> sudo snap list slack

이름     버전        개정   추적             발행인     노트
slack  4.35.131  118  latest/stable  slack✓  -
```

### Snap 구성요소

- **Snapd**
    - **정의**: Snapd 는 Snap 패키지를 관리하는 백그라운드 서비스 (데몬) 입니다. 이는 Snap 패키지의 설치, 업데이트, 제거 및 관리를 담당합니다.
    - **기능**: Snapd 는 **Snap Store**와 통신하여 사용자의 요청에 따라 패키지를 검색하고, 설치하며, 업데이트하는 역할을 합니다.
    - **호환성**: Snapd 는 Ubuntu 를 포함한 다양한 Linux 배포판에서 작동하며, Snap 패키지의 플랫폼 독립성을 가능하게 합니다.
- **Snap Store**
    - **정의**: Snap Store 는 Snap 패키지들이 모여 있는 공식 저장소입니다.
    - **역할**: 개발자들은 Snap Store 에 자신의 애플리케이션을 게시할 수 있으며, 사용자들은 필요한 소프트웨어를 여기서 찾아 설치할 수 있습니다.
    - **보안**: Snap Store 에서 제공하는 패키지들은 **보안 검증 과정을 거치므로** 사용자는 안심하고 사용할 수 있습니다.
- **Snapcraft**
    - **정의**: Snapcraft 는 Snap 패키지를 생성하는 도구입니다.
    - **기능**: 개발자들은 Snapcraft 를 사용하여 자신의 애플리케이션을 Snap 형식으로 패키징할 수 있습니다. 이는 **`snapcraft.yaml`** 파일을 통해 소프트웨어의 구성과 종속성을 정의합니다.
    - **유연성**: Snapcraft 는 다양한 프로그래밍 언어와 프레임워크를 지원하여, 광범위한 애플리케이션에 활용될 수 있습니다.

## Snap vs APT

기존에 apt 를 이용해보신 분들이라면 공감하실 수도 있겠지만 특정 소프트웨어를 설치할 때 의존성문제 때문에 많이 골치를 겪어본 경험이 많을 겁니다. 예르들어서 A 를 다운로드 하려고 했는데 B 를 다운로드 하라고 하던지 B 를 다운로드 받으려고 하니 C 를 받으라는 메세지가 나오는 그런경험은 리눅스를 사용해본 유저라면 한번쯤은 해볼 경험입니다.

대신 Snap 은 샌드박스 형태의 어플리케이션 포맷을 사용함으로써 의존성에 대해서 자요롭게하고자 하였고 APT 와 달리 의존성에 대한 정보를 가지고 있는 것이 아니라 의존성 자체를 포함하고 있어서 의존성 여부에 전혀구애를 받지 않고 사용할 수 있다.

또한 하나의 샌드박스 형태로 묶여서 있기에 격리된 공간을 할당받아서 실행하게 되는데 이를 통해서 좀 더 제한되는 형태로 외부와 통신하게 되고 이는 검증되지 않은 불안전한 어플리케잇녀이나 함부로 해당 시스템이 다른 외부시스템에 대한 간섭을 하지 못하게 막는 보안적인 측면에서 장점이 있다.

![Untitled](images/Untitled%201.png)

### Snap 유의사항

Snap 과 APT 방식을 비교했을 때 일부 고려해야하는 부분들이 있을 수 있습니다. 사실 이점이 더크기에 이런 부분이 부족할 수 있구나정도로 참고해주시면 좋을 것 같습니다.

- **디스크 공간 사용:** Snap 패키지는 APT 로 설치된 패키지보다 더 많은 디스크 공간을 차지할 수 있습니다. 왜냐하면 위에 설명이 되어있듯이 Snap 패키지가 의존성이 있는 라이브러리들을 패키지 내에 포함하기 때문입니다. 또한 여러 Snap 패키지가 같은 라이브러리를 사용하더라도, 각 패키지는 해당 라이브러리의 별도의 복사본을 포함하고 있어서 APT 에 비해 중복되는 라이브러리들이 많아 디스크 공간을 효율적으로 운영하고 있지는 않습니다.
- **메모리 및 CPU 사용량**: 격리된 환경과 자체적인 의존성들로 인해 Snap 으로 설치된 앱들은 더 많은 메모리와 CPU 자원을 사용할수도 있으며 Snap 으로 시작되는 앱은 APT 방식에 비해서 조금 느릴 수 있습니다.
- **자동 업데이트**: Snap 은 자동 업데이트 기능이 있어 편리하지만, 사용자가 업데이트를 제어할 수 있는 유연성이 떨어집니다. 예를 들어, 특정 시점에서 소프트웨어 버전을 유지하고 싶어하는 사용자에게는 불편할 수 있습니다. 대신 개발자가 Snap Store 에 여러버전을 별도로 게시하는 경우에는 특정버전을 설치 할 수 있지만 Snap 자체가 최신버전을 사용하도록 권장을 하기 떄문에 특정버전에 머무르고 싶다면 제약사항이 좀 있을 수 있습니다.다.

## 마무리

Snap 이 부족한점이 있지만 그걸 상쇄할만한 여러 장점들을 제공하고 있습니다. 특히 의존성과 보안 다양한 리눅스 배포판에서의 호환성을 고려했을 때 앞으로는 점점 더 많이 snap 으로 패키지들이 관리되지 않을까 생각해봅니다.