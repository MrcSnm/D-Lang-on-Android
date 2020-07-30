# SDL Project
## **Setup firstly your NDK and LDC before trying to setup your SDL Project**

You need to get the project from libsdl, the current SDL Version is SDL2.0.12, get the source code from [libsdl](https://www.libsdl.org/download-2.0.php)
- Click to download the SDL2-X.Y.Z.tar.gz
- Extract those files
- Import SDL2-X.Y.Z/android-project into Android Studio
- Generate symbolic links inside app/jni folder using
```sh
ln -s SDL2-X.Y.Z SDL2
ln -s SDL2_image-X.Y.Z SDL2_image
ln -s SDL2_mixer-X.Y.Z SDL2_mixer
ln -s SDL2_net-X.Y.Z SDL2_net
ln -s SDL2_ttf-X.Y.Z SDL2_ttf
```
- Go into Android Studio Build/Rebuild Project
Now your project should throw a gradlew error about `YourSourceHere.c', needed by...`, basically, this file is a placeholder for the android-project, just
go into app/jni/src/Android.mk and modify LOCAL_SRC_FILES := YourSourceHere.c to include the needed file, after that, Sync the gradle, build your project and
it should be able to run