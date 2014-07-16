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

#import "DSKFileSystem.h"
#import "DSKDrive.h"
#import "DSKEmulator.h"

#import <DOSBox/dos_inc.h>
#import <DOSBox/dos_system.h>
#import <DOSBox/drives.h>

static const UInt8 DSKHardDriveMediaID = 0xF8;
static const UInt8 DSKFloppyDriveMediaID = 0xF0;

DSK_INLINE NSUInteger _indexFromDriveLetter(DSKDriveLetter letter) {
    return letter - DSKADriveLetter;
}

@interface DSKFileSystem ()

@property (weak, readwrite) DSKEmulator *emulator;
@property (readwrite) NSMutableArray *drives;

@end

@implementation DSKFileSystem

- (instancetype)initWithEmulator:(DSKEmulator *)emulator {
    if (self = [super init]) {
        _emulator = emulator;
        _drives = [[NSMutableArray alloc] initWithCapacity:DOS_DRIVES];
    }
    return self;
}

// @see dos_programs.cpp
- (DSKDrive *)mountDriveLetter:(DSKDriveLetter)letter atURL:(NSURL *)url error:(NSError **)outError {
    DSKDrive *drive = [[DSKDrive alloc] initWithLetter:letter andURL:url];
    
    // DOSBox requires trailing slash which NSURL strips
    const char *path = [[url.path stringByAppendingString:@"/"] UTF8String];
    localDrive *dosDrive = new localDrive(path, 512, 32, 32765, 16000, DSKHardDriveMediaID);
    
    NSUInteger index = _indexFromDriveLetter(drive.letter);
    Drives[index] = dosDrive;
    mem_writeb(Real2Phys(dos.tables.mediaid) + index * 2, dosDrive->GetMediaByte());
    char label[8];
    label[0] = letter;
    strcpy(label + 1, "_DRIVE");
    dosDrive->dirCache.SetLabel(label, false, true);
    return drive;
}

@end
