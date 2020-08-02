import bindbc.sdl;
import std.string;
import std.conv : to;
import core.runtime : rt_init;
import jni;
import android;
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
