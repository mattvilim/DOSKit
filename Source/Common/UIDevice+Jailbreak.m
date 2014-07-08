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

#import "UIDevice+Jailbreak.h"
#import <TargetConditionals.h>

@implementation UIDevice (DSKJailbreakDetection)

- (BOOL)dsk_isJailbroken {
#if !TARGET_IPHONE_SIMULATOR
    NSArray *jailbreakPaths = @[@"/Applications/Cydia.app",
                                @"/bin/bash",
                                @"/private/var/lib/apt"];
    for (NSString *path in jailbreakPaths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return YES;
        }
    }
#endif
    return NO;
}
 
@end