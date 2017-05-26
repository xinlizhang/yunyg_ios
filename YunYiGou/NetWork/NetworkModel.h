//
//  NetworkModel.h
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModel : NSObject
+(instancetype)sharedNetworkModel;

// ------ 版本更新检测
-(void)request_CheckUpdate_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;

// ------ session验证
-(void)request_Session_Verify_Datasuc;

// ------ 首页的协议
-(void)request_HomeData_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_Home_CatecoryDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;

// ------ 商品列表的协议
-(void)request_List_LimitPromotionDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort;
-(void)request_List_HotGoodsDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort;
-(void)request_List_RecommendDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort;
-(void)request_List_NewArrivalDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort;
-(void)request_List_CatecoryDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort categoryID:(NSInteger)categoryID;

// ------ 商品详情协议
-(void)request_GoodsDetail_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID;
-(void)request_GoodsDescription_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID;

// ------ 商品评论协议
-(void)request_CommentList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count goodsID:(int)goodsID;
-(void)request_CommentAdd_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID content:(NSString*)content commentRank:(int)commentRank;


// ------ 购物车
-(void)request_AddToCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID goodsNum:(int)goodsNum specArray:(NSArray*)specArray;
-(void)request_Cart_List_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_UpdateCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cartID:(int)cartID goodsNum:(int)goodsNum;
-(void)request_DelToCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cartID:(int)cartID;

// ------ 加入收藏
-(void)request_AddToCollect_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID;

// ------ 分类协议 包括一二级分类
-(void)request_Catecory_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cateType:(NSString*)cateType;

// ------ 搜索协议
-(void)request_Search_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort keywords:(NSString*)keywords;

// ------ 订单协议
-(void)request_CheckOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_DoneOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_CancelOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID;
-(void)request_PayOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID;
-(void)request_OrderList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count type:(NSString*)type;
-(void)request_OderDetail_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID;
-(void)request_AffirmReceived_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID;
-(void)request_Express_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID;

// ------ 地址协议
-(void)request_GetAddrList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_AddrAdd_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrDic:(NSDictionary*)addrDic;
-(void)request_AddrUpdate_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrID:(int)addrID addrDic:(NSDictionary*)addrDic;
-(void)request_AddrDel_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrID:(int)addrID;
-(void)request_Region_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure parentID:(int)parentID;
-(void)request_AddrSetDefault_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addressID:(int)addressID;

// ------ 帮助协议
-(void)request_ShowHelp_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_Article_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure articleID:(NSString*)articleID;

// ------ 收藏协议
-(void)request_Collect_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count;
-(void)request_CollectDel_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure collectID:(NSString*)collectID;

// ------ 注册登录协议
-(void)request_RegisterFields_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_Register_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure account:(NSString*)account email:(NSString*)email password:(NSString*)password fieldArray:(NSArray*)fieldArray;
-(void)request_Login_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure account:(NSString*)account password:(NSString*)password;
-(void)request_Logout_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
-(void)request_EditInfo_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure dataDic:(NSDictionary*)dataDic;


@end
