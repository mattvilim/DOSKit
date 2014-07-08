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

#define _DSK_VECTOR2_SIZE 2

typedef union {
    GLfloat m[16];
    struct {
        GLfloat a00, a01, a02, a03;
        GLfloat a10, a11, a12, a13;
        GLfloat a20, a21, a22, a23;
        GLfloat a30, a31, a32, a33;
    };
} _DSKMatrix4;

typedef union {
    GLfloat v[_DSK_VECTOR2_SIZE];
    struct {
        GLfloat x, y;
    };
    struct {
        GLfloat s, t;
    };
} _DSKVector2;

typedef struct {
    _DSKVector2 position;
    _DSKVector2 texture;
} _DSKVertex;

typedef struct {
    GLint projection, texture;
} _DSKUniforms;

NS_ENUM(GLuint, _DSKVertexAttribs) {
    _DSKVertexAttribCoord,
    _DSKVertexAttribTexCoord
};

DSK_INLINE _DSKMatrix4 _DSKMatrix4Make(GLfloat a00, GLfloat a01, GLfloat a02, GLfloat a03,
                                       GLfloat a10, GLfloat a11, GLfloat a12, GLfloat a13,
                                       GLfloat a20, GLfloat a21, GLfloat a22, GLfloat a23,
                                       GLfloat a30, GLfloat a31, GLfloat a32, GLfloat a33) {
    _DSKMatrix4 m;
    m.a00 = a00; m.a01 = a01; m.a02 = a02; m.a03 = a03;
    m.a10 = a10; m.a11 = a11; m.a12 = a12; m.a13 = a13;
    m.a20 = a20; m.a21 = a21; m.a22 = a22; m.a23 = a23;
    m.a30 = a30; m.a31 = a31; m.a32 = a32; m.a33 = a33;
    return m;
}

DSK_INLINE _DSKVector2 _DSKVector2Make(GLfloat x, GLfloat y) {
    _DSKVector2 vector2;
    vector2.x = x;
    vector2.y = y;
    return vector2;
}

DSK_INLINE _DSKMatrix4 _DSKMatrix4MakeOrthorgraphic(GLfloat left, GLfloat right,
                                                    GLfloat bottom, GLfloat top,
                                                    GLfloat near, GLfloat far) {
    GLfloat rpl = right + left;
    GLfloat rml = right - left;
    GLfloat tpb = top + bottom;
    GLfloat tmb = top - bottom;
    GLfloat fpn = far + near;
    GLfloat fmn = far - near;
    
    _DSKMatrix4 m = _DSKMatrix4Make(2.0f / rml,       0.0f,        0.0f, 0.0f,
                                          0.0f, 2.0f / tmb,        0.0f, 0.0f,
                                          0.0f,       0.0f, -2.0f / fmn, 0.0f,
                                    -rpl / rml, -tpb / tmb,  -fpn / fmn, 1.0f);
    return m;
}

DSK_INLINE void _DSKQuadPositionFromRect(_DSKVertex vertices[4], CGRect rect) {
    vertices[0].position = _DSKVector2Make(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    vertices[1].position = _DSKVector2Make(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    vertices[2].position = _DSKVector2Make(CGRectGetMinX(rect), CGRectGetMinY(rect));
    vertices[3].position = _DSKVector2Make(CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

DSK_INLINE void _DSKQuadTextureFromRect(_DSKVertex vertices[4], CGRect rect) {
    vertices[0].texture = _DSKVector2Make(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    vertices[1].texture = _DSKVector2Make(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    vertices[2].texture = _DSKVector2Make(CGRectGetMinX(rect), CGRectGetMinY(rect));
    vertices[3].texture = _DSKVector2Make(CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

DSK_INLINE CGFloat CGSizeGetAspect(CGSize size) {
    return size.width / size.height;
}
