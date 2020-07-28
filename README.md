# D-Lang-on-Android

This repository was created because there was information mismatches when looking to the D-Lang official wiki to [Build D For Android](https://wiki.dlang.org/Build_D_for_Android)

The main differences is that I show how to get the official LDC build for your environment, how to set your variables on Linux and I discovered one problem that was missing a /lib after the lib-dirs in ldc2.conf

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
Find for a release that matches your LDC version, as the time I'm writing this, my version is 1.22.0, so, it will have prefix like **ldc2-1.22.0-linux**
What you're searching for is the android architecture 64 (aarch64), so the version I needed to download is: *ldc2-1.22.0-linux-aarch64.tar.xz*
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

After that, download the sample from the official wiki:
```sh
curl -L -O https://raw.githubusercontent.com/dlang/dmd/master/samples/sieve.d

# Cross-compile & -link to ARMv7-A (on any host)(I'm not using this right now)
#ldc2 -mtriple=armv7a--linux-androideabi sieve.d

# Cross-compile & -link to AArch64 (on any host)
ldc2 -mtriple=aarch64--linux-android sieve.d

# Compile & link natively in Termux
ldc2 sieve.d
```
