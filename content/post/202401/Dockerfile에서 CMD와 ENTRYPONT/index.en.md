+++
author = "penguinit"
title = "In the Dockerfile, CMD and ENTRYPONT"
date = "2024-01-30"
Description = "See what the roles of `ENTRYPOINT` and `CMD` play in Dockerfile and see the difference between the two commands."
tags = [
"docker"
]

categories = [
"infra"
]
+++

## Overview

Find out what role `ENTRYPOINT` and `CMD` play in Dockerfile and see the difference between the two commands.

![Untitled](images/Untitled.png)

## ENTRYPOINT

`ENTRYPOINT` defines the command to execute when the container is started. The first factor refers to the command to execute and the remaining factors refer to the parameter.

```docker
FROM centos:7
ENTRYPOINT ["echo", "Hello, Penguin"]
```

If you do it as above, you will receive "Hello, Penguin" as a factor in the echo command as below and output it.

```bash
$ $ docker run hello-world
Hello, Penguin
```

## CMD

`CMD` provides the default parameters passed to `ENTRYPOINT` or defines the default commands to execute when `ENTRYPOINT` is not provided.

When you write a simple dockerfile, you'll choose either `CMD` or `ENTRYPOINT`. So you might think that the two commands are used in a similar sense, but to be precise, `CMD` is an auxiliary role of `ENTRYPOINT`. If you look at the example code below, you'll understand it a little more.

The Hello, Penguin!!! code I wrote above can be written like this by combining `ENTRYPOINT` and `CMD`.

### CMD used as a parameter for ENTRYPOINT

```docker
FROM centos:7
CMD ["Hello Penguin!!!"]
ENTRYPOINT ["echo"]
```

```bash
$ $ docker run hello-world
Hello, Penguin!!!
```

### CMD is used alone and used as a command

```docker
FROM centos:7
CMD ["echo", "Hello Penguin!!!"]
```

```bash
$ $ docker run hello-world
Hello, Penguin!!!
```

As described above, `CMD` serves as a parameter for `ENTRYPOINT` or as a definition of the basic command to execute when used alone.

## Use Examples

Using these characteristics of `ENTRYPOINT` and `CMD`, you can.

- 'ENTRYPONT' is performed while executing echo commands
- `CMD` sets the default value for echo factor: Hello, World!
- When the docker is run, the value of `CMD` is overriding to the value of the user factor when the docker is delivered as a factor value.

I'm going to edit and paste the code that I just wrote with the example of `CMD`.

```docker
FROM centos:7
CMD ["Hello, World"]
ENTRYPOINT ["echo"]
```

If you hand over the value of "Hello, Penguin" when docker is performed like this, the value of "CMD" is ignored and replaced by the value entered by the user.

```bash
$ $ docker run hello-world
Hello, World

$ $ docker run hello-world 'Hello, Penguin'
Hello, Penguin
```

To summarize use examples, `CMD` can flexibly handle requests and allow users to change commands at execution time. `ENTRYPOINT` forces the container to execute specific commands

## CMD/ENTRYPOINT Correlation

The correlation between `CMD` and `ENTRYPOINT` is summarized in a table as follows.

|  | No ENTRYPOINT              | ENTRYPOINT exec_entry p1_entry | ENTRYPOINT ["exec_entry", "p1_entry"] |
|--|----------------------------|--------------------------------|---------------------------------------|
|  | No CMD                     | error, not allowed             | /bin/sh -c exec_entry p1_entry        | exec_entry p1_entry |
|  | CMD ["exec_cmd", "p1_cmd"] | exec_cmd p1_cmd                | /bin/sh -c exec_entry p1_entry        | exec_entry p1_entry exec_cmd p1_cmd |
|  | CMD exec_cmd p1_cmd        | /bin/sh -c exec_cmd p1_cmd     | /bin/sh -c exec_entry p1_entry        | exec_entry p1_entry /bin/sh -c exec_cmd p1_cmd |

## Clean up

Through this article, we learned about the concepts and differences between `CMD` and `ENTRYPOINT`. When used in practice, there are cases where you use only `ENTRYPOINT` or `CMD` without much thought, so I think it would be a good idea to make a flexible container by combining them properly