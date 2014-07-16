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

#import "_DSKRenderer.h"
#import "DSKGLView.h"
#import "_DSKTexture.h"
#import "_DSKDrawingTypes.h"
#import "_DSKShaderProgram.h"
#import "_DSKShader.h"
#import "_DSKFrame.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

@interface _DSKRenderer () {
    _DSKVertex _vertices[4];
    GLuint _frameBuffer, _colorRenderbuffer;
    GLuint _sampleFramebuffer, _sampleColorRenderbuffer;
    GLint _backingWidth, _backingHeight;
    GLuint _vertexBuffer, _vertexArray;
    _DSKUniforms _uniforms;
    _DSKMatrix4 _projection;
}

@property (readwrite, nonatomic) EAGLContext *context;
@property (readwrite, nonatomic) _DSKTexture *texture;
@property (readwrite, nonatomic) _DSKShaderProgram *program;
@property (readonly, nonatomic) GLfloat backingAspectRatio;
@property (readonly, nonatomic, getter = isMultisamplingEnabled) BOOL multisamplingEnabled;

- (void)_generateVertexObjects;
- (void)_deleteVertexObjects;
- (void)_generateFramebuffer;
- (void)_deleteFramebuffer;
- (BOOL)_resizeMultisample;

@end

@implementation _DSKRenderer

- (instancetype)init {
    if (![self isMemberOfClass:[_DSKRenderer class]]) {
        if (self = [super init]) {
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
            if (!_context || ![EAGLContext setCurrentContext:_context]) {
                return nil;
            }
            [self _loadShaders];
            [self _generateFramebuffer];
            [self _generateSampleFramebuffer];
            [self _generateVertexObjects];
        }
        return self;
    } else {
        [NSException dsk_raise:DSKAbstractClassNotOverriddenExceptionName
                       message:[NSString stringWithFormat:DSKAbstractClassNotOverriddenExceptionFormat, NSStringFromClass([_DSKRenderer class])]];
        return nil;
    }
}

- (BOOL)resizeFromDrawable:(id <EAGLDrawable>)drawable {
    [EAGLContext setCurrentContext:self.context];
    
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:drawable];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    [self _resizeMultisample];
    [self _updateVertices];
    _projection = _DSKMatrix4MakeOrthorgraphic(0.0f, _backingWidth, _backingHeight, 0.0f, -1.0f, 1.0f);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        DSKLog(@"failed to create framebuffer %x", status);
        return NO;
    }
    return YES;
}

- (BOOL)isMultisamplingEnabled {
    return self.multisample != DSKMultisampleNone;
}

- (void)setMultisample:(DSKMultisample)multisample {
    if (multisample != _multisample) {
        _multisample = multisample;
        [self _resizeMultisample];
    }
    return;
}

- (BOOL)_resizeMultisample {
    [EAGLContext setCurrentContext:self.context];
    NSUInteger samples;
    switch (self.multisample) {
        case DSKMultisampleNone:
            [self _deleteSampleFramebuffer];
            return YES;
        case DSKMultisample2X: samples = 2; break;
        case DSKMultisample4X: samples = 4; break;
        case DSKMultisample8X: samples = 8; break;
    }
    
    if (!_sampleFramebuffer) {
        [self _generateSampleFramebuffer];
    }
    glBindRenderbuffer(GL_RENDERBUFFER, _sampleColorRenderbuffer);
    glRenderbufferStorageMultisample(GL_RENDERBUFFER, samples, GL_RGBA8, _backingWidth, _backingHeight);
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        DSKLog(@"failed to create framebuffer %x", status);
        return NO;
    }
    return YES;
}

- (void)_loadShaders {
    _DSKShader *vertexShader = [[_DSKShader alloc] initWithFilename:@"Shader.vsh" type:GL_VERTEX_SHADER];
    _DSKShader *fragmentShader = [[_DSKShader alloc] initWithFilename:@"Shader.fsh" type:GL_FRAGMENT_SHADER];
    self.program = [[_DSKShaderProgram alloc] initWithVertexShader:vertexShader andFragmentShader:fragmentShader];
    [self.program bindAttribute:@"position" atLocation:_DSKVertexAttribCoord];
    [self.program bindAttribute:@"textureCoordIn" atLocation:_DSKVertexAttribTexCoord];
    
    [self.program link];
    _uniforms.projection = [self.program locationOfUniform:@"projection"];
    _uniforms.texture = [self.program locationOfUniform:@"texture"];
}

