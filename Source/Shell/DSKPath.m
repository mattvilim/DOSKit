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

#import "DSKPath.h"
#import "DSKDrive.h"

static NSString * const DSKURLPathSeparator = @"/";
static NSString * const DSKDOSPathSeparator = @"\\";

@interface DSKPath ()

@property (readwrite) DSKDrive *drive;
@property (readwrite) NSURL *relativeURL;

@end

@implementation DSKPath

+ (instancetype)pathFromRelativeURL:(NSURL *)url inDrive:(DSKDrive *)drive {
    return [[self alloc] initWithRelativeURL:url inDrive:drive];
}

- (instancetype)initWithRelativeURL:(NSURL *)url inDrive:(DSKDrive *)drive {
    if (self = [super init]) {
        _relativeURL = url;
        _drive = drive;
    }
    return self;
}

- (NSString *)dosPath {
    NSString *relativeDOSPath = [self.relativeURL.relativePath stringByReplacingOccurrencesOfString:DSKURLPathSeparator withString:DSKDOSPathSeparator];
    return [NSString stringWithFormat:@"%C:%@", [self.drive character], relativeDOSPath];
}

- (NSURL *)absoluteURL {
    return [NSURL URLWithString:self.relativeURL.relativePath relativeToURL:self.drive.url];
}

@end
