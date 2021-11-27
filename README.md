# [CodeChecker](http://github.com/Ericsson/CodeChecker/) C++ static analysis action

GitHub Action to execute static analysis over C-family projects (C, C++,
Objective-C) using the [Clang](http://clang.llvm.org/) infrastructure and
[CodeChecker](http://github.com/Ericsson/CodeChecker/) as its driver.

## Overview

⚠️ **CAUTION! This action has been written with commands that target Ubuntu-based distributions!**

This single action composite script encompasses the following steps:

  1. Obtain a package of the LLVM Clang suite's analysers, and CodeChecker.


## Action configuration


### Versions to install

| Variable       | Default                                                          | Description                                                                                                                                                                                                    |
|----------------|------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `repository`   | [`Ericsson/CodeChecker`](http://github.com/Ericsson/CodeChecker) | The CodeChecker repository to check out and build                                                                                                                                                              |
| `version`      | `master`                                                         | The branch, tag, or commit SHA in the `repository` to use.                                                                                                                                                     |
| `llvm-version` | `latest`                                                         | The major version of LLVM to install and use. LLVM is installed from [PPA](http://apt.llvm.org/). If `latest`, automatically gather the latest version. If `ignore`, don't install anything. (Not recommended) |
