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

#import "_DSKShaderProgram.h"
#import "_DSKShader.h"
#import "OpenGLES/ES3/gl.h"
#import "OpenGLES/ES3/glext.h"

@interface _DSKShaderProgram ()

@property (readwrite, nonatomic) GLuint name;
@property (readwrite, nonatomic) _DSKShader *vertexShader, *fragmentShader;

@end

@implementation _DSKShaderProgram

- (instancetype)initWithVertexShader:(_DSKShader *)vertexShader andFragmentShader:(_DSKShader *)fragmentShader {
    if (self = [super init]) {
        _name = glCreateProgram();
        _vertexShader = vertexShader;
        glAttachShader(_name, _vertexShader.name);
        _fragmentShader = fragmentShader;
        glAttachShader(_name, _fragmentShader.name);
    }
    return self;
}

- (void)bindAttribute:(NSString *)attributeName atLocation:(GLuint)index {
    glBindAttribLocation(self.name, index, [attributeName UTF8String]);
}

- (GLuint)locationOfUniform:(NSString *)uniformName {
    return glGetUniformLocation(self.name, [uniformName UTF8String]);
}

- (BOOL)link {
    GLint status;
    glLinkProgram(self.name);
    glGetProgramiv(self.name, GL_LINK_STATUS, &status);
    
    if (!status) {
        return NO;
    }
    
    _DSKShader *shaders[] = {self.vertexShader, self.fragmentShader};
    for (NSUInteger i = 0; i < sizeof(shaders) / sizeof(shaders[0]); i++) {
        if (shaders[i]) {
            glDetachShader(self.name, shaders[i].name);
            glDeleteShader(shaders[i].name);
        }
    }
    
    return YES;
}

- (void)dealloc {
    if (self.name) {
        glDeleteProgram(self.name);
    }
}

@end
