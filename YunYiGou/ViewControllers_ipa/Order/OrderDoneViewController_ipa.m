//
//  GoodsListViewController_ipa.m
//  YunYiGou
//
//  Created by apple on 15/5/27.
//  Copyright (c) 2015年 yunfeng. All rights reserved.
//

#import "OrderDoneViewController_ipa.h"
#import "MyAlert.h"
#import "RDVTabBarController.h"
#import "MyWebViewController_ipa.h"
#import "UIImageView+OnlineImage.h"
#import "OrderGoodsListViewController_ipa.h"

@interface OrderDoneViewController_ipa () <UIAlertViewDelegate>
{
    UIScrollView*       _scrollView;            // 整个详情界面的scrollview
    MyNetLoading*       _netLoading;

    int                 _bottomH;               // 底边栏高
}
@end

@implementation OrderDoneViewController_ipa

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
}

-(void)initUI
{
    CGRect frameR = self.view.frame;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, frameR.size.height)];
    [_scrollView setBackgroundColor:[UIColor colorWithRed:238.0/255 green:243.0/255 blue:246.0/255 alpha:1]];
    [self.view addSubview:_scrollView];
    [_scrollView setDelegate:self];
    [_scrollView release];
    
    // 取消订单
    UIView* cancelList = [[UIView alloc] initWithFrame:CGRectMake(0, frameR.size.height-_bottomH, frameR.size.width/2, _bottomH)];
    [cancelList setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    [self.view addSubview:cancelList];
    cancelList.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancelListClicked:)];
    [cancelList addGestureRecognizer:singleTap];
    [singleTap release];
    [cancelList release];
    UILabel* cancelListLabel = [[UILabel alloc] initWithFrame:cancelList.frame];
    [cancelListLabel setText:@"取消订单"];
    [cancelListLabel setNumberOfLines:1];
    [cancelListLabel setTextColor:[UIColor whiteColor]];
    [cancelListLabel setCenter:cancelList.center];
    [cancelListLabel setTextAlignment:NSTextAlignmentCenter];
    [cancelListLabel setFont:[UIFont systemFontOfSize:18]];
    [self.view addSubview:cancelListLabel];
    [cancelListLabel release];
    
    // 去付款
    UIView* gotoPay = [[UIView alloc] initWithFrame:CGRectMake(cancelList.frame.size.width, frameR.size.height-_bottomH, frameR.size.width/2, _bottomH)];
    [gotoPay setBackgroundColor:[UIColor colorWithRed:255.0/255 green:78.0/255 blue:68.0/255 alpha:0.7]];
    [self.view addSubview:gotoPay];
    gotoPay.userInteractionEnabled = YES;
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGotoPayClicked:)];
    [gotoPay addGestureRecognizer:singleTap];
    [singleTap release];
    [gotoPay release];
    UILabel* gotoPayLabel = [[UILabel alloc] initWithFrame:gotoPay.frame];
    [gotoPayLabel setText:@"去付款"];
    [gotoPayLabel setNumberOfLines:1];
    [gotoPayLabel setTextColor:[UIColor whiteColor]];
    [gotoPayLabel setCenter:gotoPay.center];
    [gotoPayLabel setTextAlignment:NSTextAlignmentCenter];
    [gotoPayLabel setFont:[UIFont systemFontOfSize:18]];
    [self.view addSubview:gotoPayLabel];
    [gotoPayLabel release];
    
    
    [self initDetailUI];
    
    // loading
    _netLoading = [[MyNetLoading alloc] init];
    [_netLoading setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [self.view addSubview:_netLoading];
    [_netLoading release];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"等待付款";
    self.view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    
    UINavigationController* navigationController = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [navigationController setNavigationBarHidden:NO animated:YES];
    
    // 获取订单支付状态 若为支付成功 提示用户返回
    [self verifyOrderPayStatus];

}

- (void)viewWillDisappear:(BOOL)animated {
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    [super viewWillDisappear:animated];
    
    UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
    [pNv setNavigationBarHidden:YES animated:YES];
}


