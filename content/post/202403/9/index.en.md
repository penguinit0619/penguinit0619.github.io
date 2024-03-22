+++
author = "penguinit"
title = "Automatically create TOCs when writing Markdown"
date = "2024-03-22"
description = "If you look at open source projects on Github, you'll see that they are mostly written in Markdown, but they still have a TOC. In today's post, I'll explain what a TOC is and how you can easily create one from Markdown."
tags = [
"markdown"
]
categories = [
"language"
]
+++

## Overview
If you look at open source projects on Github, you'll see that they are mostly written in Markdown, but they still have a TOC. In today's post, I'll show you what a TOC is and how you can easily write a TOC in Markdown.

## What is a TOC?
A Markdown Table of Contents (TOC) is a table of contents provided within a Markdown document. It is organized based on headings and subheadings within the document, and helps readers easily navigate to specific parts of the document. TOCs are especially useful in long documents to quickly grasp the structure and immediately access the desired section.

[https://github.com/samber/lo](https://github.com/samber/lo)

![Untitled](images/Untitled.png)

## Markdown Acnhor
The Markdown syntax supports anchors. If you write it like below, it will scroll to the location you are referring to when you click the link.

```markdown
## Table of Contents
- [Section 1: Introduction](#section-1-introduction)
- [Section 2: Main Content](#section-2-main-content)
  - [Subsection 2.1: Topic A](#subsection-21-topic-a)
  - [Subsection 2.2: Topic B](#subsection-22-topic-b)
- [Section 3: Conclusion](#section-3-conclusion)

## Section 1: Introduction
Content for Section 1...

## Section 2: Main Content
### Subsection 2.1: Topic A
Content for Subsection 2.1...

### Subsection 2.2: Topic B
Content for Subsection 2.2...

## Section 3: Conclusion
Content for Section 3...

```

However, there are problems with the above method.

1. it takes too much time to write a lot of content.
2. when defining the anchor, we specify the name of the header, and if there are special characters or spaces in the header, we need to encode it into a string that the anchor can understand.

Subsection 2.2: Topic B → #subsection-22-topic-b

Everyone has their own favorite way to create a TOC, but today we'll show you how to generate one automatically using the CLI command.

## Generate TOC automatically
I used to be a big fan of websites that let you paste in Markdown and return Markdown with a TOC, but lately I've been writing a lot of articles here and there, so I started looking for other ways to do it.

There are a lot of services like this, so there are a lot of different ways to do it, but I'd like to introduce an open source project that has a lot of options and is easy to use.

[https://github.com/jonschlinkert/markdown-toc](https://github.com/jonschlinkert/markdown-toc)

### How to install
To install markdown-toc, you need to have node installed beforehand.

- Installing node (Windows)
  1. **Visit the Node.js website**: [Node.js official website](https://nodejs.org/).
  2. Download the Windows installer: Select "Windows Installer" from the homepage to download it. We usually recommend the Long Term Support (LTS) version.
  3. Run the installer: Run the downloaded ``.msi`** file and follow the instructions in the installation wizard. npm will be installed automatically along with Node.js.
- Installing node (MacOS)

```bash
brew install node
```bash brew install node

- Ubuntu/Debian Systems

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
```

- CentOS, Fedora, Red Hat Systems

```bash
curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
sudo yum install nodejs
```

---]

Once the node installation is complete, execute the command below.

```bash
npm install -g markdown-toc
```

### How to use
Let's write the TOC from the Anchor example above using markdown-toc with the TOC deleted.

```bash
## Table of Contents

## Section 1: Introduction
Content for Section 1...

## Section 2: Main Content
### Subsection 2.1: Topic A
Content for Subsection 2.1...

### Subsection 2.2: Topic B
Content for Subsection 2.2...

## Section 3: Conclusion
Content for Section 3...
```

In the above state, under ## Table of Contents, write `<!-- toc -->`. This will automatically create the TOC on that line.

```bash
## Table of Contents

<!-- toc -->

## Section 1: Introduction
Content for Section 1...

## Section 2: Main Content
### Subsection 2.1: Topic A
Content for Subsection 2.1...

### Subsection 2.2: Topic B
Content for Subsection 2.2...

## Section 3: Conclusion
Content for Section 3...
```

Do a markdown-toc (assuming the file is named [README.md](http://README.md))

```bash
markdown-toc -i README.md
```

#### Result
```bash
## Table of Contents

<!-- toc -->

- [Section 1: Introduction](#section-1-introduction)
- [Section 2: Main Content](#section-2-main-content)
  * [Subsection 2.1: Topic A](#subsection-21-topic-a)
  * [Subsection 2.2: Topic B](#subsection-22-topic-b)
- [Section 3: Conclusion](#section-3-conclusion)

<!-- tocstop -->

## Section 1: Introduction
Content for Section 1...

## Section 2: Main Content
### Subsection 2.1: Topic A
Content for Subsection 2.1...

### Subsection 2.2: Topic B
Content for Subsection 2.2...

## Section 3: Conclusion
Content for Section 3...
```

If you check the result, you can see that the TOCs for the headers you wrote under `<!-- toc -->` are automatically created. If you press it in the editor, you can see that it works properly.

## Summary
The CLI gave me a lot of freedom and made it easy to create a TOC. This is the simplest case, but there are many other options, so I hope you can use them as well.