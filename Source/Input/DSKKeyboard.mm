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

#import "DSKKeyboard.h"
#import "DSKEmulatorInternal.h"

#import <DOSBox/control.h>
#import <DOSBox/keyboard.h>

NSString * const DSKKeyboardPressedNotification = @"DSKKeyboardPressedNotification";
NSString * const DSKKeyboardReleasedNotification = @"DSKKeyboardReleasedNotification";
NSString * const DSKKeyUserInfo= @"DSKKeyUserInfo";

// some games poll instead of reading straight from the keyboard buffer, so we need to hold for a time
static const NSTimeInterval DSKKeyHoldDuration = 0.1;

static KBD_KEYS _keyFromKeyCode(DSKKeyCode keyCode);

DSKKey DSKKeyFromCharacter(unichar character) {
    DSKKeyCode code;
    DSKKeyModifier modifier;
    switch (character) {
            // lowercase letters
        case 'a': code = DSKAKeyCode; modifier = DSKNoKeyModifier; break;
        case 'b': code = DSKBKeyCode; modifier = DSKNoKeyModifier; break;
        case 'c': code = DSKCKeyCode; modifier = DSKNoKeyModifier; break;
        case 'd': code = DSKDKeyCode; modifier = DSKNoKeyModifier; break;
        case 'e': code = DSKEKeyCode; modifier = DSKNoKeyModifier; break;
        case 'f': code = DSKFKeyCode; modifier = DSKNoKeyModifier; break;
        case 'g': code = DSKGKeyCode; modifier = DSKNoKeyModifier; break;
        case 'h': code = DSKHKeyCode; modifier = DSKNoKeyModifier; break;
        case 'i': code = DSKIKeyCode; modifier = DSKNoKeyModifier; break;
        case 'j': code = DSKJKeyCode; modifier = DSKNoKeyModifier; break;
        case 'k': code = DSKKKeyCode; modifier = DSKNoKeyModifier; break;
        case 'l': code = DSKLKeyCode; modifier = DSKNoKeyModifier; break;
        case 'm': code = DSKMKeyCode; modifier = DSKNoKeyModifier; break;
        case 'n': code = DSKNKeyCode; modifier = DSKNoKeyModifier; break;
        case 'o': code = DSKOKeyCode; modifier = DSKNoKeyModifier; break;
        case 'p': code = DSKPKeyCode; modifier = DSKNoKeyModifier; break;
        case 'q': code = DSKQKeyCode; modifier = DSKNoKeyModifier; break;
        case 'r': code = DSKRKeyCode; modifier = DSKNoKeyModifier; break;
        case 's': code = DSKSKeyCode; modifier = DSKNoKeyModifier; break;
        case 't': code = DSKTKeyCode; modifier = DSKNoKeyModifier; break;
        case 'u': code = DSKUKeyCode; modifier = DSKNoKeyModifier; break;
        case 'v': code = DSKVKeyCode; modifier = DSKNoKeyModifier; break;
        case 'w': code = DSKWKeyCode; modifier = DSKNoKeyModifier; break;
        case 'x': code = DSKXKeyCode; modifier = DSKNoKeyModifier; break;
        case 'y': code = DSKYKeyCode; modifier = DSKNoKeyModifier; break;
        case 'z': code = DSKZKeyCode; modifier = DSKNoKeyModifier; break;
            // uppercase letters
        case 'A': code = DSKAKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'B': code = DSKBKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'C': code = DSKCKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'D': code = DSKDKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'E': code = DSKEKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'F': code = DSKFKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'G': code = DSKGKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'H': code = DSKHKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'I': code = DSKIKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'J': code = DSKJKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'K': code = DSKKKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'L': code = DSKLKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'M': code = DSKMKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'N': code = DSKNKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'O': code = DSKOKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'P': code = DSKPKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'Q': code = DSKQKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'R': code = DSKRKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'S': code = DSKSKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'T': code = DSKTKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'U': code = DSKUKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'V': code = DSKVKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'W': code = DSKWKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'X': code = DSKXKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'Y': code = DSKYKeyCode; modifier = DSKShiftKeyModifier; break;
        case 'Z': code = DSKZKeyCode; modifier = DSKShiftKeyModifier; break;
            // lowercase numbers
        case '1': code = DSK1KeyCode; modifier = DSKNoKeyModifier; break;
        case '2': code = DSK2KeyCode; modifier = DSKNoKeyModifier; break;
        case '3': code = DSK3KeyCode; modifier = DSKNoKeyModifier; break;
        case '4': code = DSK4KeyCode; modifier = DSKNoKeyModifier; break;
        case '5': code = DSK5KeyCode; modifier = DSKNoKeyModifier; break;
        case '6': code = DSK6KeyCode; modifier = DSKNoKeyModifier; break;
        case '7': code = DSK7KeyCode; modifier = DSKNoKeyModifier; break;
        case '8': code = DSK8KeyCode; modifier = DSKNoKeyModifier; break;
        case '9': code = DSK9KeyCode; modifier = DSKNoKeyModifier; break;
        case '0': code = DSK0KeyCode; modifier = DSKNoKeyModifier; break;
            // uppercase numbers
        case '!': code = DSK1KeyCode; modifier = DSKShiftKeyModifier; break;
        case '@': code = DSK2KeyCode; modifier = DSKShiftKeyModifier; break;
        case '#': code = DSK3KeyCode; modifier = DSKShiftKeyModifier; break;
        case '$': code = DSK4KeyCode; modifier = DSKShiftKeyModifier; break;
        case '%': code = DSK5KeyCode; modifier = DSKShiftKeyModifier; break;
        case '^': code = DSK6KeyCode; modifier = DSKShiftKeyModifier; break;
        case '&': code = DSK7KeyCode; modifier = DSKShiftKeyModifier; break;
        case '*': code = DSK8KeyCode; modifier = DSKShiftKeyModifier; break;
        case '(': code = DSK9KeyCode; modifier = DSKShiftKeyModifier; break;
        case ')': code = DSK0KeyCode; modifier = DSKShiftKeyModifier; break;
            // whitespace
        case '\t': code = DSKTabKeyCode; modifier = DSKNoKeyModifier; break;
        case '\b': code = DSKBackspaceKeyCode; modifier = DSKNoKeyModifier; break;
        case '\n': code = DSKEnterKeyCode; modifier = DSKNoKeyModifier; break;
        case ' ': code = DSKSpaceKeyCode; modifier = DSKNoKeyModifier; break;
            // lowercase other
        case '`': code = DSKGraveKeyCode; modifier = DSKNoKeyModifier; break;
        case '-': code = DSKMinusKeyCode; modifier = DSKNoKeyModifier; break;
        case '=': code = DSKEqualsKeyCode; modifier = DSKNoKeyModifier; break;
        case '\\': code = DSKBackslashKeyCode; modifier = DSKNoKeyModifier; break;
        case '[': code = DSKLeftBracketKeyCode; modifier = DSKNoKeyModifier; break;
        case ']': code = DSKRightBracketKeyCode; modifier = DSKNoKeyModifier; break;
        case ';': code = DSKSemicolonKeyCode; modifier = DSKNoKeyModifier; break;
        case '\'': code = DSKQuoteKeyCode; modifier = DSKNoKeyModifier; break;
        case '.': code = DSKPeriodKeyCode; modifier = DSKNoKeyModifier; break;
        case ',': code = DSKCommaKeyCode; modifier = DSKNoKeyModifier; break;
        case '/': code = DSKSlashKeyCode; modifier = DSKNoKeyModifier; break;
            // uppercase other
        case '~': code = DSKGraveKeyCode; modifier = DSKShiftKeyModifier; break;
        case '_': code = DSKMinusKeyCode; modifier = DSKShiftKeyModifier; break;
        case '+': code = DSKEqualsKeyCode; modifier = DSKShiftKeyModifier; break;
        case '|': code = DSKBackslashKeyCode; modifier = DSKShiftKeyModifier; break;
        case '{': code = DSKLeftBracketKeyCode; modifier = DSKShiftKeyModifier; break;
        case '}': code = DSKRightBracketKeyCode; modifier = DSKShiftKeyModifier; break;
        case ':': code = DSKSemicolonKeyCode; modifier = DSKShiftKeyModifier; break;
        case '\"': code = DSKQuoteKeyCode; modifier = DSKShiftKeyModifier; break;
        case '>': code = DSKPeriodKeyCode; modifier = DSKShiftKeyModifier; break;
        case '<': code = DSKCommaKeyCode; modifier = DSKShiftKeyModifier; break;
        case '?': code = DSKSlashKeyCode; modifier = DSKShiftKeyModifier; break;
        default: code = DSKUnknownKeyCode; modifier = DSKNoKeyModifier; break;
    }
    return DSKKeyMake(code, modifier, character);
}

