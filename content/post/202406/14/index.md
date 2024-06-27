+++
author = "penguinit"
title = "스프링에서 스트레오 타입 어노테이션에 대한 설명(Stereotype Annotations)"
date = "2024-06-27"
description = "Spring을 사용할 일이 점차 생기기 시작하고 있는데요, 스프링에서 제공하는 스트레오 타입 어노테이션에 대해 알아보고자 합니다."
tags = [
"spring",
]
categories = [
"framework"
]
+++

## 개요
Spring을 사용할 일이 점차 생기기 시작하고 있는데요, 스프링에서 제공하는 스트레오 타입 어노테이션에 대해 알아보고자 합니다.

## 스트레오 타입 어노테이션(Stereotype Annotations)
"스트레오타입"이라는 용어는 객체 지향 설계에서 특정 역할이나 책임을 가진 클래스를 묘사하기 위해 사용됩니다. 
역할에 맞게 구현된 어노테이션들이 여럿있지만 근본적으로 @Component 어노테이션을 확장한 것이고 기능상으로는 차이가 크게 없습니다.

- @Component : 범용적으로 사용되는 스프링 컴포넌트를 나타냅니다.
- @Repository : 데이터베이스와 관련된 작업을 수행하는 클래스를 나타냅니다.
- @Service : 비즈니스 로직을 처리하는 클래스를 나타냅니다.
- @Controller : 웹 요청을 처리하는 클래스를 나타냅니다.

위 4개의 어노테이션은 모두 @Component를 확장한 것이며, 스프링이 빈으로 등록할 클래스를 지정하는 데 사용됩니다.

## 사용해야 하는 이유
스트레오 타입 어노테이션을 사용하면 다음과 같은 이점을 얻을 수 있습니다.

### 코드의 가독성 향상
어노테이션을 통해 클래스의 역할을 명확하게 표현할 수 있습니다. 예를 들어, @Service 어노테이션을 사용하면 해당 클래스가 서비스 역할을 한다는 것을 명시적으로 알 수 있습니다.

### 예외적인 처리 가능
@Repository 어노테이션의 경우에는 다른 어노테이션과 달리 예외를 자동으로 처리해주는 기능을 제공합니다. 따라서 데이터베이스와 관련된 작업을 수행하는 클래스에 사용하면 편리합니다.

```java
@Repository
public class UserRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public User findById(Long id) {
        try {
            return jdbcTemplate.queryForObject("SELECT * FROM users WHERE id = ?", new Object[]{id}, new UserRowMapper());
        } catch (EmptyResultDataAccessException e) {
            throw new UserNotFoundException("User not found", e);
        } catch (DataAccessException e) {
            // 다른 데이터 접근 예외를 처리할 수 있습니다.
            throw new DatabaseOperationException("Database operation failed", e);
        }
    }
}
```
위의 케이스에서 데이터 접근 예외를 처리하는 부분에서 @Repository 어노테이션을 사용하면 EmptyResultDataAccessException과 DataAccessException을 자동으로 처리해줍니다.
실제로 Persistence Layer에서 사용하는 각각 데이터베이스가 뱉는 에러는 다르지만, @Repository 어노테이션을 통해 이를 통합하여 처리할 수 있습니다.

### AOP
각 어노테이션은 AOP에서 특정 포인트컷을 정의할 때 유용하게 사용될 수 있습니다. 예를 들어, @Service로 정의된 클래스에만 적용되는 로깅 기능 등을 쉽게 설정할 수 있습니다.

### 미래의 확장성
스프링은 계속해서 업데이트 되고 있고 각 어노테이션에 추가적인 의미와 기능이 부여될 수 있습니다. 예를 들어서 향후에 @Controller 어노테이션에 특정 기능이 추가된다면, 별도의 작업없이 해당 기능을 사용할 수 있습니다.
만약에 이런 구분없이 @Component만 사용한다면, 향후에 추가된 기능을 사용하기 위해서는 모든 클래스를 찾아서 수정해야 할 수도 있습니다.


## 합성 어노테이션 (Composed Annotations)
위에 설명했지만 스트레오 타입 어노테이션은 @Component를 합성한 어노테이션 입니다.

#### @Service 어노테이션 정의

```java
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Component 
public @interface Service {

	// ...
}
```
@Target, @Retention, @Documented는 메타 어노테이션(Meta-annotations)이라고 합니다.

### @Target(ElementType.TYPE)
어노테이션이 적용될 수 있는 요소를 지정합니다. 여기서 ElementType.TYPE은 클래스, 인터페이스(애노테이션 타입 포함), 열거형에 적용될 수 있음을 의미합니다.

### @Retention(RetentionPolicy.RUNTIME)
어노테이션이 어느 시점까지 유지되는지를 지정합니다. RetentionPolicy.RUNTIME은 런타임까지 어노테이션이 유지됨을 의미합니다. 즉, 런타임 시 리플렉션을 통해 어노테이션 정보를 사용할 수 있습니다.

### @Documented
어노테이션이 Javadoc에 포함되도록 합니다.

## 정리
오늘은 스트레오 타입 어노테이션에 대해서 알아보았습니다. 스프링을 사용하다보면 스트레오타입을 엄청 많이 사용하게 되는데 @Component와 어떤 점이 다르고 왜 사용하는 것이 좋은지에 대해서 알아보았습니다.



