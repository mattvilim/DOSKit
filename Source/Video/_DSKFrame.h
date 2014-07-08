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

typedef struct {
    NSUInteger y;
    NSUInteger height;
} DSKDirtyRect;

DSK_INLINE DSKDirtyRect DSKDirtyRectMake(NSUInteger y, NSUInteger height) {
    DSKDirtyRect dirtyRect;
    dirtyRect.y = y;
    dirtyRect.height = height;
    return dirtyRect;
}

@class _DSKTexture;

@interface _DSKFrame : NSObject

@property (readwrite, nonatomic) CGSize size;
@property (readonly, nonatomic) NSUInteger pitch;
@property (readonly, nonatomic) NSUInteger dirtyRectangleCount;

- (instancetype)initWithSize:(CGSize)size;

- (void *)buffer;

- (void)addDirtyRectangle:(DSKDirtyRect)dirtyRect;
- (DSKDirtyRect)dirtyRectangleAtIndex:(NSUInteger)index;
- (void)clearDirtyRectangles;

@end
