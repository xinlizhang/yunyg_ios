//
//  NetworkModel.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "DataCenter.h"

static DataCenter * dataCenterInstance;

@implementation DataCenter

+(instancetype)sharedDataCenter
{
    if (dataCenterInstance == nil)
    {
        dataCenterInstance = [[DataCenter alloc] init];
    }
    return dataCenterInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _isLogin = false;
        _loginInfoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
        _sessionDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        
        _orderCheckListDefaultDic = [[NSMutableDictionary alloc] init];
        _orderCheckListSelectDic = [[NSMutableDictionary alloc] init];
        _orderDoneResultDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - LOGIN
@synthesize isLogin = _isLogin;
@synthesize loginInfoDic = _loginInfoDic;
@synthesize sessionDic = _sessionDic;
-(void)initLoginInfo
{
    NSUserDefaults *myData = [NSUserDefaults standardUserDefaults];
    [_loginInfoDic addEntriesFromDictionary:[myData objectForKey:@"LOGININFO"]];
    [_sessionDic addEntriesFromDictionary:[myData objectForKey:@"SESSION"]];
}
-(void)writeLoginInfo:(NSDictionary*)loginDic
{
    [_loginInfoDic removeAllObjects];
    [_loginInfoDic addEntriesFromDictionary:loginDic];
}
-(void)editLoginInfo:(id)value forKey:(NSString *)key
{
    [_loginInfoDic setValue:value forKey:key];
}
-(void)writeSessionInfo:(NSDictionary*)sessDic
{
    [_sessionDic removeAllObjects];
    [_sessionDic addEntriesFromDictionary:sessDic];
}
-(void)synchronizeLoginData
{
    NSUserDefaults *myData = [NSUserDefaults standardUserDefaults];
    [myData setObject:_loginInfoDic forKey:@"LOGININFO"];
    [myData setObject:_sessionDic forKey:@"SESSION"];
    [myData synchronize];
}
-(void)removeLoginData
{
    _isLogin = false;
    
    [_loginInfoDic removeAllObjects];
    [_sessionDic removeAllObjects];
    
    _loginInfoDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    _sessionDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSUserDefaults *myData = [NSUserDefaults standardUserDefaults];
    [myData removeObjectForKey:@"LOGININFO"];
    [myData removeObjectForKey:@"SESSION"];
    [myData synchronize];
}

#pragma mark - ORDER
@synthesize orderCheckListDefaultDic = _orderCheckListDefaultDic;
@synthesize orderCheckListSelectDic = _orderCheckListSelectDic;
@synthesize orderDoneResultDic = _orderDoneResultDic;

- (void)removeOrderSelectDicDatas
{
    [_orderCheckListSelectDic removeAllObjects];
}

@end


