# Docker 시리즈-1 [컨테이너란 무엇인가]

#### Docker에 관심을 가지다

입사를 하고 부터 꾸준히 Docker관련 내용들을 동료들로부터 들었는데 실제로 써볼 기회가 없었다. 개인적인 관심으로 PC에 설치를 해서 돌려본게 다였는데 최근에 이직을 하면서 모든 프로젝트들이 컨테이너 기반에 올라가다 보니 본의 아니게 Docker에 대해서 관심을 많이 쏟을수 밖에 없게 되었다. 정확하게 말하자면 컨테이너 기반 플랫폼에 대해서 관심이 많아졌다는 것이지만..

아직 걸음마 정도수준밖에 안되지만 공부도 할겸 Docker 시리즈를 한번 적어내려 가보려고 한다.



#### 컨테이너란 무엇인가

Docker가 무엇인가를 설명하기 전에 우선 컨테이너에 대해서 이해를 해야한다.  도커 공식사이트에서는 컨테이너를 아래와 같이 정의하고 있다.

> A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another.



즉 컨테이너란 Application이 돌아가는데 필요한 패키지들과 의존성들이 포함된 단위라고 보면된다. 그럼 이런 의문이 들 수 있는데 기존 VM도 Application을 운영하기 위해서는 필요한 패키지들과 다양한 의존파일들이 있는데 그럼 이것도 컨테이너냐라고 반문할 수 있는데 이때 큰 차이점은 **단위(Unit)**에 있다.

![img](https://www.docker.com/sites/default/files/d8/2018-11/container-vm-whatcontainer_2.png)  



VM기반에서 서비스를 운영한다면 Application은 위와 같은 구조를 가지고 있을 것이다. 컨테이너와의 차이는 Application이 돌아가는데는 최소한의 단위가 게스트 OS가 필요한 반면 Container는 그렇지않다. 필요로하는 패키지와 의존성만 있으면 되므로 아주 빠르고 신뢰할 수 있는 Application을 구성할 수 있다. 

빠르다는건 기본적으로 특정 OS를 설치하여 운영하는 것 보다 필요로하는 최소한의 패키지와 파일들을 구성하여 운영하는 것이 훨씬 효율적이기 때문이다.

신뢰할 수 있는 Application이라면 그럼 뭘까? 예를 들어서 A와 B라는 개발자가 일을 하고 있다고 가정해보자. A라는 개발자는 윈도우에서 개발을 하고 있고 B라는 개발자는 맥에서 개발을 하고 있다. 하지만 둘다 배포는 CentOS에 배포를 해야하는 상황이라면 어떤식으로 개발이 될까?

사실 각자 PC에서 개발을 하고 배포를 하더라도 문제가 없을 수 있지만 확실한건 로컬에서 잘돌아가는 코드들이 막상 서버에 배포를 하게되면 문제가 발생할 경우가 있다. 구현했던 테스트가 Production환경에서는 다르게 동작이 된다던가, 최악의 경우에는 빌드자체도 되지 않을 수 있다. 개발자 A, B의 코드가 배포하는 서버와의 환경과 동일하지 않다면 신뢰성이 떨어질 수 있다는 걸 의미한다.



![img](https://www.docker.com/sites/default/files/d8/2018-11/docker-containerized-appliction-blue-border_2.png)



위에서 들은 예시는 컨테이너를 통해서 간단하게 해결 할 수 있다. 개발자 A,B 가 설치하고 배포하려는 CentOS서버와 동일한 환경을 이미지로 만들어 개발한다면 실제 Production환경에서도 문제없이 똑같은 빌드결과와 테스트를 기대할 수 있을 것이다. 왜냐하면 Docker위에서 운영되는 컨테이너들은 모두 Host에서 고립(Isolation)될 수 있기에 항상 같은 결과를 기대할 수 있고 그렇기에 컨테이너는 신뢰할 수 있는 (reliable) 특징을 가지고 있다고 말 할 수 있다. 

<u>주의해야할 점이 있는데 고립되어 있다고 하지만 커널레벨에서까지 고립이 되어있지 않기에 커널을 건드려야하는 프로젝트에서는 컨테이너기술이 적합하지 않을 수 있다.</u>



#### Docker란

Docker는 거의 업계 표준으로 자리를 잡았지만 컨테이너와 Docker가 동일한 의미는 아니다. Docker는 컨테이너를 만들고 사용할 수 있도록 하는 기술 중에 하나다. Docker이전에도 컨테이너를 만드는 기술이 없었던 것은 아니다. 리눅스 LXC가 이전부터 있었고 초기 Docker도 리눅스 LXC기반으로 만들어지긴 하였지만 지금은 종속성을 벗어나 Docker Engine을 기반으로 컨테이너 기술을 구현하였다.

![img](https://www.redhat.com/cms/managed-files/traditional-linux-containers-vs-docker_0.png)



CentOS8에서는 리눅스 컨테이너 기반의 **podman**이 기본적으로 설치가 된다고 하는데 개인적으로는 Docker를 이기기는 힘들지 않을까 싶다. **podman**의 경우 Docker Engine이 필요없다는 장점이 있지만 사실 LXC가 사람들의 선택을 받지 못한 이유도 세상에 나왔을 당시에 그다지 사람들의 사랑을 받지 못하였기 때문인데 이 부분은 자세히 모르기 때문에 나중에 기회가 된다면 다른 컨테이너기술들에 대해서도 다뤄봐야겠다는 생각이들었다.

오늘 글은 여기서 마무리를 하고 다음에는 Docker에 대해서 설치와 구조에 대해서 조금더 심화하여 파보겠다.  
