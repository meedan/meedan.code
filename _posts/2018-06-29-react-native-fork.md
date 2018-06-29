---
title: Using a fork of React Native in your React Native application
layout: post
author: caiosba
---
[React Native](https://facebook.github.io/react-native/) lets you build native mobile apps using only JavaScript. It uses the same design as React, letting you compose a rich mobile UI from declarative components. Here at Meedan we use it on the development of [Check Mark](https://github.com/meedan/check-mark), our mobile and browser extension submission app for [Check](https://meedan.com/check), which is our open source software for collaborative fact-checking.

It's very straightforward to use React Native to develop a mobile application. But when it comes to use a non-official version (for example, a fork) things get more complicated. We faced it recently at Meedan, when we had to fork React Native and make a few changes on it to work on Android 4.4.4.

## Pre

You need to install Android SDK and Android NDK and make sure that your environment will use them to compile React Native code.

`~/.bashrc` (or equivalent):
```
export ANDROID_SDK=/path/to/android-sdk
export ANDROID_NDK=/oath/to/android-ndk/android-ndk-r10e
```

`android/local.properties`:
```
sdk.dir=/path/to/android-sdk
ndk.dir=/path/to/android-ndk/android-ndk-r10e
```

## Installing the fork

First, you need to install react-native from your fork. For example, to install the master branch from the official repo, run the following:

```
npm install --save github:facebook/react-native#master
```

## Adding gradle dependencies

Add gradle-download-task as dependency in `android/build.gradle`:

```
...
dependencies {
  classpath 'com.android.tools.build:gradle:1.3.1'
  classpath 'de.undercouch:gradle-download-task:3.1.2' # add this line
}
...
```

## Adding the :ReactAndroid project

Add the `:ReactAndroid` project in `android/settings.gradle`:

```
...
include ':ReactAndroid'

project(':ReactAndroid').projectDir = new File(rootProject.projectDir, '../node_modules/react-native/ReactAndroid')
...
```

Modify your `android/app/build.gradle` to use the `:ReactAndroid` project instead of the pre-compiled library

```
...
dependencies {
  compile fileTree(dir: 'libs', include: ['*.jar'])
    compile 'com.android.support:appcompat-v7:26.0.2'
    compile project(':ReactAndroid')
    ...
}
...
```

## Making 3rd-party modules use your fork

The previous steps can be found in the [official documentation](https://facebook.github.io/react-native/docs/building-from-source.html). But if you use 3rd-party modules, that's where things get more complicated and that's where we got stuck until we found a solution (a.k.a. hack). Those modules usually list React Native as one of the dependencies that should be compiled before it. When we use a fork, the 3rd party modules still point to the official module, which doesn't exist, so, you'll receive many exceptions from those modules related to classes that it can't find. In theory, something like this should work:

`android/app/build.gradle`:
```
configurations.all {
  exclude group: 'com.facebook.react', module: 'react-native'
}
```

But it doesn't. So, our solution was to add a `postinstall` `script` to our `package.json`:

```
"scripts": {
  "postinstall": "find node_modules/ -type f -name build.gradle -not -path \"*/react-native/*\" -not -path \"*/Examples/*\" -not -path \"*/examples/*\" -exec sed -i \"s/.*com.facebook.react:react-native:.*/ compile project(':ReactAndroid')/\" {} \";\"",
}
```

This script basically iterates through all installed modules and replaces the React Native core dependency by our fork.

And after that, we are able to compile our application correctly, using our fork, and supporting 3rd party modules.

## Bonus: If your React Native application is a Git submodule that has its own Docker container

In our architecture, our React Native application is a Git submodule and has its own Docker container that is part of a Docker Composer architecture. More about that [here](https://github.com/meedan/check).

So, when you add a Git dependency to `package.json` (for example: `"react-native": "meedan/react-native#master"`), it will find that the Git directory is actually a link to another directory... here's the content of a `.git` file of a Git submodule:

```
gitdir: ../.git/modules/submodule-name
```

In our `docker-compose.yml` file, we mount the application directory at the root of the filesystem. So, there is no `../.git` directory when NPM tries to install the Git dependency. So, one solution is to mount the `.git` directory of the parent Git repository as well:

`docker-compose.yml`:
```
...
container:
  volumes:
  - ./.git:/.git
...
```

After that, NPM is able to find the `.git` directory. But that's not enough. Pay attention to the `worktree` configuration of the `../.git/modules/submodule-name/config` file:

```
worktree = ../../../submodule-name
```

This configuration option should point to the root of our application. So, you need to make sure that the Docker volume mount point matches the submodule name. Then that's how our `docker-compose.yml` will look like:

`docker-compose.yml`:
```
...
container:
  volumes:
  - ./submodule-name:/submodule-name
  - ./.git:/.git
...
```

And now we are able to install NPM dependencies from Git repositories and keep working on the host machine.

Another solution would be to set the `GIT_DIR` and `GIT_WORK_TREE` environment variables. We tried and it works well for `bower`, but not for `npm`.
