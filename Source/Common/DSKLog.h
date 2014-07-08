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

#if DEBUG
# define DSK_LOG(format, ...) DSKLog(format, ##__VA_ARGS__)
#else
# define DSK_LOG(format, ...) do {} while (0)
#endif

# define DSK_LOG_NF(string) DSK_LOG(@"%@", string)

DOSKIT_EXTERN void DSKLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);
DOSKIT_EXTERN void DSKLogv(NSString *format, va_list args) NS_FORMAT_FUNCTION(1, 0);

@interface NSString (DSKLog)

+ (NSString *)dsk_logString:(NSString *)message;

@end