#pragma mark - init UI in scrollview
-(void)initDetailUI
{
    NSDictionary* checkDic = [DataCenter sharedDataCenter].orderCheckListDefaultDic;
    NSDictionary* doneDic = [DataCenter sharedDataCenter].orderDoneResultDic;
    
    CGRect frameR = self.view.frame;
    
    // 订单号
    CGPoint relationP = CGPointMake(0, 0);
    int height = 40;
    UIView* listNumBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [listNumBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:listNumBG];
    [listNumBG release];
    
    NSString* listNumStr = [doneDic objectForKey:@"order_sn"];
    UILabel* listNumLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, listNumBG.frame.size.width-60, listNumBG.frame.size.height)];
    [listNumLable setText:[NSString stringWithFormat:@"订单号：%@",listNumStr]];
    [listNumLable setNumberOfLines:1];
    [listNumLable setTextColor:[UIColor grayColor]];
    [listNumLable setTextAlignment:NSTextAlignmentLeft];
    [listNumLable setFont:[UIFont systemFontOfSize:16]];
    [listNumBG addSubview:listNumLable];
    [listNumLable release];
    
    UIView* seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [listNumBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    // 默认地址
    relationP.y = relationP.y + height +10;
    height = 96;
    UIImageView* addrBGView = [[UIImageView alloc] initWithFrame:CGRectMake(relationP.x, relationP.y, frameR.size.width, height)];
    [addrBGView setImage:[UIImage imageNamed:@"order_addr_bg"]];
    [_scrollView addSubview:addrBGView];
    [addrBGView release];
    
    CGPoint relationCenter = CGPointMake(25, 35);
    UIImageView* addrHeadView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_addr_head"]];
    [addrHeadView setCenter:relationCenter];
    [addrBGView addSubview:addrHeadView];
    [addrHeadView release];
    
    NSString* nameOfAddr = [[checkDic objectForKey:@"consignee"] objectForKey:@"consignee"];
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
    
    NSString* numberWds = [[checkDic objectForKey:@"consignee"] objectForKey:@"mobile"];
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
    
    NSDictionary* addrDic = [checkDic objectForKey:@"consignee"];
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

    // 商品详情
    relationP.y = relationP.y + height + 10;
    height = 86;
    
    UIView* goodsListBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [goodsListBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:goodsListBG];
    goodsListBG.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onGoodsListClicked:)];
    [goodsListBG addGestureRecognizer:tapGesture];
    [tapGesture release];
    [goodsListBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [goodsListBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [goodsListBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    float totalCost = 0.00f;
    NSArray* goodsListArray = [checkDic objectForKey:@"goods_list"];
    for ( int i = 0; i < [goodsListArray count] && i < 3; i++ )
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

    UIImageView* rightIdentify = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 18)];
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
    [invoiceWdsLable release];*/
    
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
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(15, height-0.5f, frameR.size.width, 0.5f)];
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
    
    // 实付款
    relationP.y = relationP.y + height;
    height = 50;
    UIView* amountFeeBG = [[UIView alloc] initWithFrame:CGRectMake(0, relationP.y, frameR.size.width, height)];
    [amountFeeBG setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:amountFeeBG];
    [amountFeeBG release];
    
    seperatorlINE = [[UIView alloc] initWithFrame:CGRectMake(0, height-0.5f, frameR.size.width, 0.5f)];
    [seperatorlINE setBackgroundColor:[UIColor lightGrayColor]];
    [amountFeeBG addSubview:seperatorlINE];
    [seperatorlINE release];
    
    NSString* amountFee = [[doneDic objectForKey:@"order_info"] objectForKey:@"order_amount"];
    float amountFeeW = [Utils widthForString:amountFee fontSize:18]+20;
    UILabel* amountLable = [[UILabel alloc] initWithFrame:CGRectMake(shipFeeBG.frame.size.width-amountFeeW-15, 0, amountFeeW, shipFeeBG.frame.size.height)];
    [amountLable setText:[NSString stringWithFormat:@"￥%@",amountFee]];
    [amountLable setNumberOfLines:1];
    [amountLable setTextColor:[UIColor redColor]];
    [amountLable setTextAlignment:NSTextAlignmentRight];
    [amountLable setFont:[UIFont systemFontOfSize:18]];
    [amountFeeBG addSubview:amountLable];
    [amountLable release];
    
    NSString* amountWds = @"实付款：";
    float amountWdsW = [Utils widthForString:amountWds fontSize:18];
    float amountWdsLabelX = shipFeeBG.frame.size.width-amountFeeW-15-amountWdsW;
    UILabel* amountWdsLable = [[UILabel alloc] initWithFrame:CGRectMake(amountWdsLabelX, 0, amountWdsW, shipFeeBG.frame.size.height)];
    [amountWdsLable setText:amountWds];
    [amountWdsLable setNumberOfLines:1];
    [amountWdsLable setTextColor:[UIColor lightGrayColor]];
    [amountWdsLable setTextAlignment:NSTextAlignmentRight];
    [amountWdsLable setFont:[UIFont systemFontOfSize:18]];
    [amountFeeBG addSubview:amountWdsLable];
    [amountWdsLable release];
    

    int iTotalH = relationP.y + height;
    iTotalH += 60;
    [_scrollView setContentSize:CGSizeMake(frameR.size.width, iTotalH)];
    
    // 最下面的总额
    //totalCost += [[shippingDic objectForKey:@"shipping_fee"] floatValue];
    //[_moneyLabel setText:[NSString stringWithFormat:@"￥%.2f",totalCost]];
}

