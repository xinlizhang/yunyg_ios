//
//  NetworkModel.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "Utils.h"

static Utils * utilsInstance;

@implementation Utils

+ (float) heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    UITextView *detailTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    detailTextView.font = [UIFont systemFontOfSize:fontSize];
    detailTextView.text = value;
    CGSize deSize = [detailTextView sizeThatFits:CGSizeMake(width,CGFLOAT_MAX)];
    return deSize.height;
}

+ (float) widthForString:(NSString *)value fontSize:(float)fontSize
{
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:value];
    
    NSRange allRange = [value rangeOfString:value];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:allRange];

    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, fontSize+1) options:options context:nil];

    return ceilf(rect.size.width);
}

@end


