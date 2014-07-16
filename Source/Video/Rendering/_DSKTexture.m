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

#import "_DSKTexture.h"
#import "_DSKFrame.h"
#import "_DSKDrawingTypes.h"

@interface _DSKTexture () {
    GLenum _format;
    GLenum _type;
}

@property (readwrite, nonatomic) CGSize frameSize;
@property (readwrite, nonatomic) CGRect clipping;

@end

@implementation _DSKTexture

- (instancetype)initWithFrame:(_DSKFrame *)frame error:(NSError **)outError {
    if (self = [super init]) {
        _target = GL_TEXTURE_2D;
        glGenTextures(1, &_name);
        glBindTexture(_target, _name);
        _format = GL_BGRA;
        _type = GL_UNSIGNED_BYTE;

        glTexParameteri(_target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(_target, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        [self loadWithFrame:frame error:outError];
    }
    return self;
}

+ (instancetype)textureWithFrame:(_DSKFrame *)frame error:(NSError **)outError {
    return [[self alloc] initWithFrame:frame error:outError];
}

- (void)loadWithFrame:(_DSKFrame *)frame error:(NSError **)outError {
    _frameSize = frame.size;
    NSUInteger size;
    for (size = 1; size < MAX(frame.size.width, frame.size.height); size <<= 1);
    _width = _height = size;
    _clipping = CGRectMake(0.0f, 0.0f, (frame.size.width / _width), (frame.size.height / _height));
    
    glBindTexture(_target, _name);
    glTexImage2D(_target, 0, GL_RGBA, _width, _height, 0, _format, _type, NULL);
    //glTexSubImage2D(_target, 0, 0, 0, frame.size.width, frame.size.height, _format, _type, frame.buffer);
    NSAssert(glGetError() == GL_NO_ERROR, @"");
}

- (void)updateWithFrame:(_DSKFrame *)frame {
    glBindTexture(_target, _name);
    glTexSubImage2D(_target, 0, 0, 0, frame.size.width, frame.size.height, _format, _type, frame.buffer);
    
    for (NSUInteger i = 0; i < frame.dirtyRectangleCount; i++) {
        UInt8 *test = malloc(2000);
        memset(test, 0xFF, 2000);
        DSKDirtyRect dirtyRect = [frame dirtyRectangleAtIndex:i];
        const GLvoid *pixels = (UInt8 *)frame.buffer + (dirtyRect.y * frame.pitch);
        //glTexSubImage2D(_target, 0, 0, dirtyRect.y, frame.size.width, dirtyRect.height, _format, _type, test);
    }
    [frame clearDirtyRectangles];

}

- (GLfloat)clippingAspectRatio {
    return CGSizeGetAspect(self.clipping.size);
}

- (void)dealloc {
    if (_name) {
        glDeleteTextures(1, &_name);
    }
}

@end