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

DOSKIT_EXTERN NSString * const DSKEmulatorWillStartNotification;
DOSKIT_EXTERN NSString * const DSKEmulatorDidStartNotification;
DOSKIT_EXTERN NSString * const DSKEmulatorWillPauseNotification;
DOSKIT_EXTERN NSString * const DSKEmulatorDidPauseNotification;
DOSKIT_EXTERN NSString * const DSKEmulatorWillHaltNotification;
DOSKIT_EXTERN NSString * const DSKEmulatorDidHaltNotification;

typedef NS_ENUM(NSInteger, DSKCore) {
    DSKAutoCore,
    DSKDynamicCore,
    DSKNormalCore,
    DSKSimpleCore,
    DSKFullCore,
};

@class DSKEmulator;

@protocol DSKEmulatorDelegate <NSObject>

@optional
// emulator events
- (void)emulatorWillStart:(DSKEmulator *)emulator;
- (void)emulatorDidStart:(DSKEmulator *)emulator;
- (void)emulatorWillPause:(DSKEmulator *)emulator;
- (void)emulatorDidPause:(DSKEmulator *)emulator;
- (void)emulatorWillResume:(DSKEmulator *)emulator;
- (void)emulatorDidResume:(DSKEmulator *)emulator;
- (void)emulatorWillHalt:(DSKEmulator *)emulator;
- (void)emulatorDidHalt:(DSKEmulator *)emulator;

@end

@class DSKVideo, DSKShell, DSKKeyboard, DSKMouse, DSKJoystick, DSKAudio, DSKFileSystem;

@interface DSKEmulator : NSObject

@property (weak, readwrite) id <DSKEmulatorDelegate> delegate;

@property (readonly, nonatomic) DSKVideo *video;
@property (readonly, nonatomic) DSKAudio *audio;
@property (readonly, nonatomic) DSKShell *shell;
@property (readonly, nonatomic) DSKKeyboard *keyboard;
@property (readonly, nonatomic) DSKMouse *mouse;
@property (readonly, nonatomic) DSKJoystick *joystick;
@property (readonly, nonatomic) DSKFileSystem *fileSystem;

@property (readonly, nonatomic) DSKCore core;
@property (readwrite, nonatomic, getter = isPaused) BOOL paused;

+ (instancetype)sharedEmulator;

- (BOOL)requestCore:(DSKCore)core;

@end