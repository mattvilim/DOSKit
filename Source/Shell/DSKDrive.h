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

typedef NS_ENUM(NSInteger, DSKDriveLetter) {
    DSKADriveLetter = 'A',
    DSKBDriveLetter,
    DSKCDriveLetter,
    DSKDDriveLetter,
    DSKEDriveLetter,
    DSKFDriveLetter,
    DSKGDriveLetter,
    DSKHDriveLetter,
    DSKIDriveLetter,
    DSKJDriveLetter,
    DSKKDriveLetter,
    DSKLDriveLetter,
    DSKMDriveLetter,
    DSKNDriveLetter,
    DSKODriveLetter,
    DSKPDriveLetter,
    DSKQDriveLetter,
    DSKRDriveLetter,
    DSKSDriveLetter,
    DSKTDriveLetter,
    DSKUDriveLetter,
    DSKVDriveLetter,
    DSKWDriveLetter,
    DSKXDriveLetter,
    DSKYDriveLetter,
    DSKZDriveLetter,
};

@interface DSKDrive : NSObject

@property (readonly, nonatomic) DSKDriveLetter letter;
@property (readonly, nonatomic) NSURL *url;
@property (readwrite, nonatomic) BOOL mounted;

- (instancetype)initWithLetter:(DSKDriveLetter)letter andURL:(NSURL *)url;
- (unichar)character;

@end
