//
//  NetworkModel.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEF_APP_VER     @"1.0"


@interface DataCenter : NSObject

+(instancetype)sharedDataCenter;

#pragma mark - LOGIN
// 记录是否为登陆状态
@property (nonatomic) BOOL isLogin;
// 玩家信息包括姓名邮箱等级ID等
@property (nonatomic, assign) NSMutableDictionary* loginInfoDic;
// SESSION信息
@property (nonatomic, assign) NSMutableDictionary* sessionDic;
// 玩家信息初始化
-(void)initLoginInfo;
// 写入登录信息
-(void)writeLoginInfo:(NSDictionary*)loginDic;
// 修改登录信息某个值
-(void)editLoginInfo:(id)value forKey:(NSString *)key;
// 写入session信息
-(void)writeSessionInfo:(NSDictionary*)sessDic;
// 玩家信息写文件
-(void)synchronizeLoginData;
// 验证SESSION信息失败清除存储
-(void)removeLoginData;

#pragma mark - ORDER
@property (nonatomic, retain) NSMutableDictionary* orderCheckListDefaultDic;        // checkorder时服务器下发的地址信息
@property (nonatomic, retain) NSMutableDictionary* orderCheckListSelectDic;         // 用户选择的配送方式发票信息等
@property (nonatomic, retain) NSMutableDictionary* orderDoneResultDic;              // 用户提交订单成功后返回的结果
// 每次初始化订单checkout界面时清空订单的选择项
- (void)removeOrderSelectDicDatas;


@end