- (void)_generateVertexObjects {
    // generate VAO
    glGenVertexArrays(1, &_vertexArray);
    glBindVertexArray(_vertexArray);
    
    // generate VBO
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(_vertices), _vertices, GL_STATIC_DRAW);
    // vertex coordinates
    glVertexAttribPointer(_DSKVertexAttribCoord, _DSK_VECTOR2_SIZE, GL_FLOAT, GL_FALSE,
                          sizeof(_DSKVertex), offsetof(_DSKVertex, position));
    glEnableVertexAttribArray(_DSKVertexAttribCoord);
    // texture coordinates
    glVertexAttribPointer(_DSKVertexAttribTexCoord, _DSK_VECTOR2_SIZE, GL_FLOAT, GL_FALSE,
                          sizeof(_DSKVertex), offsetof(_DSKVertex, texture));
    glEnableVertexAttribArray(_DSKVertexAttribTexCoord);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}

- (void)_deleteVertexObjects {
    if (_vertexBuffer) {
        glDeleteBuffers(1, &_vertexBuffer);
    }
    if (_vertexArray) {
        glDeleteVertexArrays(1, &_vertexArray);
    }
}

- (void)_generateFramebuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_colorRenderbuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
}

- (void)_deleteFramebuffer {
    if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
    if (_colorRenderbuffer) {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }
}

- (void)_generateSampleFramebuffer {
    glGenFramebuffers(1, &_sampleFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
    
    glGenRenderbuffers(1, &_sampleColorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _sampleColorRenderbuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _sampleColorRenderbuffer);
}

- (void)_deleteSampleFramebuffer {
    if (_sampleFramebuffer) {
        glDeleteFramebuffers(1, &_sampleFramebuffer);
        _sampleFramebuffer = 0;
    }
    if (_sampleColorRenderbuffer) {
        glDeleteRenderbuffers(1, &_sampleColorRenderbuffer);
        _sampleColorRenderbuffer = 0;
    }
}

- (void)setScaleStyle:(DSKViewScaleStyle)scaleStyle {
    if (scaleStyle != _scaleStyle) {
        _scaleStyle = scaleStyle;
        [self _updateVertices];
    }
    return;
}

- (void)_updateVertices {
    CGRect bounds;
    switch (self.scaleStyle) {
        case DSKViewScaleStyleStretch:
            bounds = CGRectMake(0.0f, 0.0f, _backingWidth, _backingHeight);
            break;
        case DSKViewScaleStyleAspectFill:
        case DSKViewScaleStyleAspectFit:
            if (self.texture.clippingAspectRatio > self.backingAspectRatio) {
                GLfloat height = _backingWidth / self.texture.clippingAspectRatio;
                GLfloat y = (_backingHeight - height) / 2.0f;
                bounds = CGRectMake(0.0f, y, _backingWidth, height);
            } else {
                GLfloat width = _backingHeight * self.texture.clippingAspectRatio;
                GLfloat x = (_backingWidth - width) / 2.0f;
                bounds = CGRectMake(x, 0.0f, width, _backingHeight);
            }
            break;
    }
    
    _DSKQuadPositionFromRect(_vertices, bounds);
    _DSKQuadTextureFromRect(_vertices, self.texture.clipping);
    
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(_vertices), _vertices);
}

- (void)render {
    [EAGLContext setCurrentContext:self.context];
    
    // DOSBox may have changed rendering resolution between frames
    if (!CGSizeEqualToSize(self.frame.size, self.texture.frameSize)) {
        self.texture = [_DSKTexture textureWithFrame:self.frame error:nil];
    }
    
    [self.texture updateWithFrame:self.frame];
    
    if (self.multisamplingEnabled) {
        glBindFramebuffer(GL_FRAMEBUFFER, _sampleFramebuffer);
    } else {
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    }
    glViewport(0, 0, _backingWidth, _backingHeight);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program.name);
    // apply projection
    glUniformMatrix4fv(_uniforms.projection, 1, GL_FALSE, _projection.m);
    // draw vertices
    glBindVertexArray(_vertexArray);
    // prepare texture
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(self.texture.target, self.texture.name);
    glUniform1i(_uniforms.texture, 0);
    // draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArray(0);
    // resolve MSAA
    if (self.isMultisamplingEnabled) {
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, _frameBuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER, _sampleFramebuffer);
        glBlitFramebuffer(0, 0, _backingWidth, _backingHeight, 0, 0, _backingWidth, _backingHeight, GL_COLOR_BUFFER_BIT, GL_NEAREST);
    }
    // discard
    const GLenum discard = GL_COLOR_ATTACHMENT0;
    glInvalidateFramebuffer(GL_READ_FRAMEBUFFER, 1, &discard);
    // present
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setFrame:(_DSKFrame *)frame {
    if (frame != _frame) {
        _frame = frame;
        [EAGLContext setCurrentContext:self.context];
        self.texture = [_DSKTexture textureWithFrame:self.frame error:nil];
        [self _updateVertices];
    }
}

- (GLfloat)backingAspectRatio {
    return CGSizeGetAspect(CGSizeMake(_backingWidth, _backingHeight));
}

- (void)dealloc {
    [EAGLContext setCurrentContext:self.context];
    [self _deleteFramebuffer];
    [self _deleteSampleFramebuffer];
    [self _deleteVertexObjects];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

@end