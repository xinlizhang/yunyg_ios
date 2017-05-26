//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderExpressViewController_ipa.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "OrderGoodsListViewController_ipa.h"

@interface OrderExpressViewController_ipa ()  <UIScrollViewDelegate>
{
    UIScrollView*           _scrollView;            // 整个详情界面的scrollview
    MyNetLoading*           _netLoading;

    int                     _bottomH;               // 底边栏高
    NSMutableArray*         _orderExpressArray;     // 订单详情
    
    NSString*               _expressName;
}
@end

@implementation OrderExpressViewController_ipa

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
    _bottomH = 50;
    _orderExpressArray = [[NSMutableArray alloc] init];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"物流查询";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
    
}


#pragma mark - init UI in scrollview
-(void)updateExpressUI
{
    CGRect frameR = self.view.frame;
    int height = 0;
    
    CGPoint relationP = CGPointMake(0, 0);      // 背景图片的相对坐标

    // 顶部背景
    UIImageView* headerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"express_header_bg"]];
    [headerView setCenter:CGPointMake(frameR.size.width/2, headerView.frame.size.height/2)];
    [_scrollView addSubview:headerView];
    [headerView release];
    
    // 物流名称
    UILabel* shippingNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, 100, 20)];
    [shippingNameLabel setBackgroundColor:[UIColor clearColor]];
    [shippingNameLabel setText:_expressName];
    [shippingNameLabel setTextAlignment:NSTextAlignmentLeft];
    [shippingNameLabel setTextColor:[UIColor grayColor]];
    [shippingNameLabel setFont:[UIFont systemFontOfSize:15]];
    [headerView addSubview:shippingNameLabel];
    [shippingNameLabel release];
    
    // 物流信息背景
    height = headerView.frame.size.height;
    relationP.y += height;
    UIImageView* namerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"express_name_bg"]];
    [namerView setCenter:CGPointMake(frameR.size.width/2, relationP.y+namerView.frame.size.height/2)];
    [_scrollView addSubview:namerView];
    [namerView release];
    
    UILabel* infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 2, namerView.frame.size.width, namerView.frame.size.height)];
    [infoLabel setBackgroundColor:[UIColor clearColor]];
    [infoLabel setText:@"物流信息"];
    [infoLabel setTextAlignment:NSTextAlignmentLeft];
    [infoLabel setTextColor:[UIColor grayColor]];
    [infoLabel setFont:[UIFont systemFontOfSize:13]];
    [namerView addSubview:infoLabel];
    [infoLabel release];
    
    height = namerView.frame.size.height;
    for ( int i = 0; i < [_orderExpressArray count]; i++ )
    {
        NSDictionary* dic = [_orderExpressArray objectAtIndex:i];
        
        relationP.y += height;
        UIImageView* bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"express_middle_bg"]];
        [bgView setCenter:CGPointMake(frameR.size.width/2, relationP.y+bgView.frame.size.height/2)];
        [_scrollView addSubview:bgView];
        [bgView release];
        
        height = bgView.frame.size.height;
        
        UIView* circleView = [[UIView alloc] initWithFrame:CGRectMake(30, 12, 20, 20)];
        if (i == 0)
            [circleView.layer setBackgroundColor:[UIColor colorWithRed:240.0/255 green:68.0/255 blue:58.0/255 alpha:1.0f].CGColor];
        else
            [circleView.layer setBackgroundColor:[UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0f].CGColor];
        [circleView.layer setCornerRadius:10];
        [bgView addSubview:circleView];
        [circleView release];
        
        // 位置信息
        UILabel* positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, frameR.size.width-90, 40)];
        [positionLabel setText:[dic valueForKey:@"context"]];
        [positionLabel setTextAlignment:NSTextAlignmentLeft];
        [positionLabel setTextColor:[UIColor grayColor]];
        [positionLabel setBackgroundColor:[UIColor clearColor]];
        [positionLabel setNumberOfLines:3];
        [positionLabel setFont:[UIFont systemFontOfSize:11]];
        [bgView addSubview:positionLabel];
        [positionLabel release];
        
        // 时间信息
        UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 40, frameR.size.width-90, 15)];
        [timeLabel setText:[dic valueForKey:@"time"]];
        [timeLabel setTextAlignment:NSTextAlignmentLeft];
        [timeLabel setTextColor:[UIColor grayColor]];
        [timeLabel setBackgroundColor:[UIColor clearColor]];
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        [bgView addSubview:timeLabel];
        [timeLabel release];
    }
    
    relationP.y += height;
    UIImageView* footerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"express_footer_bg"]];
    [footerView setCenter:CGPointMake(frameR.size.width/2, relationP.y+footerView.frame.size.height/2)];
    [_scrollView addSubview:footerView];
    height = footerView.frame.size.height;
    [footerView release];
    
    int iTotalH = relationP.y + height;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
    
}

#pragma mark - 
#pragma mark - network
-(void)requestOderExpress:(NSString*)orderID
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_Express_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [_orderExpressArray addObjectsFromArray:success[@"data"][@"content"]];
            _expressName = success[@"data"][@"shipping_name"];
        }
        else
        {
            _expressName = @"暂无数据";
        }
        
        [self updateExpressUI];
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:orderID];
}


@end

