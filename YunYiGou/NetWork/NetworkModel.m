//
//  NetworkModel.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "NetworkModel.h"
#import "AFNetworking.h"
#import "PublicDefine.h"
#import "DataCenter.h"
#import "MyAlert.h"

static NetworkModel * networkInstance;

@implementation NetworkModel
+(instancetype)sharedNetworkModel
{
    if (networkInstance == nil) {
        networkInstance = [[NetworkModel alloc] init];
    }
    return networkInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


#pragma mark - inner use function

-(void)getRequest:(NSString *)url
       parameters:(id)parameters
          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:parameters success:success failure:failure];
}

-(void)postRequest:(NSString *)url
        parameters:(id)parameters
           success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
           failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:parameters success:success failure:failure];
}


#pragma mark - export interfaceß

#pragma mark - checkout
-(void)request_CheckUpdate_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure;
{
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:DEF_APP_VER forKey:@"client_version"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/check_update"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicJson release];
}

-(void)request_Session_Verify_Datasuc
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* sessionData = [[NSDictionary alloc] initWithDictionary:sessionDic];
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:sessionData forKey:@"session"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/info"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  // 数据持久化
                  if (responseObject[@"status"])
                  {
                      if ( [[responseObject[@"status"] valueForKey:@"succeed"] intValue] == 1 )
                      {
                          [DataCenter sharedDataCenter].isLogin = true;
                          [[DataCenter sharedDataCenter] writeLoginInfo:responseObject[@"data"]];
                          [[DataCenter sharedDataCenter] synchronizeLoginData];
                          
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowCartCount" object:nil];
                      }
                      else if( [[responseObject[@"status"] valueForKey:@"error_code"] intValue] == 100 )
                      {
                          [[DataCenter sharedDataCenter] removeLoginData];
                          
                          [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
                      }
                      else
                      {
                          [[DataCenter sharedDataCenter] removeLoginData];
                          
                          UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                          [alter show];
                          [alter release];
                      }
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
    
    [dicJson release];
}



#pragma mark - home
-(void)request_HomeData_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/home/data"];
    [self getRequest:url
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
}

-(void)request_Home_CatecoryDatasuc:(void (^)(id))success fail:(void (^)(NSError *))failure
{
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/home/category"];
    [self getRequest:url
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
}


#pragma mark - Goods List
-(void)request_List_LimitPromotionDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort
{
    //NSDictionary *dict = @{ @"json" : @{ @"pagination" : @{ @"page" : @"1", @"count" : @"100" }, @"sort_by" : @"default" } };
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setValue:sort forKey:@"sort_by"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/list/promote"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    [dicPage release];
    [dicJson release];
}
-(void)request_List_HotGoodsDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setValue:sort forKey:@"sort_by"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/list/hot"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    [dicPage release];
    [dicJson release];
}
-(void)request_List_RecommendDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setValue:sort forKey:@"sort_by"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/list/best"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    [dicPage release];
    [dicJson release];
}
-(void)request_List_NewArrivalDatasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setValue:sort forKey:@"sort_by"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/list/new"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    [dicPage release];
    [dicJson release];
}

-(void)request_List_CatecoryDatasuc:(void (^)(id success))success fail:(void (^)(NSError *))failure page:(int)page count:(int)count sort:(NSString*)sort categoryID:(NSInteger)categoryID
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary* dicSearchKey = [[NSMutableDictionary alloc] init];
    [dicSearchKey setValue:sort forKey:@"sort_by"];
    [dicSearchKey setValue:[NSString stringWithFormat:@"%ld", categoryID] forKey:@"category_id"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setObject:dicSearchKey forKey:@"filter"];

    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/search"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    [dicPage release];
    [dicJson release];
}


#pragma mark - Goods Detail
-(void)request_GoodsDetail_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID
{
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [DataCenter sharedDataCenter].isLogin && 0 < [sessionDic count] )
    {
        NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
        NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
        [dicJson setObject:dicSession forKey:@"session"];
    }
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/goods"];
    [self postRequest:url
          parameters:dicJson
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
    
    //[dicSession release];
    [dicJson release];
}
-(void)request_GoodsDescription_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID
{
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/goods/desc"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicJson release];
}

#pragma mark - 商品评论列表
-(void)request_CommentList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count goodsID:(int)goodsID
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setObject:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/comment/list"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicPage release];
    [dicJson release];
}

