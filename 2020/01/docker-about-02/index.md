# Docker 시리즈-2 [도커 개요 및 설치]


#### Docker 구성요소

Docker의 구성요소는 아래 그림과 같다.

![Docker Architecture Diagram](https://docs.docker.com/engine/images/architecture.svg)

#### Docker daemon(dockerd)

도커 데몬은 도커를 구성하는 이미지나 컨테이너 네트워크 볼륨등을 컨트롤 하며 도커 데몬은 다른 서비스에 떠있는 데몬들과도 통신을 할 수 있다.



#### Docker client(docker)

도커 클라이언트는 보통 도커를 이용하는 유저들이 도커와 상호작용하기위한 주된 도구이다. 도커의 특정 명령어를 실행하면 클라이언트는 도커 데몬으로 명령어를 보낸다. 이때 docker API를 사용하며 도커 클라이언트는 복수의 도커 데몬과 통신할 수 있다.



#### Docker registries

도커 레지스트리는 간단하게 말하면 도커의 이미지를 저장하는 곳이다. 그 중 도커 허브(Docker hub)가 가장 대표적인데 Public한 레지스트리로 누구나 사용할 수 있으며 별다른 설정이 없다면 기본 레지스트리는 도커 허브로 지정된다.



#### Image

이미지는 도커컨테이너를 만들기 위한 오직 읽기만 가능한 템플릿이다. 종종 이미지는 다른 이미지의 베이스 이미지가 되기도하는데 예를 들어 우분투를 이미지로 사용한다고 했을 때 이곳에 만약 아파치 서버나 다른 파일들이 설치가 되어야 한다면 이런 필요로 하는 것들이 설치된 이미지를 우분투를 베이스 이미지로 하여 새로운 이미지를 만들 수 있다.

아마도 이미지를 사용할 때는 누군가가 만들어 놓은 이미지를 사용할 수 도 있고 필요에 따라 자신만의 이미지를 만들어야 할 수도 있다. 이때 `Dockerfile`에 심플한 문법을 통해서 이미지를 만들 수도 있는데 이때 Dockerfile내의 각각 코드들은 이미지의 레이어(Layer)가 된다.

만약 어떤 변경이 일어 났을 때 변경이 일어난 레이어만 변경이 되는데 이러한 특성때문에 이미지를 만드는데 있어서 기존 VM환경과 비교하여 아주 가볍고 빠르게 만든다.  



#### Containers

컨테이너는 이미지의 실행가능한 인스턴스 단위인데 docker api나 cli를 통해서 생성,시작, 중지, 삭제등을 명령할 수 있고 복수개의 네트워크를 붙일 수 도 있고 볼륨을 땟다 붙였다 할 수도 있으며 심지어 현재의 상태에서 새로운 이미지를 만들 수도 있다. 

기본 설정으로 컨테이너는 호스트 머신으로 부터 고립되어(isolate) 있는데 설정에 따라서 네트워크나 스토리지등을 어느레벨까지 고립을 할 것인지를 정할 수 있다. 

컨테이너는 이미지에 모든 것이 정의가 되어있으며 컨테이너가 삭제되면 그동안 안에 있었던 모든 변경설정들이 저장되지 않고 휘발되어 사라진다.



<u>그럼 여기까지 Docker의 구성요소에 대해서 알아보았으니 본격적으로 Docker를 설치해보려고 한다. 현재 노트북이 우분투기반 노트북이라 우분투를 기준으로 Docker 설치를 해보려고한다.</u>



##### 이전에 설치한 Docker가 있다면 모두 삭제를 한다.

```bash
#이전에 설치된 docker, docker io, docker-engine은 모두 삭제한다.
sudo apt-get remove docker docker-engine docker.io containerd runc
```



##### Docker에 의존성이 있는 패키지들을 설치		

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```



##### Docker 공식 GPG키를 등록 

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```



##### Ubuntu 버전에 맞는 Repository를 추가

```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

 

##### APT 패키지를 업데이트 해준다. (추가한 Repository의 반영을 위해서)

```bash
sudo apt-get update
```



##### 최신버전의 Docker를 설치

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```



> 만약에 특정 버전의 Docker를 설치하고 싶다면?



##### 특정버전의 Docker를 설치

```bash
apt-cache madison docker-ce
 docker-ce | 5:19.03.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.3~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.2~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
...

sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```



<u>만약 **5:19.03.5~3-0~ubuntu-bionic** 버전의 우분투를 설치하고 싶다면 명령어는 아래와 같이 타이핑 할 수 있다.</u>



```bash
sudo apt-get install docker-ce=5:19.03.5~3-0~ubuntu-bionic docker-ce-cli=5:19.03.5~3-0~ubuntu-bionic containerd.io
```



##### 설치확인

```bash
sudo docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
....
```



Docker도 설치하였고 다음 시리즈에는 `Docker client`의 명령어에 대해서 조금 깊게 포스팅 해보려고한다.
