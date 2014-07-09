/*
 * DOSKit
 * Copyright (C) 2014  Matthew Vilim
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "DSKEmulator.h"
#import "DSKEmulatorInternal.h"
#import "DSKVideo.h"
#import "DSKAudio.h"
#import "DSKShell.h"
#import "DSKKeyboard.h"
#import "UIDevice+Jailbreak.h"
#import "DSKFileSystem.h"

#import <DOSBox/dosbox.h>
#import <DOSBox/video.h>
#import <DOSBox/cpu.h>
#import <DOSBox/control.h>

#import <SDL/SDL.h>

#import <semaphore.h>

NSString * const DSKEmulatorWillStartNotification = @"DSKmulatorWillStartNotification";
NSString * const DSKEmulatorDidStartNotification = @"DSKmulatorDidStartNotification";
NSString * const DSKEmulatorWillPauseNotification = @"DSKmulatorWillPauseNotification";
NSString * const DSKEmulatorDidPauseNotification = @"DSKmulatorDidPauseNotification";
NSString * const DSKEmulatorWillResumeNotification = @"DSKmulatorWillResumeNotification";
NSString * const DSKEmulatorDidResumeNotification = @"DSKmulatorDidResumeNotification";
NSString * const DSKEmulatorWillHaltNotification = @"DSKmulatorWillHaltNotification";
NSString * const DSKEmulatorDidHaltNotification = @"DSKmulatorDidHaltNotification";

static NSString * const DSKDefaultConfigFilename = @"dosbox.conf";

__weak static DSKEmulator *_currentEmulator;

static void _DSKWillStartNotification(void);
static void _DSKDidStartNotification(void);
static void _DSKWillPauseNotification(void);
static void _DSKDidPauseNotification(void);
static void _DSKWillHaltNotification(void);
static void _DSKDidHaltNotification(void);

@interface DSKEmulator () {
    sem_t *_bootSemaphore;
    pthread_mutex_t _eventMutex;
    pthread_cond_t _pauseCondition;
    pthread_mutex_t _pauseMutex;
}

@property (readwrite, nonatomic) NSThread *emulatorThread;

@property (readwrite, nonatomic) DSKVideo *video;
@property (readwrite, nonatomic) DSKAudio *audio;
@property (readwrite, nonatomic) DSKShell *shell;
@property (readwrite, nonatomic) DSKKeyboard *keyboard;
@property (readwrite, nonatomic) DSKJoystick *joystick;
@property (readwrite, nonatomic) DSKFileSystem *fileSystem;

@property (readwrite, nonatomic) DSKCore core;
@property (readwrite, nonatomic) NSDictionary *notificationSelectors;

+ (instancetype)currentEmulator;
+ (void)_setCurrentEmulator:(DSKEmulator *)emulator;
- (void)_postEmulatorStateNotification:(NSString *)name;
- (void)_start;
- (void)_halt;
- (void)_pause;
- (void)_runEvents;
- (BOOL)_isCoreSupported:(DSKCore)core;

@end

void _DSKEvents(void) {
    [[DSKEmulator currentEmulator] _runEvents];
}

void _DSKWillStartNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorWillStartNotification];
}

void _DSKDidStartNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorDidStartNotification];
}

void _DSKWillPauseNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorWillPauseNotification];
}

void _DSKDidPauseNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorDidPauseNotification];
}

void _DSKWillHaltNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorWillHaltNotification];
}

void _DSKDidHaltNotification(void) {
    [[DSKEmulator currentEmulator] _postEmulatorStateNotification:DSKEmulatorDidHaltNotification];
}

@implementation DSKEmulator

@synthesize paused = _paused;

+ (instancetype)currentEmulator {
    return _currentEmulator;
}

- (instancetype)init {
    if (self = [super init]) {
        _paused = NO;
        _executing = NO;
        _delegate = nil;
        _video = [[DSKVideo alloc] initWithEmulator:self];
        _keyboard = [[DSKKeyboard alloc] initWithEmulator:self];
        _shell = [[DSKShell alloc] initWithEmulator:self];
        _fileSystem = [[DSKFileSystem alloc] initWithEmulator:self];
        _notificationSelectors = @{DSKEmulatorWillStartNotification: NSStringFromSelector(@selector(emulatorWillStart:)),
                                   DSKEmulatorDidStartNotification: NSStringFromSelector(@selector(emulatorDidStart:)),
                                   DSKEmulatorWillPauseNotification: NSStringFromSelector(@selector(emulatorWillStart:)),
                                   DSKEmulatorDidPauseNotification: NSStringFromSelector(@selector(emulatorWillPause:)),
                                   DSKEmulatorWillResumeNotification: NSStringFromSelector(@selector(emulatorDidPause:)),
                                   DSKEmulatorDidResumeNotification: NSStringFromSelector(@selector(emulatorWillResume:)),
                                   DSKEmulatorWillHaltNotification: NSStringFromSelector(@selector(emulatorDidResume:)),
                                   DSKEmulatorDidHaltNotification: NSStringFromSelector(@selector(emulatorWillHalt:)),
                                   DSKEmulatorWillStartNotification: NSStringFromSelector(@selector(emulatorDidHalt:))};
        GFX_EventsHandler = _DSKEvents;
        
        _eventMutex = PTHREAD_MUTEX_INITIALIZER;
        _pauseMutex = PTHREAD_MUTEX_INITIALIZER;
        _pauseCondition = PTHREAD_COND_INITIALIZER;
        
        // iOS currently doesn't implement unnamed semaphores
        _bootSemaphore = sem_open("bootSemaphore", O_CREAT, S_IRWXU, 0);
        [NSThread detachNewThreadSelector:@selector(_emulatorThread) toTarget:self withObject:nil];
        // block until DOSBox is ready to begin accepting commands
        sem_wait(_bootSemaphore);
    }
    return self;
}

- (void)setExecuting:(BOOL)executing {
    if (executing != _executing) {
        _executing = executing;
        executing ? [self _start] : [self _halt];
    }
}

- (void)setPaused:(BOOL)paused {
    pthread_mutex_lock(&_pauseMutex);
    if (paused != _paused) {
        _paused = paused;
        paused ? [self _pause] : [self _resume];
    }
    pthread_mutex_unlock(&_pauseMutex);
}

- (BOOL)isPaused {
    pthread_mutex_lock(&_pauseMutex);
    BOOL retval = _paused;
    pthread_mutex_unlock(&_pauseMutex);
    return retval;
}

- (BOOL)requestCore:(DSKCore)core {
    BOOL isCoreSupported = [self _isCoreSupported:core];
    if (isCoreSupported) {
        switch (core) {
            case DSKAutoCore: cpudecoder = &CPU_Core_Normal_Run; break;
            case DSKDynamicCore: cpudecoder = &CPU_Core_Dynrec_Run; break;
            case DSKFullCore: cpudecoder = &CPU_Core_Full_Run; break;
            case DSKNormalCore: cpudecoder = &CPU_Core_Normal_Run; break;
            case DSKSimpleCore: cpudecoder = &CPU_Core_Simple_Run; break;
        }
        self.core = core;
    }
    return isCoreSupported;
}

+ (void)_setCurrentEmulator:(DSKEmulator *)emulator {
    _currentEmulator = emulator;
}

- (void)dealloc {
    [self _halt];
    pthread_mutex_destroy(&_eventMutex);
    sem_close(_bootSemaphore);
    delete control;
}

- (void)_postEmulatorStateNotification:(NSString *)name {
DSK_DIAG_PUSH
DSK_DIAG_IGNORE_SEL_LEAK
    // no chance of memory leak here, so silence Clang's warning
    [self.delegate performSelector:NSSelectorFromString([self.notificationSelectors objectForKey:name])  withObject:self];
DSK_DIAG_POP
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self];
}

- (void)_start {
    DSK_LOG_NF(@"starting emulator...");
    [DSKEmulator _setCurrentEmulator:self];
    // schedule DOSBox to initialize on next run loop to avoid blocking the main thread
    [self.emulatorThread start];
    /*
    [[NSRunLoop currentRunLoop] performSelector:@selector(_runLoop)
                                         target:self
                                       argument:nil
                                          order:0
                                          modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]];
     */
}