-(void)request_CommentAdd_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID content:(NSString*)content commentRank:(int)commentRank
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    [dicJson setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"name"] forKey:@"user_name"];
    [dicJson setValue:[[DataCenter sharedDataCenter].loginInfoDic objectForKey:@"email"] forKey:@"email"];
    [dicJson setValue:content forKey:@"content"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", commentRank] forKey:@"comment_rank"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/comment/add"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - add to cart
-(void)request_AddToCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID goodsNum:(int)goodsNum specArray:(NSArray*)specArray
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsNum] forKey:@"number"];
    [dicJson setObject:specArray forKey:@"spec"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/cart/create"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}


#pragma mark - cart list
-(void)request_Cart_List_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/cart/list"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - update cart
-(void)request_UpdateCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cartID:(int)cartID goodsNum:(int)goodsNum
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", cartID] forKey:@"rec_id"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsNum] forKey:@"new_number"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/cart/update"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - del to cart
-(void)request_DelToCart_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cartID:(int)cartID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", cartID] forKey:@"rec_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/cart/delete"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - add to collect
-(void)request_AddToCollect_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure goodsID:(int)goodsID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", goodsID] forKey:@"goods_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/collect/create"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - category
-(void)request_Catecory_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure cateType:(NSString*)cateType
{
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:cateType forKey:@"cate_type"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/category"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
}

#pragma mark - search
-(void)request_Search_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count sort:(NSString*)sort keywords:(NSString*)keywords
{
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary* dicSearchKey = [[NSMutableDictionary alloc] init];
    [dicSearchKey setValue:sort forKey:@"sort_by"];
    [dicSearchKey setValue:keywords forKey:@"keywords"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setObject:dicSearchKey forKey:@"filter"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/search"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicPage release];
    [dicJson release];
}

#pragma mark - check order
-(void)request_CheckOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/flow/checkOrder"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - done order
-(void)request_DoneOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    
    NSDictionary* paymentDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"payment_selected"];
    [dicJson setValue:[paymentDic valueForKey:@"pay_id"] forKey:@"pay_id"];

    NSDictionary* shippingDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"shiping_selected"];
    [dicJson setValue:[shippingDic valueForKey:@"shipping_id"] forKey:@"shipping_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/flow/done"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - cancel order
-(void)request_CancelOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:orderID forKeyedSubscript:@"order_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/cancel"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - pay order
-(void)request_PayOrder_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:orderID forKeyedSubscript:@"order_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/pay"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - order list
-(void)request_OrderList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count type:(NSString*)type
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];

    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:dicPage forKey:@"pagination"];
    [dicJson setValue:type forKey:@"type"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/list"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicPage release];
    [dicJson release];
}

#pragma mark - order detail
-(void)request_OderDetail_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:orderID forKey:@"order_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/detail"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - affirm received
-(void)request_AffirmReceived_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:orderID forKey:@"order_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/affirmReceived"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - express
-(void)request_Express_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure orderID:(NSString*)orderID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:orderID forKeyedSubscript:@"order_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/order/express"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - address list
-(void)request_GetAddrList_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/address/list"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - add address
-(void)request_AddrAdd_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrDic:(NSDictionary*)addrDic
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:addrDic forKey:@"address"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/address/add"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - update address
-(void)request_AddrUpdate_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrID:(int)addrID addrDic:(NSDictionary*)addrDic
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", addrID] forKey:@"address_id"];
    [dicJson setObject:addrDic forKey:@"address"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/address/update"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - delete address
-(void)request_AddrDel_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addrID:(int)addrID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", addrID] forKey:@"address_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/address/delete"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - region
-(void)request_Region_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure parentID:(int)parentID
{
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:[NSString stringWithFormat:@"%d", parentID] forKey:@"parent_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/region"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicJson release];
}

#pragma mark - set default address
-(void)request_AddrSetDefault_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure addressID:(int)addressID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
        return;
    
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[NSString stringWithFormat:@"%d", addressID] forKey:@"address_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/address/setDefault"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - help
-(void)request_ShowHelp_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/shopHelp"];
    [self getRequest:url
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
}
#pragma mark - article detail
-(void)request_Article_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure articleID:(NSString*)articleID
{

    NSMutableDictionary* dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:articleID forKey:@"article_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/article"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicJson release];
}

#pragma mark - collect
-(void)request_Collect_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure page:(int)page count:(int)count
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary *dicPage = [[NSMutableDictionary alloc] init];
    [dicPage setValue:[NSString stringWithFormat:@"%d", page] forKey:@"page"];
    [dicPage setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setObject:dicPage forKey:@"pagination"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/collect/list"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicPage release];
    [dicJson release];
}
-(void)request_CollectDel_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure collectID:(NSString*)collectID
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:collectID forKey:@"rec_id"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/collect/delete"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}


#pragma mark - register fields
-(void)request_RegisterFields_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/signupFields"];
    [self getRequest:url
          parameters:nil
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success(responseObject);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
}

#pragma mark - register
-(void)request_Register_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure account:(NSString*)account email:(NSString*)email password:(NSString*)password fieldArray:(NSArray*)fieldArray
{
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:account forKey:@"name"];
    [dicJson setValue:password forKey:@"password"];
    [dicJson setValue:email forKey:@"email"];
    
    NSMutableArray *arrayField = [[NSMutableArray alloc] init];
    [arrayField addObjectsFromArray:fieldArray];
    [dicJson setObject:arrayField forKey:@"field"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/signup"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [arrayField release];
    [dicJson release];
}

#pragma mark - login
-(void)request_Login_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure account:(NSString*)account password:(NSString*)password
{
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setValue:account forKey:@"name"];
    [dicJson setValue:password forKey:@"password"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/signin"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicJson release];
}

#pragma mark - logout
-(void)request_Logout_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] init];
    [dicJson setObject:dicSession forKey:@"session"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/signout"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

#pragma mark - edit user info
-(void)request_EditInfo_Datasuc:(void (^)(id success))success fail:(void (^)(NSError * error))failure dataDic:(NSDictionary*)dataDic
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    NSDictionary* dicSession = [[NSDictionary alloc] initWithDictionary:sessionDic];
    
    NSMutableDictionary *dicJson = [[NSMutableDictionary alloc] initWithDictionary:dataDic];
    [dicJson setObject:dicSession forKey:@"session"];
    [dicJson setValue:[[DataCenter sharedDataCenter].loginInfoDic valueForKey:@"name"] forKey:@"username"];
    
    NSString * url = [SERVER_URL stringByAppendingFormat:@"/?url=/user/infoUpdate"];
    [self postRequest:url
           parameters:dicJson
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  success(responseObject);
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  failure(error);
              }];
    
    [dicSession release];
    [dicJson release];
}

@end
