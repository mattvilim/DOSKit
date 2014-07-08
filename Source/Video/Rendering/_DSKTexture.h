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

@class _DSKFrame;

@interface _DSKTexture : NSObject

@property (readonly, nonatomic) GLuint name, width, height;
@property (readonly, nonatomic) GLfloat clippingAspectRatio;
@property (readonly, nonatomic) GLenum target;
@property (readonly, nonatomic) CGRect clipping;

+ (instancetype)textureWithFrame:(_DSKFrame *)frame error:(NSError **)outError;

- (instancetype)initWithFrame:(_DSKFrame *)frame error:(NSError **)outError;
- (void)updateWithFrame:(_DSKFrame *)frame;
- (void)loadWithFrame:(_DSKFrame *)frame error:(NSError **)outError;

@end
