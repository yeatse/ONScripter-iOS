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

FOUNDATION_STATIC_INLINE Coding2UTF16 *CoderFromEncoding(ONScripterEncoding encoding)
{
    static GBK2UTF16 *gbk2utf16 = nullptr;
    static SJIS2UTF16 *sjis2utf16 = nullptr;
    
    switch (encoding) {
        case ONScripterGBKEncoding: {
            if (!gbk2utf16) {
                gbk2utf16 = new GBK2UTF16();
                gbk2utf16->init();
            }
            return gbk2utf16;
        }
        case ONScripterSJISEncoding: {
            if (!sjis2utf16) {
                sjis2utf16 = new SJIS2UTF16();
                sjis2utf16->init();
            }
            return sjis2utf16;
        }
        default: {
            return nullptr;
        }
    }
}

@implementation ONScripterConfiguration

- (instancetype)initWithArchivePath:(NSString *)archivePath savePath:(NSString *)savePath encoding:(ONScripterEncoding)encoding {
    self = [super init];
    if (self) {
        _archivePath = archivePath.copy;
        _savePath = savePath.copy;
        _encoding = encoding;
    }
    return self;
}

@end

@implementation ONScripterExecutor {
    ONScripter *_onscripter;
}

+ (instancetype)sharedExecutor {
    static ONScripterExecutor *executor;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        executor = [ONScripterExecutor new];
    });
    return executor;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SDL_SetMainReady();
        });
        [self registerApplicationNotifications];
    }
    return self;
}

- (void)dealloc {
    [self unregisterApplicationNotifications];
}

- (ONSExecuteErrorCode)executeWithConfiguration:(ONScripterConfiguration *)configuration {
    if (_onscripter) {
        return ONSExecuteStillRunning;
    }
    
    coding2utf16 = CoderFromEncoding(configuration.encoding);
    
    _onscripter = new ONScripter();
    _onscripter->setArchivePath(configuration.archivePath.UTF8String);
    _onscripter->setSaveDir(configuration.savePath.UTF8String);
    _onscripter->renderFontOutline();
    
    if (_onscripter->openScript() != 0) {
        delete _onscripter; _onscripter = nullptr;
        return ONSExecuteCantOpenScript;
    }
    
    if (_onscripter->init() != 0) {
        delete _onscripter; _onscripter = nullptr;
        return ONSExecuteInitializationError;
    }
    
    SDL_iPhoneSetEventPump(SDL_TRUE);
    // Run loop here
    int result = _onscripter->executeLabel();
    SDL_iPhoneSetEventPump(SDL_FALSE);
    
    delete _onscripter; _onscripter = nullptr;
    return result == 0 ? ONSExecuteNoError : ONSExecuteRuntimeError;
}

- (void)quit {
    
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
    if (_onscripter && _onscripter->getWindow()) {
        SDL_SendWindowEvent(_onscripter->getWindow(), SDL_WINDOWEVENT_FOCUS_LOST, 0, 0);
        SDL_SendWindowEvent(_onscripter->getWindow(), SDL_WINDOWEVENT_MINIMIZED, 0, 0);
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
    if (_onscripter && _onscripter->getWindow()) {
        SDL_SendWindowEvent(_onscripter->getWindow(), SDL_WINDOWEVENT_FOCUS_GAINED, 0, 0);
        SDL_SendWindowEvent(_onscripter->getWindow(), SDL_WINDOWEVENT_RESTORED, 0, 0);
    }
}

@end