- (void)_halt {
    DSK_LOG_NF(@"halting emulator...");
    // cancel the scheduled message in case DOSBox hasn't been initialized yet
    /*
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(_runLoop)
                                               target:self
                                             argument:nil];
     */
}

- (void)_pause {
    DSK_LOG_NF(@"pausing emulator...");
}

- (void)_resume {
    DSK_LOG_NF(@"resuming emulator...");
    // we already hold the pause mutex here
    pthread_cond_signal(&_pauseCondition);
}

- (void)_startup {

}

/*
 * Initializes DOSBox and begins emulation; this method does not return until DOSBox closes, this method should be scheduled
 * at the beginning of the next run loop execution to avoid blocking the main thread's run loop.
 * @see main sdlmain.cpp:1879
 */
- (void)_emulatorThread {
    try {
        char *argv[0];
        CommandLine commandLine(0, argv);
        control = new Config(&commandLine);
        
        DSK_LOG_NF(@"initializing DOSBox...");
        DOSBOX_Init();
        DSK_LOG_NF(@"DOSBox successfully initialized!");
        
        DSK_LOG_NF(@"initializing SDL...");
        if (SDL_Init(SDL_INIT_TIMER | SDL_INIT_NOPARACHUTE)) {
            [NSException dsk_raise:DSKSDLUnrecoverableExceptionName
                           message:[NSString stringWithFormat:DSKSDLUnrecoverableExceptionFormat, SDL_GetError()]];
        }
        DSK_LOG_NF(@"SDL successfully initialized!");
        NSURL *configFile = [[NSBundle dsk_emulatorBundle] URLForResource:[DSKDefaultConfigFilename stringByDeletingPathExtension]
                                                            withExtension:[DSKDefaultConfigFilename pathExtension]];
        
        control->ParseConfigFile(configFile.path.fileSystemRepresentation);
        control->Init();
        sem_post(_bootSemaphore);
        control->StartUp();
    } catch (char *error) {
        NSString *errorMessage = [NSString stringWithCString:error encoding:NSUTF8StringEncoding];
        [NSException dsk_raise:DSKDOSBoxUnrecoverableExceptionName
                       message:[NSString stringWithFormat:DSKDOSBoxUnrecoverableExceptionFormat, errorMessage]];
    } catch (int) {
        // DOSBox throws an integer exception to shutdown
        DSK_LOG_NF(@"shutting down DOSBox...");
    }
    DSK_LOG_NF(@"shutting down SDL...");
    SDL_Quit();
}

