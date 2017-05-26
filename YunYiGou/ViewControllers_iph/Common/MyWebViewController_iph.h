//
//  GoodsListViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController_iph.h"


@interface MyWebViewController_iph : BasicViewController_iph<UIWebViewDelegate>


-(void)loadHTMLString:(NSString*)string;

@end

