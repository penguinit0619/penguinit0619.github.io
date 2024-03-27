+++
author = "penguinit"
title = "What is a Rate Limiter Part 1"
date = "2024-03-27"
description = "In this post, we'll discuss what a Rate Limiter is and what you need to consider when implementing one. This post will be a two-part series, as we'll also detail the algorithms that make up Rate Limiter."
tags = [
"rate-limiter"
]
categories = [
"web"
]
+++

## Overview
This article explains what a Rate Limiter is and what you need to consider when implementing it. This post will be part of a series, as we'll also detail the algorithms that make up Rate Limiter.

## What is a Rate Limiter
A rate limiter is a feature that limits the number of requests allowed over a period of time. This helps prevent server overload and increases the availability of your service. Rate limiters can be implemented through various algorithms.

- Token Bucket
- Leaky Bucket
- Fixed Window Counter
- Sliding Window Log
- Sliding Window Counter

We will explain each algorithm with detailed diagrams after this post.

## Rate Limiter on the HTTP API server
When implementing a rate limiter on an HTTP API server, the server needs to clearly inform the client when a request has exceeded the limit. This can be implemented using specific HTTP headers along with HTTP response status codes

### HTTP Status Code
429 Too Many Requests: This status code indicates that the client has exceeded the number of requests allowed for the specified time. This status code should be used as a response when requests are limited by a rate limiter.

### Rate Limiter header
You can use the following HTTP headers to provide information to the client about rate limiting.

- X-RateLimit-Limit: The maximum number of requests allowed (usually within a certain amount of time).
- X-RateLimit-Remaining: The remaining number of requests a client can make in a given amount of time.
- X-RateLimit-Reset: The time at which the Rate Limit is reset (usually given in epoch time).

These are not necessarily rules to follow, but they are conventionally used and many places (Twitter, Google, Facebook, etc...) give these status codes and header response values when implementing Rate Limiter, so I think it's a good idea to follow them if you implement Rate Limiter.

## Rate Limiter Targets
Defining a target is an important consideration when implementing a Rate Limiter. A target is the range or unit to which a rate limiter is applied, which can vary depending on the nature of your service, infrastructure, and the nature of the resources you want to protect.

### IP address
IP address-based rate limiting is one of the most common forms of rate limiting. By limiting the number of requests coming from a specific IP address, this approach prevents excessive requests for a service from a single user or network. This is useful for protecting your service from server attacks (e.g., DDoS attacks).

### User accounts
User-based rate limiting limits the number of requests for a specific user account. This is effective when the service can track requests based on personal user identification information (e.g., user ID, API key). User-based limiting is useful when you want to set different levels of service usage, such as for paid/free subscription plans.

### Application/Service
It is also possible to restrict requests to specific applications or services. For example, you can identify each application via an API key and limit the number of requests by that key. This is useful when a service is used by multiple applications, and you want to manage each application's usage fairly.

### Endpoints
This is how you limit the number of requests for a specific API endpoint or resource within your service. Some API endpoints may consume more server resources than others, so you may want to set stricter request limits for those endpoints.

### Region/Country
You can also limit requests by region or country. This can be used to manage excessive traffic from certain regions, or to optimize the user experience by region.

## Summary
We've covered what a rate limiter is, why you need one, and what you need to consider. I think it's a feature you'll have to consider at some point when running a server in production, and there are a variety of algorithms for implementing it. In the next post, we'll dive deeper into the different algorithms that can be used to implement a rate limiter.