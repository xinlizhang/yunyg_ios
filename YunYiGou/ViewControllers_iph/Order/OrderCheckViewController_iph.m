//
//  GoodsListViewController_iph.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderCheckViewController_iph.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "UIImageView+OnlineImage.h"
#import "OrderAddrMngViewController_iph.h"
#import "OrderGoodsListViewController_iph.h"
#import "OrderPayAndShipViewController_iph.h"
#import "OrderDoneViewController_iph.h"
#import "AddrEditViewController_iph.h"

@interface OrderCheckViewController_iph ()
{
    UIScrollView*       _scrollView;            // 整个详情界面的scrollview
    UILabel*            _moneyLabel;
    MyNetLoading*       _netLoading;
    
    int                 _bottomH;               // 底边栏高
}
@end

@implementation OrderCheckViewController_iph

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
    
    // 初始化时清空选择项的数据列表 控制为从选择界面回来时显示选择的数据 一旦退出订单check界面再进入就加载新数据
    [[DataCenter sharedDataCenter] removeOrderSelectDicDatas];
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // 实付款背景
    UIView* bottomBar1 = [[UIView alloc] initWithFrame:CGRectMake(0, frameR.size.height-_bottomH, frameR.size.width*3/5, _bottomH)];
    [bottomBar1 setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:bottomBar1];
    [bottomBar1 release];

    UILabel* moneyNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
    [moneyNameLabel setText:@"实付款："];
    [moneyNameLabel setNumberOfLines:1];
    [moneyNameLabel setTextColor:[UIColor whiteColor]];
    [moneyNameLabel setCenter:CGPointMake(40, bottomBar1.frame.size.height/2)];
    [moneyNameLabel setTextAlignment:NSTextAlignmentCenter];
    [moneyNameLabel setFont:[UIFont systemFontOfSize:14]];
    [bottomBar1 addSubview:moneyNameLabel];
    [moneyNameLabel release];
    
    int moneyStartX = moneyNameLabel.frame.origin.x + moneyNameLabel.frame.size.width;
    _moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(moneyStartX, (bottomBar1.frame.size.height-17)/2, bottomBar1.frame.size.width-moneyStartX, 18)];
    [_moneyLabel setText:@"￥0.00"];
    [_moneyLabel setNumberOfLines:1];
    [_moneyLabel setTextColor:[UIColor whiteColor]];
    [_moneyLabel setTextAlignment:NSTextAlignmentLeft];
    [_moneyLabel setFont:[UIFont systemFontOfSize:17]];
    [bottomBar1 addSubview:_moneyLabel];
    [_moneyLabel release];
    
    
    // 提交订单
    UIView* bottomBar2 = [[UIView alloc] initWithFrame:CGRectMake(bottomBar1.frame.size.width, frameR.size.height-_bottomH, frameR.size.width*2/5, _bottomH)];
    [bottomBar2 setBackgroundColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:68.0/255 alpha:0.7]];
    [self.view addSubview:bottomBar2];
    bottomBar2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCommitClicked:)];
    [bottomBar2 addGestureRecognizer:singleTap1];
    [singleTap1 release];
    [bottomBar2 release];
    UILabel* commitListLabel = [[UILabel alloc] initWithFrame:bottomBar2.frame];
    [commitListLabel setText:@"提交订单"];
    [commitListLabel setNumberOfLines:1];
    [commitListLabel setTextColor:[UIColor whiteColor]];
    [commitListLabel setCenter:bottomBar2.center];
    [commitListLabel setTextAlignment:NSTextAlignmentCenter];
    [commitListLabel setFont:[UIFont systemFontOfSize:18]];
    [self.view addSubview:commitListLabel];
    [commitListLabel release];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"填写订单";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    [self requestCheckOrder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}


