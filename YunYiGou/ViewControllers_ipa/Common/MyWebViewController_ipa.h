//
//  GoodsListViewController_ipa.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController_ipa.h"


@interface MyWebViewController_ipa : BasicViewController_ipa<UIWebViewDelegate>


-(void)loadHTMLString:(NSString*)string;

@end

