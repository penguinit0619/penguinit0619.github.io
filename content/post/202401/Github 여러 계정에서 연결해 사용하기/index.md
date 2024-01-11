+++
author = "penguinit"
title = "Github 여러 계정에서 연결해 사용하기"
date = "2024-01-11"
description = "해당 포스트를 통해서 특정 머신에서 여러개의 git 프로젝트를 관리할 수 있습니다."
tags = [
"git", "github", "ssh",
]

categories = [
"script",
]
+++

# Github 여러 계정에서 연결해 사용하기

## 개요

본의아니게 개인컴퓨터로 회사 일을 해야할 때 가 종종 있습니다. (~~리눅스 유저의 숙명인진 모르겠지만~~) 처음에 이걸 맞닥뜨렸을 때는 너무 불편했었는데 Github 이 여러 계정 지원을 하지 않았던 시절도 있었고 이미 개인적으로 쓰고 있던 프로젝트들과 회사 프로젝트들을 같이 운영하다보니 삽질했던 기억들이 많은데 이를 정리하고자 합니다.

## Github 에서 여러계정 운영

예전부터 왜 지원안해주지 시리즈 중에 하나였는데 생각보다 최근에 지원을 하게된 기능입니다.

[https://github.blog/changelog/2023-11-03-multi-account-support-on-github-com/](https://github.blog/changelog/2023-11-03-multi-account-support-on-github-com/)

![Untitled](images/Untitled.png)

![Untitled](images/Untitled%201.png)

이미 계정을 등록한 경우에는 **Switch account**를 통해서 계정을 변경할 수 있고 **Add account**를 통해서 자신이 사용하고 있는 계정을 추가로 등록할 수 있습니다. 👍

## 로컬환경 세팅

Github 계정은 미리 등록해둠으로써 편하게 변경할 수 있는 것을 확인했는데 로컬에서는 어떻게 작업해야할까? 우선 제가 원하는 건 아래와 같았습니다.

![Untitled](images/Untitled%202.png)

- A 와 B 는 각기 다른계정의 프로젝트이다.
- A 와 B 모두 SSH 를 이용해서 프로젝트를 Clone 받고 싶다.
- A 와 B 모두 Commit 을 하면 해당 프로젝트에 맞는 계정으로 Author 정보가 남았으면 좋겠다.
- A 와 B 모두 Push 를 하게 되면 각 계정, 프로젝트에 맞게 Push 가 되었으면 좋겠다.

### Github 연동 세팅

대부분 그렇겠지만 `HTTPS`의 경우에는 매번 비밀번호를 입력해야하는 귀찮음 때문에 `SSH`로 환경설정을 해두고 있습니다. 하지만 문제는 연동해야하는 계정이 2 개이기 때문에 키도 2 개를 설정해야만 합니다.

### SSH 키 세팅

우선 추가적인 계정에 대한 세팅을 해야하기 때문에 SSH 키를 새롭게 만들고 Github 계정에 등록을 해야합니다.

```bash
> ssh-keygen -t rsa -C "user-email@gmail.com"

Generating public/private rsa key pair.
Enter file in which to save the key (/home/penguin/.ssh/id_rsa):
```

위에 처럼 입력하게 되면 어디에 저장하기를 원하냐는 메세지가 나오는데 적당하게 홈디렉토리 기준으로 `.ssh` 폴더 하위에 원하는 이름으로 만들어줍니다. 저같은 경우에는 `사명_rsa` 로 저장하였습니다.

위와 같이 생성하게 되면 사설키와 공개키가 만들어지는데 공개키는 `.pub` 확장자로 페어로 만들어집니다.

이렇게 키를 만들었으면 공개키를 github 에 등록해줍니다. 등록되는 사용되는 곳에서 유일해야하기 때문에 이렇게 매번 만들어 줘야만 합니다.

1. [https://github.com/settings/ssh/new](https://github.com/settings/ssh/new) 접속 (로그인이 되어있어야 하고 등록하려는 계정으로 스위치가 되어있어야 합니다)

![Untitled](images/Untitled%203.png)

2. Title 은 본인이 나중에 식별할 수 있게 적어두고 Key 값에는 방금 생성한 공개키를 넣습니다. (.pub 확장자 파일 안에 있는 내용을 그대로 copy & paste)
3. Add SSH key 클릭

### Github Clone

SSH 키를 등록했으니 클론을 해봐야지라고 생각하고 땡겨보면 아래와 같은 에러가 생깁니다.

```bash
'example-repo'에 복제합니다...
ERROR: Repository not found.
fatal: 리모트 저장소에서 읽을 수 없습니다

올바른 접근 권한이 있는지, 그리고 저장소가 있는지
확인하십시오.
```

위와 같은 에러가 생기는 이유는 기존에 사용하고 있는 사설키가 SSH 의 기본키로 잡혀있기 때문에 맞지 않는 키로 접근시도를 했기에 권한문제가 생기는 것입니다. 이를 해결 하기 위해서는 ssh 접근시 적절한 사설키로 접근 할 수 있게 작업이 필요합니다.

ssh 사용시 `config` 파일을 통해서 특정 주소에 접근할 때 어떤 사설키를 사용하게 할 수 있을지 설정을 할 수 있습니다.

1. 키가 저장되어있는 폴더에 `$home/.ssh`에 들어가서 `config` 파일을 생성합니다.
2. 파일 내부에 아래와 같이 값을 설정합니다.

```bash
# 기존에 설정된 SSH 정보
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/first_rsa

# 방금 추가한 SSH키 값 정보
Host penguin.github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/second_rsa
```

위에 설정을 좀 더 자세히 설명하자면 아래와 같은데 이런 조건이 있으면 특정 사설키를 쓰겠다는 설정으로 이해하면 됩니다.

- **Host penguin.github.com**: 이 설정은 **`penguin.github.com`**이라는 별칭으로 SSH 연결을 구성합니다.
- **HostName github.com**: 실제 연결할 서버의 주소는 여전히 **`github.com`**입니다.
- **User git**: GitHub 의 'git' 사용자가 사용됩니다.
- **IdentityFile ~/.ssh/second_rsa**: 이 연결에는 다른 SSH 키인 **`second_rsa`**가 사용됩니다.
3. git clone 을 다시 시도

```bash
## AS-IS (권한문제로 동작하지 않음)
git clone git@github.com:penguin-project/example.git 

## TO-BE (장상동작)
git clone git@penguin.github.com:penguin-project/example.git
```

### Git 계정분리

위와 같이 설정하면 작업하는데 크게 무리는 없지만 commit 을 할 때 author 에 대한 이슈가 아직 남아있습니다. 🤒

계정을 하나만 사용한다면 보통은 바꿀 일이 별로 없기때문에 아래처럼 보통 설정을 하게 됩니다.

```bash
git config --global user.name "펭귄님"
git config --global user.email "penguinit0619@gmail.com"
```

계정을 여러 개 사용하기 때문에 별도의 작업을 하지 않으면 commit 할 때마다 원하지 않는 작업자로 기록이됩니다. 해결하기 위해서는 해당저장소에서 아래처럼 local 설정을 해주거나 매번 이런 작업이 괜찮다면 디렉토리 기준으로 global 설정값을 다르게 주는 방법이 있습니다.

- 로컬설정

```bash
git config --local user.name "펭귄님"
git config --local user.email "penguinit0619@gmail.com"
```

- 디렉토리 기반 Global 설정

**~/.gitconfig 파일**

```bash
[user]
        name = user
        email = user@gmail.com

[includeIf "gitdir:~/penguin/"]
        path = ~/.gitconfig-penguin
```

**`[includeIf "gitdir:~/penguin/"]`**: 이 지시문은 특정 조건 하에서 추가설정파일을 포함시키는 방법을 정의합니다. 여기서 조건은 **`gitdir:~/penguin/`**로, 이는 **`~/penguin/`** 디렉토리(또는 그 하위 디렉토리)에서 작업할 때만 적용됩니다

**~/.github-penguin 파일**

```bash
[user]
        name = penguin
        email = penguinit0619@gmail.com
```

**penguin 디렉토리 하위에서 유저설정확인**

```bash
> git config user.email
penguinit0619@gmail.com

> git config user.name
penguin
```

## 마무리

해당 포스트를 통해서 특정 머신에서 여러개의 git 프로젝트를 관리할 수 있습니다. 저 처럼 개인 프로젝트 작업도 하고 회사일도 하는 사람들에게 많이 도움이 될 수 있는 포스트였으면 좋겠습니다.