#pragma mark - alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( alertView.tag == 123456 )
    {
        [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
        
        UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
        [pNv setNavigationBarHidden:YES animated:YES];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - 各种点击、网络事件
// 商品
-(void)onGoodsListClicked:(id)sender
{
    BasicViewController_ipa *viewController = [[OrderGoodsListViewController_ipa alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}
// 取消订单
-(void)onCancelListClicked:(UITapGestureRecognizer*)sender
{
    NSString* orderIDStr = [[DataCenter sharedDataCenter].orderDoneResultDic objectForKey:@"order_id"];
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_CancelOrder_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            [MyAlert showMessage:@"订单取消成功" timer:2.0f];
            
            [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
            
            UINavigationController* pNv = (UINavigationController*)[[self rdv_tabBarController] selectedViewController];
            [pNv setNavigationBarHidden:YES animated:YES];
            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:orderIDStr];
}
// 去支付
-(void)onGotoPayClicked:(UITapGestureRecognizer*)sender
{
    NSString* orderIDStr = [[DataCenter sharedDataCenter].orderDoneResultDic objectForKey:@"order_id"];
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_PayOrder_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            NSString* payURL = nil;
            NSString* upopTn = success[@"data"][@"upop_tn"];
            NSString* payWap = success[@"data"][@"pay_wap"];
            NSString* payOnline = success[@"data"][@"pay_online"];
            
            if ( upopTn!=nil && [upopTn compare:@""]!=NSOrderedSame )
            {
                payURL = upopTn;
            }
            else if ( payWap!=nil && [payWap compare:@""]!=NSOrderedSame )
            {
                payURL = payWap;
            }
            else if ( payOnline!=nil && [payOnline compare:@""]!=NSOrderedSame )
            {
                payURL = payOnline;
            }
            
            MyWebViewController_ipa *viewController = [[MyWebViewController_ipa alloc] init];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController loadHTMLString:payURL];

        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:orderIDStr];
}
// 验证订单支付状态
-(void)verifyOrderPayStatus
{
    NSDictionary* doneDic = [DataCenter sharedDataCenter].orderDoneResultDic;
    NSString* orderID = [doneDic objectForKey:@"order_id"];
    
    [_netLoading startAnimating];
    
    NetworkModel * net = [NetworkModel sharedNetworkModel];
    
    [net request_OderDetail_Datasuc:^(id success) {
        
        [_netLoading stopAnimating];
        
        if ( success[@"status"] && [[success[@"status"] valueForKey:@"succeed"] intValue] == 1 )
        {
            if ( [[success[@"data"] valueForKey:@"pay_status"] compare:@"2"] == NSOrderedSame )
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"支付成功,请于待发货订单中查看!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alert setTag:123456];
                [alert show];
                [alert release];
            }
        }
    } fail:^(NSError *error) {
        
        [_netLoading stopAnimating];
        
    } orderID:orderID];
}

@end

