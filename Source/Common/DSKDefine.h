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

#define DOSKIT 1

#ifdef __cplusplus
# define DOSKIT_EXTERN extern "C"
#else
# define DOSKIT_EXTERN extern
#endif

#define DSK_INLINE static inline

#define DSK_DIAG_PUSH _Pragma("clang diagnostic push")
#define DSK_DIAG_POP _Pragma("clang diagnostic pop")

#define DSK_DIAG_IGNORE_SEL_LEAK _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
