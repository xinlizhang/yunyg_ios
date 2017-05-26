//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "AboutViewController_iph.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "ArticleDetailViewController_iph.h"

@interface AboutViewController_iph ()
{

    int                 _topBarH;                           // 顶边栏高度
    
}
@end

@implementation AboutViewController_iph

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initData];
        [self initUI];
    }
    return self;
}

-(void)initData
{
    _topBarH = 64;
}

-(void)initUI
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        // OS version >= 7.0
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect r = self.view.frame;

    CGPoint relationP = CGPointMake(0, 30);
    int height = 30;
    UILabel* appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, r.size.width, height)];
    appNameLabel.backgroundColor = [UIColor clearColor];
    [appNameLabel setText:@"雲易购"];
    [appNameLabel setTextColor:[UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0]];
    [appNameLabel setFont:[UIFont systemFontOfSize:22]];
    [appNameLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:appNameLabel];
    [appNameLabel release];
    
    relationP.y = relationP.y + height;
    height = 30;
    UILabel* welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, r.size.width, height)];
    welcomeLabel.backgroundColor = [UIColor clearColor];
    [welcomeLabel setText:@"欢迎使用雲易购"];
    [welcomeLabel setTextColor:[UIColor grayColor]];
    [welcomeLabel setFont:[UIFont systemFontOfSize:13]];
    [welcomeLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:welcomeLabel];
    [welcomeLabel release];
    
    relationP.y = relationP.y + height + 20;
    height = 120;
    UIImageView* qrCodeView = [[UIImageView alloc] initWithFrame:CGRectMake(r.size.width/2-(height-20)/2, relationP.y, height-20, height-20)];
    [qrCodeView setImage:[UIImage imageNamed:@"about_qrcode"]];
    [self.view addSubview:qrCodeView];
    [qrCodeView release];
    
    relationP.y = relationP.y + height + 20;
    height = 15;
    UILabel* versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, r.size.width, height)];
    versionLabel.backgroundColor = [UIColor clearColor];
    [versionLabel setText:@"For Iphone V1.0"];
    [versionLabel setTextColor:[UIColor grayColor]];
    [versionLabel setFont:[UIFont systemFontOfSize:10]];
    [versionLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:versionLabel];
    [versionLabel release];
    
    relationP.y = relationP.y + height;
    height = 30;
    UILabel* copyrightLabel = [[UILabel alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, r.size.width, height)];
    copyrightLabel.backgroundColor = [UIColor clearColor];
    [copyrightLabel setText:@"雲易购 版权所有"];
    [copyrightLabel setTextColor:[UIColor grayColor]];
    [copyrightLabel setFont:[UIFont systemFontOfSize:13]];
    [copyrightLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:copyrightLabel];
    [copyrightLabel release];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
    self.view.backgroundColor = [UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1];
}

- (void)viewWillAppear:(BOOL)animated
{
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

@end

