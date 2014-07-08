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

#import "DKDAppDelegate.h"

@interface DKDAppDelegate ()

@property (readwrite, nonatomic) DSKEmulator *emulator;
@property (readwrite, nonatomic) UIViewController *viewController;
@property (readwrite, nonatomic) DSKView *view;

@end

@implementation DKDAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    self.emulator = [[DSKEmulator alloc] init];
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSURL *test = [NSURL fileURLWithPath:path];
    [self.emulator.fileSystem mountDriveLetter:DSKCDriveLetter atURL:test error:nil];
    
    self.emulator.executing = YES;
    
    self.view = [[DSKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.emulator = self.emulator;
    self.viewController = [[UIViewController alloc] init];
    self.viewController.view = self.view;
    [self.view.glView attachEmulator:self.emulator];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:self.viewController];
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //self.emulator.paused = NO;
    self.view.glView.drawing = YES;
}

/*
- (void)applicationWillResignActive:(UIApplication *)application {
    self.emulator.paused = YES;
    self.view.drawing = NO;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.emulator.paused = NO;
    self.view.drawing = YES;
}
*/
@end