#pragma mark - network
-(void)updateUI
{
    CGRect frameR = self.view.frame;
    
    // 默认地址
    CGPoint relationP = CGPointMake(0, 10);
    int height = 96;
    UIImageView* addrBGView = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    [addrBGView setImage:[UIImage imageNamed:@"order_addr_bg"]];
    [_scrollView addSubview:addrBGView];
    addrBGView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onAddrClicked:)];
    [addrBGView addGestureRecognizer:tapGesture];
    [tapGesture release];
    [addrBGView release];
    
    CGPoint relationCenter = CGPointMake(25, 35);
    UIImageView* addrHeadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_addr_head"]];
    [addrHeadView setCenter:relationCenter];
    [addrBGView addSubview:addrHeadView];
    [addrHeadView release];
    
    NSString* nameOfAddr = [[[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"consignee"] objectForKey:@"consignee"];
    float addrNameLableW = [Utils widthForString:nameOfAddr fontSize:14];
    float addrNameLableCX = relationCenter.x + addrHeadView.frame.size.width/2 + 10 + addrNameLableW/2;
    UILabel* addrNameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, addrNameLableW, 15)];
    [addrNameLable setCenter:CGPointMake(addrNameLableCX, relationCenter.y)];
    [addrNameLable setText:nameOfAddr];
    [addrNameLable setNumberOfLines:1];
    [addrNameLable setTextColor:[UIColor blackColor]];
    [addrNameLable setTextAlignment:NSTextAlignmentLeft];
    [addrNameLable setFont:[UIFont systemFontOfSize:14]];
    [addrBGView addSubview:addrNameLable];
    [addrNameLable release];
    
    UIImageView* phoneView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_addr_phone"]];
    [phoneView setCenter:CGPointMake(frameR.size.width/2, relationCenter.y)];
    [addrBGView addSubview:phoneView];
    [phoneView release];
    
    NSString* numberWds = [[[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"consignee"] objectForKey:@"mobile"];
    float numberWdsW = [Utils widthForString:numberWds fontSize:14];
    float numberWdsCX = phoneView.center.x + phoneView.frame.size.width/2 + 10 + numberWdsW/2;
    UILabel* phoneNumLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, numberWdsW, 15)];
    [phoneNumLable setCenter:CGPointMake(numberWdsCX, relationCenter.y)];
    [phoneNumLable setText:numberWds];
    [phoneNumLable setNumberOfLines:1];
    [phoneNumLable setTextColor:[UIColor blackColor]];
    [phoneNumLable setTextAlignment:NSTextAlignmentLeft];
    [phoneNumLable setFont:[UIFont systemFontOfSize:14]];
    [addrBGView addSubview:phoneNumLable];
    [phoneNumLable release];
    
    relationCenter.x = relationCenter.x + 10;
    relationCenter.y = relationCenter.y + 30;
    UIImageView* morenBG = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg_save"]];
    [morenBG setCenter:relationCenter];
    [addrBGView addSubview:morenBG];
    [morenBG release];

    UILabel* morenWds = [[UILabel alloc] initWithFrame:morenBG.frame];
    [morenWds setCenter:morenBG.center];
    [morenWds setText:@"默认"];
    [morenWds setTextColor:[UIColor whiteColor]];
    [morenWds setFont:[UIFont systemFontOfSize:14]];
    [morenWds setTextAlignment:NSTextAlignmentCenter];
    [addrBGView addSubview:morenWds];
    [morenWds release];
    
    NSDictionary* addrDic = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"consignee"];
    NSString* addrWds = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",[addrDic objectForKey:@"country_name"],[addrDic objectForKey:@"province_name"],[addrDic objectForKey:@"city_name"],[addrDic objectForKey:@"district_name"],[addrDic objectForKey:@"address"]];
    CGFloat addrWdsW = MIN([Utils widthForString:addrWds fontSize:14], frameR.size.width-100);
    float addrWdsCX = relationCenter.x + morenBG.frame.size.width/2 + 10 + addrWdsW/2;
    UILabel* addrWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, addrWdsW, 15)];
    [addrWdsLable setCenter:CGPointMake(addrWdsCX, relationCenter.y)];
    [addrWdsLable setText:addrWds];
    [addrWdsLable setNumberOfLines:1];
    [addrWdsLable setTextColor:[UIColor grayColor]];
    [addrWdsLable setTextAlignment:NSTextAlignmentLeft];
    [addrWdsLable setFont:[UIFont systemFontOfSize:14]];
    [addrBGView addSubview:addrWdsLable];
    [addrWdsLable release];
    
    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-20, addrBGView.frame.size.height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [addrBGView addSubview:rightIdentify];
    [rightIdentify release];
    
    // 商品详情
    relationP.y = relationP.y + height + 10;
    height = 86;
    
    UIView* goodsListBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [goodsListBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:goodsListBG];
    goodsListBG.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGoodsListClicked:)];
    [goodsListBG addGestureRecognizer:tapGesture];
    [tapGesture release];
    [goodsListBG release];
    
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [goodsListBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [goodsListBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    float totalCost = 0.00f;
    NSArray* goodsListArray = [[DataCenter sharedDataCenter].orderCheckListDefaultDic objectForKey:@"goods_list"];
    for ( int i = 0; i < [goodsListArray count]; i++ )
    {
        NSDictionary* goodsDic = [goodsListArray objectAtIndex:i];
        totalCost += [[goodsDic objectForKey:@"goods_price"] floatValue];
        
        if ( 3 <= i )
            continue;

        UIImageView * goodsView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, height - 20, height - 20)];
        [goodsView setCenter:CGPointMake(height/2 + i*height, goodsListBG.frame.size.height/2)];
        [goodsView setOnlineImage:goodsDic[@"img"][@"small"] placeholderImage:[UIImage imageNamed:@"common_img_loding"]];
        [goodsListBG addSubview:goodsView];
        [goodsView release];
    }
    
    UILabel* goodsTotalLable = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, goodsListBG.frame.size.width-60, goodsListBG.frame.size.height)];
    [goodsTotalLable setText:[NSString stringWithFormat:@"共%ld件",[goodsListArray count]]];
    [goodsTotalLable setNumberOfLines:1];
    [goodsTotalLable setTextColor:[UIColor lightGrayColor]];
    [goodsTotalLable setTextAlignment:NSTextAlignmentRight];
    [goodsTotalLable setFont:[UIFont systemFontOfSize:12]];
    [goodsListBG addSubview:goodsTotalLable];
    [goodsTotalLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-20, goodsListBG.frame.size.height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [goodsListBG addSubview:rightIdentify];
    [rightIdentify release];
    
    // 支付配送
    relationP.y = relationP.y + height + 10;
    height = 60;
    
    UIView* payAndShipBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [payAndShipBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:payAndShipBG];
    payAndShipBG.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onPayAndShipClicked:)];
    [payAndShipBG addGestureRecognizer:tapGesture];
    [tapGesture release];
    [payAndShipBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [payAndShipBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UILabel* payAndShipLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, payAndShipBG.frame.size.width-60, payAndShipBG.frame.size.height)];
    [payAndShipLable setText:@"支付配送"];
    [payAndShipLable setNumberOfLines:1];
    [payAndShipLable setTextColor:[UIColor grayColor]];
    [payAndShipLable setTextAlignment:NSTextAlignmentLeft];
    [payAndShipLable setFont:[UIFont systemFontOfSize:16]];
    [payAndShipBG addSubview:payAndShipLable];
    [payAndShipLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-20, payAndShipBG.frame.size.height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [payAndShipBG addSubview:rightIdentify];
    [rightIdentify release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0/*15*/, height-1, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];//colorWithRed:230.0/255 green:230.0/255 blue:230.0/255 alpha:1]];
    [payAndShipBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    NSDictionary* paymentDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"payment_selected"];
    
    UILabel* paymentLable = [[UILabel alloc] initWithFrame:CGRectMake(40, 6, payAndShipBG.frame.size.width-80, payAndShipBG.frame.size.height/2)];
    [paymentLable setText:[paymentDic objectForKey:@"pay_name"]];
    [paymentLable setNumberOfLines:1];
    [paymentLable setTextColor:[UIColor blackColor]];
    [paymentLable setTextAlignment:NSTextAlignmentRight];
    [paymentLable setFont:[UIFont systemFontOfSize:12]];
    [payAndShipBG addSubview:paymentLable];
    [paymentLable release];
    
    NSDictionary* shippingDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"shiping_selected"];
    
    UILabel* shippingLable = [[UILabel alloc] initWithFrame:CGRectMake(40, payAndShipBG.frame.size.height/2-6, payAndShipBG.frame.size.width-80, payAndShipBG.frame.size.height/2)];
    [shippingLable setText:[shippingDic objectForKey:@"shipping_name"]];
    [shippingLable setNumberOfLines:1];
    [shippingLable setTextColor:[UIColor blackColor]];
    [shippingLable setTextAlignment:NSTextAlignmentRight];
    [shippingLable setFont:[UIFont systemFontOfSize:12]];
    [payAndShipBG addSubview:shippingLable];
    [shippingLable release];
    
    // 发票信息
    /*relationP.y = relationP.y + height;
    height = 60;
    
    UIView* invoiceBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [invoiceBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:invoiceBG];
    invoiceBG.userInteractionEnabled = YES;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInvoiceClicked:)];
    [invoiceBG addGestureRecognizer:tapGesture];
    [tapGesture release];
    [invoiceBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [invoiceBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UILabel* invoiceWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, invoiceBG.frame.size.width-60, invoiceBG.frame.size.height)];
    [invoiceWdsLable setText:@"发票信息"];
    [invoiceWdsLable setNumberOfLines:1];
    [invoiceWdsLable setTextColor:[UIColor grayColor]];
    [invoiceWdsLable setTextAlignment:NSTextAlignmentLeft];
    [invoiceWdsLable setFont:[UIFont systemFontOfSize:16]];
    [invoiceBG addSubview:invoiceWdsLable];
    [invoiceWdsLable release];
    
    rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
    [rightIdentify setCenter:CGPointMake(frameR.size.width-20, invoiceBG.frame.size.height/2)];
    [rightIdentify setImage:[UIImage imageNamed:@"home_btn_godetail"]];
    [invoiceBG addSubview:rightIdentify];
    [rightIdentify release];*/
    
    // 商品金额
    relationP.y = relationP.y + height + 10;
    height = 35;
    
    UIView* goodsPriceBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [goodsPriceBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:goodsPriceBG];
    [goodsPriceBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [goodsPriceBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UILabel* goodsPriceWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, goodsPriceBG.frame.size.width-60, goodsPriceBG.frame.size.height)];
    [goodsPriceWdsLable setText:@"商品金额"];
    [goodsPriceWdsLable setNumberOfLines:1];
    [goodsPriceWdsLable setTextColor:[UIColor lightGrayColor]];
    [goodsPriceWdsLable setTextAlignment:NSTextAlignmentLeft];
    [goodsPriceWdsLable setFont:[UIFont systemFontOfSize:16]];
    [goodsPriceBG addSubview:goodsPriceWdsLable];
    [goodsPriceWdsLable release];
    
    UILabel* goodsPriceLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, goodsPriceBG.frame.size.width-30, goodsPriceBG.frame.size.height)];
    [goodsPriceLable setText:[NSString stringWithFormat:@"￥%.2f",totalCost]];
    [goodsPriceLable setNumberOfLines:1];
    [goodsPriceLable setTextColor:[UIColor redColor]];
    [goodsPriceLable setTextAlignment:NSTextAlignmentRight];
    [goodsPriceLable setFont:[UIFont systemFontOfSize:16]];
    [goodsPriceBG addSubview:goodsPriceLable];
    [goodsPriceLable release];
    
    // 运费
    relationP.y = relationP.y + height;
    height = 35;
    
    UIView* shipFeeBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [shipFeeBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:shipFeeBG];
    [shipFeeBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [shipFeeBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    UILabel* shipFeeWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, shipFeeBG.frame.size.width-60, shipFeeBG.frame.size.height)];
    [shipFeeWdsLable setText:@"运费"];
    [shipFeeWdsLable setNumberOfLines:1];
    [shipFeeWdsLable setTextColor:[UIColor lightGrayColor]];
    [shipFeeWdsLable setTextAlignment:NSTextAlignmentLeft];
    [shipFeeWdsLable setFont:[UIFont systemFontOfSize:16]];
    [shipFeeBG addSubview:shipFeeWdsLable];
    [shipFeeWdsLable release];
    
    NSString* shippingFeeStr = @"￥0.00";
    if ( 0 < [shippingDic count] )
    {
        shippingFeeStr = [shippingDic objectForKey:@"shipping_fee"];
        float shippingFee = [shippingFeeStr floatValue];
        shippingFeeStr = [NSString stringWithFormat:@"+￥%.2f",shippingFee];
    }
    UILabel* shipFeeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, shipFeeBG.frame.size.width-30, shipFeeBG.frame.size.height)];
    [shipFeeLable setText:shippingFeeStr];
    [shipFeeLable setNumberOfLines:1];
    [shipFeeLable setTextColor:[UIColor redColor]];
    [shipFeeLable setTextAlignment:NSTextAlignmentRight];
    [shipFeeLable setFont:[UIFont systemFontOfSize:16]];
    [shipFeeBG addSubview:shipFeeLable];
    [shipFeeLable release];
    
    int iTotalH = relationP.y + height;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
    
    // 最下面的总额
    totalCost += [[shippingDic objectForKey:@"shipping_fee"] floatValue];
    [_moneyLabel setText:[NSString stringWithFormat:@"￥%.2f",totalCost]];
}

