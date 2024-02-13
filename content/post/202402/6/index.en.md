+++
author = "penguinit"
title = "How to store and manage time in Golang"
date = "2024-02-13"
description = "In this post, you'll learn about the time package that Golang provides by default and what you should keep in mind when storing and using time data."
tags = [
"golang"
]

categories = [
"language"
]
+++

## Overview

In this post, we'll see how to use the time package provided by Golang by default and what to keep in mind when storing and using time data.

## Time package

The **`time`** package is a Golang standard library package that provides time-related functions. You can utilize it to perform various time-related tasks such as getting the current time, comparing time, adding and subtracting time, and formatting time.

### Getting the current time

Getting the current time in Golang is very simple.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	fmt.Println("Current time:", currentTime)
}
```

### Formatting time

The **`time`** package provides the ability to format time in various formats. You can use the **`Time.Format`** method to convert a time to a string of any format.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	fmt.Println("Default format:", currentTime.Format("2006-01-02 15:04:05"))
	fmt.Println("RFC1123 format:", currentTime.Format(time.RFC1123))
}
```

### Time operations

Time addition and subtraction operations are also very simple. You can use the **`time.Add`** method to add or subtract a specific time interval.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	currentTime := time.Now()
	oneWeekLater := currentTime.Add(7 * 24 * time.Hour)
	fmt.Println("One week later:", oneWeekLater)
}
```

## Dealing with timezones

The time covered by Golang's **`time`** package includes time zone information by default. This makes it easy to calculate and convert time in different time zones. However, it is important to note that if you do not specify a time zone when using the **`time`** package, it will default to the local time zone of the environment where Golang is running.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// output the current time using the local timezone
	currentTime := time.Now()
	fmt.Println("Current time (local timezone):", currentTime)

	// print the current time in UTC
	utcTime := time.Now().UTC()
	fmt.Println("Current time (UTC):", utcTime)
}
```

### Changing the timezone globally in Golang

Golang itself does not directly provide the ability to change the timezone globally while running a program. Instead, you can set the timezone through system or environment variables.

```bash
export TZ=Asia/Seoul
./my_go_application
```

### Changing the timezone in Docker

The default timezone for Docker containers is usually set to UTC. To change the timezone within a container, you can use one of the following methods

```docker
RUN apk add --no-cache tzdata \
    && ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
    && echo "Asia/Tokyo" > /etc/timezone
```

## JSON strings and the Time package

When Golang unmarshals JSON types to the **`time.Time`** type, the timezone handling depends on the format of the date and time data contained in the JSON string. By default, if the date and time string in JSON conforms to the RFC 3339 standard (for example, **`2006-01-02T15:04:05Z07:00`**), it can contain timezone information according to this standard.

If no timezone information is specified in the JSON string, Go's **`time.Time`** type interprets the time as UTC.

```go
package main

import (
	"encoding/json"
	"fmt"
	"time"
)

type EventWithTimezone struct {
	StartTime time.Time `json:"start_time"`
}

func main() {
	jsonStringWithTimezone := `{"start_time": "2024-02-13T15:04:05+09:00"}`
	jsonStringWithoutTimezone := `{"start_time": "2024-02-13T15:04:05"}`

	var eventWithTimezone EventWithTimezone
	var eventWithoutTimezone EventWithTimezone

	// JSON unmarshal with timezone information
	if err := json.Unmarshal([]byte(jsonStringWithTimezone), &eventWithTimezone); err != nil {
		fmt.Println("Unmarshal with timezone failed:", err)
		return
	}
	} fmt.Println("With timezone:", eventWithTimezone.StartTime)

	// Unmarshal JSON without timezone information
	if err := json.Unmarshal([]byte(jsonStringWithoutTimezone), &eventWithoutTimezone); err != nil {
		fmt.Println("Unmarshal without timezone failed:", err)
		return
	}
	// Interpreted as UTC by default.
	fmt.Println("Without timezone (interpreted as UTC):", eventWithoutTimezone.StartTime)
}
```

When processing JSON data, you should consider the above behavior to ensure proper timezone handling.

## MYSQL time-related types and Golang timezone handling

In MySQL, both the **`DATETIME`** and **`TIMESTAMP`** types are used to store dates and times, but they differ in the way they handle timezones.

- **`DATETIME`**: This type stores date and time without timezone information. This means that the **`DATETIME`** type is not affected by the database server's timezone setting, and you must manage timezones separately in your application.
- **`TIMESTAMP`**: The **`TIMESTAMP`** type is stored converted to UTC, and when retrieved, it is converted and returned based on the current MySQL server's timezone setting. This means that the **`TIMESTAMP`** type takes timezone information into account internally.

For example, if you save **`2023-01-01 12:00:00`** in the Seoul time zone as **`DATETIME`** and **`TIMESTAMP`** types, the **`DATETIME`** type will be saved as **`2023-01-01 12:00:00`** as it is, but the **`TIMESTAMP`** type will be converted to UTC and saved as **`2023-01-01 03:00:00`** in the database because Seoul/Asia has a UTC+9 value.

### Data binding

Golang provides functions to map columns to objects in most DB drives, so let's see how the stored time-related data is bound according to the type.

First of all, **`DATETIME`** does not have a timezone, so the value will be bound as a timezone-less value. In practice, you may need to explicitly create time data for a specific time zone, and if you check, you'll see that you can create time without a time zone.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// Generate time without timezone
	// Example 1: using the time.Date function and nil Location
	noZoneTime := time.Date(2023, time.January, 1, 0, 0, 0, 0, 0, nil)
	fmt.Println("Time without timezone Example 1:", noZoneTime)
}
```

Secondly, **`TIMESTAMP`**. Unlike **`DATETIME`**, it has a timezone and is affected by the timezone of the Golang server when fetching data. For example, if the server's timezone is currently set to Seoul, the UTC timezone will be changed to the Seoul timezone and bound to the object.

## Summary

In this post, we briefly introduced Golang's Time package and summarized the timezones that need to be considered when working with time in the client or DB, along with the detailed code. How to manage them is likely to vary from project to project, but nevertheless, consistent timezone handling between the database server and the application client is important for accurate time data.

It's especially important for applications that target a multinational audience to manage these time zones clearly.