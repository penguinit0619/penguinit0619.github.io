+++
author = "penguinit"
title = "What is the heredoc syntax?"
date = "2024-02-27"
description = "In today's post, we're going to talk about the heredoc syntax. I've been using it a lot in my day-to-day development to make my writing cleaner, but I recently realized that it's called a heredoc, so I thought I'd clean it up."
tags = [
"heredoc", "golang", "python", "ruby", "php", "bash", "javascript", "java", "go"
]
categories = [
"language",
]
+++

![Untitled](images/Untitled.png)

## Overview

In today's post, we're going to learn about the heredoc syntax. I've been using it a lot in my day-to-day development to make things a little cleaner, but I recently realized that it's called a heredoc, so I thought I'd summarize it.

## What is heredoc?

Heredoc syntax is a convenient way to handle long strings used in many programming languages. It allows you to insert strings that span multiple lines directly into your code, preserving any line breaks or indentation within the string.

### Advantages of the heredoc syntax

1. Better readability: Strings that span multiple lines can be inserted directly into the code, which improves readability.
2. easier to maintain: when modifying the contents of a string, it's much easier to do so than with regular string concatenation.
3. Handles special characters: You can freely use quotes within strings without using escape characters.

## Language-specific heredoc handling.

While not all languages support the heredoc syntax, there are similar ways to display multiple strings.

### PHP

PHP starts the heredoc syntax with an identifier followed by **`<<<<`**. The identifier must be repeated at the end of the string again.

```php
<?php
$text = <<<EOT
This is a multi-line
string that spans multiple lines.
You can output special characters 'as is'.
EOT;

echo $text;
?
```

### Ruby

```ruby
text = <<-HEREDOC
This is a multi-line
string that spans multiple lines.
The 'special characters' are also output as is.
HEREDOC

puts text
```

### Python

Python uses triple quotes (**`"""`** or **`'''`**) to handle strings that span multiple lines, with a syntax that does the same thing as HEREDOC.

```python
text = """This is a multi-line
string that spans multiple lines.
The 'special characters' will be printed as well.""""
print(text)
````

### Bash (Shell Script)

Bash uses the **`<<<`** operator to implement the syntax of a herdac. This makes it easy to handle multi-line strings within a script.

```bash
cat <<'EOF'
This is a multi-line
string that spans multiple lines.
The 'special characters' are also output as is.
EOF
```

### Golang

While the Go language doesn't have anything directly equivalent to the syntax of HereDoc, it does allow you to use backticks (`) to represent multi-line strings.

```go
package main

import "fmt"

func main() {
    str := `this is
multi-line
string that spans multiple lines`.
    fmt.Println(str)
}
```

### Java

In Java, the Heredoc syntax does not exist directly. Starting with Java 13, similar functionality can be implemented using Text Blocks.

```java
String str = """
             Here
             multi-line
             string that spans multiple lines.
             """;
System.out.println(str);
```

### Javascript

While it doesn't directly use the name Heredoc syntax, similar functionality can be achieved using template literals, which were introduced in ES6 (ECMAScript 2015). Template literals use a backtick (`) to represent strings, which makes it easy to write strings that span multiple lines

```jsx
const multiLineString = `this is a
a multi-line
string that spans multiple lines`;

console.log(multiLineString);
```

## Summary

Heredoc syntax is a useful feature provided by many programming languages for dealing with long or complex strings. It allows you to conveniently represent strings that span multiple lines within your code, and allows you to use special characters or quotes directly without the need for additional escaping. This greatly improves the readability of your code and makes working with strings more efficient.

While the syntax is implemented in different ways in many languages, including PHP, Ruby, Python, and Bash, the basic purpose and usage is similar. It's best to use it according to the syntax and idiosyncrasies of each language.