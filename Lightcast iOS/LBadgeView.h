//
//  LBadgeView.h
//  Lightcast
//
//  Created by Martin N. Kovachev on 23.01.13.
//  Copyright (c) 2013 г. Nimasystems Ltd. All rights reserved.
//

#import <Lightcast/Lightcast.h>

@class LBadgeView;

@protocol LBadgeViewDelegate <NSObject>

@optional

- (void)viewTouched:(LBadgeView*)view;

@end

extern CGFloat const kLBadgeViewDefaultCornerRadius;
extern CGFloat const kLBadgeViewDefaultTextPadding;
extern CGFloat const kLBadgeViewDefaultBorderWidth;
extern CGFloat const kLBadgeViewDefaultBorderWidthIOS7;
extern NSString *const kLBadgeViewDefaultFontName;
extern CGFloat const kLBadgeViewDefaultFontSize;
extern CGFloat const kLBadgeViewDefaultShadowOffset;

@interface LBadgeView : LView

@property (nonatomic, copy, setter = setValue:) NSString *value;

@property (nonatomic, retain, setter = setFont:) UIFont *font;
@property (nonatomic, retain, setter = setBackgroundColor:) UIColor *backgroundColor;
@property (nonatomic, retain, setter = setBorderColor:) UIColor *borderColor;
@property (nonatomic, retain, setter = setTextColor:) UIColor *textColor;
@property (nonatomic, assign, setter = setBorderWidth:) CGFloat borderWidth;
@property (nonatomic, assign, setter = setCornerRadius:) CGFloat cornerRadius;

@property (nonatomic, assign) CGFloat textPaddingX;
@property (nonatomic, assign) CGFloat textPaddingY;

@property (assign) id<LBadgeViewDelegate> delegate;

@end
