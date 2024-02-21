+++
author = "penguinit"
title = "Learn about merge, diff3, and zdiff3"
date = "2024-02-20"
description = "Let's learn what git conflicts are, and learn about the conflict styles merge, diff3, and zdiff3."
tags = [
"conflcit", "merge", "diff3", "zdiff3",
]

categories = [
"git",
]
+++


## Overview
Let's see what git conflict is and learn about conflict styles: merge, diff3, zdiff3.

> I referenced the post below.

[https://ductile.systems/zdiff3/](https://ductile.systems/zdiff3/)

## Git Conflict

In git, conflict occurs when you merge two branches and you have modified the same part of the same file differently. git tries to merge automatically if you have modified different parts of the same file, but there are situations where it can't decide without your help, in which case you have to resolve it manually.

## Conflict Style

Conflict Style is a setting that determines how content is displayed when a conflict occurs. This setting adjusts the amount and format of information provided to developers during the conflict resolution process, making it easier to understand and resolve conflicts.

If left untouched, Conflict Style is set to the value `merge`.

### How to change Conflict Style

You can change the conflict style via git commands.

```bash
git config --global merge.conflictStyle zdiff3 # zdiff3 is one of the conflict algorithms
```

### Preparation

In order to explain the Conflict Style that we will be discussing in the following, we will create a conflict situation and describe it in detail based on the following files.

- A file (main branch) **sha → ab812f2**

```bash
A
B
C
# Add More Letters
```

- Commit A file (main branch) **sha → e7a12c6** Add **sha → e7a12c6**

```bash
A
B
C
D
E
F
G
```

- A file (target branch) **ab812f2 based on **add commits sha → s1jd9c1**

```bash
A
B
C
D
E
F
Y
Z
```

### Merge Style

This is the default style used in Git, where for each conflict, the changes in the `HEAD` (the currently checked out branch) are shown side by side with the changes in the branch you are merging into.  It's simple and straightforward, but if you don't know your development context well, you may not have enough information about what has changed and what code you need to keep, and end up asking someone who does.

```bash
<<<<<<< HEAD
What's in the current branch
=======
Contents from the branch you want to merge into
>>>>>>> feature-branch
```bash

```bash
A
B
C
D
E
<<<<<<< HEAD
F
G
=======
X
Y
Z
>>>>>>> feature-branch
```

The default merge method focuses on the differences between files, and you can see that they are listed for different values when merged.

### diff3 Style

The **`diff3`** style provides more information compared to the **`merge`** style. For conflicting sections, it shows not only the changes in the current branch and the branch to be merged, but also the original content before the changes were made. The original content can give you a deeper understanding of the changes on both sides to help you arrive at the best solution.

```bash
<<<<<<< HEAD
[Changes in the current branch]
||||||| merged common ancestor
[original content before merging]
=======
[Changes in the branch you want to merge].
>>>>>>> [name of branch you want to merge]
```

```bash
A
B
C
<<<<<<< ours
D
E
F
G
||||||| base
# Add More Letters
=======
D
E
F
Y
Z
>>>>>>> theirs
```

You can see that we have uncommented and added the changes to both files we want to merge. However, in the case of diff3 above, you might think that D and E don't need to be in the Conflict line because they don't have any changes based on the merge case, but since the purpose of diff3 is to provide as much context as possible so that you can better understand the cause of the conflict and the changes made, this can add complexity.

If you don't mind the complexity, a traditional merge-style merge might be simpler.

### zdiff3 Style

zdiff3 is a new algorithm added to `git 2.35` in January 2022. (If you want to use zdiff3, you'll need to use git 2.35 or later)

To briefly summarize its features, it can be thought of as an algorithm that mixes the best of merge with the best of diff3.

```bash
A
B
C
D
E
<<<<<<< ours
F
G
||||||| base
# Add More Letters
=======
X
Y
Z
>>>>>>> theirs
```

If you look at the result above, you can see that the same as merge, the code is listed for the changes, but also exposes the original before the changes.

## Summary

I use git every day, but I didn't realize how many different conflict styles were available as options until I did this cleanup.

I've been using it for a few days now and I find that showing the original content helps a lot in resolving conflicts.