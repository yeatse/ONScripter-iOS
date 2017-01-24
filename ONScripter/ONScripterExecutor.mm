//
//  ONScripterExecutor.m
//  ONScripter
//
//  Created by Yang Chao on 2017/1/23.
//  Copyright © 2017年 Yang Chao. All rights reserved.
//

#import "ONScripterExecutor.h"
#import <UIKit/UIKit.h>

#import "ONScripter.h"
#import <SDL.h>
#import "gbk2utf16.h"
#import "sjis2utf16.h"

FOUNDATION_EXTERN int SDL_SendAppEvent(SDL_EventType eventType);
FOUNDATION_EXTERN int SDL_SendWindowEvent(SDL_Window * window, Uint8 windowevent, int data1, int data2);
FOUNDATION_EXTERN void SDL_SyncDisplayModeWithOrientation(UIInterfaceOrientation orientation);

FOUNDATION_EXTERN void playVideoIOS(const char *filename, bool click_flag, bool loop_flag)
{
    NSString *fileName = [NSString stringWithUTF8String:filename];
}

Coding2UTF16 *coding2utf16 = NULL;

@implementation ONSConfiguration

- (instancetype)initWithArchivePath:(NSString *)archivePath savePath:(NSString *)savePath {
    self = [super init];
    if (self) {
        self.archivePath = archivePath;
        self.savePath = savePath;
    }
    return self;
}
#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [[ONSConfiguration allocWithZone:zone] initWithArchivePath:self.archivePath savePath:self.savePath];
}

@end

@implementation ONScripterExecutor {
    ONSConfiguration *_configuration;
    ONScripter *_onscripter;
    
    SDL_Window *_sdlWindow;
    SDL_Renderer *_sdlRenderer;
    
    BOOL _isExecuting;
}

- (instancetype)initWithConfiguration:(ONSConfiguration *)configuration {
    self = [super init];
    if (self) {
        _configuration = configuration.copy;
        [self registerApplicationNotifications];
    }
    return self;
}

- (void)dealloc {
    [self unregisterApplicationNotifications];
    
    if (_sdlRenderer) {
        SDL_DestroyRenderer(_sdlRenderer);
        _sdlRenderer = nullptr;
    }
    
    if (_sdlWindow) {
        SDL_DestroyWindow(_sdlWindow);
        _sdlWindow = nullptr;
    }
}

- (ONSExecuteErrorCode)exec {
    if (_onscripter) {
        return ONSExecuteStillRunning;
    }
    
    if (![self initSDL]) {
        return ONSExecuteInitializationError;
    }
    
    if (!coding2utf16) {
        coding2utf16 = new GBK2UTF16();
    }
    
    _onscripter = new ONScripter(_sdlWindow, _sdlRenderer);
    _onscripter->setArchivePath(_configuration.archivePath.UTF8String);
    _onscripter->setSaveDir(_configuration.savePath.UTF8String);
    _onscripter->renderFontOutline();
    
    if (_onscripter->openScript() != 0) {
        delete _onscripter; _onscripter = nullptr;
        return ONSExecuteScriptError;
    }
    
    if (_onscripter->init() != 0) {
        delete _onscripter; _onscripter = nullptr;
        return ONSExecuteInitializationError;
    }
    
    SDL_ShowWindow(_sdlWindow);
    SDL_iPhoneSetEventPump(SDL_TRUE);
    // Runloop here
    _onscripter->executeLabel();
    SDL_iPhoneSetEventPump(SDL_FALSE);
    
    delete _onscripter; _onscripter = nullptr;
    return ONSExecuteNoError;
}

- (void)quit {
    
}

#pragma mark - SDL calls

- (BOOL)initSDL {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SDL_SetMainReady();
    });
    
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_AUDIO) < 0) {
        NSLog(@"Couldn't initialize SDL: %s", SDL_GetError());
        return NO;
    }
    
    atexit(SDL_Quit);
    
    if (TTF_Init() < 0) {
        NSLog(@"Couldn't initialize SDL TTF");
        return NO;
    }
    
    SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
    SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 0);
    SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "linear");
    SDL_SetHint(SDL_HINT_ORIENTATIONS, "LandscapeLeft LandscapeRight Portrait");
    
    if (_sdlWindow && _sdlRenderer) {
        return YES;
    }
    
    SDL_DestroyRenderer(_sdlRenderer);
    SDL_DestroyWindow(_sdlWindow);
    
    if (SDL_CreateWindowAndRenderer(0, 0, SDL_WINDOW_FULLSCREEN|SDL_WINDOW_OPENGL|SDL_WINDOW_BORDERLESS, &_sdlWindow, &_sdlRenderer) < 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Application event handling

- (void)registerApplicationNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)unregisterApplicationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillTerminate {
    SDL_SendAppEvent(SDL_APP_TERMINATING);
}

- (void)applicationDidReceiveMemoryWarning {
    SDL_SendAppEvent(SDL_APP_LOWMEMORY);
}

- (void)applicationDidChangeStatusBarOrientation {
    SDL_SyncDisplayModeWithOrientation([UIApplication sharedApplication].statusBarOrientation);
}

- (void)applicationWillResignActive {
    if (_sdlWindow) {
        SDL_SendWindowEvent(_sdlWindow, SDL_WINDOWEVENT_FOCUS_LOST, 0, 0);
        SDL_SendWindowEvent(_sdlWindow, SDL_WINDOWEVENT_MINIMIZED, 0, 0);
    }
    SDL_SendAppEvent(SDL_APP_WILLENTERBACKGROUND);
}

- (void)applicationDidEnterBackground {
    SDL_SendAppEvent(SDL_APP_DIDENTERBACKGROUND);
}

- (void)applicationWillEnterForeground {
    SDL_SendAppEvent(SDL_APP_WILLENTERFOREGROUND);
}

- (void)applicationDidBecomeActive {
    SDL_SendAppEvent(SDL_APP_DIDENTERFOREGROUND);
    if (_sdlWindow) {
        SDL_SendWindowEvent(_sdlWindow, SDL_WINDOWEVENT_FOCUS_GAINED, 0, 0);
        SDL_SendWindowEvent(_sdlWindow, SDL_WINDOWEVENT_RESTORED, 0, 0);
    }
}

@end