- (pthread_mutex_t *)eventMutex {
    return &_eventMutex;
}

/*
 * Replaces DOSBox's SDL based event handling. This method will be called by DOSBox when it's ready to process events; NEVER call it directly.
 * DOSBox's event loop blocks the main thread's run loop, so we need to pump the main thread's run loop periodically.
 * Similarly, pausing is also implemented here because DOSBox's pause functionality blocks its thread waiting for SDL events we aren't using.
 * @see GFX_Events - sdlmain.cpp:1482
 */
- (void)_runEvents {
    pthread_mutex_unlock(&_eventMutex);
    
    pthread_mutex_lock(&_pauseMutex);
    while (_paused) {
        pthread_cond_wait(&_pauseCondition, &_pauseMutex);
    }
    pthread_mutex_unlock(&_pauseMutex);
    
    // signal DOSBox to cleanup
    if (!self.isExecuting) {
        KillSwitch(true);
    }
    // everything except DOSBox's event loop is one huge critical section since it's not thread safe
    pthread_mutex_lock(&_eventMutex);
}

- (BOOL)_isCoreSupported:(DSKCore)core {
    switch (core) {
        case DSKDynamicCore: return [[UIDevice currentDevice] dsk_isJailbroken];
        default: return YES;
    }
}

@end