KBD_KEYS _keyFromKeyCode(DSKKeyCode keyCode) {
    // letters
    switch (keyCode) {
        case DSKAKeyCode: return KBD_a;
        case DSKBKeyCode: return KBD_b;
        case DSKCKeyCode: return KBD_c;
        case DSKDKeyCode: return KBD_d;
        case DSKEKeyCode: return KBD_e;
        case DSKFKeyCode: return KBD_f;
        case DSKGKeyCode: return KBD_g;
        case DSKHKeyCode: return KBD_h;
        case DSKIKeyCode: return KBD_i;
        case DSKJKeyCode: return KBD_j;
        case DSKKKeyCode: return KBD_k;
        case DSKLKeyCode: return KBD_l;
        case DSKMKeyCode: return KBD_m;
        case DSKNKeyCode: return KBD_n;
        case DSKOKeyCode: return KBD_o;
        case DSKPKeyCode: return KBD_p;
        case DSKQKeyCode: return KBD_q;
        case DSKRKeyCode: return KBD_r;
        case DSKSKeyCode: return KBD_s;
        case DSKTKeyCode: return KBD_t;
        case DSKUKeyCode: return KBD_u;
        case DSKVKeyCode: return KBD_v;
        case DSKWKeyCode: return KBD_w;
        case DSKXKeyCode: return KBD_x;
        case DSKYKeyCode: return KBD_y;
        case DSKZKeyCode: return KBD_z;
            // number
        case DSK1KeyCode: return KBD_1;
        case DSK2KeyCode: return KBD_2;
        case DSK3KeyCode: return KBD_3;
        case DSK4KeyCode: return KBD_4;
        case DSK5KeyCode: return KBD_5;
        case DSK6KeyCode: return KBD_6;
        case DSK7KeyCode: return KBD_7;
        case DSK8KeyCode: return KBD_8;
        case DSK9KeyCode: return KBD_9;
        case DSK0KeyCode: return KBD_0;
            // function
        case DSKF1KeyCode: return KBD_f1;
        case DSKF2KeyCode: return KBD_f2;
        case DSKF3KeyCode: return KBD_f3;
        case DSKF4KeyCode: return KBD_f4;
        case DSKF5KeyCode: return KBD_f5;
        case DSKF6KeyCode: return KBD_f6;
        case DSKF7KeyCode: return KBD_f7;
        case DSKF8KeyCode: return KBD_f8;
        case DSKF9KeyCode: return KBD_f9;
        case DSKF10KeyCode: return KBD_f10;
        case DSKF11KeyCode: return KBD_f11;
        case DSKF12KeyCode: return KBD_f12;
            // modifier
        case DSKLeftAltKeyCode: return KBD_leftalt;
        case DSKRightAltKeyCode: return KBD_rightalt;
        case DSKLeftCtrlKeyCode: return KBD_leftctrl;
        case DSKRightCtrlKeyCode: return KBD_rightctrl;
        case DSKLeftShiftKeyCode: return KBD_leftshift;
        case DSKRightShiftKeyCode: return KBD_rightshift;
        case DSKCapsLockKeyCode: return KBD_capslock;
        case DSKScrollLockKeyCode: return KBD_scrolllock;
        case DSKNumLockKeyCode: return KBD_numlock;
            // whitespace
        case DSKTabKeyCode: return KBD_tab;
        case DSKBackspaceKeyCode: return KBD_backspace;
        case DSKEnterKeyCode: return KBD_enter;
        case DSKSpaceKeyCode: return KBD_space;
            // other
        case DSKEscKeyCode: return KBD_esc;
        case DSKGraveKeyCode: return KBD_grave;
        case DSKMinusKeyCode: return KBD_minus;
        case DSKEqualsKeyCode: return KBD_equals;
        case DSKBackslashKeyCode: return KBD_backslash;
        case DSKLeftBracketKeyCode: return KBD_leftbracket;
        case DSKRightBracketKeyCode: return KBD_rightbracket;
        case DSKSemicolonKeyCode: return KBD_semicolon;
        case DSKQuoteKeyCode: return KBD_quote;
        case DSKPeriodKeyCode: return KBD_period;
        case DSKCommaKeyCode: return KBD_comma;
        case DSKSlashKeyCode: return KBD_slash;
        case DSKPrintScreenKeyCode: return KBD_printscreen;
        case DSKPauseKeyCode: return KBD_pause;
        case DSKInsertKeyCode: return KBD_insert;
        case DSKHomeKeyCode: return KBD_home;
        case DSKPageUpKeyCode: return KBD_pageup;
        case DSKDeleteKeyCode: return KBD_delete;
        case DSKEndKeyCode: return KBD_end;
        case DSKPageDownKeyCode: return KBD_pagedown;
        case DSKLeftArrowKeyCode: return KBD_left;
        case DSKUpArrowKeyCode: return KBD_up;
        case DSKDownArrowKeyCode: return KBD_down;
        case DSKRightArrowKeyCode: return KBD_right;
            // keypad
        case DSKKeypad1KeyCode: return KBD_kp1;
        case DSKKeypad2KeyCode: return KBD_kp2;
        case DSKKeypad3KeyCode: return KBD_kp3;
        case DSKKeypad4KeyCode: return KBD_kp4;
        case DSKKeypad5KeyCode: return KBD_kp5;
        case DSKKeypad6KeyCode: return KBD_kp6;
        case DSKKeypad7KeyCode: return KBD_kp7;
        case DSKKeypad8KeyCode: return KBD_kp8;
        case DSKKeypad9KeyCode: return KBD_kp9;
        case DSKKeypad0KeyCode: return KBD_kp0;
        case DSKKeypadDivideKeyCode: return KBD_kpdivide;
        case DSKKeypadMultiplyKeyCode: return KBD_kpmultiply;
        case DSKKeypadMinusKeyCode: return KBD_kpminus;
        case DSKKeypadPlusKeyCode: return KBD_kpplus;
        case DSKKeypadEnterKeyCode: return KBD_kpenter;
        case DSKKeypadPeriodKeyCode: return KBD_kpperiod;
            
        case DSKUnknownKeyCode: return KBD_NONE;
        case DSKLastKeyCode: return KBD_LAST;
    }
    
}

