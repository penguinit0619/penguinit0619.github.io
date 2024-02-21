+++
author = "penguinit"
title = "merge, diff3, zdiff3에 대해서 알아보기"
date = "2024-02-20"
description = "git conflict가 무엇인지에 대해서 알아보고 conflict style인 merge, diff3, zdiff3에 대해서 알아보겠습니다."
tags = [
"conflcit", "merge", "diff3", "zdiff3",
]

categories = [
"git",
]
+++


## 개요
git conflict가 무엇인지에 대해서 알아보고 conflict style인 merge, diff3, zdiff3에 대해서 알아보겠습니다.

> 해당글은 아래 포스팅을 참조하였습니다.

[https://ductile.systems/zdiff3/](https://ductile.systems/zdiff3/)

## Git Conflict

git에서 conflict는 두 개의 브랜치를 merge 할 때 같은 파일의 같은 부분을 다르게 수정했을 때 발생합니다. 같은 파일이라도 다른 부분을 수정한 경우에는 자동으로 병합하려고 하지만 사용자의 도움 없이는 결정할 수 없는 상황이 발생하는데 이 경우 사용자는 수동으로 해결해야 합니다.

## Conflict Style

Conflict Style 이란 충돌이 발생했을 때 내용을 어떻게 표시할지를 결정하는 설정입니다. 이 설정은 충돌 해결 과정에서 개발자에게 제공되는 정보의 양과 형식을 조정하여, 충돌을 더 쉽게 이해하고 해결할 수 있도록 돕습니다.

따로 건들지 않으면 Conflict Style은 `merge` 값으로 설정되어 있습니다.

### Conflict Style 변경방법

git 명령어를 통해서 conflict style을 변경할 수 있습니다.

```bash
git config --global merge.conflictStyle zdiff3 # zdiff3는 conflict 알고리즘 중 하나
```

### 사전준비

앞으로 설명할 Conflict Style을 설명하기 위해서 Conflict 상황을 만들고 해당 파일을 기준으로 상세하게 설명하겠습니다.

- A 파일 (main branch) **sha → ab812f2**

```bash
A
B
C
# Add More Letters
```

- A 파일 (main branch) 커밋추가 **sha → e7a12c6**

```bash
A
B
C
D
E
F
G
```

- A 파일 (target branch) **ab812f2 기반으로 커밋추가 sha → s1jd9c1**

```bash
A
B
C
D
E
X
Y
Z
```

### Merge Style

Git에서 기본으로 사용되는 스타일로 충돌이 일어난 각 부분에 대해서 `HEAD`(현재 체크아웃된 브랜치)의 변경사항과 병합하려는 브랜치의 변경사항이 나란히 표기가 됩니다.  간단 명료하지만 개발 콘텍스트를 잘 알지 못하면 어떤 것에서부터 변경이 있었고 어떤 코드를 유지해야 되는지에 있어서 정보가 부족하여 결국에는 해당 컨텍스트를 잘 아는 사람에게 물어보는 경우가 있습니다.

```bash
<<<<<<< HEAD
현재 브랜치에서의 내용
=======
병합하려는 브랜치에서의 내용
>>>>>>> feature-branch
```

```bash
A
B
C
D
E
<<<<<<< HEAD
F
G
=======
X
Y
Z
>>>>>>> feature-branch
```

기본 merge 방식은 파일 간의 차이점에 초점을 맞추고 있으며 병합 시 다른 값들에 대해서 나열되는 것을 확인하실 수 있습니다.

### diff3 Style

**`diff3`** 스타일은 **`merge`** 스타일에 비해 더 많은 정보를 제공합니다. 충돌하는 섹션에 대해 현재 브랜치와 병합 대상 브랜치의 변경사항뿐만 아니라, 변경 전 원본 내용도 함께 표시됩니다. 원본 내용을 통해서 양쪽 변경사항을 더 깊게 이해하여 최적의 해결책을 도출하는 데 도움을 줄 수 있습니다.

```bash
<<<<<<< HEAD
[현재 브랜치의 변경 내용]
||||||| merged common ancestor
[번경 전 원본 내용]
=======
[병합하려는 브랜치의 변경 내용]
>>>>>>> [병합하려는 브랜치 이름]
```

```bash
A
B
C
<<<<<<< ours
D
E
F
G
||||||| base
# Add More Letters
=======
D
E
X
Y
Z
>>>>>>> theirs
```

병합하려는 두 파일 모두 다 주석을 지우고 변경사항들을 추가했음을 알 수 있습니다. 하지만 위에 diff3의 경우에는 아쉬운 부분이 있는데요 D, E의 경우에는 merge 케이스를 기준으로 봤을 때 변화가 없다고 봐도 무방하기 때문에 Conflict 라인에 없어도 되지 않을까 생각할 수 있지만 diff3 목적이 최대한 많은 맥락을 제공해서 충돌의 원인과 변경사항을 더 잘 이해할 수 있게 하는 것에 목적이 있기에 오히려 복잡성이 증가할 수 있습니다. 

복잡하지 않다면 기존 merge 스타일의 병합이 좀 더 간단할 수 있습니다.

### zdiff3 Style

zdiff3는 2022년 1월 `git 2.35`에 새로 추가된 알고리즘입니다. (zdiff3를 사용하고 싶으시다면 2.35 이상버전의 git을 사용하셔야 합니다) 

특징을 간략하게 요약하자면 merge의 장점과 diff3의 장점을 섞어놓은 알고리즘으로 볼 수 있습니다.

```bash
A
B
C
D
E
<<<<<<< ours
F
G
||||||| base
# Add More Letters
=======
X
Y
Z
>>>>>>> theirs
```

위에 결과를 보면 merge와 동일하게 변경 점에 대해서 코드들이 나열되는 부분과 동시에 변경 전 원본 또한 노출되는 것을 확인하실 수 있습니다.

## 정리

git을 매일 사용하지만  이렇게 다양한 conflict style을 옵션으로 주고 있는지 이번에 정리를 하면서 알게 되었습니다. 

며칠 동안 사용해 봤는 데 저는 원본 내용이 나오는 것이 충돌을 해결하는 데 많은 도움이 되는 것 같습니다.