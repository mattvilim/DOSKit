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

#import "DSKDrive.h"

@interface DSKDrive ()

@property (readwrite, nonatomic) DSKDriveLetter letter;
@property (readwrite, nonatomic) NSURL *url;

@end

@implementation DSKDrive

- (instancetype)initWithLetter:(DSKDriveLetter)letter andURL:(NSURL *)url {
    if (self = [super init]) {
        _letter = letter;
        _url = url;
    }
    return self;
}

- (unichar)character {
    return  self.letter;
}

- (void)setMounted:(BOOL)mounted {
    if (_mounted != mounted) {
        if (mounted) {
            [self _mount];
        } else {
            [self _unmount];
        }
    }
}

- (void)_mount {
    
}

- (void)_unmount {
    
}

@end
