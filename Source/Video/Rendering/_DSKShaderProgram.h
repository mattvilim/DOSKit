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

@class _DSKShader;

@interface _DSKShaderProgram : NSObject

@property (readonly, nonatomic) GLuint name;

- (instancetype)initWithVertexShader:(_DSKShader *)vertexShader andFragmentShader:(_DSKShader *)fragmentShader;
- (void)bindAttribute:(NSString *)attributeName atLocation:(GLuint)index;
- (GLuint)locationOfUniform:(NSString *)uniformName;
- (BOOL)link;

@end
