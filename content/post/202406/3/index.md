+++
author = "penguinit"
title = "MYSQL8.0 로컬에서 접속이 되지않는 문제"
date = "2024-06-07"
description = "이번 포스팅에서는 Docker로 MYSQL8.0을 실행하고 로컬환경에서 외부 클라이언트(Datagrip, mysql workbench...)를 통해 접속이 되지 않는 문제에 대해서 알아보려고 합니다."
tags = [
"mysql"
]
categories = [
"database"
]
+++

## 개요
이번 포스팅에서는 Docker로 MYSQL8.0을 실행하고 로컬환경에서 외부 클라이언트(Datagrip, mysql workbench...)를 통해 접속이 되지 않는 문제에 대해서 알아보려고 합니다.

## 문제상황
- Docker로 MYSQL8.0을 실행하였고, 컨테이너 내부에서는 접속이 잘 되는 상황이었습니다.
- 하지만 로컬에서 외부 클라이언트(Datagrip, mysql workbench...)를 통해 접속을 시도하면 문제가 발생하였습니다.
- 에러메세지 : rsa public key is not available client side

## 원인
MYSQL5.x 버전에서는 `mysql_native_password`가 기본값으로 설정되어 있었기에 별도의 설정 없이도 유저 / 비밀번호만 입력하면 접속이 되었지만 MYSQL8.0부터는 `caching_sha2_password`로 기본값이 설정되어 있기에 외부 클라이언트에서 접속을 시도하면 에러가 발생하게 됩니다.

### caching_sha2_password
caching_sha2_password 플러그인을 사용하게 되면 서버와 클라이언트 연결시 암호화가 된 상태로 전달이 되어야합니다.
- RSA 공개 키 검색 및 사용
- SSL/TLS 설정

공개키를 이용해서 암호화된 비밀번호를 서버로 전달을하거나 SSL/TLS를 사용하여 암호화된 비밀번호를 전달하는 방식으로 접속을 해야합니다.

## 해결방법
두 가지 방법 중에서 하나를 선택해야 하는데 보통은 로컬에서 테스트를 위해 Docker로 DB를 띄우는 경우가 많기에 SSL/TLS를 설정하는 것은 너무 번거러운 작업이라고 생각됩니다.

RSA 공개키를 사용하는 방법을 사용하는게 가장 간단하며 아래와 같이 접속시 옵션들을 활성화 해주는 것으로 에러를 피할 수 있습니다. 

```
jdbc:mysql://localhost:3306/exampledb?allowPublicKeyRetrieval=true&useSSL=false";
```

- allowPublicKeyRetrieval=true : RSA 공개키를 사용하여 접속을 허용
- useSSL=false : SSL/TLS를 사용하지 않음

위와 같이 설정을 하면 MYSQL8.0에서도 로컬에서 외부 클라이언트로 접속이 가능합니다. 


### RSA 공개키를 사용하여 접속하는 방법
막연하게 RSA 공개키를 사용하여 접속한다고 하였지만 실제로 어떻게 동작하는지에 대해서 좀 더 자세히 설명해보려고 합니다. 

1. 클라이언트 연결 시도: 클라이언트가 MySQL 서버에 연결을 시도합니다.
2. 공개 키 요청: allowPublicKeyRetrieval=true 옵션이 설정되어 있으면, 클라이언트는 서버에 공개 키를 요청합니다.
3. 서버의 응답: 서버는 자신의 공개 키를 클라이언트에게 전송합니다.
4. 비밀번호 암호화: 클라이언트는 받은 공개 키를 사용하여 비밀번호를 암호화하고 서버로 전송합니다.
5. 서버에서 인증: 서버는 자신의 개인 키를 사용하여 암호화된 비밀번호를 복호화하고, 클라이언트를 인증합니다.

위와 같은 과정을 통해서 RSA 공개키를 사용하여 접속을 하게 됩니다. 내용을 보시면 알겠지만 MYSQL8.0 이상부터는 평문으로 민감한 정보들이 전송되지 않도록 보안을 강화하였습니다.

## 정리
MYSQL8.0 이상부터는 caching_sha2_password로 기본값이 설정되어 있기에 외부 클라이언트에서 접속을 시도하면 RSA 공개키를 사용하여 접속을 해야합니다. 구체적으로 어떤 옵션들을 이용하면 접속할 수 있는지 알아보았고 서버와 클라이언트가 어떻게 RSA 공개키를 사용하여 접속하는지에 대해서도 알아보았습니다.