# SDL Project
## **Setup firstly your NDK and LDC before trying to setup your SDL Project**

You need to get the project from libsdl, the current SDL Version is SDL2.0.12, get the source code from [libsdl](https://www.libsdl.org/download-2.0.php)
- Click to download the SDL2-X.Y.Z.tar.gz
- Extract those files
- Import SDL2-X.Y.Z/android-project into Android Studio
- Generate symbolic links inside SDL2-X.Y.Z/android-project/app/jni folder using
```sh
ln -s SDL2-X.Y.Z SDL2
ln -s SDL2_image-X.Y.Z SDL2_image
ln -s SDL2_mixer-X.Y.Z SDL2_mixer
ln -s SDL2_net-X.Y.Z SDL2_net
ln -s SDL2_ttf-X.Y.Z SDL2_ttf
```

- Go into Android Studio Build/Rebuild Project
Now your project should throw a gradlew error about `YourSourceHere.c', needed by...`, basically, this file is a placeholder for the android-project.
## If you were to make a C project
> Go into app/jni/src/Android.mk, if you modify LOCAL_SRC_FILES := YourSourceHere.c to include the needed file, after that, Sync the gradle, build your project and
it should be able to run.

# As a D project
Delete the folder app/jni/src, this folder is where it creates the libmain.so, while the app/jni/ folder contains an Android.mk that will compile your SDL
library.
With D, you will need to provide your own libmain.so. That will be the main entrance point for using SDL on that android Project.
After that, you're setup for including your main function.
- Find app/src/jniLibs
- Create the target architecture folder (I'm current using arm64-v8a)

## D code
- Download/clone bindbc-sdl and bindbc-loader
> [BindBC-SDL](https://github.com/BindBC/bindbc-sdl)
> [BindBC-Loader](https://github.com/BindBC/bindbc-loader)
- Import it into your main module
- Follow BindBC SDL tutorial
You will have a main function, change your main function to the `extern(C)int SDL_main()`, this is the entrance point to SDL
> Minimal example code below:
```d
import bindbc.sdl;
import std.string;
import std.conv : to;
import core.runtime : rt_init;
import jni.d;
import android.d;
bool loadSDLLibs()
{
  SDLSupport ret = loadSDL();
  if(ret != sdlSupport)
    if(ret == SDLSupport.noLibrary)
      __android_log_print(android_LogPriority.ANDROID_LOG_ERROR, toStringz("Sample"), toStringz("SDL not found"));
    else if(ret == SDLSupport.badLibrary)
      __android_log_print(android_LogPriority.ANDROID_LOG_ERROR, toStringz("Sample"), toStringz("Current SDL version lower than the expected version"));
}

SDL_Window* gWindow = null;
SDL_Surface* gScreenSurface = null;

extern(C) int SDL_main()
{
  rt_init();
  loadSDLLibs();
  const int winPos = SDL_WINDOWPOS_UNDEFINED;
  SDL_Rect gScreenRect = {0,0,320,240};
  SDL_DisplayMode displayMode;
  if( SDL_GetCurrentDisplayMode( 0, &displayMode ) == 0 )
  {
      gScreenRect.w = displayMode.w;
      gScreenRect.h = displayMode.h;
  }

  gWindow = SDL_CreateWindow(cast(char*)"Sample", winPos, winPos, gScreenRect.w, gScreenRect.h,
  SDL_WindowFlags.SDL_WINDOW_SHOWN | SDL_WindowFlags.SDL_WINDOW_OPENGL );
  if(window == null)
      __android_log_print(android_LogPriority.ANDROID_LOG_ERROR, toStringz("Sample"), toStringz("Window could not open: "~ to!string(SDL_GetError()));
  gScreenSurface = SDL_GetWindowSurface(gWindow);
  SDL_FillRect(gScreenSurface, null, SDL_MapRGB(gScreenSurface.format, 0xff, 0xff, 0x00));
  bool quit = false;
  
  while(!quit)
  {
    SDL_Event e;
    while(SDL_PollEvent(&e))
    {
      switch(e.type)
      {
        case SDL_QUIT:
          quit = true;
          break;
        default:break;
      }
    }
    SDL_UpdateWindowSurface(gWindow);
    SDL_Delay(16);
  }
  
  SDL_DestroyWindow(gWindow);
  gWindow = null;
  SDL_Quit();
}
```

## D compile
- Compile your D code as a shared library called libmain.so
> Usually using the command ldc2 --arch=aarch64--linux-android app.d --shared --of=libmain.so
> **Don't forget to include important LIBs like liblog.so with the -L command**
>> Usually located at $NDK_PATH/toolchains/llvm/prebuilt/(yourpcSO_x86_64)/sysroot/usr/lib/(yourarchitecture)/(androidNdkApiLevel)/
>>> There are other important libs but as we're using SDL2, they are already included in the libsdl.so output from app/jni/src/Android.mk
- Copy that file to app/src/main/jniLibs/(architecture folder)

