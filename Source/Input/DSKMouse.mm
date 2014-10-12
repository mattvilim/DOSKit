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

#import "DSKMouse.h"
#import "DSKEmulator.h"

#import <DOSBox/control.h>
#import <DOSBox/mouse.h>

@interface DSKMouse ()

@property (weak, readwrite) DSKEmulator *emulator;
@property (assign) CGPoint lastMousePosition;

@end

@implementation DSKMouse

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithEmulator:(DSKEmulator *)emulator {
    if (self = [super init]) {
        self.emulator = emulator;
    }
    return self;
}

- (void)setMousePointerTo:(CGPoint)point {
    Mouse_CursorSet(point.x, point.y);
}

- (void)applyMousePointerMovementTo:(CGPoint)point {
    if (CGPointEqualToPoint(self.lastMousePosition, CGPointZero)) {
        self.lastMousePosition = point;
    }
    Mouse_CursorMoved(point.x - self.lastMousePosition.x, point.y - self.lastMousePosition.y, point.x, point.y, YES);
    self.lastMousePosition = point;
}

- (void)leftMouseButtonSingleClick {
    [self _perfomSingleClickForButton:0];
}

- (void)rightMouseButtonSingleClick {
    [self _perfomSingleClickForButton:1];
}

- (void)_perfomSingleClickForButton:(NSUInteger)button {
    Mouse_ButtonPressed(button);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Mouse_ButtonReleased(button);
    });
}

@end