@implementation NSValue (DSKKey)

+ (id)valueWithKey:(DSKKey)keyPair {
    return [NSValue value:&keyPair withObjCType:@encode(DSKKey)];
}

- (DSKKey)keyPairValue {
    DSKKey keyPair;
    [self getValue:&keyPair];
    return keyPair;
}

@end

@interface DSKKeyboard () {
    BOOL _keyPressed[DSKLastKeyCode];
}

@property (weak, readwrite) DSKEmulator *emulator;
@property (readwrite) DSKKeyModifier modifiers;

- (void)_postNotification:(NSString *)name forKey:(DSKKey)key;

@end

@implementation DSKKeyboard

- (instancetype)initWithEmulator:(DSKEmulator *)emulator {
    if (self = [super init]) {
        _emulator = emulator;
        _modifiers = DSKNoKeyModifier;
    }
    return self;
}

- (BOOL)keyPressed:(DSKKey)key {
        return [self keyCodePressed:key.code] && [self modifiersActive:DSKShiftKeyModifier] == (key.modifier & DSKShiftKeyModifier);
}

- (BOOL)keyCodePressed:(DSKKeyCode)keyCode {
    return _keyPressed[keyCode];
}

- (BOOL)modifiersActive:(DSKKeyModifier)modifiers {
    return self.modifiers & modifiers;
}

