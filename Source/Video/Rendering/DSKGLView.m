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

#import "DSKGLView.h"
#import "DSKGLViewSubclass.h"

#import "DSKVideo.h"
#import "DSKVideoInternal.h"
#import "DSKEmulatorInternal.h"
#import "_DSKSimpleRenderer.h"
#import "_DSKTexture.h"
#import "_DSKCRTRenderer.h"
#import "_DSKFrame.h"

@interface DSKGLView ()

@property (readwrite, nonatomic) CADisplayLink *displayLink;
@property (readwrite, nonatomic) DSKEmulator *emulator;

- (void)_commonInit;
- (void)_startDrawing;
- (void)_stopDrawing;

@end

@implementation DSKGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _commonInit];
    }
    return self;
}

- (void)attachEmulator:(DSKEmulator *)emulator {
    self.emulator = emulator; // TEMP
    self.renderer.frame = self.emulator.video.frame;
}

- (void)_commonInit {
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    _frameInterval = 2;
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = @{@(NO): kEAGLDrawablePropertyRetainedBacking,
                                     kEAGLColorFormatRGBA8: kEAGLDrawablePropertyColorFormat};
    self.rendererStyle = DSKSimpleRendererStyle;
    self.scaleStyle = DSKViewScaleStyleAspectFit;
    self.multisample = DSKMultisample4X;
}

- (void)setDrawing:(BOOL)drawing {
    if (drawing != _drawing) {
        _drawing = drawing;
        drawing ? [self _startDrawing] : [self _stopDrawing];
    }
}

- (void)setFrameInterval:(NSUInteger)frameInterval {
    if (frameInterval != _frameInterval) {
        _frameInterval = frameInterval;
        if (self.isDrawing) {
            [self _stopDrawing];
            [self _startDrawing];
        }
    }
}

- (void)setDisplayLink:(CADisplayLink *)displayLink {
    if (displayLink != _displayLink) {
        [_displayLink invalidate];
        _displayLink = displayLink;
    }
    return;
}

- (void)layoutSubviews {
    [self.renderer resizeFromDrawable:(CAEAGLLayer *)self.layer];
    [self _draw:nil];
}

- (void)_startDrawing {
    self.displayLink = [self.window.screen displayLinkWithTarget:self selector:@selector(_draw:)];
    self.displayLink.frameInterval = self.frameInterval;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)_stopDrawing {
    self.displayLink = nil;
}

- (void)_draw:(CADisplayLink *)displayLink {
    pthread_mutex_lock(self.emulator.video.renderMutex);
    [self.renderer render];
    pthread_mutex_unlock(self.emulator.video.renderMutex);
}

- (void)setRendererStyle:(DSKRendererStyle)rendererStyle {
    if (rendererStyle != _rendererStyle || !self.renderer) {
        _rendererStyle = rendererStyle;
        
        Class rendererClass = Nil;
        switch (rendererStyle) {
            case DSKSimpleRendererStyle: rendererClass = [_DSKSimpleRenderer class]; break;
            case DSKCRTRendererStyle: rendererClass = [_DSKCRTRenderer class]; break;
        }
        NSAssert(rendererClass, [NSString dsk_logString:@"no renderer class defined for style"]);
        self.renderer = [[rendererClass alloc] init];
    }
}

- (void)setMultisample:(DSKMultisample)multisample {
    if (multisample != _multisample) {
        _multisample = multisample;
        [self.renderer setMultisample:multisample];
    }
}

- (void)setScaleStyle:(DSKViewScaleStyle)scaleStyle {
    if (scaleStyle != _scaleStyle) {
        [self.renderer setScaleStyle:scaleStyle];
    }
    return;
}

- (void)dealloc {
    [self _stopDrawing];
}

@end