#pragma mark - 各种点击事件
// 地址
-(void)onAddrClicked:(id)sender
{
    BasicViewController_iph *viewController = [[OrderAddrMngViewController_iph alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 商品
-(void)onGoodsListClicked:(id)sender
{
    BasicViewController_iph *viewController = [[OrderGoodsListViewController_iph alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 支付配送
-(void)onPayAndShipClicked:(id)sender
{
    BasicViewController_iph *viewController = [[OrderPayAndShipViewController_iph alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

// 发票
-(void)onInvoiceClicked:(id)sender
{
    
}

// 提交
-(void)onCommitClicked:(id)sender
{
    NSDictionary* sessionDic = [DataCenter sharedDataCenter].sessionDic;
    if ( [sessionDic count] <= 0)
    {
        [MyAlert showMessage:@"登录信息不存在" timer:2.0f];
        return;
    }

    NSDictionary* paymentDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"payment_selected"];
    if ( paymentDic == nil || [paymentDic count] <= 0 )
    {
        [MyAlert showMessage:@"请选择支付方式" timer:2.0f];
        return;
    }
    
    NSDictionary* shippingDic = [[DataCenter sharedDataCenter].orderCheckListSelectDic objectForKey:@"shiping_selected"];
    if ( shippingDic == nil || [shippingDic count] <= 0 )
    {
        [MyAlert showMessage:@"请选择配送方式" timer:2.0f];
        return;
    }
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_DoneOrder_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [[DataCenter sharedDataCenter].orderDoneResultDic setValuesForKeysWithDictionary:success[@"data"]];
            BasicViewController_iph *viewController = [[OrderDoneViewController_iph alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:[success[@"status"] valueForKey:@"error_desc"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alter show];
            [alter release];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    }];
}



#pragma mark - network
-(void)requestCheckOrder
{
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_CheckOrder_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [[DataCenter sharedDataCenter].orderCheckListDefaultDic setValuesForKeysWithDictionary:success[@"data"]];
            [self updateUI];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 100 )
        {
            [MyAlert showMessage:@"您的账号已过期，请尝试重新登陆！" timer:4.0f];
            [[DataCenter sharedDataCenter] removeLoginData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if( success[@"status"] && [[success[@"status"] valueForKey:@"error_code"] intValue] == 10010 )
        {
            [MyAlert showMessage:[success[@"status"] valueForKey:@"error_desc"] timer:4.0f];
            
            BasicViewController_iph *viewController = [[AddrEditViewController_iph alloc] init];
            viewController.editAddrDic = nil;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    }];
}

#pragma mark - scroll view delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _scrollView)
    {

    }
}

@end

