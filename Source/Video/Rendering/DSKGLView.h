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

typedef NS_ENUM(NSUInteger, DSKMultisample) {
    DSKMultisampleNone,
    DSKMultisample2X,
    DSKMultisample4X, // default
    DSKMultisample8X,
};

typedef NS_ENUM(NSUInteger, DSKRendererStyle) {
    DSKSimpleRendererStyle, // default
    DSKCRTRendererStyle,
};

typedef NS_ENUM(NSUInteger, DSKViewScaleStyle) {
    DSKViewScaleStyleStretch,
    DSKViewScaleStyleAspectFit, // default
    DSKViewScaleStyleAspectFill,
};

@class DSKEmulator, DSKVideo;

@interface DSKGLView : UIView

@property (readwrite, nonatomic) NSUInteger frameInterval;
@property (readwrite, nonatomic, getter = isDrawing) BOOL drawing;
@property (readwrite, nonatomic) DSKViewScaleStyle scaleStyle;
@property (readwrite, nonatomic) DSKRendererStyle rendererStyle;
@property (readwrite, nonatomic) DSKMultisample multisample;

- (void)attachEmulator:(DSKEmulator *)emulator;

@end
