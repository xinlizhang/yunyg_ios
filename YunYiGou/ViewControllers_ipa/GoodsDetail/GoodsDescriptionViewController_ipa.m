//
//  GoodsListViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "GoodsDescriptionViewController_ipa.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "MyAlert.h"

@interface GoodsDescriptionViewController_ipa ()
{
    UIWebView*      _goodsInfoWebView;
    
    MyNetLoading*   _netLoading;
}
@end

@implementation GoodsDescriptionViewController_ipa

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)initData
{

}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    _goodsInfoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    //NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    //[_goodsInfoWebView loadRequest:request];
    _goodsInfoWebView.delegate = self;
    [self.view addSubview: _goodsInfoWebView];
    [_goodsInfoWebView release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"商品介绍";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];

    int iGoodsID = self.iGoodsID2Info;
    if ( 0 < iGoodsID )
        [self requestData:iGoodsID];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}

#pragma mark - web view delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_netLoading startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_netLoading stopAnimating];
}

#pragma mark - network
-(void)updateUI:(NSString*)goodsDescription
{
    //CGRect frameR = self.view.frame;
    
    [_goodsInfoWebView loadHTMLString:goodsDescription baseURL:nil];
}

-(void)requestData : (int)goodsID
{
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
        [net request_GoodsDescription_Datasuc:^(id success) {
            if (success[@"status"])
            {
                if ( [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
                {
                    [self updateUI:success[@"data"]];
                }
            }
        } fail:^(NSError *error) {
            
        } goodsID:goodsID];
}

@end

