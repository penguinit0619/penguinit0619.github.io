+++
author = "penguinit"
title = "What is Idempotent?"
date = "2024-02-03"
description = "If you're developing HTTP APIs, you've probably heard about idempotent at one point or another. In this post, we'll look at what idempotent is and try to understand it a little better through an HTTP API example."
tags = [
    "http", "rfc", "idempotent"
]

categories = [
    "api",
]
+++

## Overview

When developing HTTP APIs, you've probably heard about idempotent from time to time. In today's post, we'll look at what idempotent is and try to understand it better through an HTTP API example.

## What does it mean to be idempotent?

I first heard this term when a team I used to work for was talking about how to design RESTful APIs, and while I understand it now, I remember being stumped when I first heard it because I couldn't even make an analogy to a word I'd never heard before.

To start, here's a quick summary of the dictionary meaning of idempotent.

> In mathematics or computing, a property of an operation, such that the result does not change when the operation is applied multiple times.

*Source ([https://en.wikipedia.org/wiki/Idempotence](https://en.wikipedia.org/wiki/Idempotence))*

>

For example, the act of adding 0 or multiplying a certain number by 1 is said to be commutative because it always gives the same result, and if applying a certain function twice on a certain set gives the same value, then the function is said to be commutative.

**f(f(x)) = f(x)**

In programming, for example, if we have a set called [1,2,3,4,5] and we perform the Max function on this set of functions, we will get the value 5. If we call the Max function again on this output, we will get the value 5 again, so we can say that this function is **idempotent**.

## Idempotent in HTTP

Idempotent also exists for HTTP methods ([RFC 7231](https://www.rfc-editor.org/rfc/rfc7231#section-8.1.3))

| Methods | Safety | Idempotent |
|---------|--------|------------|
| CONNECT | no     | no         |
| DELETE  | no     | yes        |
| GET     | yes    | yes        |
| HEAD    | yes    | yes        |
| OPTIONS | yes    | yes        |
| POST    | no     | no         |
| PUT     | no     | yes        |
| TRACE   | yes    | yes        |

When I first understood idempotent, POST and PATCH made sense to me, but I was a little surprised that PUT and DELETE were idempotent. But if you think about it from a resource perspective, PUT is an overwrite, so you can think that the result is always the same, and so is DELETE. If you think about it from that perspective, PUT and DELETE are also idempotent methods.

### What is safety?

Stability is related to resources. Stable methods do not change the resource, for example, GET, HEAD, and OPTIONS will not change the resource no matter how many times you request them. Conversely, DELETE and PUT have idempotent, but we can say that they are not safe because sometimes the resource is actually spilled or deleted with other information.

## PATCH Method

If you look at the previous table, you'll notice that a commonly used method is missing. The PATCH method is not mentioned in RFC 7231 because the document is called "HTTP/1.1 Semantics and Content", which defines its usage based on HTTP/1.1. The PATCH method was officially introduced in [RFC 5789] (https://www.rfc-editor.org/rfc/rfc5789) "PATCH Method for HTTP", and the HTTP/1.1 definition does not include the PATCH method, so it is missing.

### Idempotent

The bottom line is that the PATCH method may or may not be idempotent. You may be asking what this means, but the RFC 5789 document actually states that PATCH may or may not be idempotent.

In the "2. Idempotent Methods" section of RFC 5789, it says the following.

> PATCH is neither safe nor idempotent as defined by [RFC2616], Section 9.1.
> -.
> A PATCH request can be issued in such a way as to be idempotent, which also helps prevent bad outcomes from collisions between two PATCH requests on the same resource in a similar time frame. Collisions from multiple PATCH requests may be more dangerous than PUT collisions because some patch formats need to operate from a known base-point or else they will corrupt the resource. Clients using this kind of patch application SHOULD use a conditional request such that the request will fail if the resource has been updated since the client last accessed the resource. For example, the client can use a strong ETag [RFC2616] in an If-Match header on the PATCH request.

For example, you can design an API with an idempotent case and a non-idempotent case, depending on the situation, as shown below.

- Idempotent : If a **PATCH** request changes a specific part of a resource to a specific value, repeating the same **PATCH** request multiple times will have the same result. For example, a request that replaces a specific section of a specific document with a specific content is an idempotent because that section of the document will reflect the same content no matter how many times it is performed.

- Non-idempotent: On the other hand, if a **PATCH** request makes a relative change to a resource (for example, an operation like "add 1 to the current value"), it might not be idempotent. If such a request is performed multiple times, the state of the resource will change each time.

## Idempotent examples

Let's assume we're creating a user API for the sake of argumentation and give an example of idempotent.

### GET

- Idempotent: The **GET** method is idempotent. Sending the same **GET** request multiple times does not change any data or state on the server.

- Example

    - Retrieve user profile information.

    - The request

    ```http
    GET /users/123
    ```

    - Response: Returns the profile information for user 123.

### POST

- Idempotent: The **POST** method is generally not idempotent. Sending the same request multiple times can result in multiple copies of the same data on the server.

- Examples

    - Create a new user.
    - The request

  ```http
  POST /users
  {
     "name":"John Doe",
     "email":"john@example.com"
  }
  ```

    - Response: A new user is created and the information of the created user is returned

### PUT

- Idempotent: The **PUT** method is idempotent: sending the same **PUT** request multiple times will not change the state of the resource created or modified by the first request.

- Examples

    - Update a user's email address.
    - The request

  ```http
  PUT /users/123
  {
     "name":"Jane Doe",
     "email":"janedoe@example.com"
  }
  ```

    - Response: User 123's email address is updated, and the changed user information is returned.

### PATCH

- Idempotent: The **PATCH** method may or may not be implementation dependent. However, it is recommended that it be implemented as such.

- Example.

    - Update partial information (name) of a user.
    - The request

  ```http
  PATCH /users/123
  {
     "name":"Jane Doe"
  }
  ```

    - Response: The name of user 123 is updated, and the changed user information is returned.

### DELETE

- Idempotent: The **DELETE** method is idempotent. After the first **DELETE** request successfully deletes a resource, repeating the same request will not result in any additional changes to the server's state.

- Examples

    - Delete a user.
    - The request

  ```http
  DELETE /users/123
  ```

    - Response: User 123 has been deleted. Additional requests may return a **404 Not Found** or **204 No Content** with no status change.

## Summary

We've seen what idempotent is, and we've summarized the idempotent and stability of each method through the RFC document.

In real life, I've encountered many HTTP APIs that don't conform to the RFC documentation. At first, I remember thinking that I was wrong and trying to make it right, but I think RFC documents define Internet standards, and I don't think you can say that it's wrong to deviate from them. Sometimes you have to deviate from them for certain business requirements, and sometimes you have to do it the old-fashioned way because existing implementations don't follow them.

API design is really hard, I've done it hundreds of times, but every time I do it, it seems like it's hard, and I think that's what makes it hard and fun because there's no answer.