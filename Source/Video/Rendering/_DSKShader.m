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

#import "_DSKShader.h"
#import "NSBundle+Resources.h"
#import "_DSKDrawingTypes.h"

#import <OpenGLES/ES3/glext.h>

@interface _DSKShader ()

@property (readwrite, nonatomic) GLuint name;
@property (readwrite, nonatomic) NSString *filename;
@property (readwrite, nonatomic) GLenum type;

- (BOOL)_compile;

@end

@implementation _DSKShader

- (instancetype)initWithFilename:(NSString *)filename type:(GLenum)type {
    if (self = [super init]) {
        _filename = filename;
        _type = type;
        if (![self _compile]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)_compile {
    NSString *path = [[NSBundle dsk_emulatorBundle] pathForResource:[self.filename stringByDeletingPathExtension]
                                                             ofType:[self.filename pathExtension]];
    const GLchar *source = [[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] UTF8String];
    
    if (!source) {
        return NO;
    }
    
    self.name = glCreateShader(self.type);
    glShaderSource(self.name, 1, &source, NULL);
    glCompileShader(self.name);
    
    GLint status;
    glGetShaderiv(self.name, GL_COMPILE_STATUS, &status);
    return status;
}

- (void)dealloc {
    if (self.name) {
        glDeleteShader(self.name);
    }
}

@end
