# D-Lang-on-Android

This repository was created because there was information mismatches when looking to the D-Lang official wiki to [Build D For Android](https://wiki.dlang.org/Build_D_for_Android)

The main differences is that I show how to get the official LDC build for your environment, how to set your variables on Linux and I discovered one problem that was missing a /lib after the lib-dirs in ldc2.conf

# Install Android Studio and get NDK
This is a very simple tutorial on how to do it as it has an infinitude of tutorials on how to get NDK for android
Get Android Studio at https://developer.android.com/studio
Finish installing it
Go into the top right of your Android Studio IDE (taskbar) and search for `SDK Manager`
Install the target SDK, currently the newest one is Android 10(Q), it is on "SDK Platforms" Selection
Beside "SDK Platforms", it has "SDK Tools", click on it and select NDK, Android SDK Tools, Android SDK Platform-Tools, Android SDK Build-Tools then click on OK
On the Top of the window, it has where SDK is located, you can always check it again for reference
After that, just remember where your ndk is installed

## Installing LDC on Linux
For installing LDC on Linux, I do not recommend getting it from the repository, instead, go to Dlang official installation website:
[D-Lang Official Install Website](https://dlang.org/install.html)
Then, get the D-Lang official installation script (install.sh) -> Direct link [D-Lang Install Script](https://dlang.org/install.sh)
After that, open the Bash and:
- chmod +x ./install.sh
- ./install.sh ldc
Executing those commands will install it in your /home/currentUser/dlang (~/dlang)
If you try to execute than ldc2(the current version), you will see that it is not available, the install script actually comes with -a parameter that
lets you "activate"(Actually export important variables to your path), but for some reason, my linux is not exports command is not saving those variables.
So what we'll do is simply:
- Go to ~/dlang/ldc(currentVersion)
- Open activate with your favorite text editor
- You will find the following lines in your text editor
```sh
deactivate() {
    export PATH="$_OLD_D_PATH"
    export LIBRARY_PATH="$_OLD_D_LIBRARY_PATH"
    export LD_LIBRARY_PATH="$_OLD_D_LD_LIBRARY_PATH"
    unset _OLD_D_LIBRARY_PATH
    unset _OLD_D_LD_LIBRARY_PATH
    unset DMD
    unset DC
    export PS1="$_OLD_D_PS1"
    unset _OLD_D_PATH
    unset _OLD_D_PS1
    unset -f deactivate
}

if [ -v _OLD_D_PATH ] ; then deactivate; fi
_OLD_D_PATH="${PATH:-}"
_OLD_D_LIBRARY_PATH="${LIBRARY_PATH:-}"
_OLD_D_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="/home/hipreme/dlang/ldc-1.22.0/lib${LIBRARY_PATH:+:}${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="/home/hipreme/dlang/ldc-1.22.0/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH:-}"
_OLD_D_PATH="${PATH:-}"
_OLD_D_PS1="${PS1:-}"
export PS1="(ldc-1.22.0)${PS1:-}"
export PATH="/home/hipreme/dlang/ldc-1.22.0/bin${PATH:+:}${PATH:-}"
export DMD=ldmd2
export DC=ldc2
```
The important lines are those with `export` after the `if [ -v _OLD_D_PATH ]`
Showing it easier as:
```sh
export LIBRARY_PATH="/home/hipreme/dlang/ldc-1.22.0/lib${LIBRARY_PATH:+:}${LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="/home/hipreme/dlang/ldc-1.22.0/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH:-}"
export PS1="(ldc-1.22.0)${PS1:-}"
export PATH="/home/hipreme/dlang/ldc-1.22.0/bin${PATH:+:}${PATH:-}"
export DMD=ldmd2
export DC=ldc2
```
Change /hipreme/ with your current username, save those lines on your clipboard and then:
- Go to your $HOME
- Edit .bashrc (you can just sudo vim ~/.bashrc if you wish)
- On the top of your exports, copy every line that were described above
- Now your PC should be able to execute ldc

## Getting Android lib for LDC
Now you need to include an Android architecture lib on your LDC, to do that, go into the [LDC github repository](https://github.com/ldc-developers/ldc/)
Go into the [releases](https://github.com/ldc-developers/ldc/releases/)
Find for a release that matches your LDC version, as the time I'm writing this, my version is 1.22.0, so, it will have prefix like **ldc2-1.22.0-android**
What you're searching for is the android architecture 64 (aarch64), so the version I needed to download is: *ldc2-1.22.0-android-aarch64.tar.xz*

**IMPORTANT** 
> If your target architecture does not have a prebuilt binary(Those one that are in the LDC developers release assets), you will have to [build it yourself the Phobos and the DRuntime](https://wiki.dlang.org/Building_LDC_runtime_libraries)

> Notice that inside your architecture target folder, you will see that there is a lib/ and other lib(commonly related to 32 bits), you can use that for
distributing for another target, inside aarch64 there is a x86_64, you can set a configuration for targeting it too and in the binaries inside -gcc, search for x86_64

After downloading it, it's time to setup your compiler to find its existence.

## Adding compilation command
- Go to ~/dlang/ldc(yourVersionHere)
- Extract your newly acquired file
- Rename it to `lib-android__aarch64`

- Go to ~/dlang/ldc(yourVersionHere)/etc/
- Open ldc2.conf
- Append to the end of the file the following:
```
"aarch64-.*-linux-android":
{
    switches = [
        "-defaultlib=phobos2-ldc,druntime-ldc",
        "-link-defaultlib-shared=false",
        "-gcc=/home/hipreme/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang",
    ];
    lib-dirs = [
        "%%ldcbinarypath%%/../lib-android_aarch64/lib",
    ];
    rpath = "";
};
```
- In the line of `-gcc=` you should put your Android NDK, mine was on that folder, but what you should search for is `toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android21-clang`

> If you're compiling for Windows, your path will probably be something like
>`"-gcc=C:/Users/Hipreme/AppData/Local/Android/Sdk/ndk/21.3.6528147/toolchains/llvm/prebuilt/windows-x86_64/bin/aarch64-linux-android21-clang.cmd"`

After that, download a sample d program from the official wiki:
```sh
curl -L -O https://raw.githubusercontent.com/dlang/dmd/master/samples/sieve.d

# Cross-compile & -link to ARMv7-A (on any host)(I'm not using this right now)
#ldc2 -mtriple=armv7a--linux-androideabi sieve.d

# Cross-compile & -link to AArch64 (on any host)
ldc2 -mtriple=aarch64--linux-android sieve.d

# Compile & link natively in Termux
ldc2 sieve.d
```
If it compiles well, your LDC is correctly configured to start working with Android.

Before going to the next part of this tutorial, I would like to increment that this architecture is used as a sample because this is my phone's
respective architecture, if you wish to compile for any other architecture, take a look at [Cross Compiling with LDC](https://wiki.dlang.org/Cross-compiling_with_LDC)



# Preparing your D module for Android
After your first succesful try of compiling it to the Android architecture, you will actually need to do three things:
1. You will need to import the D module jni on the top of your file: `import jni`. The JNI module was not made by me, the file in this repository is
a reference to the [Original Repository](https://github.com/Diewi/android) for mantaining compatibility
2. Create a file that you wish to export into Android. You will need to make your function to export as `extern(C)` and name it in the same convention as you
would name a C function to be exported from NDK Java_packagename_ClassName_methodName(JNIEnv* env, jclass clazz)
sample.d
```d
import jni;
import std.conv : to;
import core.runtime : rt_init;
import std.string;
extern(C) jstring Java_my_long_package_name_ClassName_methodname(JNIEnv* env, jclass clazz, jstring stringArgReceivedFromJava)
{
    rt_init();
    const char* javaStringInCStyle = (*env).GetStringUTFChars(env, stringArgReceivedFromJava, null);
    string javaStringInDStyle = to!string(javaStringInCStyle);
    (*env).ReleaseStringUTFChars(env, stringArgReceivedFromJava, javaStringInCStyle);

    return (*env).NewUTFString(toStringz("Hello from D, myarg: "~javaStringInDStyle));
}
void main(){}
```
3. Compile it as a shared library, suppose you're targetting the Arm64 architecture, you would need to call:
`ldc2 -mtriple=aarch64--linux-android --shared sample.d`
This will output libsample.so, this file will be included in your Android project

# Word of caution
Always call rt_init, or it will probably cause the sigsegfault(5), using to!string didn't work until I called rt_init();

# Creating an Android Project
By the time of this writing, in the Official D Wiki for Building to Android, the way to generate an apk is documented for using Ant, but this is long gone,
there's little documentation on how to actually use it, and it would be useless for today's Android development, as everyone uses Gradle, there's little to
know about gradle when managing an entire android project, and it can add many libs with simple commands, so we'll be using Android Studio
- Open Android Studio
- Go into "Start a new Android Studio project"
- Select "Empty Activity"
- Name your project(Suppose I named mine as Test with the package as com.hipreme.test)
- Configure and click on Finish(I'm currently using min API 23)
- Go into the left side of your window and set your view as "Project"
Your folder structure must be like:
```
Test
|--.gradle
|--.idea
|--app
|--|--build
|--|--libs
|--|--src
|--|--|--androidTest
|--|--|--main
|--|--|--test
|--|--|.gitignore
|--|--app.iml
|--|--build.gradle
|--|--proguard-rules.pro
|--gradle
|--.gitignore
|--buid.gradle
|--gradle.properties
|--gradlew
|--gradlew.bat
|--local.properties
|--settings.gradle
|--Test.iml
```
And in the end there are:
```
|> External Libraries
|> Scratches and Consoles
```
Open the folder Test/app/src/main and inside main, create a folder called `jniLibs`, this folder is **extremely important**, it is the default folder to
put your shared libraries to be imported together with your .apk. If you wish to use other name for it, you will need to change your gradle file.
For actually putting your libraries inside that folder, you will actually need to make directories for the target architectures, so, create inside it:
- armeabi-v7a
- arm64-v8a
- x86
- x86_64
For reference, check ndk abi guide from official android site: [Android ABI Guide](https://developer.android.com/ndk/guides/abis)
Your new main structure must be:
```
main
|--java
|--jniLibs
|--|--armeabi-v7a
|--|--arm64-v8a
|--|--x86
|--|--x86_64
|--res
|--AndroidManifest.xml
```
After creating those folderes, you can actually move your shared library into one of those folders, as we're showing with aarch64, you should move
your libsample.so into arm64-v8a
With that, you should now be able to import your library into Android Studio by calling inside your java code, so, at main/ảva/your/long/package/name, create
a new .java file, I'll create a Sample.java file:
```java
package com.hipreme.Sample;
public class Sample
{
    static{
        System.loadLibrary("sample");
    }
    public static native String methodname(String stringArgReceivedFromJava);
}
```
Now, you're able to call `Sample.methodname("hello")` from anywhere in your code and D will be called on that
If you wish to setup SDL with D, the tutorial is on Setting_D_SDL
