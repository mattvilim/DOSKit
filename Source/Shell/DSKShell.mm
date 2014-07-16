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

#import "DSKShell.h"
#import "DSKEmulator.h"
#import "DSKEmulatorInternal.h"

#import <DOSBox/shell.h>

#import <pthread.h>

@interface DSKShell () {
    char _buffer[CMD_MAXLINE];
}

@property (weak, readwrite) DSKEmulator *emulator;

@end

@implementation DSKShell

- (instancetype)initWithEmulator:(DSKEmulator *)emulator {
    if (self = [super init]) {
        _emulator = emulator;
    }
    return self;
}

- (void)changeDrive:(DSKDriveLetter)drive {
    pthread_mutex_lock(self.emulator.eventMutex);
    strcpy(_buffer, "C:");
    current_shell->DoCommand(_buffer);
    current_shell->WriteOut_NoParsing("\n\n");
    current_shell->ShowPrompt();
    pthread_mutex_unlock(self.emulator.eventMutex);
}

- (void)executeProgram:(NSString *)program withArgs:(char *)args {
    pthread_mutex_lock(self.emulator.eventMutex);
    strcpy(_buffer, "FIRE");
    current_shell->DoCommand(_buffer);
    //bool retval = current_shell->Execute((char *)[program UTF8String], _buffer);
    pthread_mutex_unlock(self.emulator.eventMutex);
    return;
}
/*
- (void)mountDriveLetter:(DSKDriveLetter)letter atURL:(NSURL *)url error:(NSError **)outError {
    pthread_mutex_lock(self.emulator.eventMutex);
    strcpy(_buffer, "C:");
    current_shell->CMd_M
    pthread_mutex_unlock(self.emulator.eventMutex);
}
 */
@end