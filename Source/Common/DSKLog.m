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

#import "DSKLog.h"

static NSString * const DSKLogFormat = @"DOSKit: %@";

void DSKLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    DSKLogv(format, args);
}

void DSKLogv(NSString *format, va_list args) {
    NSLog(@"%@", [NSString dsk_logString:[[NSString alloc] initWithFormat:format arguments:args]]);
    va_end(args);
}

@implementation NSString (DSKLog)

+ (NSString *)dsk_logString:(NSString *)message {
    return [NSString stringWithFormat:DSKLogFormat, message];
}

@end