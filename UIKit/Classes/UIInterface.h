/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIColor.h"
#import "UIFont.h"


typedef enum {
    UIBarStyleDefault = 0,
    UIBarStyleBlack = 1,
    UIBarStyleBlackOpaque = 1, // Deprecated
    UIBarStyleBlackTranslucent = 2 // Deprecated
} UIBarStyle;


@interface UIColor (UIColorSystemColors)
+ (UIColor *)lightTextColor;                // for a dark background
+ (UIColor *)darkTextColor;                 // for a light background

// Group style table view backgrounds can no longer be represented by a simple color.
// If you want to have a background in your own view that looks like the table view background,
// then you should create an empty table view and place it behind your content.
+ (UIColor *)groupTableViewBackgroundColor; // This method will be deprecated during the 6.0 seed program

+ (UIColor *)viewFlipsideBackgroundColor;
+ (UIColor *)scrollViewTexturedBackgroundColor;
+ (UIColor *)underPageBackgroundColor;

@end


@interface UIFont (UIFontSystemFonts)
+ (CGFloat)systemFontSize;
+ (CGFloat)smallSystemFontSize;
+ (CGFloat)labelFontSize;
+ (CGFloat)buttonFontSize;
@end
