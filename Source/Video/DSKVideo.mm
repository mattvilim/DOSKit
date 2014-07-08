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

#import "DSKVideo.h"
#import "DSKVideoInternal.h"
#import "DSKEmulatorInternal.h"
#import "_DSKFrame.h"

#import <DOSBox/dosbox.h>
#import <DOSBox/video.h>
#import <DOSBox/render.h>
#import <DOSBox/shell.h>
#import <DOSBox/callback.h>

static Bitu _DSKGetBestMode(Bitu flags);
static Bitu _DSKGetRGB(Bit8u red, Bit8u green, Bit8u blue);
static Bitu _DSKSetSize(Bitu width, Bitu height, Bitu flags, double scalex, double scaley, GFX_CallBack_t cb);
static bool _DSKStartUpdate(Bit8u * &pixels, Bitu &pitch);
static void _DSKEndUpdate(const Bit16u *changedLines);

@interface DSKVideo () {
    GFX_CallBack_t _callback;
}

@property (weak, readwrite, nonatomic) DSKEmulator *emulator;

- (void)_startFrameWithBuffer:(void **)buffer pitch:(NSUInteger *)pitch;
- (void)_endFrameWithChangedLines:(const UInt16 *)lines;
- (void)_createFrameWithSize:(CGSize)size atScale:(CGSize)scale withCallback:(GFX_CallBack_t)callback;

@end

Bitu _DSKGetBestMode(Bitu flags) {
    return GFX_CAN_32 | GFX_SCALING;
}

Bitu _DSKGetRGB(Bit8u red, Bit8u green, Bit8u blue) {
    return (blue << 0) | (green << 8) | (red << 16) | (255 << 24);
}

Bitu _DSKSetSize(Bitu width, Bitu height, Bitu flags, double scalex, double scaley, GFX_CallBack_t cb) {
    [[DSKEmulator currentEmulator].video _createFrameWithSize:CGSizeMake(width, height)
                                                      atScale:CGSizeMake(scalex, scaley)
                                                 withCallback:cb];
    return _DSKGetBestMode(flags);
}

bool _DSKStartUpdate(Bit8u * &pixels, Bitu &pitch) {
    [[DSKEmulator currentEmulator].video _startFrameWithBuffer:(void **)&pixels pitch:&pitch];
    return true;
}

void _DSKEndUpdate(const Bit16u *changedLines) {
    [[DSKEmulator currentEmulator].video _endFrameWithChangedLines:changedLines];
}


@implementation DSKVideo

- (instancetype)initWithEmulator:(DSKEmulator *)emulator {
    if (self = [super init]) {
        _emulator = emulator;
        _frame = [[_DSKFrame alloc] initWithSize:CGSizeMake(640, 400)];
        
        GFX_GetBestModeHandler = _DSKGetBestMode;
        GFX_GetRGBHandler = _DSKGetRGB;
        GFX_SetSizeHandler = _DSKSetSize;
        GFX_StartUpdateHandler = _DSKStartUpdate;
        GFX_EndUpdateHandler = _DSKEndUpdate;
        
        pthread_mutex_init(&_renderMutex, NULL);
    }
    return self;
}

- (CGSize)resolution {
    return CGSizeMake(render.src.width, render.src.height);
}

- (NSUInteger)frameskip {
	return render.frameskip.max;
}

- (void)setFrameskip:(NSUInteger)frameskip {
	render.frameskip.max = frameskip;
}

- (void)_startFrameWithBuffer:(void **)buffer pitch:(NSUInteger *)pitch  {
    [self.frame clearDirtyRectangles];
    
    pthread_mutex_lock(&_renderMutex);
    *buffer = self.frame.buffer;
    *pitch = self.frame.pitch;
}

- (void)_endFrameWithChangedLines:(const UInt16 *)lines {
    if (lines) {
        for (NSUInteger i = 0, y = 0, height; y < self.frame.size.height; i++, y += height) {
            height = lines[i];
            // dirty regions are at odd indices
            if (i & 0x1) {
                [self.frame addDirtyRectangle:DSKDirtyRectMake(y, height)];
            }
        }
    }
    pthread_mutex_unlock(&_renderMutex);
}

- (void)_createFrameWithSize:(CGSize)size atScale:(CGSize)scale withCallback:(GFX_CallBack_t)callback {
    _callback = callback;
    self.frame.size = size;
}

- (pthread_mutex_t *)renderMutex {
    return &_renderMutex;
}

- (void)dealloc {
    pthread_mutex_destroy(&_renderMutex);
}

@end
