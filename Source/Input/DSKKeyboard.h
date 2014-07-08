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

DOSKIT_EXTERN NSString * const DSKKeyboardPressedNotification;  // userInfo holds key data
DOSKIT_EXTERN NSString * const DSKKeyboardReleasedNotification; // userInfo holds key data
DOSKIT_EXTERN NSString * const DSKKeyUserInfo;                  // userInfo key for key data

typedef NS_ENUM(NSInteger, DSKKeyCode) {
    // letters
    DSKAKeyCode,
    DSKBKeyCode,
    DSKCKeyCode,
    DSKDKeyCode,
    DSKEKeyCode,
    DSKFKeyCode,
    DSKGKeyCode,
    DSKHKeyCode,
    DSKIKeyCode,
    DSKJKeyCode,
    DSKKKeyCode,
    DSKLKeyCode,
    DSKMKeyCode,
    DSKNKeyCode,
    DSKOKeyCode,
    DSKPKeyCode,
    DSKQKeyCode,
    DSKRKeyCode,
    DSKSKeyCode,
    DSKTKeyCode,
    DSKUKeyCode,
    DSKVKeyCode,
    DSKWKeyCode,
    DSKXKeyCode,
    DSKYKeyCode,
    DSKZKeyCode,
    // numbers
    DSK1KeyCode,
    DSK2KeyCode,
    DSK3KeyCode,
    DSK4KeyCode,
    DSK5KeyCode,
    DSK6KeyCode,
    DSK7KeyCode,
    DSK8KeyCode,
    DSK9KeyCode,
    DSK0KeyCode,
    // function
    DSKF1KeyCode,
    DSKF2KeyCode,
    DSKF3KeyCode,
    DSKF4KeyCode,
    DSKF5KeyCode,
    DSKF6KeyCode,
    DSKF7KeyCode,
    DSKF8KeyCode,
    DSKF9KeyCode,
    DSKF10KeyCode,
    DSKF11KeyCode,
    DSKF12KeyCode,
    // modifier
    DSKLeftAltKeyCode,
    DSKRightAltKeyCode,
    DSKLeftCtrlKeyCode,
    DSKRightCtrlKeyCode,
    DSKLeftShiftKeyCode,
    DSKRightShiftKeyCode,
    DSKCapsLockKeyCode,
    DSKScrollLockKeyCode,
    DSKNumLockKeyCode,
    // whitespace
    DSKTabKeyCode,
    DSKBackspaceKeyCode,
    DSKEnterKeyCode,
    DSKSpaceKeyCode,
    // other
    DSKEscKeyCode,
    DSKGraveKeyCode,
    DSKMinusKeyCode,
    DSKEqualsKeyCode,
    DSKBackslashKeyCode,
    DSKLeftBracketKeyCode,
    DSKRightBracketKeyCode,
    DSKSemicolonKeyCode,
    DSKQuoteKeyCode,
    DSKPeriodKeyCode,
    DSKCommaKeyCode,
    DSKSlashKeyCode,
    DSKPrintScreenKeyCode,
    DSKPauseKeyCode,
    DSKInsertKeyCode,
    DSKHomeKeyCode,
    DSKPageUpKeyCode,
    DSKDeleteKeyCode,
    DSKEndKeyCode,
    DSKPageDownKeyCode,
    DSKLeftArrowKeyCode,
    DSKUpArrowKeyCode,
    DSKDownArrowKeyCode,
    DSKRightArrowKeyCode,
    // keypad
    DSKKeypad1KeyCode,
    DSKKeypad2KeyCode,
    DSKKeypad3KeyCode,
    DSKKeypad4KeyCode,
    DSKKeypad5KeyCode,
    DSKKeypad6KeyCode,
    DSKKeypad7KeyCode,
    DSKKeypad8KeyCode,
    DSKKeypad9KeyCode,
    DSKKeypad0KeyCode,
    DSKKeypadDivideKeyCode,
    DSKKeypadMultiplyKeyCode,
    DSKKeypadMinusKeyCode,
    DSKKeypadPlusKeyCode,
    DSKKeypadEnterKeyCode,
    DSKKeypadPeriodKeyCode,
    
    DSKUnknownKeyCode,
    DSKLastKeyCode,
};

typedef NS_OPTIONS(NSUInteger, DSKKeyModifier) {
    DSKNoKeyModifier         = 0,
    // shift
    DSKLShiftKeyModifier     = 1 << 0,
    DSKRShiftKeyModifier     = 1 << 1,
    DSKShiftKeyModifier      = (DSKLShiftKeyModifier | DSKRShiftKeyModifier),
    // ctrl
    DSKLCtrlKeyModifier      = 1 << 2,
    DSKRCtrlKeyModifier      = 1 << 3,
    DSKCtrlKeyModifier       = (DSKLCtrlKeyModifier | DSKRCtrlKeyModifier),
    // alt
    DSKLAltKeyModifier       = 1 << 4,
    DSKRAltKeyModifier       = 1 << 5,
    DSKAltKeyModifier        = (DSKLAltKeyModifier | DSKRAltKeyModifier),
    // locks
    DSKCapsLockKeyModifier   = 1 << 6,
    DSKScrollLockKeyModifier = 1 << 7,
    DSKNumLockKeyModifier    = 1 << 8,
};

typedef struct {
    DSKKeyCode code;
    DSKKeyModifier modifier;
    unichar character;
} DSKKey;

extern DSKKey DSKKeyFromCharacter(unichar character);

DSK_INLINE DSKKey DSKKeyMake(DSKKeyCode code, DSKKeyModifier modifier, unichar character) {
    DSKKey pair;
    pair.code = code;
    pair.modifier = modifier;
    pair.character = character;
    return pair;
}

@interface NSValue (DSKKey)

+ (id)valueWithKey:(DSKKey)keyPair;
- (DSKKey)keyPairValue;

@end

@class DSKEmulator, DSKKeyboard;

@protocol DSKKeyboardDelegate <NSObject>

- (void)keyPressed:(DSKKey)key fromKeyboard:(DSKKeyboard *)keyboard;
- (void)keyReleased:(DSKKey)key fromKeyboard:(DSKKeyboard *)keyboard;

@end

@interface DSKKeyboard : NSObject

@property (weak, readwrite) id <DSKKeyboardDelegate> delegate;
@property (readonly) DSKKeyModifier modifiers;

- (instancetype)initWithEmulator:(DSKEmulator *)emulator;

- (BOOL)keyPressed:(DSKKey)key;
- (BOOL)keyCodePressed:(DSKKeyCode)keyCode;
- (BOOL)modifiersActive:(DSKKeyModifier)modifiers;

- (void)setKey:(DSKKeyCode)key pressed:(BOOL)pressed;
- (void)pressKey:(DSKKeyCode)key;
- (void)pressKey:(DSKKeyCode)key forDuration:(NSTimeInterval)duration;

- (void)setCharacter:(unichar)character pressed:(BOOL)pressed;
- (void)pressCharacter:(unichar)character;
- (void)pressCharacter:(unichar)character forDuration:(NSTimeInterval)duration;

@end