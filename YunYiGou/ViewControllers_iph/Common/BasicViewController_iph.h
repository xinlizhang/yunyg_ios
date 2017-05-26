//
//  BasicViewController_iph.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "DataCenter.h"
#import "NetworkModel.h"
#import "MyNetLoading.h"

@interface BasicViewController_iph : UIViewController

@property (nonatomic,strong) NSString* strClickedName;              // 首页点击条目的名称 用于首页跳转到商品列表
@property (nonatomic) NSInteger iIDClicked;                         // 首页点击条目的ID（包括分类ID和商品ID）

@property (nonatomic,strong) NSString* strSearchKey;                // 首页输入的搜索关键字 用于点击搜索跳转

@property (nonatomic) int iGoodsIDClicked;                          // 商品ID 用于列表点击某条跳转到商品详情界面

@property (nonatomic) int iGoodsID2Info;                            // 商品ID 用于详情到信息界面

@property (nonatomic,strong) NSString* strURL;                      // web打开的URL

@property (nonatomic,strong) NSMutableDictionary* editAddrDic;      // 要修改的地址 如果为空即为创建新地址

@property (nonatomic,strong) NSString* orderType;                   // 拉取订单列表的类型 "await_pay":待付款 "await_ship":待发货 "shipped":已发货 "finished":已完成

@property (nonatomic,strong) NSString* strArticleID2Info;           // 文章ID 帮助到文章详情界面

@end
