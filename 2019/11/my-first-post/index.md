# My First Post

# 11월 19일 메모



# Docker

- Docker 설치하기 (우분투)

**이전에 설치한 Docker가 있다면 모두 삭제를 한다.**

```bash
#이전에 설치된 docker, docker io, docker-engine은 모두 삭제한다.
sudo apt-get remove docker docker-engine docker.io containerd runc
```



**Docker에 의존성이 있는 패키지들을 설치**		

```bash
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```



**Docker 공식 GPG키를 등록** 

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```



**Ubuntu 버전에 맞는 Repository를 추가**

```bash
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

 

**APT 패키지를 업데이트 해준다. (추가한 Repository의 반영을 위해서)**

```bash
sudo apt-get update
```



**최신버전의 Docker를 설치**

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io
```



> 만약에 특정 버전의 Docker를 설치하고 싶다면?



**특정버전의 Docker를 설치**

```bash
apt-cache madison docker-ce
 docker-ce | 5:19.03.5~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.4~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.3~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
 docker-ce | 5:19.03.2~3-0~ubuntu-bionic | https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
...

sudo apt-get install docker-ce=<VERSION_STRING> docker-ce-cli=<VERSION_STRING> containerd.io
```



만약 **5:19.03.5~3-0~ubuntu-bionic** 버전의 우분투를 설치하고 싶다면 명령어는 아래와 같이 타이핑 할 수 있다.



```bash
sudo apt-get install docker-ce=5:19.03.5~3-0~ubuntu-bionic docker-ce-cli=5:19.03.5~3-0~ubuntu-bionic containerd.io
```



**설치확인**

```bash
sudo docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.
....
```







- sudo 없이 Docker 실행하기

  ```bash
  # usermod :사용자 속성을 변경하는 명령어
  sudo usermod -aG docker $USER
  
  #리부팅 필요
  sudo systemctl reboot
  ```

  

# GPG

- GPG란 무엇인가? (Docker를 설치하다가 나온개념)

1. 첫번째 개념
2. 두번째 개념
3. 세번째 개념