- (void)_postNotification:(NSString *)name forKey:(DSKKey)key {
    if (name == DSKKeyboardPressedNotification) {
        [self.delegate keyPressed:key fromKeyboard:self];
    } else if (name == DSKKeyboardReleasedNotification) {
        [self.delegate keyReleased:key fromKeyboard:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:@{DSKKeyUserInfo: [NSValue valueWithKey:key]}];
}

- (void)setCharacter:(unichar)character pressed:(BOOL)pressed {
    DSKKey key = DSKKeyFromCharacter(character);
    if (key.modifier & DSKShiftKeyModifier) {
        [self setKey:DSKLeftShiftKeyCode pressed:pressed];
    }
    [self setKey:key.code pressed:pressed];
}

- (void)pressCharacter:(unichar)character {
    [self pressCharacter:character forDuration:DSKKeyHoldDuration];
}

- (void)pressCharacter:(unichar)character forDuration:(NSTimeInterval)duration {
    [self setCharacter:character pressed:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self setCharacter:character pressed:NO];
    });
}

- (void)setKey:(DSKKeyCode)key pressed:(BOOL)pressed {
    /*
     * keys from iOS keyboard passed here may be non-ascii unicode characters which will crash DOSBox
     * we also need to avoid pushing consecutive key presses or releases into the buffer which could never happen
     * with a physical keyboard
     * we shouldn't tamper with the key buffer while paused because the keys will be read on resume
     */
    if (key != DSKUnknownKeyCode && _keyPressed[key] != pressed && !self.emulator.paused) {
        _keyPressed[key] = pressed;
        pthread_mutex_lock(self.emulator.eventMutex);
        KEYBOARD_AddKey(_keyFromKeyCode(key), pressed);
        pthread_mutex_unlock(self.emulator.eventMutex);
    }
}

- (void)pressKey:(DSKKeyCode)key {
    [self pressKey:key forDuration:DSKKeyHoldDuration];
}

- (void)pressKey:(DSKKeyCode)key forDuration:(NSTimeInterval)duration {
    [self setKey:key pressed:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self setKey:key pressed:NO];
    });
}

@end