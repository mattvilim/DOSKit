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

#import "DSKView.h"

#import "DSKGLView.h"
#import "DSKEmulator.h"
#import "DSKKeyboard.h"
#import "DSKMouse.h"
#import "_DSKDrawingTypes.h"
#import "DSKFileSystem.h"

#import "DSKShell.h"

@interface DSKView ()

@property (readwrite, nonatomic) DSKGLView *glView;
@property (readwrite, nonatomic) UITapGestureRecognizer *tapGesture;
@property (readwrite, nonatomic) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation DSKView

@synthesize autocapitalizationType = _autocapitalizationType;
@synthesize autocorrectionType = _autocorrectionType;
@synthesize spellCheckingType = _spellCheckingType;
@synthesize keyboardType = _keyboardType;
@synthesize keyboardAppearance = _keyboardAppearance;
@synthesize returnKeyType = _returnKeyType;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _commonInit];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentSize = self.glView.bounds.size;
}

- (void)_commonInit {
    _glView = [[DSKGLView alloc] initWithFrame:self.bounds];
    _glView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_glView];
    
    self.backgroundColor = [UIColor blackColor];
    self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowOrHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // TESTING
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:_tapGesture];
    [self addGestureRecognizer:_longPressGesture];
    
    // UIKeyInput
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;
    self.keyboardType = UIKeyboardTypeASCIICapable;
    self.keyboardAppearance = UIKeyboardAppearanceDark;
    self.returnKeyType = UIReturnKeyDefault;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets;
    CGPoint contentOffset;
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect keyboardRect = [self convertRect:[notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];;
        contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, keyboardRect.size.height, 0.0f);
        contentOffset = CGPointMake(0.0f, keyboardRect.size.height);
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        contentInsets = UIEdgeInsetsZero;
        contentOffset = CGPointZero;
    }
    
    [UIView animateWithDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                          delay:0.0
                        options:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16
                     animations:^{
                         self.contentInset = self.scrollIndicatorInsets = contentInsets;
                         self.contentOffset = contentOffset;
                     }
                     completion:NULL];
    NSLog(@"%@", NSStringFromCGSize(self.bounds.size));
}

#pragma mark UIResponder
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(paste:) ? YES : NO;
}

- (void)paste:(id)sender {
    [self.emulator.keyboard typeText:[UIPasteboard generalPasteboard].string];
}

#pragma mark UITouches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    [self.emulator.mouse applyMousePointerMovementTo:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    [self.emulator.mouse applyMousePointerMovementTo:point];
}

#pragma mark UIKeyInput

- (void)tap:(UITapGestureRecognizer *)tapGesture {
   // [self.emulator.shell changeDrive:DSKCDriveLetter];
    [self.emulator.shell executeProgram:@"FIRE" withArgs:NULL];
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    } else {
        [self resignFirstResponder];
    }
    if (tapGesture.numberOfTouches == 1) {
        return [self.emulator.mouse leftMouseButtonSingleClick];
    }
    if (tapGesture.numberOfTouches == 2) {
        return [self.emulator.mouse rightMouseButtonSingleClick];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)longPressGesture {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:CGRectMake(100, 100, 100, 100) inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)hasText {
    return NO;
}

- (void)insertText:(NSString *)text {
    [self.emulator.keyboard pressCharacter:[text characterAtIndex:0]];
}

- (void)deleteBackward {
    [self.emulator.keyboard pressKey:DSKBackspaceKeyCode];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
