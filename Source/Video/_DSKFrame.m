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

#import "_DSKFrame.h"
#import "_DSKTexture.h"

// DOSBox renders at 32 bits per pixel, so we don't have a choice here
static const NSUInteger DSKFrameBitsPerPixel = 32;
static const NSUInteger DSKFrameBytesPerPixel = DSKFrameBitsPerPixel / 8;

@interface _DSKFrame () {
    DSKDirtyRect *_dirtyRectangles;
}

@property (readwrite, nonatomic) NSMutableData *data;

@end

@implementation _DSKFrame

- (instancetype)initWithSize:(CGSize)size {
    if (self = [super init]) {
        self.size = size;
    }
    return self;
}

- (void)setSize:(CGSize)size {
    if (!CGSizeEqualToSize(_size, size)) {
        _size = size;
        
        free(_dirtyRectangles);
        _dirtyRectangles = malloc(size.height * sizeof(DSKDirtyRect));
        NSAssert(_dirtyRectangles, @"");
        _dirtyRectangleCount = 0;
        
        NSUInteger bufferSize = size.width * size.height * DSKFrameBytesPerPixel;
        _data = [[NSMutableData alloc] initWithCapacity:bufferSize];
    }
    return;
}

- (void *)buffer {
    return [self.data mutableBytes];
}

- (NSUInteger)pitch {
    return self.size.width * DSKFrameBytesPerPixel;
}

- (void)addDirtyRectangle:(DSKDirtyRect)dirtyRect {
    NSAssert(_dirtyRectangleCount < self.size.height, @"");
    _dirtyRectangles[_dirtyRectangleCount] = dirtyRect;
    _dirtyRectangleCount++;
}

- (DSKDirtyRect)dirtyRectangleAtIndex:(NSUInteger)index {
    return _dirtyRectangles[index];
}

- (void)clearDirtyRectangles {
    _dirtyRectangleCount = 0;
}

- (void)dealloc {
    free(_dirtyRectangles);
}

@end