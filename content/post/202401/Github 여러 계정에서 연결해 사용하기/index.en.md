+++
author = "penguinit"
Title = "Github Connecting and Using Multiple Accounts"
date = "2024-01-11"
Description = "This post allows you to manage multiple git projects on a particular machine."
tags = [
"git", "github", "ssh",
]

categories = [
"script",
]
+++

## Overview

There are often times when I unintentionally have to work at a company with a personal computer. (I don't know if it's the fate of Linux users.) When I first encountered this, I was very uncomfortable, but there were times when Github didn't apply for multiple accounts, and I have a lot of memories of shoveling because I already run projects and company projects together.

## Github operates multiple accounts

It's been one of the series of why I didn't apply for it for a long time, but it's a function that I recently applied for.

[https://github.blog/changelog/2023-11-03-multi-account-support-on-github-com/](https://github.blog/changelog/2023-11-03-multi-account-support-on-github-com/)

![Untitled](images/Untitled.png)

![Untitled](images/Untitled%201.png)

If you have already registered an account, you can change it through **Switch account** and you can register additional accounts you are using through **Add account**. 👍

## Local Environment Settings

I checked that the Github account can be changed conveniently by registering it in advance, but how can I work locally? First of all, what I wanted was as follows.

![Untitled](images/Untitled%202.png)

- A and B are projects with different accounts.
- Both A and B want to get a clone of the project using SSH.
- If both A and B commit, I hope the Author information will be left with the appropriate account for the project.
- If both A and B push, I hope they will be pushed according to each account and project.

### Github Interworking Settings

Most likely, but in the case of HTTPS, I set it up as SSH because it's annoying to enter a password every time. However, the problem is that there are two accounts that need to be linked, so you also have to set two keys.

### SSH key setting

First of all, you need to set up an additional account, so you need to create a new SSH key and register with a Github account.

```bash
> ssh-keygen -t rsa -C "user-email@gmail.com"

Generating public/private rsa key pair.
Enter file in which to save the key (/home/penguin/.ssh/id_rsa):
```

If you type it as above, you'll get a message asking where you want to save it, and make it the name you want in the lower part of the folder '.ssh' based on the home directory. In my case, I saved it as 'Myung_rsa'.

When generated as above, a private key and a public key are created, and the public key is paired with the '.pub' extension.

If you made the key like this, register the public key with the github. You have to make it every time like this because it has to be the only place where it is registered.

1. [https://github.com/settings/ssh/new ] (access to https://github.com/settings/ssh/new) (must be logged in and switched to the account you want to register)

![Untitled](images/Untitled%203.png)

2. Title writes down the public key that you just generated in the key value so that you can identify it later. (.copy & paste as it is in the pub extension file)
3. Click Add SSH key

### Github Clone

If you think that since you registered the SSH key, you will have to clone it and pull it, you will get the following error.

```bash
Replicate to 'example-repo'...
ERROR: Repository not found.
Fatal: Unable to read from remote repository

Whether you have the right access, and whether you have storage
Please check it out.
```

The reason for the above error is that the existing private key is set as the default key for SSH, so the privilege problem arises because the attempt to access the wrong key is made. To solve this problem, it is necessary to make sure that the appropriate private key is accessed during the ssh access.

When you use ssh, you can set which private keys you can use to access a specific address through the 'config' file.

1. Enter '$home/.ssh' in the folder where the key is stored and create the 'config' file.
2. Set the value inside the file as follows.

```bash
# Existing configured SSH information
Host github.com
HostName github.com
User git
IdentityFile ~/.ssh/first_rsa

# About SSH key values you just added
Host penguin.github.com
HostName github.com
User git
IdentityFile ~/.ssh/second_rsa
```

To explain the settings above in more detail, it is as follows, but if you have these conditions, you can understand it as a setting that you will use a specific private key.

- **Host penguin.github.com **: This setting configures SSH connections with the alias **`penguin.github.com `**.
- **HostName github.com **: The actual address of the server to connect to is still **`github.com `**.
- **User git**: The user 'git' on GitHub is used.
- **IdentityFile ~/.ssh/second_rsa**: This connection uses another SSH key, **`second_rsa`**.
3. Try git clone again

```bash
## AS-IS (does not work as a privilege issue)
git clone git@github.com:penguin-project/example.git

## TO-BE (long motion)
git clone git@penguin.github.com:penguin-project/example.git
```

### Git Account Separation

If you set it up as above, it's not too difficult to work on it, but there are still issues about the author when you make a commit. 🤒

If you only use one account, you usually don't change much, so you'll usually set it up as below.

```bash
git config --global user.name "penguinimm"
git config --global user.email "penguinit0619@gmail.com"
```

Because I use multiple accounts, if I don't do anything else, I'll be recorded as an unwanted worker every time I make a commit. To solve this problem, you can set the local settings as below in the corresponding place, or if this is okay each time, you can give different global settings based on the directory.

- Local Settings

```bash
git config --local user.name "penguinimm"
git config --local user.email "penguinit0619@gmail.com"
```

- Directory-based Global settings

**~/.gitconfig file**

```bash
[user]
name = user
email = user@gmail.com

[includeIf "gitdir:~/penguin/"]
path = ~/.gitconfig-penguin
```

**`[includeIf "gitdir:~/penguin/"]`**: This directive defines how to include additional configuration files under certain conditions, where the condition is **`gitdir:~/penguin/`**, which applies only when working in the **`~/penguin/`** directory (or its subdirectories)

**~/.github-penguin file**

```bash
[user]
name = penguin
email = penguinit0619@gmail.com
```

**Confirm user settings under the penguin directory**

```bash
> git config user.email
penguinit0619@gmail.com

> git config user.name
penguin
```

## Let's wrap this up

Through this post, you can manage multiple git projects on a specific machine. I hope it will be a post that can help people like me who work on personal projects and work at a company.