//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderPayAndShipViewController_iph.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"


@interface OrderPayAndShipViewController_iph ()
{
    UIGestureRecognizer*        _lastClickedPayGesture;
    UIGestureRecognizer*        _lastClickedShipGesture;
}
@end

@implementation OrderPayAndShipViewController_iph

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
    _lastClickedPayGesture = nil;
    _lastClickedShipGesture = nil;
    
    [[DataCenter sharedDataCenter].orderCheckListSelectDic removeAllObjects];
}

-(void)initUI
{
    NSComparisonResult order = [[UIDevice currentDevice].systemVersion compare: @"7.0" options: NSNumericSearch];
    if (order == NSOrderedSame || order == NSOrderedDescending)
    {
        // OS version >= 7.0
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    CGRect frameR = self.view.frame;

    // 支付方式
    CGPoint relationP = CGPointMake(0, 0);
    UIView* payStyleView = [[UIView alloc] init];
    [payStyleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:payStyleView];
    [payStyleView release];
    
    UILabel* payWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, frameR.size.width-20, 17)];
    [payWdsLabel setText:@"支付方式"];
    [payWdsLabel setTextColor:[UIColor blackColor]];
    [payWdsLabel setFont:[UIFont systemFontOfSize:16]];
    [payWdsLabel setTextAlignment:NSTextAlignmentLeft];
    [payStyleView addSubview:payWdsLabel];
    [payWdsLabel release];
    
    int iRowNum = 0;                // 记录行数 用于纵向排版
    int iStartX = 20;               // 每个控件起始坐标
    int iStartY = payWdsLabel.frame.origin.y + payWdsLabel.frame.size.height + 20;
    NSArray* paymentListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"payment_list"];
    for ( int i = 0; i < [paymentListArray count]; i++ )
    {
        NSDictionary* paymentDic = [paymentListArray objectAtIndex:i];
        float wdsW = [Utils widthForString:[paymentDic objectForKey:@"pay_name"] fontSize:15] + 20;
        
        UILabel* paymentLabel = [[UILabel alloc] init];
        [paymentLabel setText:[paymentDic objectForKey:@"pay_name"]];
        [paymentLabel.layer setBorderColor:[UIColor grayColor].CGColor];
        [paymentLabel setTag:(i+1000)];
        [paymentLabel.layer setCornerRadius:3.0];
        [paymentLabel.layer setBorderWidth:0.5f];
        [paymentLabel setBackgroundColor:[UIColor whiteColor]];
        [paymentLabel setFont:[UIFont systemFontOfSize:15]];
        [paymentLabel setTextAlignment:NSTextAlignmentCenter];
        [paymentLabel setTextColor:[UIColor grayColor]];
        [payStyleView addSubview:paymentLabel];
        [paymentLabel release];

        // touch事件注册
        paymentLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(paymentCheckboxClick:)];
        [paymentLabel addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        // 动态排版
        if ( frameR.size.width < (iStartX + wdsW + 15) )
        {
            iStartX = 30;
            iRowNum++;
        }
        [paymentLabel setFrame:CGRectMake(iStartX, iStartY + iRowNum*(30+10), wdsW, 30)];
        iStartX = iStartX + wdsW + 10;
    }
    
    int height = iStartY + (iRowNum+1)*(30+10) + 20;
    [payStyleView setFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [payStyleView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    
    // 配送方式
    relationP.y = relationP.y + height + 10;
    UIView* shipStyleView = [[UIView alloc] init];
    [shipStyleView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:shipStyleView];
    [shipStyleView release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [shipStyleView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UILabel* shipWdsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, frameR.size.width-20, 17)];
    [shipWdsLabel setText:@"配送方式"];
    [shipWdsLabel setTextColor:[UIColor blackColor]];
    [shipWdsLabel setFont:[UIFont systemFontOfSize:16]];
    [shipWdsLabel setTextAlignment:NSTextAlignmentLeft];
    [shipStyleView addSubview:shipWdsLabel];
    [shipWdsLabel release];
    
    NSArray* goodsListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"goods_list"];
    for ( int i = 0; i < [goodsListArray count] && i < 3; i++ )
    {
        NSDictionary* goodsDic = [goodsListArray objectAtIndex:i];
        
        UIImageView * goodsView = [[UIImageView alloc] initWithFrame:CGRectMake(20+i*70, shipWdsLabel.frame.origin.y+shipWdsLabel.frame.size.height+20, 60,60)];
        [goodsView setOnlineImage:goodsDic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [shipStyleView addSubview:goodsView];
        [goodsView release];
    }
    
    iRowNum = 0;                // 记录行数 用于纵向排版
    iStartX = 20;               // 每个控件起始坐标
    iStartY = shipWdsLabel.frame.origin.y + shipWdsLabel.frame.size.height + 80 + 30;
    NSArray* shipListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"shipping_list"];
    for ( int i = 0; i < [shipListArray count]; i++ )
    {
        NSDictionary* shipDic = [shipListArray objectAtIndex:i];
        float wdsW = [Utils widthForString:[shipDic objectForKey:@"shipping_name"] fontSize:15] + 20;
        
        UILabel* shipLabel = [[UILabel alloc] init];
        [shipLabel setText:[shipDic objectForKey:@"shipping_name"]];
        [shipLabel.layer setBorderColor:[UIColor grayColor].CGColor];
        [shipLabel setTag:(i+1000)];
        [shipLabel.layer setCornerRadius:3.0];
        [shipLabel.layer setBorderWidth:0.5f];
        [shipLabel setBackgroundColor:[UIColor whiteColor]];
        [shipLabel setFont:[UIFont systemFontOfSize:15]];
        [shipLabel setTextAlignment:NSTextAlignmentCenter];
        [shipLabel setTextColor:[UIColor grayColor]];
        [shipStyleView addSubview:shipLabel];
        [shipLabel release];
        
        // touch事件注册
        shipLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shipCheckboxClick:)];
        [shipLabel addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        // 动态排版
        if ( frameR.size.width < (iStartX + wdsW + 15) )
        {
            iStartX = 30;
            iRowNum++;
        }
        [shipLabel setFrame:CGRectMake(iStartX, iStartY + iRowNum*(30+10), wdsW, 30)];
        iStartX = iStartX + wdsW + 10;
    }
    
    height = iStartY + (iRowNum+1)*(30+10) + 20;
    [shipStyleView setFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [shipStyleView addSubview:seperatorlINE];
    [seperatorlINE release];
    
    
    // 底部确定按钮
    relationP.y = relationP.y + height + 10;
    height = 40;
    UILabel* confirmLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, relationP.y, frameR.size.width-60, 40)];
    confirmLabel.backgroundColor = [UIColor colorWithRed:241.0/255 green:83.0/255 blue:80.0/255 alpha:1.0];
    confirmLabel.text = @"确定";
    confirmLabel.textColor = [UIColor whiteColor];
    confirmLabel.userInteractionEnabled = YES;
    [confirmLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:confirmLabel];
    [confirmLabel release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onConfirmClicked:)];
    [confirmLabel addGestureRecognizer:tap];
    [tap release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"支付配送方式";
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


#pragma mark - click event
-(void)paymentCheckboxClick:(UITapGestureRecognizer*)sender
{
    if ( _lastClickedPayGesture )
    {
        [_lastClickedPayGesture.view.layer setBorderColor:[UIColor grayColor].CGColor];
    }
    _lastClickedPayGesture = sender;
    [sender.view.layer setBorderColor:[UIColor redColor].CGColor];
    
    NSInteger index = sender.view.tag - 1000;
    NSArray* paymentListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"payment_list"];
    if ( 0 <= index && index < [paymentListArray count] )
    {
        NSDictionary* payDic = [paymentListArray objectAtIndex:index];
        [[DataCenter sharedDataCenter].orderCheckListSelectDic setValue:payDic forKey:@"payment_selected"];
    }
}

-(void)onConfirmClicked:(UITapGestureRecognizer*)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shipCheckboxClick:(UITapGestureRecognizer*)sender
{
    if ( _lastClickedShipGesture )
    {
        [_lastClickedShipGesture.view.layer setBorderColor:[UIColor grayColor].CGColor];
    }
    _lastClickedShipGesture = sender;
    [sender.view.layer setBorderColor:[UIColor redColor].CGColor];
    
    NSInteger index = sender.view.tag - 1000;
    NSArray* shipListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"shipping_list"];
    if ( 0 <= index && index < [shipListArray count] )
    {
        NSDictionary* shipDic = [shipListArray objectAtIndex:index];
        [[DataCenter sharedDataCenter].orderCheckListSelectDic setValue:shipDic forKey:@"shiping_selected"];
    }
}

@end

